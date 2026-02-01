## ECE3710 – Computer Design Lab
### Group Project: RISC-Style CPU with Forth Interpreter (Luke Stillings, Byron Stewart, Sean Moon, Matthew Lee)

### Overview

This repository contains the group project for ECE3710: Computer Design Lab.
In this project, we designed and implemented a custom RISC-style CPU from scratch and demonstrated its correctness by running a Forth interpreter on the system.

The project emphasizes full-system computer design, combining processor architecture, digital logic, memory systems, and hardware–software integration.

### Project Description

Our group designed a RISC-style processor and supporting hardware components, then built a Forth interpreter to run on top of the CPU. Forth was chosen because its stack-based execution model maps naturally to low-level hardware and provides a meaningful way to validate processor functionality beyond isolated instruction tests.

The final system executes Forth programs and supports interactive input/output, demonstrating a working computer system rather than a standalone CPU core.

### Key Features

Custom RISC-style CPU architecture

Datapath and control unit designed at the register-transfer level

Hardware support for:

Data stack

Return stack

Instruction execution including arithmetic, memory access, and control flow

Forth interpreter running on the custom CPU

Memory-mapped I/O for interaction and debugging

### Project Objectives

Design and implement a RISC-style CPU from the ground up

Integrate CPU, memory, stacks, and I/O into a complete system

Support stack-based execution required by a Forth interpreter

Verify correct operation through simulation and FPGA deployment



### License

This project is for educational purposes only and is not intended for commercial use.
