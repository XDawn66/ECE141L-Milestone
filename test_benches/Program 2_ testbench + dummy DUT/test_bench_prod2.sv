// program 2    CSE141L   product C = OpA * OpB  
// operands are 8-bit two's comp integers, product is 16-bit two's comp integer
`timescale 1ns/1ps
module test_bench;

// connections to DUT: clk (clock), reset, start (request), done (acknowledge) 
  bit  clk = 0;
  bit  reset = 1;
  bit  start = 1;
  wire done;

  logic signed[7:0] OpA, OpB;
  logic signed[15:0] Prod;
  
  logic [15:0] result;
  
  integer cycle_count = 0;

  // Instantiate Top module
  Top D1(
    .Clk(clk),
    .Reset(reset),
    .start(start),
    .Done(done)
  ); 

  // Clock generation
  always #50ns clk = ~clk;

  initial begin
    $display("\n========================================");
    $display("MULTIPLICATION TEST - DETAILED DEBUG");
    $display("========================================\n");
    
    // Initialize operands
    OpA = 2;
    OpB = -4;
    Prod = OpA * OpB;
    
    $display("Test case: %0d * %0d = %0d", OpA, OpB, Prod);
    $display("Expected: MEM[2]=0x%02h, MEM[3]=0x%02h\n", Prod[7:0], Prod[15:8]);
    
    // Load memory and programs BEFORE releasing reset
    D1.data_mem.core[0] = OpA;
    D1.data_mem.core[1] = OpB;
    
    $display("Loading program files...");
    $readmemb("machine.txt", D1.Instr_mem.core);
    $readmemb("lut.txt", D1.lookup_table.core);
    $display("Programs loaded.\n");
    
    // Display first few instructions
    $display("First 10 instructions in ROM:");
    for (int i = 0; i < 10; i++) begin
      $display("  ROM[%0d] = %b", i, D1.Instr_mem.core[i]);
    end
    $display("");
    
    // Wait a bit with reset high
    #200ns;
    
    $display("Time %0t: Releasing reset", $time);
    reset = 0;
    start = 0;
    
    $display("\n--- EXECUTION TRACE ---");
    $display("Cycle | PC    |Instruction|ACC | R1 R2 R3 R4 R5 R6 |  Mem[0-3]  | WenR WenD | Notes");
    $display("------|-------|-----------|----|-------------------|------------|-----------|-------");
    
    // Monitor execution
    fork
      begin
        // Execution monitor -- RUN FOREVER UNTIL DONE
        forever begin
          @(posedge clk);
          if (!reset) begin
            cycle_count++;
            
            $write("%5d | ", cycle_count);
            $write("%5d | ", D1.PC);
            $write("%b | ", D1.mach_code);
            $write("%02h | ", D1.register_file.core[0]);
            $write("%02h %02h %02h %02h %02h %02h | ",
                   D1.register_file.core[1],
                   D1.register_file.core[2],
                   D1.register_file.core[3],
                   D1.register_file.core[4],
                   D1.register_file.core[5],
                   D1.register_file.core[6]);
            $write("%02h %02h %02h %02h | ",
                   D1.data_mem.core[0],
                   D1.data_mem.core[1],
                   D1.data_mem.core[2],
                   D1.data_mem.core[3]);
            $write("  %b    %b   | ", D1.WenR, D1.WenD);
            
            // Decode instruction type
            if (D1.mach_code[8:7] == 2'b11)
              $write("J-type");
            else if (D1.mach_code[8] == 1'b0)
              $write("R-type");
            else if (D1.mach_code[8:7] == 2'b10)
              $write("I-type");
            else
              $write("???");
            
            if (D1.WenD)
              $write(" MEM[%0d]<-%02h", D1.Addr, D1.WdatD);
            if (D1.WenR)
              $write(" R%0d<-%02h", D1.Wd, D1.WdatR);
              
            $display("");
            
            if (done) begin
              $display("\n*** DONE signal asserted at cycle %0d ***", cycle_count);
              disable fork; // EXIT monitor + join_any finishes
            end
          end
        end
      end
      
      begin
        // Done detector
        wait(done);
        #100ns;
      end
    join_any
    
    // Display final results
    $display("\n========================================");
    $display("FINAL RESULTS");
    $display("========================================");
    $display("Cycles executed: %0d", cycle_count);
    $display("Done signal: %b", done);
    $display("");
    
    $display("Memory contents:");
    $display("  MEM[0] = 0x%02h (%3d) [OpA]", D1.data_mem.core[0], $signed(D1.data_mem.core[0]));
    $display("  MEM[1] = 0x%02h (%3d) [OpB]", D1.data_mem.core[1], $signed(D1.data_mem.core[1]));
    $display("  MEM[2] = 0x%02h (%3d) [Result LOW]", D1.data_mem.core[2], $signed(D1.data_mem.core[2]));
    $display("  MEM[3] = 0x%02h (%3d) [Result HIGH]", D1.data_mem.core[3], $signed(D1.data_mem.core[3]));
    $display("");
    
    result = {D1.data_mem.core[3], D1.data_mem.core[2]};
    
    $display("Expected: %0d * %0d = %0d (0x%04h)", OpA, OpB, Prod, Prod);
    $display("Got:      {0x%02h, 0x%02h} = %0d (0x%04h)", 
             D1.data_mem.core[3], D1.data_mem.core[2], $signed(result), result);
    $display("");
    
    if (result == Prod) begin
      $display("*** TEST PASSED ***");
    end else begin
      $display("*** TEST FAILED ***");
      $display("Difference: %0d", $signed(result) - Prod);
    end
    
    $display("\n========================================\n");
    
    #100ns;
    $stop;
  end

endmodule
