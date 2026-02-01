#!/usr/bin/python
import sys
import re

# R-type instructions (no immediate value)
rTypeMap = {
    'ADD': 0b0000_0101,
    'ADDU': 0b0000_0110,
    'ADDC': 0b0000_0111,
    'SUB': 0b0000_1001,
    'CMP': 0b0000_1011,
    'AND': 0b0000_0001,
    'OR': 0b0000_0010,
    'XOR': 0b0000_0011,
    'MOV': 0b0000_1101,
    'SCOND': 0b0100_1101,
    'JUMP': 0b0100_1100,
    'Jcond': 0b0100_1100, # alias for above operation
    'LOAD': 0b0100_0000,
    'STOR': 0b0100_0100,
    'WAIT': 0b0000_0000,
}

# I-type instructions (with immediate value)
# Binary format: 8'bXXXX_xxxx
iTypeMap = {
    'ADDI': 0b0101,
    'ADDUI': 0b0110,
    'ADDCI': 0b0111,
    'SUBI': 0b1001,
    'CMPI': 0b1011,
    'ANDI': 0b0001,
    'ORI': 0b0010,
    'XORI': 0b0011,
    'MOVI': 0b1101,
#   todo: handle these cases with don't care in LSB
#   'LSHI': 0b1000_000x,
#   'ASHUI': 0b1000_001x,
    'BCOND': 0b1100,
}

def assemble(programText):
    """Convert an assembly text into machine code"""
    lines = programText.split('\n')
    result = ""
    
    # keep a reference to the current location in memory
    memPosition = 0
    labels = {} # locations in memory
    preParser(lines, labels)

    # loop 1
    for line_num, line in enumerate(lines, start=1):
        output = ""
        line = stripLine(line)

        # do nothing for empty line, or labels
        if line is None or line.isspace() or line.strip() == "" or ':' in line.strip():
            continue
        # jump to new location with @ followed by 4 hex numbers
        if (re.match(r'\s*@\ *([0-9a-fA-F]{4})\s*', line)):
            annotation = line.strip() + "\n"
            result += annotation
            # update the memory position to the @
            memPosition = int(annotation[1:], 16)
            memPosition -= 16 # account for this instruction
            continue
        
        # otherwise, we have an instruction
        # parse the instruction
        tokens = line.split()
        if len(tokens) == 0: # should never happen
            continue
        instr = tokens[0].upper()
        memPosition += 16 # advance by one 16-bit instruction

        # Special case
        if instr.upper() == "WAIT" or instr.upper() == "NOP":
            output = '0000'
        # R-type instruction
        elif instr in rTypeMap:
            output = parseRType(instr, tokens[1:], line_num, line)
        # I-type instruction
        elif instr in iTypeMap:
            output = parseIType(instr, tokens[1:], line_num, line, memPosition, labels)
        else:
            raise NameError(f"The instruction {instr} on line {line_num} could not be found!", instr, line_num)

        # comment the original line after the hex
        output += "\t\t// " + line.strip()

        result += output + "\n"
    return result

def preParser(lines, labels):
    """preparse the program for labels"""
    memPosition = 0
    for line_num, line in enumerate(lines, start=1):
        line = stripLine(line)
        # do nothing for empty line
        if line is None or line.isspace() or line.strip() == "":
            continue
        # jump to new location with @ followed by 4 hex numbers
        if (re.match(r'\s*@\ *([0-9a-fA-F]{4})\s*', line)):
            annotation = line.strip()
            # update the memory position to the @
            memPosition = int(annotation[1:], 16)
            continue

        # support labels. We know that comments have been removed,
        # so we just have to check for the ':' character
        if ':' in line:
            # ':' char should be in final position.
            labelSplit = line.split(':')
            # if it isn't, then we throw an error
            if (len(labelSplit) > 2) or (labelSplit[1].strip() != ''):
                raise NameError(f"The line {line_num} has a malformed label!", line_num)
            # put a correct label in our list; noting current mem location
            newLabel = labelSplit[0]
            labels[newLabel] = memPosition
            continue

def stripLine(line):
        '''Strip out comments.'''
        # We should do this first because if the comment is at the
        # beginning of the line, it will convert into whitespace that
        # we will later remove. If not, then we remove the comment
        # at the end of a line after an instruction, and the instruction is is okay.
        if '//' in line:
            return line[:line.index('//')]
        elif '#' in line:
            return line[:line.index('#')]
        return line


