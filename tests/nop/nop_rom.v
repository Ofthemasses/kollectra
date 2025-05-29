module NopROM (
    input  wire        clk,
    input  wire        valid,
    input  wire [31:0] addr,
    output reg         ready,
    output reg         rsp_valid,
    output reg         rsp_error,
    output reg [31:0]  rsp_data
);
    always @(posedge clk) begin
        ready     <= 1;
        rsp_valid <= valid;
        rsp_error <= 0;
        rsp_data  <= 32'h00000013;  // RISC-V NOP (ADDI x0, x0, 0)
    end
endmodule

