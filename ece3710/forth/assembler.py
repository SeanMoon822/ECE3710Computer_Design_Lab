#!/usr/bin/env python3

import argparse
import dataclasses
import re

@dataclasses.dataclass
class Line:
    file: str
    line: int
    text: str

@dataclasses.dataclass
class Macro:
    line: Line
    tokens: list
    body: list

@dataclasses.dataclass
class Inst:
    line: Line
    tokens: list

@dataclasses.dataclass
class State:
    symbols: dict
    base: int = 10
    here: int = 0

@dataclasses.dataclass
class Symbol:
    value: any

@dataclasses.dataclass
class Opcode:
    line: Line
    addr: int
    opcode: int

@dataclasses.dataclass
class Error:
    line: Line
    message: str

def tokenize_line(line):
    text = line.text.split(";", 1)[0]
    tokens = []
    for match in re.finditer(r"^\w*|(-|\+)?\w+|\"(\\\"|.)*?\"|'|\S+", text):
        tokens.append(match.group(0))
    return tokens + [""]

def concatenate_tokens(tokens):
    ntokens = [tokens[0]]
    i = 1
    while i < (len(tokens) - 2):
        if tokens[i] == "'":
            ntokens[-1] += tokens[i + 1]
            i = i + 2
        else:
            ntokens.append(tokens[i])
            i = i + 1
    return ntokens + tokens[i:]

def define_macro(errors, macros, macro):
    name = macro.tokens[0]
    if not name:
        errors.append(Error(macro.line, f"macro needs a name"))
    elif name in macros:
        errors.append(Error(macro.line, f"macro '{name}' is already defined"))
    else:
        macros[name] = macro

def expand_macro(errors, line, macros, tokens):
    macro = macros[tokens[1]]
    params = macro.tokens[2:-1]
    args = tokens[2:-1]
    if len(args) != len(params):
        errors.append(Error(line, f"expected '{len(params)}' macro arguments"))
    param_map = dict(zip(params, args))
    minsts = []
    for mline in macro.body:
        mtokens = tokenize_line(mline)
        ntokens = []
        for mtoken in mtokens:
            if mtoken in param_map:
                ntokens.append(param_map[mtoken])
            else:
                ntokens.append(mtoken)
        ntokens = concatenate_tokens(ntokens)
        minsts.append(Inst(Line(line.file, line.line, mline.text), ntokens))
    return minsts

def macro_pass(errors, lines):
    macros = {}
    macro = None
    insts = []
    for line in lines:
        tokens = tokenize_line(line)
        opcode = tokens[1]
        if macro is None:
            if opcode == "MACRO":
                macro = Macro(line, tokens, [])
            elif opcode == "ENDM":
                errors.append(Error(line, f"unexpected end of macro"))
            elif opcode in macros:
                insts += expand_macro(errors, line, macros, tokens)
            else:
                insts.append(Inst(line, tokens))
        else:
            if opcode == "MACRO":
                errors.append(Error(line, f"expected end of macro"))
            elif opcode == "ENDM":
                define_macro(errors, macros, macro)
                macro = None
            else:
                macro.body.append(line)
    if macro is not None:
        errors.append(Error(macro.line, f"expected end of macro"))
    return insts

def define_symbol(errors, line, symbols, name, value):
    if name in symbols:
        errors.append(Error(line, f"symbol '{name}' is already defined"))
    else:
        symbols[name] = Symbol(value)

def set_symbol(errors, line, symbols, name, value):
    if name not in symbols:
        errors.append(Error(line, f"symbol '{name}' is not defined"))
    else:
        symbols[name] = Symbol(value)

def has_symbol(errors, inst, yes=True):
    name = inst.tokens[0]
    if yes and not name:
        errors.append(Error(inst.line, f"expected a symbol name"))
        return False
    if not yes and name:
        errors.append(Error(inst.line, f"unexpected symbol name"))
        return False
    return True

def has_arguments(errors, inst, count):
    args = inst.tokens[2:-1]
    if len(args) != count:
        errors.append(Error(inst.line, f"expected '{count}' arguments"))
        return False
    return True

def get_symbol(inst):
    name = inst.tokens[0]
    return name

def get_argument(inst, i):
    arg = inst.tokens[2+i]
    return arg

def get_integer(errors, inst, i, base=10, lower=None, upper=None):
    arg = get_argument(inst, i)
    try:
        integer = int(arg, base=base)
    except ValueError:
        errors.append(Error(inst.line, f"expected '{arg}' to be an integer"))
        return
    if lower is not None and integer < lower:
        errors.append(Error(inst.line, f"integer out of range"))
        return
    if upper is not None and integer > upper:
        errors.append(Error(inst.line, f"integer out of range"))
        return
    return integer

