module statemachine (
    p_reset,
    m_clock,
    start
);
    input p_reset;
    input m_clock;
    input start;

    parameter IF = 1;
    parameter DE = 2;
    parameter RF = 3;
    parameter EX = 4;
    parameter WB = 5;
    reg [2:0] state;

    always @(posedge m_clock or posedge p_reset) begin
        if (p_reset) state <= 0;
        else if (~p_reset & start) state <= IF;
        else begin
            case (state)
                IF: state <= DE;
                DE: state <= RF;
                RF: state <= EX;
                EX: state <= WB;
                WB: state <= IF; 
                default: state <= 0;
            endcase
        end
    end

endmodule