def parseRType(instr, operands, line_num, line):
    """Parse R-type instruction: INSTR Rdest, Rsrc"""
    if len(operands) != 2:
        print(f"Error: {instr} requires 2 operands (Rdest, Rsrc)")
        return ""
    
    Rdest = parseRegister(operands[0])
    Rsrc = parseRegister(operands[1])
    
    if Rdest is None or Rsrc is None:
        print(f"Error: Invalid register in {instr} instruction on line {line_num}:")
        print('\"' + line + '\"')
        exit()
    
    opcode = rTypeMap[instr]
    # Format: opcode 15-12 | Rdest 11-8 | opcode 7-4 | Rsrc 3-0
    opcode_high, opcode_low = opcode >> 4, opcode & 0x0F # from https://stackoverflow.com/questions/42896154/python-split-byte-into-high-low-nibbles
    instruction = (opcode_high << 12) | (Rdest << 8) | (opcode_low << 4) | Rsrc
    
    return format(instruction, '04x')

def parseIType(instr, operands, line_num, line, memPosition, labels):
    """Parse I-type instruction: INSTR Rdest, immediate"""
    if len(operands) < 2:
        print(f"Error: {instr} requires 2 operands (Rdest, imm)")
        return ""
    
    Rdest = parseRegister(operands[0])
    imm = parseImmediate(operands[1], memPosition, labels)
    
    if Rdest is None or imm is None:
        print(f"Error: Invalid register in {instr} instruction on line {line_num}:")
        print('\"' + line + '\"')
        exit()
    
    opcode = iTypeMap[instr]
    # Format: opcode 15-12 | Rdest 11-8 | Immediate 7-0
    instruction = (opcode << 12) | (Rdest << 8) | imm
    
    return format(instruction, '04x')

def parseRegister(reg_str):
    """Parse register notation like R0, R1, etc. Returns register number or None"""
    reg_str = reg_str.strip().upper().rstrip(',')
    #                                ^ handle terminal commas
    # Handle R0-R15 format
    if reg_str.startswith('R'):
        try:
            reg_num = int(reg_str[1:])
        except ValueError:
            pass
    # Handle 4-bit binary format
    elif len(reg_str) == 4 and all(c in '01' for c in reg_str):
        try:
            reg_num = int(reg_str, 2)
        except ValueError:
            pass
    # Handle 0-15 format
    else:
        try:
            reg_num = int(reg_str)
        except ValueError:
            pass
    
    if 0 <= reg_num <= 15:
        return reg_num

    return None

def parseImmediate(imm_str, memPosition, labels):
    """Parse immediate value (hex or decimal). Returns 8-bit value or None"""
    imm_str = imm_str.strip()
    
    try:
        # Handle hex format
        if imm_str.lower().startswith('0x'):
            value = int(imm_str, 16)
        # Binary format
        elif imm_str.lower().startswith('0b'):
            value = int(imm_str, 2)
        else:
            # Assume decimal
            value = int(imm_str)
        
        # Ensure it fits in 8 bits
        if 0 <= value < 256:
            return value
        else:
            print(f"Error: Immediate value {value} out of range [7:0]")
            return None
    except ValueError:
        # try to find potential label in labels dict
        if imm_str in labels:
            disp = memPosition - labels[imm_str]
            if -128 <= disp <= 127:
                #  mask to 8 bits
                return disp & 0xFF
            else:
                print('Displacement {disp} out of range [-128, 127]')
        print(f"Error: Invalid immediate value '{imm_str}'")
        return None

def openFile(path):
    """Open the file to be assembled and catch errors."""
    try:
        with open(path, 'r') as file:
            return file.read()
    except FileNotFoundError:
        print(f"Error: The file '{path}' was not found.")
        exit()
    except Exception as e:
        print(f"An error occurred: {e}")
        exit()

# Execute this file
if __name__ == "__main__":
    if len(sys.argv) > 1:
        for i, arg in enumerate(sys.argv[1:]):
            # TODO: write this out to file rather than printing
            result = assemble(openFile(arg))
            print(result)
    else:
        print("""
            ECE3710 Assembler
            INSERT HELP TEXT HERE

            Must pass an assembly file as an argument.""")
