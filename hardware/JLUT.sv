module JLUT(
    input  logic [7:0] Jptr,      
    output logic [15:0] Jump      
);

  logic[15:0] Core[2**5];

  initial $readmemb("jump_lut.mem", Core);
  
  always_comb Jump = Core[Jptr];

endmodule
