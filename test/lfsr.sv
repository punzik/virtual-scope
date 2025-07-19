// %SOURCE_FILE_HEADER%
//

module lfsr #(
  parameter Poly = 16'b1101_0000_0000_1000,
  parameter int unsigned Size = $clog2(Poly),
  parameter bit StuckProtect = 0,
  parameter logic [Size-1:0] SregInitial = '0
)  (
  input wire clk_i,
  input wire rst_ni,
  input wire enable_i,
  input wire preset_data_i,
  input wire preset_enable_i,
  output wire [Size-1:0] state_o,
  output wire bits_o
);

  logic [Size-1:0] sreg = SregInitial;
  logic feedback;

  assign bits_o = feedback;
  assign state_o = sreg;
  assign feedback = (StuckProtect && sreg == '1) ? 1'b0 : sreg[0];

  always_ff @(posedge clk_i or negedge rst_ni)
    if (!rst_ni) begin
      sreg <= SregInitial;
    end else begin
      if (enable_i) begin
        sreg[Size-1] <= preset_enable_i ? preset_data_i : feedback;

        for (int i = 1; i < Size; i += 1) begin
          sreg[i-1] <= Poly[i-1] ? ~(sreg[i] ^ feedback) : sreg[i];
        end
      end
    end

`ifdef FORMAL
  logic f_past_valid = 1'b0;
  always_ff @(posedge clk_i) f_past_valid <= 1'b1;
  initial assume(!rst_ni);

  // Check rst_ni
  always_ff @(posedge clk_i) begin
    if (f_past_valid && !$past(rst_ni)) begin
      assert(sreg == SregInitial);
    end
  end

  // Check preset
  always_ff @(posedge clk_i) begin
    if (f_past_valid && $past(rst_ni) && $past(enable_i) && $past(preset_enable_i)) begin
      assert(sreg[Size-1] == $past(preset_data_i));
    end
  end

  // Check for changing LFSR state on every cycle
  localparam [Size-1:0] MSB = 1'b1 << (Size - 1);
  logic [Size-1:0] psreg;

  always_ff @(posedge clk_i) begin
    assume(sreg != {Size{1'b1}});

    psreg <= sreg[0] ? (sreg >> 1) | MSB : ((sreg >> 1) ^ Poly) & ~MSB;

    if (f_past_valid && $past(rst_ni) && !$past(preset_enable_i)) begin
      if ($past(enable_i)) begin
        assert(sreg == psreg);
      end else begin
        assert($stable(sreg));
      end
    end
  end
`endif

endmodule // lfsr
