module counter (
    clock,
    reset,
    value
);
    input clock;
    input reset;
    output [31:0] value;

    reg [31:0] r_count;

    always @(posedge clock or posedge reset) begin
        if (reset) r_count <= 0;
        else r_count <= r_count + 1;
    end

    assign value = r_count;
endmodule