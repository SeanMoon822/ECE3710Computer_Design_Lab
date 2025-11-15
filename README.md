# Computer Design Lab: CPU Implementation

This project implements a single-cycle 16-bit RISC CPU in Verilog. The CPU supports arithmetic/logic operations, load/store instructions, conditional branches, and jumps. All modules are fully synthesizable and verified with ModelSim testbenches.

## Features
  * 16-bit datapath
  * 16 general-purpose registers
  * ALU supporting ADD, SUB, AND, OR, XOR, NOT, SHL, SHR, PASS, CMP
  * Condition flags (Z, N, C, V) and branch condition checking
  * Single-cycle instruction execution
  * Load and store with 8-bit immediate offsets
  * Program counter with branch/jump target logic
  * Hex-file program loading for simulation and FPGA
## Key Modules
  * datapath.v – connects PC, ALU, regfile, memory, branch/jump logic
  * decode.v – extracts opcode, registers, immediates
  * control.v – generates control signals for each instruction type
  * alu.v + alu_flags.v – executes ALU ops and sets flags
  * condcheck.v – evaluates conditional branch logic
  * regfile.v – 16×16 register file
  * datapath_test.v – testbench for R-type, load/store, and branch/jump programs
## Testing
  Programs are loaded via:
  * datapath_rtype.hex
  * datapath_loadstore.hex
  * datapath_branchjump.hex
Run simulation with:
  
        vsim datapath_test
        run -all

## Authors
- Luke Stillings
- Byron Stewart
- Sean Moon
- Matthew Lee
