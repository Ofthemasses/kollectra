module Top(
    input wire clk_25mhz,
    input wire sw, // use as power switch
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
    output [5:0] led
);

    reg [3:0] reset_cnt = 15;
    wire resetn = (reset_cnt == 0);
    always @(posedge clk_25mhz)
        if (!resetn) reset_cnt <= reset_cnt - 1;

    wire clk_165mhz;
    wire pll_locked;
    reg power_sync;

    wire power = power_sync;

    // SDRAM I/O and interface wires
    wire [4:0] currstate;
    wire cmd_ready, wdata_ready, rdata_valid;
    reg cmd_valid = 0, wdata_valid = 0;
    reg cmd_we = 0;
    reg [23:0] cmd_addr = 0;
    reg [1:0] cmd_wstrb = 2'b11;
    reg [15:0] wdata = 16'hCAFE;
    wire [15:0] rdata;

    // FSM and test logic
    reg [3:0] fsm = 0;
    reg [15:0] rdata_latched = 0;
    reg success = 0;

    always @(posedge clk_165mhz or negedge resetn) begin
        if (!resetn) begin
            fsm <= 0;
            cmd_valid <= 0;
            wdata_valid <= 0;
            cmd_we <= 0;
            cmd_addr <= 26'h0;
            wdata <= 16'hCAFE;
            rdata_latched <= 0;
            success <= 0;
        end else begin
            case (fsm)
                0: if (currstate == 5'b01110) begin 
					fsm <= 1; // Wait for IDLE
                    cmd_wstrb <= 2'b00;
                end
                1: if (cmd_ready) begin
                    cmd_we <= 1;
                    cmd_addr <= 26'h0012345;
                    cmd_valid <= 1;
                    fsm <= 2;
                end
                2: if (!cmd_ready) begin
                    cmd_valid <= 0;
                    fsm <= 3;
                end
                3: begin
                    wdata_valid <= 1;
					fsm <= 4;
                end
                4: begin
                    if (wdata_ready) begin
                        fsm <= 5;
                    end
                end
                5: if (cmd_ready) begin
                    cmd_we <= 0;
                    cmd_addr <= 26'h0012345;
                    cmd_valid <= 1;
                    fsm <= 6;
                end
                6: if (!cmd_ready) begin
                    cmd_valid <= 0;
                    fsm <= 7;
                end
                7: begin
                    rdata_latched <= rdata;
                    success <= (rdata == 16'hCAFE);
                    if (rdata == 16'hCAFE) begin
                        fsm <= 8;
                    end
                end
                8: ; // done
            endcase

        end
    end

    assign led = {success, fsm};

    w9825g6kh_6_controller sdram_ctrl_inst (
        .clk(clk_165mhz),
        .power(power_sync),
        .resetn(resetn),
        .currstate(currstate),
        .cmd_valid(cmd_valid),
        .cmd_ready(cmd_ready),
        .cmd_addr(cmd_addr),
        .cmd_we(cmd_we),
        .cmd_wstrb(cmd_wstrb),
        .wdata_valid(wdata_valid),
        .wdata_ready(wdata_ready),
        .wdata(wdata),
        .rdata_valid(rdata_valid),
        .rdata_ready(1'b1),
        .rdata(rdata),
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

    // PLL
    pll_165 pll_inst (
        .clkin(clk_25mhz),
        .clkout0(clk_165mhz),
        .clklocked(pll_locked),
        .reset(!resetn)
    );

    always @(posedge clk_25mhz or negedge resetn) begin
        if (!resetn)
            power_sync <= 0;
        else
            power_sync <= sw & pll_locked;
    end

	wire clk_ddr_out;

	ODDRX1F ddr_clk_out (
		.D0(1'b0),
		.D1(1'b1),
		.SCLK(clk_165mhz),
		.RST(1'b0),
		.Q(sdram_clk)
	);

endmodule

