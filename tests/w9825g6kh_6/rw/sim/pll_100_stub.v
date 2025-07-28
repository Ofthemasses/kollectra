module pll_100 (
    input reset,
    input clkin,
    output reg clkout0 = 0,
    output clkout1,
    output wire clklocked
);
    assign clklocked = 1'b1;
    assign #2.77 clkout1 = clkout0;

    always begin
        #5 clkout0 = ~clkout0;
    end
endmodule

