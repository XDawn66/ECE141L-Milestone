module InstROM(
  input[15:0] PC,
  output logic[8:0] mach_code);

  logic[8:0] Core[2**9];

  initial 
	$readmemb("mach_code.txt",Core);

  always_comb mach_code = Core[PC-1];

endmodule
