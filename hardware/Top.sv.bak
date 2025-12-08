module Top(
  input   		Clk,
		       Reset,
output logic Done);

  wire[5:0] Jump,
	        PC;
  wire[3:0]		Aluop,
            		Ra,
			Rb,
			Wd;
  wire[7:0]		Jptr;
  wire[8:0] mach_code;
  wire[7:0] DatA,	     // ALU data in
            DatB,
			Rslt,		 // ALU data out
			RdatA,		 // RF data out
			RdatB,
			WdatR,		 // RF data in
			WdatD,		 // DM data in
			Rdat,		 // DM data out
			Addr;		 // DM address
  wire      Jen,		 // PC jump enable
            Par,         // ALU parity flag
			SCo,         // ALU shift/carry out
            Zero,        // ALU zero flag
			WenR,		 // RF write enable
			WenD,		 // DM write enable
			Ldr,		 // LOAD
			Str, //store
			Zero2,
			Greater2,
			Less2;		

logic pair, zero, sc_0;
logic pairQ, zeroQ, carry_in;
logic carry_clr, carry_en;
logic [7:0] WdatR_mux; 
assign  DatA = RdatA;
assign  DatB = RdatB; 
assign  WdatR = Rslt; 

wire [1:0] Cond;
wire [4:0] ALU_IMM_VAL;
wire       WenImm, ALU_IMM, EnAlu2;
wire [3:0] Alu2op, Ra2, Rb2;

// jump lookup table
JLUT lookup_table(
  .Jptr(Jptr[1:0]),
  .Jump(Jump));

ProgCtr Porgram_counter(
    .Clk      (Clk),
    .Reset    (Reset),
    .ALUCondT (Zero),      
    .MCcurr   (mach_code), 
    .Jump     (Jump),    
    .PC       (PC)
);

InstROM Instr_mem(
  .PC,
  .mach_code);

Ctrl control_unit (
    .mach_code    (mach_code),
    .Sco (carry_in),
    .Zero (Zero),
    .Aluop        (Aluop),
    .Jptr         (Jptr),
    .Cond         (Cond),
    .Ra           (Ra),
    .Rb           (Rb),
    .Wd           (Wd),
    .WenR         (WenR),
    .WenImm       (WenImm),
    .WenD         (WenD),
    .Ldr          (Ldr),
    .Str          (Str),
    .ALU_IMM      (ALU_IMM),
    .EnAlu2       (EnAlu2),
    .ALU_IMM_VAL  (ALU_IMM_VAL) 
);

RegFile register_file(
  .Clk,
  .Wen(WenR),
  .Ra,
  .Rb,
  .Wd,
  .Wdat(WdatR_mux),
  .RdatA,
  .RdatB
);

ALU alu_one (
    .Aluop   (Aluop),
    .acc     (DatA),   // ACC value
    .inputReg(DatB),
    .Rslt    (Rslt),
    .Zero    (Zero),
    .Par     (Par),
    .SCo     (SCo)
);

ALU2 alu_two (
    .acc     (DatA),       // ACC value
    .inputReg(DatB),       // input register
    .Zero    (Zero2),      // Zero flag output
    .Greater (Greater2),   // Greater flag output
    .Less    (Less2)       // Less flag output
);

DMem data_mem(
  .Clk  (Clk),
  .Wen  (WenD),
  .WDat (WdatD),
  .Addr (Addr),
  .Rdat (Rdat)
);


Mux alu_to_reg (.in0(Rslt), .in1(RdatA), .S(WenD), .out(WdatR_mux));

//register flags from alu
always_ff @(posedge Clk) begin
	//pair flag and zero flags for later
	pairQ <= pair;
	zeroQ <= zero;
	if(carry_clr)
		carry_in <= 'b0;
	else if(carry_en)
		carry_in <= sc_0;
end

  // DONE signal
 assign Done = (mach_code == 9'b111111111);
endmodule