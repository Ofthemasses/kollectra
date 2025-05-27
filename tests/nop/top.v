module Top (
    input wire clk_25mhz,
    output wire [7:0] led       
);

    reg [24:0] counter = 0;
    reg slow_clk = 0;

    always @(posedge clk_25mhz) begin
        if (counter == 12_500_000 - 1) begin
            counter <= 0;
            slow_clk <= ~slow_clk;
        end else begin
            counter <= counter + 1;
        end
    end

    wire iBus_cmd_valid;
    wire iBus_cmd_ready;
    wire [31:0] iBus_cmd_payload_pc;
    wire iBus_rsp_valid;
    wire iBus_rsp_payload_error;
    wire [31:0] iBus_rsp_payload_inst;

    NopROM rom (
        .clk(slow_clk),
        .valid(iBus_cmd_valid),
        .addr(iBus_cmd_payload_pc),
        .ready(iBus_cmd_ready),
        .rsp_valid(iBus_rsp_valid),
        .rsp_error(iBus_rsp_payload_error),
        .rsp_data(iBus_rsp_payload_inst)
    );

    VexRiscv cpu (
        .clk(slow_clk),
        .reset(1'b0),
        .iBus_cmd_valid(iBus_cmd_valid),
        .iBus_cmd_ready(iBus_cmd_ready),
        .iBus_cmd_payload_pc(iBus_cmd_payload_pc),
        .iBus_rsp_valid(iBus_rsp_valid),
        .iBus_rsp_payload_error(iBus_rsp_payload_error),
        .iBus_rsp_payload_inst(iBus_rsp_payload_inst),

        .timerInterrupt(1'b0),
        .externalInterrupt(1'b0),
        .softwareInterrupt(1'b0),

        .dBus_cmd_valid(),
        .dBus_cmd_ready(1'b1),
        .dBus_cmd_payload_wr(),
        .dBus_cmd_payload_mask(),
        .dBus_cmd_payload_address(),
        .dBus_cmd_payload_data(),
        .dBus_cmd_payload_size(),
        .dBus_rsp_ready(1'b1),
        .dBus_rsp_error(1'b0),
        .dBus_rsp_data(32'b0)
    );

    assign led = iBus_cmd_payload_pc[9:2];

endmodule
