| Mnemonic  | Operands      | 15-12 | 11-8  | 7-4   | 3-0   | Notes |
| --------- | ------------- | ----- | ----- | ----- | ----- | ----- |
| ADD       | Rdst Rb       | 0000  | dst   | 0101  | b     | |
| ADDI      | Rdst imm      | 0101  | dst   | imm   | imm   | imm sign-extended |
| ADDC      | Rdst Rb       | 0000  | dst   | 0111  | b     | |
| ADDCI     | Rdst imm      | 0111  | dst   | imm   | imm   | imm sign-extended |
| SUB       | Rdst Rb       | 0000  | dst   | 1001  | b     | |
| SUBI      | Rdst imm      | 1001  | dst   | imm   | imm   | imm sign-extended |
| CMP       | Ra Rb         | 0000  | a     | 1011  | b     | |
| CMPI      | Ra imm        | 1011  | a     | imm   | imm   | imm sign-extended |
| AND       | Rdst Rb       | 0000  | dst   | 0001  | b     | |
| ANDI      | Rdst imm      | 0001  | dst   | imm   | imm   | imm zero-extended |
| OR        | Rdst Rb       | 0000  | dst   | 0010  | b     | |
| ORI       | Rdst imm      | 0010  | dst   | imm   | imm   | imm zero-extended |
| XOR       | Rdst Rb       | 0000  | dst   | 0011  | b     | |
| XORI      | Rdst imm      | 0011  | dst   | imm   | imm   | imm zero-extended |
| MOV       | Rdst Rsrc     | 0000  | dst   | 1101  | src   | |
| MOVZI     | Rdst imm      | 1101  | dst   | imm   | imm   | imm zero-extended |
| MOVSI     | Rdst imm      | 1110  | dst   | imm   | imm   | imm sign-extended |
| MOVUI     | Rdst imm      | 1111  | dst   | imm   | imm   | |
| LSHLI     | Rdst imm      | 1000  | dst   | 0000  | imm   | |
| LSHRI     | Rdst imm      | 1000  | dst   | 0001  | imm   | |
| ASHLI     | Rdst imm      | 1000  | dst   | 0010  | imm   | |
| ASHRI     | Rdst imm      | 1000  | dst   | 0011  | imm   | |
| LOAD      | Rdst Raddr    | 0100  | dst   | 0000  | addr  | |
| LOADD     | Rdst Raddr    | 0100  | dst   | 0010  | addr  | Raddr pre decremented |
| LOADI     | Rdst Raddr    | 0100  | dst   | 0011  | addr  | Raddr post incremented |
| STOR      | Rsrc Raddr    | 0100  | src   | 0100  | addr  | |
| STORD     | Rsrc Raddr    | 0100  | src   | 0110  | addr  | Raddr pre decremented |
| STORI     | Rsrc Raddr    | 0100  | src   | 0111  | addr  | Raddr post incremented |
| Scond     | Rdst          | 0100  | dst   | 1101  | cond  | |
| Bcond     | disp          | 1100  | cond  | disp  | disp  | disp sign-extended |
| Jcond     | Raddr         | 0100  | cond  | 1100  | addr  | |
| JAL       | Rdst Raddr    | 0100  | dst   | 1000  | addr  | |
| WAIT      |               | 0000  | 0000  | 0000  | 0000  | |

| Mnemonic  | 3-0   | Description               | Flags |
| --------- | ----- | ------------------------- | ----- |
| EQ        | 0000  | equal                     | Z=1 |
| NE        | 0001  | not equal                 | Z=0 |
| CS        | 0010  | carry set                 | C=1 |
| CC        | 0011  | carry clear               | C=0 |
| HI        | 0100  | higher than               | L=0 |
| LS        | 0101  | lower than or same as     | L=1 or Z=1 |
| GT        | 0110  | greater than              | N=0 |
| LE        | 0111  | less than or equal        | N=1 or Z=1 |
| FS        | 1000  | flag set                  | F=1 |
| FC        | 1001  | flag clear                | F=0 |
| LO        | 1010  | lower than                | L=1 |
| HS        | 1011  | higher than or same as    | L=0 or Z=1 |
| LT        | 1100  | less than                 | N=1 |
| GE        | 1101  | greater than or equal     | N=0 or Z=1 |
| UC        | 1110  | unconditional             | |
|           | 1111  | never                     | |
