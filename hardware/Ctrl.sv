module Ctrl(
  input        [8:0] mach_code,
  input           Sco,
  output logic [3:0] Aluop,
  output logic [3:0] Alu2op,
  output logic [7:0] Jptr,           // jump pointer to JLUT
  output logic [1:0] Cond,           // branch condition
  output logic [3:0] Ra,             // acc address
                Rb,                  // input reg address
                Wd,                  // writing address
					 Ra2,
					 Rb2,

  output logic       WenR,           // data register write enable
                     WenImm,         // data mem write imm enable
                     WenD,           // data mem load enable
                     Ldr,            // load dir
                     Str,            // string output
                     ALU_IMM,        // ALU imm enable
                     EnAlu2,         // enable secondary ALU

  output logic [4:0] ALU_IMM_VAL     // ALU imm value
);


  //acc address
  localparam acc_add = 4'b0000;

   // ALU operation codes
   localparam AND_OP  = 4'b0000;
   localparam ADD_OP  = 4'b0001;
   localparam SUB_OP  = 4'b0010;
   localparam XOR_OP  = 4'b0110;
   localparam COND_OP = 4'b0111;
   localparam OR_OP   = 4'b1010;
   localparam NOT_OP  = 4'b1011;
   localparam SHL_OP  = 4'b1100;
   localparam SHR_OP  = 4'b1101;

  always_comb begin
	Aluop = 4'b1100;		// ddefault ALU operaion (LSH)
	Jptr  = 8'b0;		// jump pointer
	Ra    = acc_add;		// accumlator as default
	Rb    = acc_add;		//placeholder    
	Wd    = acc_add;		//placeholder
	WenR  = 1'b0;		// no reg file load enable by default
	WenD  = 1'b0;		// no data mem write enable by default
	WenImm = 1'b0;		// no imm op by default
	Ldr   =	acc_add;		// load placeholder
    	Str	  = acc_add;		// store placeholder
	ALU_IMM = 1'b0;
	ALU_IMM_VAL = 5'b00000;  //ALU imm value = 0
	Alu2op = 4'b0000;
	EnAlu2 = 1'b0; //not using alu2 by default
	Ra2    = acc_add;
	Rb2    = acc_add;
	Cond        = 2'b00;

	if(mach_code[8:7] == 2'b11) begin// if j type
	Ra = acc_add;
	Aluop = SUB_OP;
	Jptr = {3'b000, mach_code[4:0]}; //zero extend to 8 bit to match PC
		case (mach_code[6:5])
            	2'b00: Cond = 2'b00; // J  
            	2'b01: Cond = 2'b01; // JE - ACC == 0
            	2'b10: Cond = 2'b10; // JG - ACC > 0
            	2'b11: Cond = 2'b11; // JL - ACC < 0
        	endcase
	end
	else if (mach_code[8] == 1'b0) begin // if R-type
    	Rb = mach_code[3:0];
    	case (mach_code[7:4])
        4'b0000: begin
            Aluop = AND_OP;
        end
        4'b0001: begin
            Aluop = ADD_OP;
        end
        4'b0010: begin
            Aluop = SUB_OP;
        end
        4'b0110: begin //load
	    Rb   = mach_code[3:0];   // Rn holds memory address
	    WenR = 1'b1;//enable load
	    Wd   = acc_add;          // ACC is destination register
	    WenD = 1'b0;             // NOT a store
        end
        4'b0101: begin //store
  	    WenR = 1'b1;//enable store to reg
	    Wd = mach_code[3:0];
        end
        4'b0011: begin //store_m
	    WenD = 1'b1;//enable store to mem
	    Rb =  mach_code[3:0];
        end
       	4'b1010: begin
            Aluop = OR_OP;
        end
        4'b1011: begin
            Aluop = NOT_OP;
        end
        4'b1100: begin
            Aluop = SHL_OP;
        end
        4'b1101: begin
            Aluop = SHR_OP;
        end
	4'b1001: begin // RESET
    	Wd    = acc_add;   // destination is accumulator
    	WenR  = 1'b1;      // enable register write
    	ALU_IMM = 1'b1;    // use immediate value (since we?re writing constant 0)
    	ALU_IMM_VAL = 4'b0000; // value = 0
	end
	4'b1000: begin // FILL
    	Wd    = acc_add;   // destination is accumulator
    	WenR  = 1'b1;      // enable register write
    	ALU_IMM = 1'b1;    // use immediate value (since we?re writing constant 0)
    	ALU_IMM_VAL = 4'b1111; // value = 0
	end
        4'b0111: begin //TST
            Aluop = AND_OP;
    	    EnAlu2 = 1'b1;     // enable ALU2
    	    Ra2    = acc_add;  // ACC as input A
    	    Rb2    = mach_code[3:0]; // operand register
        end
        4'b1110: begin //MOV
            Aluop = ADD_OP;
	    WenR = 1'b1;//enable write to register
	    Ldr = mach_code[3:0];
        end
	4'b1111: begin //ADDNE
            Aluop = ADD_OP;
	    WenR = SCo; // write only if carry = 1
        end
    	endcase
   end
	else if (mach_code[8] == 1'b1) begin //if i type
	ALU_IMM = 1'b1;
	ALU_IMM_VAL = mach_code[4:0];
	case (mach_code[7:5])
        3'b000: begin
            Aluop = AND_OP;
        end
        3'b001: begin
            Aluop = ADD_OP;
        end
        3'b010: begin
            Aluop = SUB_OP;
        end
        3'b011: begin //MOVI
            Aluop = ADD_OP;
	    WenR = 1'b1;//enable load
        end
       	3'b100: begin //LSLI
            Aluop = SHL_OP;
        end
       	3'b100: begin //RSLI
            Aluop = SHR_OP;
        end
        3'b101: begin //ORI
            Aluop = OR_OP;
        end
        3'b1100: begin
            Aluop = SHL_OP;
        end
	endcase
  end
 end
endmodule