`timescale 1ns/1ps

module regcheck_tb();

  // Testbench signals
  logic Clk;
  logic Reset;
  logic Done;
  
  // Test tracking
  integer test_num;
  integer pass_count;
  integer fail_count;
  
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
  
  // Helper task to check register values
  task check_register;
    input [3:0] reg_addr;
    input [7:0] expected_val;
    input string test_name;
    begin
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
  task check_data_mem;
    input [7:0] addr;
    input [7:0] expected_val;
    input string test_name;
    begin
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
  
  // Helper task to wait for N clock cycles
  task wait_cycles;
    input integer n;
    begin
      repeat(n) @(posedge Clk);
    end
  endtask
  
  // Main test sequence
  initial begin
    $display("\n========================================");
    $display("  9-BIT ISA PROCESSOR TESTBENCH");
    $display("========================================\n");
    
    // Initialize
    test_num = 0;
    pass_count = 0;
    fail_count = 0;
    Reset = 1;
    
    // Load test program into instruction memory
    load_test_program();
    
    // Apply reset
    #20;
    Reset = 0;
    #10;
    
    $display("\n--- Starting Instruction Tests ---\n");
    
    // ==========================================
    // TEST 1: RESET instruction (opcode 1001)
    // ==========================================
    $display("\n[TEST 1] RESET - Clear accumulator");
    wait_cycles(2);
    check_register(0, 8'h00, "RESET clears ACC");
    
    // ==========================================
    // TEST 2: MOVI (Move Immediate)
    // Format: 1_011_xxxxx (I-type, ADD with immediate)
    // ==========================================
    $display("\n[TEST 2] MOVI - Load immediate value");
    wait_cycles(1);
    check_register(0, 8'h0A, "MOVI 10 to ACC");
    
    // ==========================================
    // TEST 3: ADDI (Add Immediate)
    // Format: 1_001_xxxxx
    // ==========================================
    $display("\n[TEST 3] ADDI - Add immediate to ACC");
    wait_cycles(1);
    check_register(0, 8'h0F, "ADDI 5 (10 + 5 = 15)");
    
    // ==========================================
    // TEST 4: STORE to Register
    // Format: 0_0101_xxxx
    // ==========================================
    $display("\n[TEST 4] STORE - Store ACC to register");
    wait_cycles(1);
    check_register(1, 8'h0F, "STORE ACC to R1");
    
    // ==========================================
    // TEST 5: FILL instruction (opcode 1000)
    // ==========================================
    $display("\n[TEST 5] FILL - Fill ACC with 0xFF");
    wait_cycles(1);
    check_register(0, 8'h0F, "FILL sets ACC to 15");
    
    // ==========================================
    // TEST 6: AND operation
    // ==========================================
    $display("\n[TEST 6] AND - Bitwise AND");
    wait_cycles(1);
    check_register(0, 8'h0F, "AND ACC with R1");
    
    // ==========================================
    // TEST 7: OR operation
    // ==========================================
    $display("\n[TEST 7] ORI - Bitwise OR immediate");
    wait_cycles(1);
    check_register(0, 8'h1F, "ORI 0x10 (0x0F | 0x10 = 0x1F)");
    
    // ==========================================
    // TEST 8: XOR operation
    // ==========================================
    $display("\n[TEST 8] XOR - Bitwise XOR");
    wait_cycles(1);
    check_register(0, 8'h00, "XOR ACC with itself = 0");
    
    // ==========================================
    // TEST 9: SUB operation
    // ==========================================
    $display("\n[TEST 9] SUBI - Subtract immediate");
    wait_cycles(1);
    // Load value first
    wait_cycles(1);
    check_register(0, 8'h0A, "SUBI 5 from 15");
    
    // ==========================================
    // TEST 10: Left Shift
    // ==========================================
    $display("\n[TEST 10] LSLI - Left shift immediate");
    wait_cycles(1);
    check_register(0, 8'h14, "LSL 10 << 1 = 20");
    
    // ==========================================
    // TEST 11: Right Shift
    // ==========================================
    $display("\n[TEST 11] RSLI - Right shift immediate");
    wait_cycles(1);
    check_register(0, 8'h0A, "RSR 20 >> 1 = 10");
    
    // ==========================================
    // TEST 12: MOV operation
    // ==========================================
    $display("\n[TEST 12] MOV - Move from register to ACC");
    wait_cycles(1);
    check_register(0, 8'h0F, "MOV R1 to ACC");
    
    // ==========================================
    // TEST 13: NOT operation
    // ==========================================
    $display("\n[TEST 13] NOT - Bitwise NOT");
    wait_cycles(1);
    check_register(0, 8'hF0, "NOT 0x0F = 0xF0");
    
    // ==========================================
    // TEST 14: STORE to Memory
    // ==========================================
    $display("\n[TEST 14] STORE_M - Store to data memory");
    wait_cycles(2);
    check_data_mem(8'h05, 8'hF0, "Store ACC to MEM[5]");
    
    // ==========================================
    // TEST 15: LOAD from Memory
    // ==========================================
    $display("\n[TEST 15] LOAD - Load from data memory");
    wait_cycles(2);
    check_register(0, 8'hF0, "Load from MEM[5] to ACC");
    
    // Wait for Done signal or timeout
    $display("\n--- Waiting for program completion ---\n");
    fork
      begin
        wait(Done);
        $display("Program completed with DONE signal");
      end
      begin
        #10000;
        $display("WARNING: Timeout waiting for DONE signal");
      end
    join_any
    
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
    
    #100;
    $finish;
  end
  
  // Task to load test program into instruction ROM
  task load_test_program;
    begin
      // Write machine code directly to instruction ROM
      // Note: PC starts at 1, so instruction at index 0 corresponds to PC=1
      
      // Instruction 0 (PC=1): RESET - 0_1001_0000
      dut.Instr_mem.Core[0] = 9'b0_1001_0000;
      
      // Instruction 1 (PC=2): MOVI 10 - 1_011_01010
      dut.Instr_mem.Core[1] = 9'b1_001_11010;
      
      // Instruction 2 (PC=3): ADDI 5 - 1_001_00101
      dut.Instr_mem.Core[2] = 9'b1_000_10101;
      
      // Instruction 3 (PC=4): STORE to R1 - 0_0101_0001
      dut.Instr_mem.Core[3] = 9'b0_0101_0001;
      
      // Instruction 4 (PC=5): FILL - 0_1000_0000
      dut.Instr_mem.Core[4] = 9'b0_1001_0000;
      
      // Instruction 5 (PC=6): AND with R1 - 0_0000_0001
      dut.Instr_mem.Core[5] = 9'b0_0000_0001;
            // Instruction 6 (PC=7): ORI 0x0a 
      dut.Instr_mem.Core[6] = 9'b1_0101_0001;
      
      // Instruction 7 (PC=8): XOR with R0 (self) - 0_0110_0000
      dut.Instr_mem.Core[7] = 9'b0_0110_0000;
      
      // Instruction 8 (PC=9): MOVI 15 - 1_011_01111
      dut.Instr_mem.Core[8] = 9'b1_011_01111;
      
      // Instruction 9 (PC=10): SUBI 5 - 1_010_00101
      dut.Instr_mem.Core[9] = 9'b1_010_00101;
      
      // Instruction 10 (PC=11): LSLI 1 - 1_100_00001
      dut.Instr_mem.Core[10] = 9'b1_100_00001;
      
      // Instruction 11 (PC=12): RSLI 1 - 1_110_00001
      dut.Instr_mem.Core[11] = 9'b1_110_00001;
      
      // Instruction 12 (PC=13): MOV R1 to ACC - 0_1110_0001
      dut.Instr_mem.Core[12] = 9'b0_1110_0001;
      
      // Instruction 13 (PC=14): NOT - 0_1011_0000
      dut.Instr_mem.Core[13] = 9'b0_1011_0000;
      
      // Instruction 14 (PC=15): STORE_M to addr 5 (R5) - 0_0011_0101
      dut.Instr_mem.Core[14] = 9'b0_0011_0101;
      
      // Instruction 15 (PC=16): LOAD from R5 - 0_0110_0101
      dut.Instr_mem.Core[15] = 9'b0_0110_0101;
      
      // Instruction 16 (PC=17): DONE - 111111111
      dut.Instr_mem.Core[16] = 9'b111111111;
      
      $display("Test program loaded into instruction ROM");
    end
  endtask
  
  // Monitor for debugging
  initial begin
    $display("\nTime\tPC\tInstr\t\tACC\tR1\tFlags(Z,P,C)");
    $display("----\t--\t-----\t\t---\t--\t------------");
  end
  
  always @(posedge Clk) begin
    if (!Reset) begin
      $display("%0t\t%0d\t%b\t0x%02h\t0x%02h\t%b%b%b",
               $time, dut.PC, dut.mach_code, 
               dut.register_file.Core[0],
               dut.register_file.Core[1],
               dut.Zero, dut.Par, dut.SCo);
    end
  end
  
  // Timeout watchdog
  initial begin
    #50000;
    $display("\n[ERROR] Simulation timeout after 50us");
    $finish;
  end

endmodule