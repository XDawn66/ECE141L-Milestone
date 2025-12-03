`timescale 1ns/1ps

module tb_Ctrl;

    logic [8:0] mach_code;
    logic Sco, Zero;

    // Outputs from DUT
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
        .Ra(Ra),
        .Rb(Rb),
        .Wd(Wd),
        .Ra2(Ra2),
        .Rb2(Rb2),
        .WenR(WenR),
        .WenImm(WenImm),
        .WenD(WenD),
        .Ldr(Ldr),
        .Str(Str),
        .ALU_IMM(ALU_IMM),
        .EnAlu2(EnAlu2),
        .ALU_IMM_VAL(ALU_IMM_VAL)
    );

    // Stimulus
    initial begin
        Sco = 0;
        Zero = 0;

        // Loop through many instruction patterns
        repeat (80) begin
            mach_code = $random & 9'h1FF;  // any 9-bit instruction
            Zero = $random;                // toggle Zero sometimes
            Sco  = $random;
            #20;   
        end

        $stop;
    end

endmodule
