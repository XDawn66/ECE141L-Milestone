module Mux(
    input  logic [8:0] in0,   // input 0
    input  logic [8:0] in1,   // input 1
    input  logic       S,     // select signal
    output logic [8:0] out    // mux output
);

    always_comb begin
        case (S)
            1'b0: out = in0;
            1'b1: out = in1;
        endcase
    end

endmodule
