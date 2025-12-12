module ALU2(
    input  logic signed[7:0] acc,
    output logic       Zero,     // ACC == inputReg
    output logic       Greater,  // ACC > inputReg
    output logic       Less      // ACC < inputReg
);
logic signed [7:0] s_acc;
assign s_acc = acc;
logic signed [7:0]  zero  = 8'd0;

always_comb begin
    Zero    = 1'b0;
    Greater = 1'b0;
    Less    = 1'b0;

    if (s_acc == zero)
        Zero = 1'b1;
    else if (s_acc > zero)
        Greater = 1'b1;
    else if (s_acc < zero)
        Less = 1'b1;
    else
	Less = 1'b0;
end

endmodule
