`timescale 1ns/1ps

module regcheck_tb();

  // Testbench signals
  logic Clk;
  logic Reset;
  logic Done;
  
  // Test tracking
  integer pass_count;
  integer fail_count;
  logic tests_complete;
  
  // Instantiate DUT (Device Under Test)
  Top dut (
    .Clk(Clk),
    .Reset(Reset),
    .Done(Done)
  );
  
  // Clock generation - 10ns period (100MHz)
  initial begin
    Clk = 0;
    forever #5 Clk = ~Clk;
  end
  
  // Helper task to check register values at specific PC
  task automatic check_at_pc;
    input [5:0] expected_pc;
    input [3:0] reg_addr;
    input [7:0] expected_val;
    input string test_name;
    begin
      wait(dut.PC == expected_pc);
      @(posedge Clk);
      
      if (dut.register_file.Core[reg_addr] === expected_val) begin
        $display("[PASS] %s: R%0d = 0x%02h (expected 0x%02h)", 
                 test_name, reg_addr, dut.register_file.Core[reg_addr], expected_val);
        pass_count++;
      end else begin
        $display("[FAIL] %s: R%0d = 0x%02h (expected 0x%02h)", 
                 test_name, reg_addr, dut.register_file.Core[reg_addr], expected_val);
        fail_count++;
      end
    end
  endtask
  
  // Helper task to check data memory values
  task automatic check_mem_at_pc;
    input [5:0] expected_pc;
    input [7:0] addr;
    input [7:0] expected_val;
    input string test_name;
    begin
      wait(dut.PC == expected_pc);
      @(posedge Clk);
      
      if (dut.data_mem.Core[addr] === expected_val) begin
        $display("[PASS] %s: MEM[0x%02h] = 0x%02h (expected 0x%02h)", 
                 test_name, addr, dut.data_mem.Core[addr], expected_val);
        pass_count++;
      end else begin
        $display("[FAIL] %s: MEM[0x%02h] = 0x%02h (expected 0x%02h)", 
                 test_name, addr, dut.data_mem.Core[addr], expected_val);
        fail_count++;
      end
    end
  endtask
  
  // Main test sequence
  initial begin
    $display("\n========================================");
    $display("  9-BIT ISA PROCESSOR TESTBENCH");
    $display("========================================\n");
    
    // Initialize
    pass_count = 0;
    fail_count = 0;
    tests_complete = 0;
    Reset = 1;
    
    // Load test program into instruction memory
    load_test_program();
    
    // Apply reset
    #20;
    Reset = 0;
    #10;
    
    $display("\n--- Starting Instruction Tests ---\n");
    $display("Note: Program will run continuously. Tests check at specific PCs.\n");
    
    // All tests run in parallel, each waiting for their PC
    fork
      // TEST 1: RESET (PC=1 executes Core[0], check at PC=2)
      begin
        $display("[TEST 1] RESET - Clear accumulator");
        check_at_pc(6'd2, 4'd0, 8'h00, "RESET clears ACC");
      end
      
      // TEST 2: MOVI 10 (PC=2 executes Core[1], check at PC=3)
      begin
        $display("[TEST 2] MOVI - Load immediate value");
        check_at_pc(6'd3, 4'd0, 8'h0A, "MOVI 10 to ACC");
      end
      
      // TEST 3: ADDI 5 (PC=3 executes Core[2], check at PC=4)
      begin
        $display("[TEST 3] ADDI - Add immediate to ACC");
        check_at_pc(6'd4, 4'd0, 8'h0F, "ADDI 5 (10 + 5 = 15)");
      end
      
      // TEST 4: STORE to R1 (PC=4 executes Core[3], check at PC=5)
      begin
        $display("[TEST 4] STORE - Store ACC to register");
        check_at_pc(6'd5, 4'd1, 8'h0F, "STORE ACC to R1");
      end
      
      // TEST 5: FILL (PC=5 executes Core[4], check at PC=6)
      begin
        $display("[TEST 5] FILL - Fill ACC with 0xFF");
        check_at_pc(6'd6, 4'd0, 8'hFF, "FILL sets ACC to 0xFF");
      end
      
      // TEST 6: AND with R1 (PC=6 executes Core[5], check at PC=7)
      begin
        $display("[TEST 6] AND - Bitwise AND");
        check_at_pc(6'd7, 4'd0, 8'h0F, "AND ACC (0xFF) with R1 (0x0F) = 0x0F");
      end
      
      // TEST 7: ORI 0x04 (PC=7 executes Core[6], check at PC=8)
      begin
        $display("[TEST 7] ORI - Bitwise OR immediate");
        check_at_pc(6'd8, 4'd0, 8'h0F, "ORI 0x04 (0x0F | 0x04 = 0x0F)");
      end
      
      // TEST 8: XOR with R0 (PC=8 executes Core[7], check at PC=9)
      begin
        $display("[TEST 8] XOR - Bitwise XOR with R0 (self)");
        check_at_pc(6'd9, 4'd0, 8'h00, "XOR ACC with itself = 0");
      end
      
      // TEST 9: MOVI 15 (PC=9 executes Core[8], check at PC=10)
      begin
        $display("[TEST 9] MOVI 15");
        check_at_pc(6'd10, 4'd0, 8'h0F, "MOVI 15 to ACC");
      end
      
      // TEST 10: SUBI 5 (PC=10 executes Core[9], check at PC=11)
      begin
        $display("[TEST 10] SUBI 5");
        check_at_pc(6'd11, 4'd0, 8'h0A, "SUBI 5 from 15 = 10");
      end
      
      // TEST 11: LSLI 1 (PC=11 executes Core[10], check at PC=12)
      begin
        $display("[TEST 11] LSLI - Left shift immediate");
        check_at_pc(6'd12, 4'd0, 8'h14, "LSL 10 << 1 = 20");
      end
      
      // TEST 12: RSLI 1 (PC=12 executes Core[11], check at PC=13)
      begin
        $display("[TEST 12] RSLI - Right shift immediate");
        check_at_pc(6'd13, 4'd0, 8'h0A, "RSR 20 >> 1 = 10");
      end
      
      // TEST 13: MOV R1 to ACC (PC=13 executes Core[12], check at PC=14)
      begin
        $display("[TEST 13] MOV - Move from register to ACC");
        check_at_pc(6'd14, 4'd0, 8'h0F, "MOV R1 to ACC");
      end
      
      // TEST 14: NOT (PC=14 executes Core[13], check at PC=15)
      begin
        $display("[TEST 14] NOT - Bitwise NOT");
        check_at_pc(6'd15, 4'd0, 8'hF0, "NOT 0x0F = 0xF0");
      end
      
      // TEST 15: Setup R5 and STORE_M (PC=15 executes Core[14], check at PC=16)
      begin
        $display("[TEST 15] STORE_M - Store to data memory");
        // Setup R5 before instruction executes
        wait(dut.PC == 6'd14);
        @(posedge Clk);
        force dut.register_file.Core[5] = 8'h05;
        @(posedge Clk);
        release dut.register_file.Core[5];
        check_mem_at_pc(6'd16, 8'h05, 8'hF0, "Store ACC to MEM[5]");
      end
      
      // TEST 16: LOAD (PC=16 executes Core[15], check at PC=17)
      begin
        $display("[TEST 16] LOAD - Load from data memory");
        wait(dut.PC == 6'd17);
        @(posedge Clk);
        @(posedge Clk); // Extra cycle to ensure write completes
        
        if (dut.register_file.Core[4'd0] === 8'hF0) begin
          $display("[PASS] Load from MEM[5] to ACC: R0 = 0x%02h (expected 0xf0)", 
                   dut.register_file.Core[4'd0]);
          pass_count++;
        end else begin
          $display("[FAIL] Load from MEM[5] to ACC: R0 = 0x%02h (expected 0xf0)", 
                   dut.register_file.Core[4'd0]);
          fail_count++;
        end
      end
      
      // Wait for completion
      begin
        wait(Done);
        tests_complete = 1;
        $display("\n--- Program completed with DONE signal ---\n");
      end
      
      // Timeout
      begin
        #100000;
        $display("\n[ERROR] Simulation timeout");
        tests_complete = 1;
      end
    join_any
    
    // Wait a bit for any pending checks
    #500;
    
    // Final summary
    $display("\n========================================");
    $display("  TEST SUMMARY");
    $display("========================================");
    $display("Total Tests: %0d", pass_count + fail_count);
    $display("Passed:      %0d", pass_count);
    $display("Failed:      %0d", fail_count);
    if (fail_count == 0)
      $display("\nALL TESTS PASSED!");
    else
      $display("\nSOME TESTS FAILED!");
    $display("========================================\n");
    
    $finish;
  end
  
  // Task to load test program into instruction ROM
  task load_test_program;
    begin
      // Since InstROM uses Core[PC-1]:
      // When PC=1, reads Core[0]
      // When PC=2, reads Core[1], etc.
      
      // Core[0] (executed when PC=1): RESET
      dut.Instr_mem.Core[0] = 9'b0_1001_0000;
      
      // Core[1] (executed when PC=2): MOVI 10
      dut.Instr_mem.Core[1] = 9'b10_011_1010;
      
      // Core[2] (executed when PC=3): ADDI 5
      dut.Instr_mem.Core[2] = 9'b10_001_0101;
      
      // Core[3] (executed when PC=4): STORE to R1
      dut.Instr_mem.Core[3] = 9'b0_0101_0001;
      
      // Core[4] (executed when PC=5): FILL
      dut.Instr_mem.Core[4] = 9'b0_1000_0000;
      
      // Core[5] (executed when PC=6): AND with R1
      dut.Instr_mem.Core[5] = 9'b0_0000_0001;
      
      // Core[6] (executed when PC=7): ORI 0x04
      dut.Instr_mem.Core[6] = 9'b10_101_0100;
      
      // Core[7] (executed when PC=8): XOR with R0 (self)
      dut.Instr_mem.Core[7] = 9'b0_0110_0000;
      
      // Core[8] (executed when PC=9): MOVI 15
      dut.Instr_mem.Core[8] = 9'b10_011_1111;
      
      // Core[9] (executed when PC=10): SUBI 5
      dut.Instr_mem.Core[9] = 9'b10_010_0101;
      
      // Core[10] (executed when PC=11): LSLI 1
      dut.Instr_mem.Core[10] = 9'b10_100_0001;
      
      // Core[11] (executed when PC=12): RSLI 1
      dut.Instr_mem.Core[11] = 9'b10_110_0001;
      
      // Core[12] (executed when PC=13): MOV R1 to ACC
      dut.Instr_mem.Core[12] = 9'b0_1110_0001;
      
      // Core[13] (executed when PC=14): NOT
      dut.Instr_mem.Core[13] = 9'b0_1011_0000;
      
      // Core[14] (executed when PC=15): STORE_M to addr in R5
      dut.Instr_mem.Core[14] = 9'b0_0100_0101;
      
      // Core[15] (executed when PC=16): LOAD from R5
      dut.Instr_mem.Core[15] = 9'b0_0011_0101;
      
      // Core[16] (executed when PC=17): DONE
      dut.Instr_mem.Core[16] = 9'b111111111;
      
      $display("Test program loaded into instruction ROM");
      $display("Instructions placed in Core[0] through Core[16]");
      $display("PC-1 indexing: PC=1 reads Core[0], PC=2 reads Core[1], etc.\n");
    end
  endtask
  
  // Monitor for debugging
  initial begin
    $display("Time\tPC\tInstr\t\tACC\tR1\tR5\tFlags(Z,P,C)");
    $display("----\t--\t-----\t\t---\t--\t--\t------------");
  end
  
  always @(posedge Clk) begin
    if (!Reset && !tests_complete) begin
      $display("%0t\t%0d\t%b\t0x%02h\t0x%02h\t0x%02h\t%b%b%b",
               $time, dut.PC, dut.mach_code, 
               dut.register_file.Core[0],
               dut.register_file.Core[1],
               dut.register_file.Core[5],
               dut.Zero, dut.Par, dut.SCo);
    end
  end

endmodule
