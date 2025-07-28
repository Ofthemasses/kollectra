`timescale 1ns/1ps
module tb_top;
    reg clk_25mhz = 0;
    reg sw = 0;

    wire sdram_clk, sdram_cke, sdram_csn, sdram_rasn, sdram_casn, sdram_wen;
    wire [12:0] sdram_a;
    wire [1:0] sdram_ba;
    wire [1:0] sdram_dqm;
	wire [15:0] sdram_d;
    wire [5:0] led;

    // Clock generation (40ns period = 25MHz)
    always #20 clk_25mhz = ~clk_25mhz;

    Top dut (
        .clk_25mhz(clk_25mhz),
        .sw(sw),
        .sdram_clk(sdram_clk),
        .sdram_cke(sdram_cke),
        .sdram_csn(sdram_csn),
        .sdram_rasn(sdram_rasn),
        .sdram_casn(sdram_casn),
        .sdram_wen(sdram_wen),
        .sdram_a(sdram_a),
        .sdram_ba(sdram_ba),
        .sdram_dqm(sdram_dqm),
        .sdram_d(sdram_d),
        .led(led)
    );

	mt48lc16m16a2 sdram_model (
		.Dq(sdram_d),          // Data bus
		.Addr(sdram_a),        // Address bus
		.Ba(sdram_ba),         // Bank address
		.Clk(sdram_clk),       // SDRAM clock
		.Cke(sdram_cke),       // Clock enable
		.Cs_n(sdram_csn),      // Chip select
		.Ras_n(sdram_rasn),    // RAS
		.Cas_n(sdram_casn),    // CAS
		.We_n(sdram_wen),      // WE
		.Dqm(sdram_dqm)        // Byte enable
	);


    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_top);

        // Reset/power sequence
        sw = 0;
        #1000;
        sw = 1;

        #1000000;
        $finish;
    end
endmodule
