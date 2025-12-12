module ALU2(
    input  logic [7:0] acc,
    input  logic [7:0] inputReg,
    output logic       Zero,     // ACC == inputReg
    output logic       Greater,  // ACC > inputReg
    output logic       Less      // ACC < inputReg
);
logic signed [7:0] s_acc, s_in;
assign s_acc = acc;
assign s_in  = inputReg;

always_comb begin
    Zero    = 1'b0;
    Greater = 1'b0;
    Less    = 1'b0;

    if (s_acc == s_in)
        Zero = 1'b1;
    else if (s_acc > s_in)
        Greater = 1'b1;
    else
        Less = 1'b1;
end

endmodule
