`timescale 1ns/1ps
`default_nettype none 

module w9825g6kh_6_controller(
    input clk,
    input power,
	input resetn,
    output [4:0] currstate,

	input cmd_valid,
	output cmd_ready,
	input [23:0] cmd_addr, // 23:22 bank, 21:9 row, 8:0 col
	input cmd_we, // 1: Write, 0: Read
	input [1:0] cmd_wstrb,

	input wdata_valid,
	output wdata_ready,
	input [15:0] wdata,

	output rdata_valid,
	input rdata_ready,
	output [15:0] rdata,

    output sdram_clk, // CLK
    output sdram_cke, // CKE
    output sdram_csn, // CS
    output sdram_rasn, // RAS
    output sdram_casn, // CAS
    output sdram_wen, // WE
    output [12:0] sdram_a, // Address Lines
    output [1:0] sdram_ba, // Bank Address Lines
    output [1:0] sdram_dqm, // LDQM HDQM
    inout [15:0] sdram_d // Data Lines
);

// 166Mhz CLK (CL*=3)

// CMD = CS, RAS, CAS, WE
// CKEn-1 
// signal is the input level one clock cycle before the command is
// issued.
localparam CMD_BA = 4'b0011, // Bank Active
           CMD_PC = 4'b0010, // Precharge (Bank or All)
           A10_BPC = 0, // Bank Precharge
           A10_PCA = 1, // Precharge All
           CMD_W = 4'b0100, // Write (+ Auto-Precharge)
           A10_W = 0, // Write
           A10_WAP = 1, // Write with Auto-Precharge
           CMD_R = 4'b0101, // Read (+ Auto-Precharge)
           A10_R = 0, // Read 
           A10_RAP = 1, // READ with Auto-Precharge
           CMD_MRS = 4'b0000, // Mode Register Set
           CMD_NOP = 4'b0111, // No Operation
           CMD_BS = 4'b0110, // Burst Stop
           CMD_AR = 4'b0001, // Auto Refresh
           T_RC = 10, // 60ns -> Manual 55ns
           T_RAS = 7, // 42ns -> Manual 42ns
           T_RCD = 3, // 18ns -> Manual 15ns
           T_CL = 3, // 18ns -> Manual 3T_CK
           T_CCD = 1, // 6ns -> Manual 1T_CK
           T_RP = 3, // 18ns -> Manual 15ns
           T_RRD = 2, // 6ns -> Manual 1T_CK
           T_WR = 2, // 6ns -> Manual 1T_CK
           T_CK = 1, // 6ns -> Manual 6ns
           T_RSC = 2, // 6ns -> Manual 2T_CK
           T_XSR = 12,  // 72ns -> Manual 72ns
           INIT_DELAY = 16'b1000001000110110, // 200_004ns -> Manual 200_000ns
           S_POWERDOWN = 5'b00000,
           S_INIT = 5'b00001,
           S_DELAY = 5'b00010,
           S_DESELECT_DELAY = 5'b00011,
           S_PRECHARGE = 5'b00100,
           S_REFRESH1 = 5'b00101,
           S_REFRESH2 = 5'b00110,
           S_REFRESH3 = 5'b00111,
           S_REFRESH4 = 5'b01000,
           S_REFRESH5 = 5'b01001,
           S_REFRESH6 = 5'b01010,
           S_REFRESH7 = 5'b01011,
           S_REFRESH8 = 5'b01100,
           S_MODE_REGISTER_SET = 5'b01101,
           S_IDLE = 5'b01110,
           S_READ = 5'b01111,
           S_READ_BURST = 5'b10000,
           S_WRITE = 5'b10001,
           S_WRITE_BURST = 5'b10010,
           MRS_BURST_1 = 3'b000,
           MRS_BURST_2 = 3'b001,
           MRS_BURST_4 = 3'b010,
           MRS_BURST_8 = 3'b011,
           MRS_BURST_FP = 3'b111,
           MRS_AM_SEQ = 0,
           MRS_AM_INT = 1,
           MRS_SWM_BRBW = 0,
           MRS_SWM_BRSW = 1;

reg [4:0] state_q, state_d = S_POWERDOWN;
reg [4:0] next_state_q, next_state_d= S_POWERDOWN;
reg [16:0] delay_count_q, delay_count_d = 0;

