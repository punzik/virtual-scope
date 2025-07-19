// %SOURCE_FILE_HEADER%
//

module scope_test (
    input logic clk_i,
    input logic rst_ni,

    output logic [7:0] o_x,
    output logic [7:0] o_y
);

    localparam PointsCount = 11 + 15 + 18 + 14 + 2;
    localparam CntWidth = $clog2(PointsCount);

    logic [7:0] x[PointsCount];
    logic [7:0] y[PointsCount];

    initial begin
        int n;

        // F
        n = 0;
        {x[n+0 ], y[n+0 ]} = {8'd025, 8'd038};
        {x[n+1 ], y[n+1 ]} = {8'd025, 8'd100};
        {x[n+2 ], y[n+2 ]} = {8'd063, 8'd100};
        {x[n+3 ], y[n+3 ]} = {8'd063, 8'd088};
        {x[n+4 ], y[n+4 ]} = {8'd038, 8'd088};
        {x[n+5 ], y[n+5 ]} = {8'd038, 8'd075};
        {x[n+6 ], y[n+6 ]} = {8'd050, 8'd075};
        {x[n+7 ], y[n+7 ]} = {8'd050, 8'd063};
        {x[n+8 ], y[n+8 ]} = {8'd038, 8'd063};
        {x[n+9 ], y[n+9 ]} = {8'd038, 8'd038};
        {x[n+10], y[n+10]} = {8'd025, 8'd038};

        // P
        n += 11;
        {x[n+0 ], y[n+0 ]} = {8'd075, 8'd038};
        {x[n+1 ], y[n+1 ]} = {8'd075, 8'd100};
        {x[n+2 ], y[n+2 ]} = {8'd088, 8'd088};
        {x[n+3 ], y[n+3 ]} = {8'd100, 8'd088};
        {x[n+4 ], y[n+4 ]} = {8'd100, 8'd075};
        {x[n+5 ], y[n+5 ]} = {8'd088, 8'd075};
        {x[n+6 ], y[n+6 ]} = {8'd088, 8'd088};
        {x[n+7 ], y[n+7 ]} = {8'd075, 8'd100};
        {x[n+8 ], y[n+8 ]} = {8'd100, 8'd100};
        {x[n+9 ], y[n+9 ]} = {8'd113, 8'd088};
        {x[n+10], y[n+10]} = {8'd113, 8'd075};
        {x[n+11], y[n+11]} = {8'd100, 8'd063};
        {x[n+12], y[n+12]} = {8'd088, 8'd063};
        {x[n+13], y[n+13]} = {8'd088, 8'd038};
        {x[n+14], y[n+14]} = {8'd075, 8'd038};

        // G
        n += 15;
        {x[n+0 ], y[n+0 ]} = {8'd150, 8'd063};
        {x[n+1 ], y[n+1 ]} = {8'd150, 8'd075};
        {x[n+2 ], y[n+2 ]} = {8'd175, 8'd075};
        {x[n+3 ], y[n+3 ]} = {8'd175, 8'd050};
        {x[n+4 ], y[n+4 ]} = {8'd163, 8'd038};
        {x[n+5 ], y[n+5 ]} = {8'd138, 8'd038};
        {x[n+6 ], y[n+6 ]} = {8'd125, 8'd050};
        {x[n+7 ], y[n+7 ]} = {8'd125, 8'd088};
        {x[n+8 ], y[n+8 ]} = {8'd138, 8'd100};
        {x[n+9 ], y[n+9 ]} = {8'd175, 8'd100};
        {x[n+10], y[n+10]} = {8'd175, 8'd088};
        {x[n+11], y[n+11]} = {8'd150, 8'd088};
        {x[n+12], y[n+12]} = {8'd138, 8'd075};
        {x[n+13], y[n+13]} = {8'd138, 8'd063};
        {x[n+14], y[n+14]} = {8'd150, 8'd050};
        {x[n+15], y[n+15]} = {8'd163, 8'd050};
        {x[n+16], y[n+16]} = {8'd163, 8'd063};
        {x[n+17], y[n+17]} = {8'd150, 8'd063};

        // A
        n += 18;
        {x[n+0 ], y[n+0 ]} = {8'd188, 8'd038};
        {x[n+1 ], y[n+1 ]} = {8'd200, 8'd100};
        {x[n+2 ], y[n+2 ]} = {8'd213, 8'd100};
        {x[n+3 ], y[n+3 ]} = {8'd225, 8'd038};
        {x[n+4 ], y[n+4 ]} = {8'd213, 8'd038};
        {x[n+5 ], y[n+5 ]} = {8'd210, 8'd050};

        {x[n+6 ], y[n+6 ]} = {8'd209, 8'd060};
        {x[n+7 ], y[n+7 ]} = {8'd206, 8'd070};
        {x[n+8 ], y[n+8 ]} = {8'd204, 8'd060};
        {x[n+9 ], y[n+9 ]} = {8'd209, 8'd060};

        {x[n+10], y[n+10]} = {8'd210, 8'd050};
        {x[n+11], y[n+11]} = {8'd203, 8'd050};
        {x[n+12], y[n+12]} = {8'd200, 8'd038};
        {x[n+13], y[n+13]} = {8'd188, 8'd038};

        // Back
        n += 14;
        {x[n+0], y[n+0]} = {8'd240, 8'd020};
        {x[n+1], y[n+1]} = {8'd010, 8'd020};
    end

    logic [CntWidth-1:0] cnt;
    // assign o_x = x[cnt];
    // assign o_y = y[cnt];

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) cnt <= '0;
        else         cnt <= (cnt == (PointsCount - 1)) ? '0 : cnt + 1'b1;
    end

    localparam LfsrAddWidth = 1;

    logic [15:0] lfsr_state;
    logic lfsr_out;

    lfsr u_lfsr (
        .clk_i,
        .rst_ni,
        .enable_i(1'b1),
        .preset_data_i('0),
        .preset_enable_i(1'b0),
        .state_o(lfsr_state),
        .bits_o(lfsr_out)
    );

    assign o_x = lfsr_out ? x[cnt] + 8'(lfsr_state[3 -: LfsrAddWidth]) : x[cnt] - 8'(lfsr_state[3 -: LfsrAddWidth]);
    assign o_y = lfsr_out ? y[cnt] + 8'(lfsr_state[9 -: LfsrAddWidth]) : y[cnt] - 8'(lfsr_state[9 -: LfsrAddWidth]);

endmodule // scope_test
