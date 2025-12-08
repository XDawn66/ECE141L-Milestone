`timescale 1ns/1ps

module dat_mem(
    input  logic        clk,
    input  logic        wen,
    input  logic [7:0]  addr,
    input  logic [7:0]  dat_in,
    output logic [7:0]  dat_out
);
    logic [7:0] core [0:255];
    assign dat_out = core[addr];

    always_ff @(posedge clk) begin
        if (wen) core[addr] <= dat_in;
    end
endmodule

module instr_mem(
    input  logic [7:0] addr,
    output logic [8:0] instr
);
    logic [8:0] core [0:255];

    initial begin
        if ($fopen("program.txt") != 0)
            $readmemb("program.txt", core);
    end

    assign instr = core[addr];
endmodule

module DUT(
  input  logic clk,
  input  logic reset,
  input  logic start,
  output logic done
);

  logic [7:0] pc;
  logic [7:0] regs [0:7];

  logic [8:0] inst;
  logic [2:0] opcode;
  logic [5:0] arg;
  logic [2:0] rd, rs;
  logic [7:0] imm6;

  logic        mem_wen;
  logic [7:0]  mem_addr;
  logic [7:0]  mem_wdata;
  logic [7:0]  mem_rdata;

  instr_mem imem(.addr(pc), .instr(inst));
  dat_mem   dm  (.clk(clk), .wen(mem_wen), .addr(mem_addr), .dat_in(mem_wdata), .dat_out(mem_rdata));

  always_comb begin
    opcode = inst[8:6];
    arg    = inst[5:0];
    rd     = arg[5:3];
    rs     = arg[2:0];
    imm6   = {2'b00, arg};
  end

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      pc <= 0;
      done <= 0;
      mem_wen <= 0;
      mem_addr <= 0;
      mem_wdata <= 0;
      for (int i = 0; i < 8; i++) regs[i] <= 0;

    end else begin
      mem_wen   <= 0;
      mem_addr  <= 8'h00;
      mem_wdata <= 8'h00;

      if (!start && !done) begin
        case (opcode)

          3'b000: begin // HALT
            done <= 1;
            pc <= pc;
          end

          3'b001: begin // LOAD_IMM
            regs[rd] <= imm6;
            pc <= pc + 1;
          end

          3'b010: begin // LOAD
            mem_addr <= arg;
            regs[rd] <= mem_rdata;
            pc <= pc + 1;
          end

          3'b011: begin // STORE
            mem_addr  <= arg;
            mem_wdata <= regs[rd];
            mem_wen   <= 1;
            pc <= pc + 1;
          end

          3'b100: begin // XOR
            regs[rd] <= regs[rd] ^ regs[rs];
            pc <= pc + 1;
          end

          3'b101: begin // ADD
            regs[rd] <= regs[rd] + regs[rs];
            pc <= pc + 1;
          end

          3'b110: begin // JMP
            pc <= {2'b00, arg};
          end

          3'b111: begin // BRZ
            if (regs[rd] == 0)
              pc <= {2'b00, arg};
            else
              pc <= pc + 1;
          end

          default: pc <= pc + 1;
        endcase

      end // if running
    end // else not reset
  end // always_ff

endmodule
