`timescale 1ns/1ps

module tb_Ctrl;

    logic [8:0] mach_code;
    logic       Sco;
    logic       Zero;

    logic [3:0] Aluop, Alu2op;
    logic [7:0] Jptr;
    logic [1:0] Cond;
    logic [3:0] Ra, Rb, Wd, Ra2, Rb2;
    logic       WenR, WenImm, WenD, Ldr, Str, ALU_IMM, EnAlu2;
    logic [4:0] ALU_IMM_VAL;

    // DUT
    Ctrl dut(
        .mach_code(mach_code),
        .Sco(Sco),
        .Zero(Zero),
        .Aluop(Aluop),
        .Alu2op(Alu2op),
        .Jptr(Jptr),
        .Cond(Cond),
        .Ra(Ra), .Rb(Rb), .Wd(Wd), .Ra2(Ra2), .Rb2(Rb2),
        .WenR(WenR), .WenImm(WenImm), .WenD(WenD),
        .Ldr(Ldr), .Str(Str),
        .ALU_IMM(ALU_IMM),
        .EnAlu2(EnAlu2),
        .ALU_IMM_VAL(ALU_IMM_VAL)
    );

    task print_state(string name);
        $display("\n----- %s -----", name);
        $display("mach_code = %b", mach_code);
        $display("Aluop=%b Alu2op=%b", Aluop, Alu2op);
        $display("Ra=%0d Rb=%0d Wd=%0d", Ra, Rb, Wd);
        $display("Ra2=%0d Rb2=%0d", Ra2, Rb2);
        $display("WenR=%b WenImm=%b WenD=%b", WenR, WenImm, WenD);
        $display("Ldr=%0d Str=%0d", Ldr, Str);
        $display("ALU_IMM=%b ImmVal=%0d", ALU_IMM, ALU_IMM_VAL);
        $display("Cond=%b Jptr=%0d\n", Cond, Jptr);
    endtask

    task run_test(input [8:0] code, input bit Z, string msg);
        mach_code = code;
        Zero      = Z;
        Sco       = 0;
        #1;
        print_state(msg);
    endtask


    initial begin
        $display("================ CTRL UNIT TESTS ================");

	//R type
        run_test(9'b0_0000_0101, 0, "AND");
        run_test(9'b0_0001_0110, 0, "ADD");
        run_test(9'b0_0010_0011, 0, "SUB");
        run_test(9'b0_0110_1010, 0, "LOAD");
        run_test(9'b0_0101_1100, 0, "STORE");
        run_test(9'b0_0011_0010, 0, "STORE_M");
        run_test(9'b0_1010_0011, 0, "OR");
        run_test(9'b0_1011_0100, 0, "NOT");
        run_test(9'b0_1100_0001, 0, "SHL");
        run_test(9'b0_1101_0111, 0, "SHR");

        // RESET
        run_test(9'b0_1001_0000, 0, "RESET");
        // FILL
        run_test(9'b0_1000_0000, 0, "FILL");

        // TST
        run_test(9'b0_0111_0011, 0, "TST");

        // MOV
        run_test(9'b0_1110_0100, 0, "MOV");

        // ADDNE (Zero = 1 triggers write)
        run_test(9'b0_1111_0101, 1, "ADDNE Zero=1");
        run_test(9'b0_1111_0101, 0, "ADDNE Zero=0");

        // I type 
        run_test(9'b1_000_10101, 0, "ANDI");
        run_test(9'b1_001_00101, 0, "ADDI");
        run_test(9'b1_010_00110, 0, "SUBI");
        run_test(9'b1_011_11111, 0, "MOVI");
        run_test(9'b1_100_01000, 0, "LSLI");
        run_test(9'b1_110_01000, 0, "RSRI");
        run_test(9'b1_011_10101, 0, "ORI");

        // J type
        run_test(9'b11_00_00101, 0, "JUMP (unconditional)");
        run_test(9'b11_01_00010, 0, "JE");
        run_test(9'b11_10_01010, 0, "JG");
        run_test(9'b11_11_00100, 0, "JL");


        $display("\n============== CTRL TESTING COMPLETE ==============");
        $finish;
    end

endmodule
