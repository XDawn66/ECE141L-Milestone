module ProgCtr( // Program Counter
  input        Clk,     // Clock
  input        Reset,   // Active-high Reset
  input        ALUCondT, // True when the ALU condition (Zero/Greater/Less) is met
  input  [8:0] MCcurr,  // Current instruction (for branch/jump decoding)
  input  [5:0] Jump,               // Jump address (from JLUT)
  output logic [5:0] PC            // Current Program Counter
);

  // Internal combinational next-PC wire
  logic [5:0] PCnext;

  // Decode signals for control flow instructions
  logic BranchCond;
  logic BranchUn;
  logic CondT;

  assign BranchCond =
    (MCcurr[8:7] == 2'b00) && // J-type instruction format
    ((MCcurr[6:5] == 2'b01) || // JE (Equal)
    (MCcurr[6:5] == 2'b10) || // JG (Greater)
    (MCcurr[6:5] == 2'b11)); // JL (Less)

  assign is_unconditional_jump_instr =
    (MCcurr[8:7] == 2'b00) && (MCcurr[6:5] == 2'b00); // J (unconditional)

  assign CondT = BranchCond ? ALUCondT : 1'b0;


  always_comb begin
    if (BranchUn) begin // Unconditional jump
      PCnext = Jump;
    end 
    else if (BranchCond) begin // Conditional jump: skip next instruction if condition met
      if (CondT)
        PCnext = Jump;
      else
        PCnext = PC + 6'd1;
    end
  end


  always_ff @(posedge Clk or posedge Reset) begin
    if (Reset)
      PC <= 6'd0;       // Reset PC to 0
    else
      PC <= PCnext;    // Load next PC
  end

endmodule