def do_nothing(errors, state, inst, entry):
    return

def set_base(errors, state, inst, entry):
    if not has_symbol(errors, inst, False):
        return
    if not has_arguments(errors, inst, 1):
        return
    base = get_integer(errors, inst, 0, base=10, lower=2, upper=36)
    if base is not None:
        state.base = base

def set_here(errors, state, inst, entry):
    if not has_symbol(errors, inst, False):
        return
    if not has_arguments(errors, inst, 1):
        return
    here = get_integer(errors, inst, 0, base=state.base, lower=0, upper=65535)
    if here is not None:
        state.here = here

def define_variable(errors, state, inst, entry):
    if not has_symbol(errors, inst):
        return
    if not has_arguments(errors, inst, 1):
        return
    name = get_symbol(inst)
    value = get_argument(inst, 0)
    define_symbol(errors, inst.line, state.symbols, name, value)

def set_variable(errors, state, inst, entry):
    if not has_symbol(errors, inst):
        return
    if not has_arguments(errors, inst, 1):
        return
    name = get_symbol(inst)
    value = get_argument(inst, 0)
    set_symbol(errors, inst.line, state.symbols, name, value)

def define_label(errors, state, inst, entry):
    if not has_arguments(errors, inst, 0):
        return
    name = get_symbol(inst)
    if not name:
        return
    define_symbol(errors, inst.line, state.symbols, name, state.here)

def advance_word(errors, state, inst, entry):
    name = get_symbol(inst)
    if name:
        define_symbol(errors, inst.line, state.symbols, name, state.here)
    state.here = state.here + 1

def advance_dword(errors, state, inst, entry):
    name = get_symbol(inst)
    if name:
        define_symbol(errors, inst.line, state.eymbols, name, state.here)
    state.here = state.here + 2

def get_string(errors, state, inst, i):
    arg = get_argument(inst, i)
    if arg[0] != "\"" and arg[-1] != "\"":
        errors.append(Error(inst.line, f"expected a string"))
        string = ""
    else:
        string = arg[1:-1].replace("\\\"", "\"")
    return string

def advance_string(errors, state, inst, entry):
    if not has_arguments(errors, inst, 1):
        return
    name = get_symbol(inst)
    if name:
        define_symbol(errors, inst.line, state.symbols, name, state.here)
    string = get_string(errors, state, inst, 0)
    state.here = state.here + int((2+len(string))/2)

def get_value(symbols, value):
    while value in symbols:
        value = symbols[value].value
    return value

def get_register(errors, state, inst, i):
    arg = get_argument(inst, i)
    value = get_value(state.symbols, arg)
    match = re.match(r"R([0-9]|10|[1-9][1-5])$", value)
    if match is not None:
        reg = int(match.group(1))
    else:
        errors.append(Error(inst.line, f"expected a register"))
        reg = 0
    return reg

def get_immediate(errors, state, inst, i, lower=None, upper=None, relative=False):
    arg = get_argument(inst, i)
    value = get_value(state.symbols, arg)
    if type(value) is str:
        try:
            imm = int(value, base=state.base)
        except ValueError:
            errors.append(Error(inst.line, f"expected an immediate"))
            imm = 0
    else:
        imm = int(value)
    if relative:
        imm = imm - state.here
    if lower is not None and imm < lower:
        errors.append(Error(inst.line, f"immediate out of range"))
    if upper is not None and imm > upper:
        errors.append(Error(inst.line, f"immediate out of range"))
    return imm

def emit_opcode(state, inst, opcode):
    here = state.here
    state.here = state.here + 1
    return Opcode(inst.line, here, opcode)

def encode_word(errors, state, inst, entry):
    if not has_arguments(errors, inst, 1):
        return
    word = get_immediate(errors, state, inst, 0, lower=-32768, upper=65535)
    return [emit_opcode(state, inst, word&0xffff)]

def encode_string(errors, state, inst, entry):
    if not has_arguments(errors, inst, 1):
        return
    string = get_string(errors, state, inst, 0)
    if len(string) > 255:
        errors.append(Error(inst.line, f"string is too long"))
        string = string[0:255]
    chars = [len(string)] + [ord(c) for c in string] + [0]
    opcodes = []
    while len(chars) > 1:
        opcodes.append(emit_opcode(state, inst, (chars[0]&0xff)<<8 | (chars[1]&0xff)))
        chars = chars[2:]
    return opcodes

