module ALU2(
    input  logic [7:0] acc,
    input  logic [7:0] inputReg,
    output logic       Zero,     // ACC == inputReg
    output logic       Greater,  // ACC > inputReg
    output logic       Less      // ACC < inputReg
);

always_comb begin
    Zero    = 1'b0;
    Greater = 1'b0;
    Less    = 1'b0;

    if (acc == inputReg)
        Zero = 1'b1;
    else if (acc > inputReg)
        Greater = 1'b1;
    else
        Less = 1'b1;
end

endmodule
