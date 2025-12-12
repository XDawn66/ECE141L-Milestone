module ProgCtr( // Program Counter
  input        Clk,     // Clock
  input        Reset,   // Active-high Reset
  input		Zero, Greater, Less,
  input  [8:0] MCcurr,  // Current instruction (for branch/jump decoding)
  input  [15:0] Jump,    // Jump address (from JLUT)
  output logic [15:0] PC // Current Program Counter
);

  // Decode signals for control flow instructions
  logic is_jump_instr;
  logic       take_branch;
  logic [1:0] cond;  

  // Detect J-type instructions (bits [8:7] == 2'b11)
  assign is_jump_instr = (MCcurr[8:7] == 2'b11);
  assign cond    = MCcurr[6:5];
 // assign Jump_index = urr[4:0];

   always_comb begin
      take_branch = 1'b0;

       if (is_jump_instr) begin
           case (cond)
               2'b00: take_branch = 1'b1;               // J (unconditional)
               2'b01: take_branch = Zero;               // JE
               2'b10: take_branch = Greater;    // JG
               2'b11: take_branch = Less;                // JL
            endcase
        end
    end
  // Unconditional jump: J instruction (bits [6:5] == 2'b00)
  //assign BranchUn = is_jump_instr && (MCcurr[6:5] == 2'b00);
  
  // Conditional jump: JE, JG, JL (bits [6:5] != 2'b00)
  //assign BranchCond = is_jump_instr && (MCcurr[6:5] != 2'b00);
  
  // Use ALU condition for conditional branches
  //assign CondT = BranchCond && ALUCondT;
  
  // Sequential PC update
  always_ff @(posedge Clk) begin
    if (Reset)
      PC <= 16'd0;
    else if (take_branch)
      PC <= Jump + 16'd1;
    else
      PC <= PC + 16'd1;
  end
  
endmodule
