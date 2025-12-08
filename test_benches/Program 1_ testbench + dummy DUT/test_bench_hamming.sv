// program 1-2-3    CSE141L  
`timescale 1ns/1ps 
module test_bench;

  // connections to DUT
  bit clk,
      reset = 1'b1,        // PC = 0 at start
      start = 1'b1;        // falling edge starts program
  wire done;               // high when DUT finished

  logic [3:0] Dist, Min, Max;     // current, min, max Hamming distances
  logic [4:0] Min1, Min2;         // addresses of pair w/ smallest distance
  logic [4:0] Max1, Max2;         // addresses of pair w/ largest distance
  logic [7:0] Tmp[16];            // cache of 16 8-bit operands from data memory

  // DUT instance
  DUT D1(
      .clk(clk),
      .reset(reset),
      .start(start),
      .done(done)
  );

  // 100 MHz clock (10 ns period)
  always begin
    #50 clk = 1'b1;
    #50 clk = 1'b0;
  end

  initial begin
    // Wait a little before starting
    #100;

    // Initialize Hamming min/max
    Min = 4'd8;    // max possible Hamming distance (for 8-bit operands)
    Max = 4'd0;    // min possible distance

    $readmemb("mach_code.txt", D1.imem.core);

    for (int r = 0; r < 16; r++) begin
      D1.dm.core[r] = r;           // example operand values
      Tmp[r] = D1.dm.core[r];
      $display("%0d: %b", r, Tmp[r]);
    end

    // Preset memory for min/max storage
    D1.dm.core[16] = 8'd8;         // final Min placeholder
    D1.dm.core[17] = 8'd0;         // final Max placeholder
    for (int r = 18; r < 256; r++)
      D1.dm.core[r] = 8'd0;

    for (int j = 0; j < 16; j++) begin
      for (int k = j + 1; k < 16; k++) begin
        #1 Dist = ham(Tmp[j], Tmp[k]);
        if (Dist < Min) begin
          Min = Dist; Min1 = k; Min2 = j;
        end
        if (Dist > Max) begin
          Max = Dist; Max1 = k; Max2 = j;
        end
      end
    end

    // Save correct answers in data memory
    D1.dm.core[16] = Min;
    D1.dm.core[17] = Max;

    #200 reset = 1'b0;
    #200 start = 1'b0;

    #200 wait(done);   // wait until DUT signals done

    if (Min == D1.dm.core[16]) $display("Good Min = %d", Min);
    else $display("Fail Min: Correct = %d, DUT = %d", Min, D1.dm.core[16]);
    $display("Min pair: %d, %d; values: %b, %b", Min1, Min2, Tmp[Min1], Tmp[Min2]);

    if (Max == D1.dm.core[17]) $display("Good Max = %d", Max);
    else $display("Fail Max: Correct = %d, DUT = %d", Max, D1.dm.core[17]);
    $display("Max pair: %d, %d; values: %b, %b", Max1, Max2, Tmp[Max1], Tmp[Max2]);

    // End simulation
    #10 reset = 1'b1; start = 1'b1;
    $stop;
  end

  function [3:0] ham(input [7:0] a, b);
    ham = 4'd0;
    for (int q = 0; q < 8; q++)
      if (a[q] ^ b[q]) ham++;
  endfunction

endmodule
