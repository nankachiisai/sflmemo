module adder (
    a,
    b,
    r,
    c
);
    input [31:0] a;
    input [31:0] b;
    output [31:0] r;
    output c;

    wire [32:0] tmp;

    assign tmp = {1'b0, a} + {1'b0, b};
    assign r = tmp[31:0];
    assign c = tmp[32];
endmodule