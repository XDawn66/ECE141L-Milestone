module JLUT(
    input  logic [1:0] Jptr,       // 2-bit jump type from Ctrl
    output logic [5:0] Jump        // 6-bit jump address
);

    always_comb begin
        case (Jptr)
            2'b00: Jump = 6'd10;  // J   unconditional jump to address 10
            2'b01: Jump = 6'd12;  // JE  jump if ACC == 0
            2'b10: Jump = 6'd8;   // JG jump if ACC > 0
            2'b11: Jump = 6'd5;   // JL  jump if ACC < 0
            default: Jump = 6'd0; // default
        endcase
    end

endmodule