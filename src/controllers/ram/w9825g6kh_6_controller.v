`timescale 1ns/1ps
`default_nettype none 

module w9825g6kh_6_controller(
    input clk,
    input power,
    output ready,

    output sdram_clk, // CK
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
           CMD_R = 4'b0101, // Write (+ Auto-Precharge)
           A10_R = 0, // Write
           A10_RAP = 1, // Write with Auto-Precharge
           CMD_MRS = 4'b0000, // Mode Register Set
           CMD_NOP = 4'b0111, // No Operation
           CMD_BS = 4'b0110, // Burst Stop
           CMD_AR = 4'b0001, // Auto Refresh
           T_RC = 10, // 60ns -> Manual 55ns
           T_RAS = 7, // 42ns -> Manual 42ns
           T_RCD = 3, // 18ns -> Manual 15ns
           T_CCD = 1, // 6ns -> Manual 1T_CK
           T_RP = 3, // 18ns -> Manual 15ns
           T_RRD = 2, // 6ns -> Manual 1T_CK
           T_WR = 2, // 6ns -> Manual 1T_CK
           T_CK = 1, // 6ns -> Manual 6ns
           T_RSC = 2, // 6ns -> Manual 2T_CK
           T_XSR = 12,  // 72ns -> Manual 72ns
           INIT_DELAY = 16'b1000001000110110, // 200_004ns -> Manual 200_000ns
           S_POWERDOWN = 4'b0000,
           S_INIT = 4'b0001,
           S_DELAY = 4'b0010,
           S_DESELECT_DELAY = 4'b0011,
           S_PRECHARGE = 4'b0100,
           S_REFRESH1 = 4'b0101,
           S_REFRESH2 = 4'b0110,
           S_REFRESH3 = 4'b0111,
           S_REFRESH4 = 4'b1000,
           S_REFRESH5 = 4'b1001,
           S_REFRESH6 = 4'b1010,
           S_REFRESH7 = 4'b1011,
           S_REFRESH8 = 4'b1100,
           S_MODE_REGISTER_SET = 4'b1101,
           S_IDLE = 4'b1110,
           MRS_BURST_1 = 3'b000,
           MRS_BURST_2 = 3'b001,
           MRS_BURST_4 = 3'b010,
           MRS_BURST_8 = 3'b011,
           MRS_BURST_FP = 3'b111,
           MRS_AM_SEQ = 0,
           MRS_AM_INT = 1,
           MRS_SWM_BRBW = 0,
           MRS_SWM_BRSW = 1;

reg [3:0] state_q, state_d = S_POWERDOWN;
reg [1:0] next_state_q, next_state_d= S_POWERDOWN;
reg [16:0] delay_count_q, delay_count_d = 0;

reg ready_q, ready_d = 0;
reg [3:0] cmd_q, cmd_d = CMD_NOP;
reg cke_q, cke_d = 0;
reg [1:0] dqm_q, dqm_d = 0;
reg [12:0] sdram_a_q, sdram_a_d = 0;
reg [1:0] sdram_ba_q, sdram_ba_d = 0;

function  [12:0] mode_reg_set;
  input [2:0] burst_length;   // A2-A0
  input       burst_type;     // A3
  input       write_burst;    // A9

  begin
    mode_reg_set = 13'b0;
    mode_reg_set[2:0] = burst_length;
    mode_reg_set[3]   = burst_type;
    mode_reg_set[6:4] = 3'b001;
    mode_reg_set[9]   = write_burst;
  end
endfunction

assign sdram_clk = clk, // CK
	   ready = ready_q,
       sdram_cke = cke_q, // CKE
       sdram_csn = cmd_q[3], // CS
       sdram_rasn = cmd_q[2], // RAS
       sdram_casn = cmd_q[1], // CAS
       sdram_wen = cmd_q[0], // WE
       sdram_a = sdram_a_q, // Address Lines
       sdram_ba = sdram_ba_q, // Bank Address Lines
       sdram_dqm = 0, // LDQM HDQM
       sdram_d = 0; // Data Lines

always @* begin
    delay_count_d = delay_count_q;
    state_d = state_q;
    next_state_d = next_state_q;
    cke_d = cke_q;
    dqm_d = dqm_q;
    sdram_a_d = sdram_a_q;
    sdram_ba_d = sdram_ba_q;
    ready_d = ready_q;
    
    case(state_q)
        S_DELAY: begin
            if (delay_count_d == 1) state_d=next_state_q;
            delay_count_d=delay_count_q-1;
        end
        S_DESELECT_DELAY: begin
            cmd_d[3] = 1;
            if (delay_count_d == 1) state_d=next_state_q;
            delay_count_d=delay_count_q-1;
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
		    ready_d = 1;	
		end
        S_POWERDOWN: begin
            cke_d = 0;
            ready_d = 0;
            state_d = S_INIT;
        end
    endcase
end

always @(posedge clk) begin
    state_q <= power ? state_d : S_POWERDOWN;
    cmd_q <= cmd_d;
    cke_q <= cke_d;
    dqm_q <= dqm_d;
    sdram_a_q <= sdram_a_d;
    sdram_ba_q <= sdram_ba_d;
    next_state_q <= next_state_d;
    delay_count_q <= delay_count_d;
    ready_q <= ready_d;
end
endmodule
