`timescale 1ps/1ps

module scope_test_tb;
    logic clk   = 1'b0;
    logic rst_n = 1'b0;
    initial forever #(10ns/2) clk = ~clk;

    logic [7:0] x, y;

    scope_test u_scope_test (
        .clk_i(clk),
        .rst_ni(rst_n),
        .o_x(x),
        .o_y(y)
    );

    initial begin
        int fd;

        rst_n <= 1'b0;
        repeat(2) @(posedge clk);
        rst_n <= 1'b1;
        repeat(2) @(posedge clk);

        forever begin
            @(posedge clk);
            if (rst_n == 1'b1) begin
                real xf, yf;
                xf = (real'(x) / 256.0 - 0.5) * 2;
                yf = (real'(y) / 256.0 - 0.5) * 2 + 0.5;
                $display("%f %f", xf, yf);
            end
        end
    end

    initial
      if ($test$plusargs ("dump")) begin
          $dumpfile("scope_test_tb.fst");
          $dumpvars(0, scope_test_tb);
      end

endmodule // scope_test_tb