reg [3:0] cmd_q, cmd_d = CMD_NOP;

reg cmd_ready_q, cmd_ready_d = 0;
reg wdata_ready_q, wdata_ready_d = 0;
reg rdata_valid_q, rdata_valid_d = 0;
reg [15:0] rdata_q, rdata_d = 0;

reg cke_q, cke_d = 0;
reg [1:0] dqm_q, dqm_d = 0;
reg [12:0] sdram_a_q, sdram_a_d = 0;
reg [1:0] sdram_ba_q, sdram_ba_d = 0;

reg [7:0] burst_counter_q, burst_counter_d = 0;

reg [15:0] sdram_d_out_q, sdram_d_out_d = 0;
reg sdram_d_oe_q, sdram_d_oe_d = 0;

function  [12:0] mode_reg_set;
  input [2:0] burst_length;   // A2-A0
  input       burst_type;     // A3
  input       write_burst;    // A9

  begin
    mode_reg_set = 13'b0;
    mode_reg_set[2:0] = burst_length;
    mode_reg_set[3]   = burst_type;
    mode_reg_set[6:4] = 3'b011;
    mode_reg_set[9]   = write_burst;
  end
endfunction

assign cmd_ready = cmd_ready_q,
       sdram_cke = cke_q, // CKE
       sdram_csn = cmd_q[3], // CS
       sdram_rasn = cmd_q[2], // RAS
       sdram_casn = cmd_q[1], // CAS
       sdram_wen = cmd_q[0], // WE
       sdram_a = sdram_a_q, // Address Lines
       sdram_ba = sdram_ba_q, // Bank Address Lines
       sdram_dqm = cmd_wstrb, // LDQM HDQM
       sdram_d = sdram_d_oe_q ? sdram_d_out_q : 16'bz, // Data Lines
       currstate = state_q,
       wdata_ready = wdata_ready_q,
       rdata_valid = rdata_valid_q,
       rdata = rdata_q;

