def convert(inFile, outFile1, outFile2):
    assembly_file = open(inFile, 'r')
    machine_file = open(outFile1, 'w')
    lut_file = open(outFile2, 'w')
    assembly = list(assembly_file.read().split('\n'))

    # keep track of index and file line number
    lineNum = 0
    labelsNum = 0

    R_ops = {
        'AND':'0000','ADD':'0001','SUB':'0010','LOAD':'0011',
        'STORE':'0100','STORE_M':'0101','XOR':'0110','TST':'0111',
        'FILL':'1000','RESET':'1001','OR':'1010','NOT':'1011',
        'LSL':'1100','RSL':'1101','MOV':'1110', 'ADDNE':'1111'
    }

    I_ops = {
        'ANDI':'000','ADDI':'001','SUBI':'010','MOVI':'011',
        'LSLI':'100','ORI':'101','RSLI':'110' 
    }

    J_ops = {
        'J':'00','JE':'01','JG':'10','JL':'11'
    }

    R_no_operand = {"RESET", "FILL", "NOT", "LSL", "RSL"}


    # registers R0–R15
    registers = {f'R{i}': format(i,'04b') for i in range(16)}

    # collect labels
    lut = {}
    pc = 0

    for line in assembly:
        instr = line.split("//")[0].strip() # also strip comments
        if len(instr) == 0:
            continue
        
        token = instr.split()
        if token[0].endswith(":"):
            label = token[0][:-1]
            lut[label] = pc # if we get a jump label
        else:
            pc += 1
    
    lut_entries = [0] * 32        # 32-entry jump table
    target_to_index = {}          # PC target to LUT index
    next_lut_index = 0

    # convert assembly to machine code
    for line in assembly:
        line = line.split("//")[0].strip()
        instr = line.split()
        if len(instr) == 0:
            continue

        # skip labels
        if instr[0].endswith(":"):
            continue
        
        mnemonic = instr[0]
        args = instr[1:] if len(instr) > 1 else []

        output = ""

        # ---------- R-TYPE ----------
        if mnemonic in R_ops:
            output += "0"                     # R header
            output += R_ops[mnemonic]         # 4-bit opcode
            if mnemonic in R_no_operand:
                # No operand → emit 0000
                output += "0000"
            else:
                if len(args) == 0:
                    raise ValueError(f"Missing register for instruction: {mnemonic}")
                reg = args[0].replace(",", "")
                output += registers[reg]

        # ---------- I-TYPE ----------
        elif mnemonic in I_ops:
            output += "10"                    # I header
            output += I_ops[mnemonic]         # 3-bit opcode
            imm = int(args[0].replace(",", ""))
            imm_bin = format(imm & 0xF, '04b')
            output += imm_bin                 # 4-bit immediate

        # ---------- J-TYPE ----------
        elif mnemonic in J_ops:
            output += "11"                    # J header
            output += J_ops[mnemonic]         # 2-bit opcode
            arg = args[0].replace(",", "")
            # if arg.isdigit() or (arg[0] == '-' and arg[1:].isdigit()):
            #     imm = int(arg)
            # else:
            #     # label case
            #     if arg not in lut:
            #         raise ValueError(f"Unknown label: {arg}")
            #     imm = lut[arg]
            if arg in lut:
                pc_target = lut[arg]
            else:
                try:
                    pc_target = int(arg)
                except ValueError:
                    raise ValueError(f"Unknown label or invalid target: {arg}")

            if pc_target not in target_to_index:
                if next_lut_index >= 32:
                    raise ValueError("Too many distinct jump targets; LUT size exceeded (32).")
                target_to_index[pc_target] = next_lut_index
                lut_entries[next_lut_index] = pc_target
                next_lut_index += 1
            
            lut_index = target_to_index[pc_target]
            imm_bin = format(lut_index & 0x1F, '05b')
            output += imm_bin               # 5-bit immediate

        else:
            continue  # ignore unknown lines or blanks

        #machine_file.write(output + "\n") # output without comments
        machine_file.write(output + "\t// " + line + "\n") #output with comments
    for entry in lut_entries:
        lut_file.write(format(entry & 0xFFFF, '016b') + "\n")
    assembly_file.close()
    machine_file.close()
    lut_file.close()

# convert("assembly.txt", "machine.txt", "lut.txt")
# convert("stringmatch.txt", "sm_machine.txt", "sm_lut.txt")
# convert("cordic.txt", "c_machine.txt", "c_lut.txt")
# convert("division.txt", "d_machine.txt", "d_lut.txt")
convert("closetest.txt", "d_machine_p1.txt", "d_lut_p1.txt")
