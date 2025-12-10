module JLUT(
    input  logic [4:0] Jptr, // since we only have 5 bit for imm      
    output logic [15:0] Jump      
);

  logic [15:0] core [0:31];    // 32 entries, 16-bit each

  initial $readmemb("d_lut_p1.txt", core);
  
  always_comb Jump = core[Jptr];

endmodule
