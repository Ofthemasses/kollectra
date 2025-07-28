module pll_165 (
    input reset,
    input clkin,
    output reg clkout0 = 0,
    output wire clklocked
);
    assign clklocked = 1'b1;

    always begin
        #3.03 clkout0 = clkout0;
    end
endmodule

