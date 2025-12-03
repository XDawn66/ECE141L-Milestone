`timescale 1ns/1ps

module tb_Ctrl;

    logic [8:0] mach_code;
    logic Sco;
    logic Zero;

    // DUT outputs
    logic [3:0] Aluop, Alu2op, Ra, Rb, Wd, Ra2, Rb2;
    logic [7:0] Jptr;
    logic [1:0] Cond;
    logic WenR, WenImm, WenD, Ldr, Str, ALU_IMM, EnAlu2;
    logic [4:0] ALU_IMM_VAL;

    // Instantiate DUT
    Ctrl dut(
        .mach_code(mach_code),
        .Sco(Sco),
        .Zero(Zero),
        .Aluop(Aluop),
        .Alu2op(Alu2op),
        .Jptr(Jptr),
        .Cond(Cond),
        .Ra(Ra), .Rb(Rb), .Wd(Wd),
        .Ra2(Ra2), .Rb2(Rb2),
        .WenR(WenR), .WenImm(WenImm),
        .WenD(WenD), .Ldr(Ldr), .Str(Str),
        .ALU_IMM(ALU_IMM), .EnAlu2(EnAlu2),
        .ALU_IMM_VAL(ALU_IMM_VAL)
    );

    // Procedure
    initial begin
        $display("Starting Ctrl testbench...");

        Sco  = 0;
        Zero = 0;

        // Test all major instruction categories 

        // R-type AND R3
        mach_code = 9'b0_0000_0011; #20;

        // R-type ADD R7
        mach_code = 9'b0_0001_0111; #20;

        // R-type LOAD from R5
        mach_code = 9'b0_0110_0101; #20;

        // R-type STORE into R2
        mach_code = 9'b0_0101_0010; #20;

        // R-type STORE_M (write to memory)
        mach_code = 9'b0_0011_0100; #20;

        // R-type TST on R1
        mach_code = 9'b0_0111_0001; #20;

        // R-type MOV from R4
        mach_code = 9'b0_1110_0100; #20;

        // R-type ADDNE (depends on Zero flag)
        Zero = 0;
        mach_code = 9'b0_1111_0000; #20;
        Zero = 1;
        mach_code = 9'b0_1111_0000; #20;

        // I-type MOVI with immediate = 0x0F
        mach_code = 9'b1_011_01111; #20;

        // I-type ADDI imm=4
        mach_code = 9'b1_001_00100; #20;

        // I-type ORI imm=12
        mach_code = 9'b1_101_01100; #20;

        // J-type unconditional
        mach_code = 9'b11_00_00010; #20;

        // J-type JE (JE ACC==0)
        mach_code = 9'b11_01_00101; #20;

        // J-type JG
        mach_code = 9'b11_10_01000; #20;

        // J-type JL
        mach_code = 9'b11_11_11100; #20;

        // Randomized testing
        repeat (40) begin
            mach_code = $urandom_range(0, 511); // full 9-bit range
            Sco  = $urandom_range(0, 1);
            Zero = $urandom_range(0, 1);
            #20;
        end

        $display("Finished.");
        $stop;
    end

endmodule