def encode_movi(errors, state, inst, entry):
    if not has_arguments(errors, inst, 2):
        return
    dst = get_register(errors, state, inst, 0)
    imm = get_immediate(errors, state, inst, 1, lower=-32768, upper=65535)
    return [
        emit_opcode(state, inst, 0xd<<12 | dst<<8 | (imm>>0)&0xff),
        emit_opcode(state, inst, 0xf<<12 | dst<<8 | (imm>>8)&0xff),
        ]

def encode_inherent(errors, state, inst, entry):
    if not has_arguments(errors, inst, 0):
        return
    return [emit_opcode(state, inst, entry["opcode"])]

def encode_register(errors, state, inst, entry):
    if not has_arguments(errors, inst, 2):
        return
    dst = get_register(errors, state, inst, 0)
    b = get_register(errors, state, inst, 1)
    opcode = entry["opcode"]
    return [emit_opcode(state, inst, 0x0<<12 | dst<<8 | opcode<<4 | b)]

def encode_immediate(errors, state, inst, entry):
    if not has_arguments(errors, inst, 2):
        return
    dst = get_register(errors, state, inst, 0)
    imm = get_immediate(errors, state, inst, 1, lower=-128, upper=255)
    opcode = entry["opcode"]
    return [emit_opcode(state, inst, opcode<<12 | dst<<8 | imm&0xff)]

def encode_shift(errors, state, inst, entry):
    if not has_arguments(errors, inst, 2):
        return
    dst = get_register(errors, state, inst, 0)
    imm = get_immediate(errors, state, inst, 1, lower=0, upper=15)
    opcode = entry["opcode"]
    return [emit_opcode(state, inst, 0x8<<12 | dst<<8 | opcode<<4 | imm&0xf)]

def encode_load_store(errors, state, inst, entry):
    if not has_arguments(errors, inst, 2):
        return
    reg = get_register(errors, state, inst, 0)
    addr = get_register(errors, state, inst, 1)
    opcode = entry["opcode"]
    return [emit_opcode(state, inst, 0x4<<12 | reg<<8 | opcode<<4 | addr)]

def encode_scond(errors, state, inst, entry):
    if not has_arguments(errors, inst, 1):
        return
    dst = get_register(errors, state, inst, 0)
    opcode = entry["opcode"]
    return [emit_opcode(state, inst, 0x4<<12 | dst<<8 | 0xd<<4 | opcode)]

def encode_bcond(errors, state, inst, entry):
    if not has_arguments(errors, inst, 1):
        return
    disp = get_immediate(errors, state, inst, 0, lower=-128, upper=255, relative=True)
    opcode = entry["opcode"]
    return [emit_opcode(state, inst, 0xc<<12 | opcode<<8 | disp&0xff)]

def encode_jcond(errors, state, inst, entry):
    if not has_arguments(errors, inst, 1):
        return
    addr = get_register(errors, state, inst, 0)
    opcode = entry["opcode"]
    return [emit_opcode(state, inst, 0x4<<12 | opcode<<8 | 0xc<<4 | addr)]

inherent_opcodes = [
    ("WAIT", 0x0000),
    ]

register_opcodes = [
    ("ADD", 0b0101),
    ("ADDC", 0b0111),
    ("SUB", 0b1001),
    ("CMP", 0b1011),
    ("AND", 0b0001),
    ("OR", 0b0010),
    ("XOR", 0b0011),
    ("MOV", 0b1101),
    ]

immediate_opcodes = [
    ("ADDI", 0b0101),
    ("ADDCI", 0b0111),
    ("SUBI", 0b1001),
    ("CMPI", 0b1011),
    ("ANDI", 0b0001),
    ("ORI", 0b0010),
    ("XORI", 0b0011),
    ("MOVZI", 0b1101),
    ("MOVSI", 0b1110),
    ("MOVUI", 0b1111),
    ]

shift_opcodes = [
    ("LSHLI", 0b0000),
    ("LSHRI", 0b0001),
    ("ASHLI", 0b0010),
    ("ASHRI", 0b0011),
    ]

load_store_opcodes = [
    ("LOAD", 0b0000),
    ("LOADD", 0b0010),
    ("LOADI", 0b0011),
    ("STOR", 0b0100),
    ("STORD", 0b0110),
    ("STORI", 0b0111),
    ("JAL", 0b1000),
    ]

cond_opcodes = [
    ("EQ", 0b0000),
    ("NE", 0b0001),
    ("CS", 0b0010),
    ("CC", 0b0011),
    ("HI", 0b0100),
    ("LS", 0b0101),
    ("GT", 0b0110),
    ("LE", 0b0111),
    ("FS", 0b1000),
    ("FC", 0b1001),
    ("LO", 0b1010),
    ("HS", 0b1011),
    ("LT", 0b1100),
    ("GE", 0b1101),
    ("UC", 0b1110),
    ]

