module ProgCtr( // Program Counter
  input        Clk,     // Clock
  input        Reset,   // Active-high Reset
  input        ALUCondT, // True when the ALU condition (Zero/Greater/Less) is met
  input  [8:0] MCcurr,  // Current instruction (for branch/jump decoding)
  input  [5:0] Jump,    // Jump address (from JLUT)
  output logic [5:0] PC // Current Program Counter
);

  // Decode signals for control flow instructions
  logic BranchCond;
  logic BranchUn;
  logic CondT;
  logic is_jump_instr;

  // Detect J-type instructions (bits [8:7] == 2'b11)
  assign is_jump_instr = (MCcurr[8:7] == 2'b11);
  
  // Unconditional jump: J instruction (bits [6:5] == 2'b00)
  assign BranchUn = is_jump_instr && (MCcurr[6:5] == 2'b00);
  
  // Conditional jump: JE, JG, JL (bits [6:5] != 2'b00)
  assign BranchCond = is_jump_instr && (MCcurr[6:5] != 2'b00);
  
  // Use ALU condition for conditional branches
  assign CondT = BranchCond && ALUCondT;
  
  // Sequential PC update
  always_ff @(posedge Clk) begin
    if (Reset)
      PC <= 6'd0;
    else if (BranchUn)
      PC <= Jump;
    else if (CondT)
      PC <= Jump;
    else
      PC <= PC + 6'd1;
  end
  
endmodule
