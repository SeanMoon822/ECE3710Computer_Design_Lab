@ 0000
ADD R0 R1        // R-type: Add R1 to R0
SUB 2 R3         // R-type: Subtract R3 from R2 (implicit reg name of R2)
ADDI R4 0xFF     // I-type: Add 255 to R4
XORI R5 0b1010   // I-type: XOR with binary 10
SUBI R6 69       // I-type: SUB with decimal 10
WAIT             // Wait (no args)
WAIT R2 R5       // Wait
MOV R7 R8        // R-type: Move R8 to R7
@ 00F0
    ADDI R2 13        // R-type: Add 13 to R2
Loop:                // an annotation for a loop
    ADD R2 R1        // R-type: Add R1 to R0
    JUMP 5 R1        // R-type: Jump to R1 if condition '5' is met
    JUMP 0101 R1     // ^ should result in same instruction
Bcond 5 Loop