inst_table = {

    # Directives
    "BASE": {
        "symbol": set_base,
        "encode": set_base,
        },
    "HERE": {
        "symbol": set_here,
        "encode": set_here,
        },
    "EQU": {
        "symbol": define_variable,
        "encode": do_nothing,
        },
    "SET": {
        "symbol": do_nothing,
        "encode": set_variable,
        },
    "WORD": {
        "symbol": advance_word,
        "encode": encode_word,
        },
    "STRING": {
        "symbol": advance_string,
        "encode": encode_string,
        },

    # Pseudo opcodes
    "": {
        "symbol": define_label,
        "encode": do_nothing,
        },
    "MOVI": {
        "symbol": advance_dword,
        "encode": encode_movi,
        },

    # Opcodes
    } | { name: {
        "symbol": advance_word,
        "encode": encode_inherent,
        "opcode": opcode,
        } for (name, opcode) in inherent_opcodes
    } | { name: {
        "symbol": advance_word,
        "encode": encode_register,
        "opcode": opcode,
        } for (name, opcode) in register_opcodes
    } | { name: {
        "symbol": advance_word,
        "encode": encode_immediate,
        "opcode": opcode,
        } for (name, opcode) in immediate_opcodes
    } | { name: {
        "symbol": advance_word,
        "encode": encode_shift,
        "opcode": opcode,
        } for (name, opcode) in shift_opcodes
    } | { name: {
        "symbol": advance_word,
        "encode": encode_load_store,
        "opcode": opcode,
        } for (name, opcode) in load_store_opcodes
    } | { f"S{cond}": {
        "symbol": advance_word,
        "encode": encode_scond,
        "opcode": opcode,
        } for (cond, opcode) in cond_opcodes
    } | { f"B{cond}": {
        "symbol": advance_word,
        "encode": encode_bcond,
        "opcode": opcode,
        } for (cond, opcode) in cond_opcodes
    } | { f"J{cond}": {
        "symbol": advance_word,
        "encode": encode_jcond,
        "opcode": opcode,
        } for (cond, opcode) in cond_opcodes
    }

def symbol_pass(errors, insts):
    symbols = {}
    state = State(symbols)
    for inst in insts:
        opcode = inst.tokens[1]
        if opcode in inst_table:
            entry = inst_table[opcode]
            entry["symbol"](errors, state, inst, entry)
    return symbols

def encode_pass(errors, insts, symbols):
    opcodes = []
    state = State(symbols)
    for inst in insts:
        opcode = inst.tokens[1]
        if opcode in inst_table:
            entry = inst_table[opcode]
            ops = entry["encode"](errors, state, inst, entry)
            if ops is not None:
                opcodes += ops
        else:
            errors.append(Error(inst.line, f"unknown opcode"))
    return opcodes

def assemble_lines(lines):
    errors = []
    insts = macro_pass(errors, lines)
    symbols = symbol_pass(errors, insts)
    opcodes = encode_pass(errors, insts, symbols)
    return errors, opcodes

def print_error(error):
    if error.line is None:
        message = error.message.rstrip()
        print(f"ERROR: {message}")
    else:
        message = error.message.rstrip()
        text = error.line.text.rstrip()
        print(f"ERROR:{error.line.file}:{error.line.line}: {message}")
        print(f"{text}")

def print_errors(errors):
    for error in errors:
        print_error(error)

def read_asmfile(file):
    try:
        lines = []
        with open(file, mode="r") as asmfile:
            for line, text in enumerate(asmfile.readlines(), start=1):
                lines.append(Line(file, line, text))
    except Exception:
        lines = []
        print_error(Error(None, f"could not read file '{file}'"))
    return lines

def write_hexfile(opcodes, file):
    lines = []
    addr = None
    for opcode in opcodes:
        if opcode.addr != addr:
            lines.append(f"@{opcode.addr:04x}\n")
            addr = opcode.addr
        text = opcode.line.text.rstrip()
        lines.append(f"{opcode.opcode:04x} // {opcode.addr:04x}: {text}\n")
        addr = addr + 1
    try:
        with open(file, mode="w") as hexfile:
            hexfile.writelines(lines)
    except Exception:
        print_error(Error(None, f"could not write file '{file}'"))

def main():
    argparser = argparse.ArgumentParser()
    argparser.add_argument("asmfile")
    argparser.add_argument("hexfile")
    args = argparser.parse_args()
    lines = read_asmfile(args.asmfile)
    errors, opcodes = assemble_lines(lines)
    if not errors and opcodes:
        write_hexfile(opcodes, args.hexfile)
    print_errors(errors)

if __name__ == "__main__":
    main()
