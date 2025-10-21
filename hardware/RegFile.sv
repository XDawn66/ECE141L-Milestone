module RegFile(
  input      Clk,	 // clock
             Wen,    // write enable
  input[1:0] Ra,     // read address pointer A
             Rb,     //                      B
			 Wd,	 // write address pointer
  input[7:0] Wdat,   // write data in
  output[7:0]RdatA,	 // read data out A
             RdatB); // read data out B

  logic[7:0] Core[4]; // reg file itself (4*8 array)

  always_ff @(posedge Clk)
    if(Wen) Core[Wd] <= Wdat;

  assign RdatA = Core[Ra];
  assign RdatB = Core[Rb];

endmodule