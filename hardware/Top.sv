module Top(
  input   		Clk,
		       Reset,
  output logic Done);

  wire[5:0] Jump,
	        PC;
  wire[3:0]		Aluop,
            		Ra,
			Rb,
			Wd,
			Ra2,
			Rb2,
			Alu2op;
  wire[7:0]		Jptr;
  wire[8:0] mach_code;
  wire[7:0] DatA,	     // ALU data in A
            DatB,        // ALU data in B
			Rslt,		 // ALU data out
			RdatA,		 // RF data out A
			RdatB,       // RF data out B
			WdatR,		 // RF data in
			WdatD,		 // DM data in
			Rdat;		 // DM data out
  wire[3:0] Addr;		 // DM address (4-bit)
  wire      Jen,		 // PC jump enable
            Par,         // ALU parity flag
			SCo,         // ALU shift/carry out
            Zero,        // ALU zero flag
			WenR,		 // RF write enable
			WenD,		 // DM write enable
			Ldr,		 // LOAD signal
			Str,         // store
			Zero2,
			Greater2,
			Less2;		

  logic pair, zero, sc_0;
  logic pairQ, zeroQ, carry_in;
  logic carry_clr, carry_en;
  
  wire [1:0] Cond;
  wire [4:0] ALU_IMM_VAL;
  wire       WenImm, ALU_IMM, EnAlu2;

  // Data path connections
  assign  DatA = RdatA;
  assign  DatB = (ALU_IMM) ? {3'b000, ALU_IMM_VAL} : RdatB;
  assign  WdatD = RdatA;   // Data to write to memory comes from ACC
  assign  Addr = Rb[3:0];  // Memory address from Rb register
  
  // Write data to register file: use memory data if loading, otherwise use ALU result
  assign  WdatR = Ldr ? Rdat : Rslt;

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
      .Sco          (carry_in),
      .Zero         (Zero),
      .Aluop        (Aluop),
      .Alu2op       (Alu2op),
      .Jptr         (Jptr),
      .Cond         (Cond),
      .Ra           (Ra),
      .Rb           (Rb),
      .Wd           (Wd),
      .Ra2          (Ra2),
      .Rb2          (Rb2),
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
    .Clk(Clk),
    .Rst(Reset),
    .Wen(WenR),
    .Ra,
    .Rb,
    .Wd,
    .Wdat(WdatR),
    .RdatA,
    .RdatB
  );

  ALU alu_one (
      .Aluop   (Aluop),
      .acc     (DatA),
      .inputReg(DatB),
      .Rslt    (Rslt),
      .Zero    (Zero),
      .Par     (Par),
      .SCo     (SCo)
  );

  ALU2 alu_two (
      .acc     (RdatA),
      .inputReg(RdatB),
      .Zero    (Zero2),
      .Greater (Greater2),
      .Less    (Less2)
  );

  DMem data_mem(
    .Clk  (Clk),
    .Wen  (WenD),
    .WDat (WdatD),
    .Addr (Addr),
    .Rdat (Rdat)
  );

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
