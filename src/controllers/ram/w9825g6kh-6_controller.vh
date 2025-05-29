// 166Mhz CLK (CL*=3)

// CMD = CS, RAS, CAS, WE
// CKEn-1 
// signal is the input level one clock cycle before the command is
// issued.
`define CMD_BA 4'b0011 // Bank Active
`define CMD_PC 4'b0010 // Precharge (Bank or All)
`define A10_BPC 0 // Bank Precharge
`define A10_PCA 1 // Precharge All
`define CMD_W 4'b0100 // Write (+ Auto-Precharge)
`define A10_W 0 // Write
`define A10_WAP 1 // Write with Auto-Precharge
`define CMD_R 4'b0101 // Write (+ Auto-Precharge)
`define A10_R 0 // Write
`define A10_RAP 1 // Write with Auto-Precharge
`define CMD_MRS 4'b0000 // Mode Register Set
`define CMD_NOP 4'b0111 // No Operation
`define CMD_BS 4'b0110 // Burst Stop

// Delays
`define T_RC 10 // 60ns -> Manual 55ns
`define T_RAS 7 // 42ns -> Manual 42ns
`define T_RCD 3 // 18ns -> Manual 15ns
`define T_CCD 1 // 6ns -> Manual 1T_CK
`define T_RP 3 // 18ns -> Manual 15ns
`define T_RRD 2 // 6ns -> Manual 1T_CK
`define T_WR 2 // 6ns -> Manual 1T_CK
`define T_CK 1 // 6ns -> Manual 6ns
`define T_RSC 2 // 6ns -> Manual 2T_CK
`define T_XSR 12  // 72ns -> Manual 72ns