always @* begin
    delay_count_d = delay_count_q;
    state_d = state_q;
    next_state_d = next_state_q;
    cmd_d = cmd_q;
    cke_d = cke_q;
    dqm_d = dqm_q;
    sdram_a_d = sdram_a_q;
    sdram_ba_d = sdram_ba_q;
    cmd_ready_d = cmd_ready_q;
    wdata_ready_d = wdata_ready_q;
    rdata_valid_d = rdata_valid_q;
    rdata_d = rdata_q;
    burst_counter_d = burst_counter_q;
    sdram_d_oe_d = sdram_d_oe_q;
    sdram_d_out_d = sdram_d_out_q;
    
    case(state_q)
        S_DELAY: begin
            if (delay_count_q > 1) begin
                delay_count_d = delay_count_q - 1;
            end else begin
                state_d = next_state_q;
            end
        end
        S_DESELECT_DELAY: begin
            cmd_d[3] = 1;
            if (delay_count_q > 1) begin
                delay_count_d = delay_count_q - 1;
            end else begin
                state_d = next_state_q;
            end
        end
        S_INIT: begin
            cmd_d = CMD_NOP;
            cke_d = 1;
            state_d = S_DELAY;
            delay_count_d = INIT_DELAY;
            next_state_d = S_PRECHARGE;
        end
        S_PRECHARGE: begin
            cmd_d = CMD_PC;
            state_d = S_DELAY;
            sdram_a_d[10] = A10_PCA;
            delay_count_d = T_RP;
            next_state_d = S_REFRESH1;
        end
        S_REFRESH1,S_REFRESH2,S_REFRESH3,S_REFRESH4,S_REFRESH5,S_REFRESH6,S_REFRESH7: begin
            cmd_d = CMD_AR;
            state_d = S_DESELECT_DELAY;
            delay_count_d = T_RC;
            next_state_d = next_state_d + 1;
        end
        S_REFRESH8: begin
            cmd_d = CMD_AR;
            state_d = S_DESELECT_DELAY;
            delay_count_d = T_RC;
            next_state_d = S_MODE_REGISTER_SET;
        end
        S_MODE_REGISTER_SET: begin
            cmd_d = CMD_MRS;
            sdram_a_d = mode_reg_set(MRS_BURST_8, MRS_AM_INT, MRS_SWM_BRBW);
            sdram_ba_d = 2'b0;
            state_d = S_DESELECT_DELAY;
            delay_count_d = T_RC;
            next_state_d = S_IDLE;
        end
		S_IDLE: begin
            sdram_d_oe_d = 0;
            sdram_d_out_d = 16'b0;
			wdata_ready_d = 0;
            rdata_valid_d = 0;	
            if (cmd_valid) begin
				cmd_ready_d = 0;	
                cmd_d = CMD_BA; // Activate bank
                {sdram_ba_d, sdram_a_d} = cmd_addr[23:9]; // Select Bank and Row
                state_d = S_DESELECT_DELAY;
                delay_count_d = T_RCD-1;
                next_state_d = cmd_we ? S_WRITE : S_READ;
            end else begin
				cmd_ready_d = 1;	
                cmd_d = CMD_AR;
                state_d = S_DESELECT_DELAY;
                delay_count_d = T_RC;
                next_state_d = S_IDLE;
            end
		end
        S_READ: begin
            cmd_d = CMD_R;
            sdram_ba_d = cmd_addr[23:22];
            sdram_a_d[10] = A10_RAP;
            sdram_a_d[9:0] = cmd_addr[9:0];
            state_d = S_DESELECT_DELAY;
            delay_count_d = T_CL;
            next_state_d = S_READ_BURST;
            burst_counter_d = 7;
        end
        S_READ_BURST: begin
            rdata_valid_q = 1;
            rdata_q = sdram_d;
            if (burst_counter_d == 0) begin
                rdata_valid_d = 0;
                state_d = S_DESELECT_DELAY;
                delay_count_d = T_RP + T_WR;
                next_state_d = S_IDLE;
            end
            burst_counter_d = burst_counter_q - 1;
        end
        S_WRITE: begin
            wdata_ready_d = 1;
            cmd_d = CMD_W;
            sdram_ba_d = cmd_addr[23:22];
            sdram_a_d[10] = A10_WAP;
            sdram_a_d[8:0] = cmd_addr[8:0];
            burst_counter_d = 7;
            state_d = S_WRITE_BURST;
            sdram_d_oe_d = 1;
            sdram_d_out_d = wdata;
        end
        S_WRITE_BURST: begin
            cmd_d[3] = 1;
            wdata_ready_d = 1;
            sdram_d_oe_d = 1;
            sdram_d_out_d = wdata;
            if (burst_counter_q == 0) begin
                sdram_d_oe_d = 0;
                state_d = S_DESELECT_DELAY;
                delay_count_d = T_RP + T_WR;
                next_state_d = S_IDLE;
            end
            burst_counter_d = burst_counter_q - 1;
        end
        S_POWERDOWN: begin
            cke_d = 0;
            cmd_ready_d = 0;
            state_d = S_INIT;
        end
    endcase
end

always @(posedge clk, negedge resetn) begin
	if (!resetn) begin
        state_q <= S_POWERDOWN;
        cmd_q <= CMD_NOP;
        cke_q <= 0;
        dqm_q <= 0;
        sdram_a_q <= 0;
        sdram_ba_q <= 0;
        next_state_q <= S_INIT;
        delay_count_q <= 0;
        cmd_ready_q <= 0;
        wdata_ready_q <= 0;
        rdata_valid_q <= 0;
        rdata_q <= 0;
        burst_counter_q <= 0;
        sdram_d_oe_q <= 0;
        sdram_d_out_q <= 16'b0;
    end else begin
        state_q <= power ? state_d : S_POWERDOWN;
        cmd_q <= cmd_d;
        cke_q <= cke_d;
        dqm_q <= dqm_d;
        sdram_a_q <= sdram_a_d;
        sdram_ba_q <= sdram_ba_d;
        next_state_q <= next_state_d;
        delay_count_q <= delay_count_d;
        cmd_ready_q <= cmd_ready_d;
        wdata_ready_q <= wdata_ready_d;
        rdata_valid_q <= rdata_valid_d;
        rdata_q <= rdata_d;
        burst_counter_q <= burst_counter_d;
        sdram_d_oe_q <= sdram_d_oe_d;
        sdram_d_out_q <= sdram_d_out_d;
    end 
end
endmodule
