module Top(
    input wire clk_25mhz,
    input sw,

    output sdram_clk,
    output sdram_cke,
    output sdram_csn,
    output sdram_rasn,
    output sdram_casn,
    output sdram_wen,
    output [12:0] sdram_a,
    output [1:0] sdram_ba,
    output [1:0] sdram_dqm,
    inout [15:0] sdram_d,

    output [6:0] led
);

	reg [3:0] reset_cnt = 15;
	wire resetn = (reset_cnt == 0);

	always @(posedge clk_25mhz)
		if (!resetn)
			reset_cnt <= reset_cnt - 1;

	reg power_sync;
    wire ready;
    reg pll_locked;
    wire clk_165mhz;
    wire power;
    wire [3:0] currstate;

    assign led[3:0] = currstate;
    assign led[4] = ready;
    assign led[5] = counter2[24];
    assign led[6] = counter[24];
    assign power = sw;

	reg [24:0] counter = 0;

	always @(posedge clk_25mhz)
		counter <= counter + 1;

	reg [24:0] counter2 = 0;

    always @(posedge clk_165mhz)
        counter2 <= counter2 + 1;

    w9825g6kh_6_controller sdram_ctrl_inst (
        .clk(clk_165mhz),
        .power(power_sync),
        .ready(ready),
        .resetn(resetn),
        .currstate(currstate),
        .sdram_clk(sdram_clk),
        .sdram_cke(sdram_cke),
        .sdram_csn(sdram_csn),
        .sdram_rasn(sdram_rasn),
        .sdram_casn(sdram_casn),
        .sdram_wen(sdram_wen),
        .sdram_a(sdram_a),
        .sdram_ba(sdram_ba),
        .sdram_dqm(sdram_dqm),
        .sdram_d(sdram_d)
    );

    pll_165 pll_inst (
        .clkin(clk_25mhz),
        .clkout0(clk_165mhz),
        .clklocked(pll_locked),
        .reset(!resetn)
    );

    always @(posedge clk_25mhz, negedge resetn) begin
        if (!resetn) begin
            power_sync <= 0;
        end else begin
            power_sync <= power & pll_locked;
        end
    end
            

endmodule
