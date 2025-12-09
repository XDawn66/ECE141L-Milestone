module DMem(
  input      Clk,
  input      Wen,
  input[7:0] WDat,
  input[3:0] Addr,
  output logic[7:0] Rdat);

  logic[7:0] Core[256];

  always_ff @(posedge Clk)
    if(Wen) Core[Addr] <= WDat;

  assign Rdat = Core[Addr];

endmodule

