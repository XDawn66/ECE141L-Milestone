module RegFile(
  input  logic       Clk,	 // clock
  input  logic       Wen,    // write enable
  input  logic [3:0] Ra,     // read address pointer A
  input  logic [3:0] Rb,     //                      B
  input  logic [3:0] Wd,	 // write address pointer
  input  logic [7:0] Wdat,   // write data in
  output logic [7:0] RdatA,	 // read data out A
  output logic [7:0] RdatB); // read data out B

  logic[7:0] Core[0:15]; 

  always_ff @(posedge Clk or posedge Rst) begin
      if (Rst) begin
          integer i;
          for (i = 0; i < REG_DEPTH; i++) begin
                Core[i] <= '0;        // clear registers on reset
          end
      end else if (Wen) begin
            Core[Wd] <= Wdat;         // synchronous write
      end
  end

  assign RdatA = Core[Ra];
  assign RdatB = Core[Rb];

endmodule
