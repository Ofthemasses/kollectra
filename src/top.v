module Top (
    input wire clk,
    input wire reset,
    input wire timerInterrupt,
    input wire externalInterrupt,
    input wire softwareInterrupt,
    input wire iBus_cmd_ready,
    input wire iBus_rsp_valid,
    input wire iBus_rsp_payload_error,
    input wire [31:0] iBus_rsp_payload_inst,
    input wire dBus_cmd_ready,
    input wire dBus_rsp_ready,
    input wire dBus_rsp_error,
    input wire [31:0] dBus_rsp_data,
    output wire iBus_cmd_valid,
    output wire [31:0] iBus_cmd_payload_pc,
    output wire dBus_cmd_valid,
    output wire dBus_cmd_payload_wr,
    output wire [3:0] dBus_cmd_payload_mask,
    output wire [31:0] dBus_cmd_payload_address,
    output wire [31:0] dBus_cmd_payload_data,
    output wire [1:0] dBus_cmd_payload_size
);

    VexRiscv cpu (
        .clk(clk),
        .reset(reset),
        .timerInterrupt(timerInterrupt),
        .externalInterrupt(externalInterrupt),
        .softwareInterrupt(softwareInterrupt),
        .iBus_cmd_valid(iBus_cmd_valid),
        .iBus_cmd_ready(iBus_cmd_ready),
        .iBus_cmd_payload_pc(iBus_cmd_payload_pc),
        .iBus_rsp_valid(iBus_rsp_valid),
        .iBus_rsp_payload_error(iBus_rsp_payload_error),
        .iBus_rsp_payload_inst(iBus_rsp_payload_inst),
        .dBus_cmd_valid(dBus_cmd_valid),
        .dBus_cmd_ready(dBus_cmd_ready),
        .dBus_cmd_payload_wr(dBus_cmd_payload_wr),
        .dBus_cmd_payload_mask(dBus_cmd_payload_mask),
        .dBus_cmd_payload_address(dBus_cmd_payload_address),
        .dBus_cmd_payload_data(dBus_cmd_payload_data),
        .dBus_cmd_payload_size(dBus_cmd_payload_size),
        .dBus_rsp_ready(dBus_rsp_ready),
        .dBus_rsp_error(dBus_rsp_error),
        .dBus_rsp_data(dBus_rsp_data)
    );

endmodule

