module ProgCtr(
  input  logic      Clk,
  input  logic      Reset,
  input	 logic      Jen,
  input  logic[1:0] cond,
  input  logic[7:0] acc,
  input  logic[5:0] Jump,
  output logic[5:0] PC
);


  logic [5:0] PCnext;
  logic branch;
  logic Z = (acc == 8'b0) ;
  logic N = acc[7];
  logic P = (~acc[7]) & (acc != 8'b0);

  always_comb begin
    case (cond)
        2'b00: branch = 1'b1; //unconditional branch 
        2'b01: branch = Z;    //Branch if equal to 0
	2'b10: branch = P;    //Branch if > 
	2'b11: branch = N;    //Branch if < 
        default: branch = 1'b0;
    endcase
  end

  always_comb begin
    if (branch) 
    	PCnext = Jump;
    else 
	PCnext = PC + 1'b1;
    end
  
  always_ff @(posedge Clk)
    if(!Reset) begin 
        PC <= 0;
    end else if(Jen) begin
        PC <= Jump;
    end else begin
        PC <= PC + 6'd1;
    end

endmodule
