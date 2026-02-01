    ; ==========================================================================
    ; INTERPRETER CONSTANTS

                    BASE 16
WP0                 EQU 2000            ; working stack start (grows up)
RP0                 EQU 3000            ; return stack start (grows down)
VGA0                EQU 3000            ; VGA start
TIB0                EQU 3C00            ; TIB start
OUTREG0             EQU 4000            ; output register 0
OUTREG1             EQU 4001            ; output register 1
KEYREG              EQU 4002            ; key register
CURSOR              EQU 4003            ; cursor register address

    ; ==========================================================================
    ; INTERPRETER REGISTERS

F0                  EQU R6              ; FPU register 0
F1                  EQU R7              ; FPU register 1

EP                  EQU R8              ; execution pointer
RW                  EQU R9              ; working register
RX                  EQU R10             ; working register
RY                  EQU R11             ; working register
RZ                  EQU R12             ; working register
WP                  EQU R13             ; working stack pointer (grows up)
WT                  EQU R14             ; working stack top
RP                  EQU R15             ; return stack pointer (grows down)

    ; ==========================================================================
    ; DICTIONARY MACROS

LASTWORD EQU 0                      ; Last word defined in the dictionary.

DEFCODE MACRO SYM STR               ; Define and assemble a code word.
SYM'S STRING STR                        ; name string
    WORD SYM'S                          ; name pointer
SYM'N WORD LASTWORD                     ; link pointer
LASTWORD SET SYM'N
SYM WORD SYM'C                          ; code pointer
SYM'C                                   ; code start
    ENDM

DEFWORD MACRO SYM STR               ; Define and assemble a normal word.
SYM'S STRING STR                        ; name string
    WORD SYM'S                          ; name pointer
SYM'N WORD LASTWORD                     ; link pointer
LASTWORD SET SYM'N
SYM WORD DOENTER                        ; code pointer
SYM'B                                   ; body start
    ENDM

DEFVAR MACRO SYM STR VAL            ; Define and assemble a variable word.
SYM'S STRING STR                        ; name string
    WORD SYM'S                          ; name pointer
SYM'N WORD LASTWORD                     ; link pointer
LASTWORD SET SYM'N
SYM WORD DOVAR                          ; code pointer
    WORD VAL                            ; value
    ENDM

DEFCONST MACRO SYM STR VAL          ; Define and assemble a constant word.
SYM'S STRING STR                        ; name string
    WORD SYM'S                          ; name pointer
SYM'N WORD LASTWORD                     ; link pointer
LASTWORD SET SYM'N
SYM WORD DOCONST                        ; code pointer
    WORD VAL                            ; value
    ENDM

    ; ==========================================================================
    ; INTERPRETER MACROS

PUSHWS MACRO SRC                    ; Push a word onto the working stack.
    STORI SRC WP                        ; store word and increment pointer
    ENDM

POPWS MACRO DST                     ; Pop a word off of the working stack.
    LOADD DST WP                        ; decrement pointer and load word
    ENDM

PUSHRS MACRO SRC                    ; Push a word onto the return stack.
    STORD SRC RP                        ; decrement pointer and store word
    ENDM

POPRS MACRO DST                     ; Pop a word off of the return stack.
    LOADI DST RP                        ; load word and increment pointer
    ENDM

NEXT MACRO                          ; Execute the next word.
    LOADI RW EP                         ; load word address
    LOADI RX RW                         ; load code address
    JUC RX                              ; jump into word code routine
    ENDM

    ; ==========================================================================
    ; ENTRY POINT

    BASE 16
    HERE 0000

ENTRY
    MOVI WP WP0                         ; setup working stack
    MOVI RP RP0                         ; setup return stack
    MOVI EP START                       ; point execution to first word
    NEXT
START
    WORD RESTART

    ; ==========================================================================
    ; WORD CODE ROUTINES

DOENTER                             ; Execute a normal word.
    PUSHRS EP                           ; save execution pointer
    MOV EP RW                           ; point execution to word body
    NEXT

DOVAR                               ; Execute a variable word.
    PUSHWS WT                           ; push stack top
    MOV WT RW                           ; put variable address into stack top
    NEXT

DOCONST                             ; Execute a constant word.
    PUSHWS WT                           ; push stack top
    LOAD WT RW                          ; load constant value into stack top
    NEXT

    ; ==========================================================================
    ; CONSTANT WORDS

    DEFCONST WP0_ "WP0" WP0
    DEFCONST RP0_ "RP0" RP0
    DEFCONST VGA "VGA" VGA0
    DEFCONST TIB "TIB" TIB0
    DEFCONST OUTREG0_ "OUTREG0" OUTREG0
    DEFCONST OUTREG1_ "OUTREG1" OUTREG1
    DEFCONST KEYREG_ "KEYREG" KEYREG
    DEFCONST CURSOR_ "CURSOR" CURSOR

    ; ==========================================================================
    ; VARIABLE WORDS

    BASE 10
    DEFVAR BASE_ "BASE" 10              ; current numeric base
    DEFVAR HERE_ "HERE" QUITEND         ; current dictionary pointer
    DEFVAR LAST "LAST" QUITN            ; last dictionary word
    DEFVAR HLD "HLD" 0                  ; current output string pointer
    DEFVAR PIN ">IN" 0                  ; pointer to current input character
    DEFVAR NUMTIB "#TIB" 0              ; terminal input buffer characters
    DEFVAR PVGA ">VGA" 0                ; current VGA character offset

    ; ==========================================================================
    ; INPUT/OUTPUT WORDS

    BASE 16
    DEFCONST BS "BS" 08                 ; ASCII backspace
    DEFCONST LF "LF" 0A                 ; ASCII line feed
    DEFCONST CR "CR" 0D                 ; ASCII carriage return
    DEFCONST SP "SP" 20                 ; ASCII space

; ?KEY ( -- c T | 0 )
    DEFWORD QKEY "?KEY"             ; Check for a valid key input.
    WORD KEYREG_
    WORD FETCH                          ; read register
    WORD DUP
    WORD ZBRANCH                        ; if zero exit
    WORD QKEY0
    WORD NONE                           ; else push true flag
QKEY0
    WORD EXIT

; KEY ( -- c )
    DEFWORD KEY "KEY"               ; Get the next valid key input.
KEY0
    WORD QKEY                           ; check key
    WORD ZBRANCH                        ; if zero try again
    WORD KEY0
    WORD EXIT

; SCROLL ( -- )
    DEFWORD SCROLL "SCROLL"         ; Scroll the output by one line.
    BASE 10
    WORD VGA
    WORD ATOCA
    WORD DUP
    WORD LITERAL
    WORD 80
    WORD ADD_                           ; start at second line
    WORD SWAP
    WORD LITERAL
    WORD 4720                           ; move 80x59 characters
    WORD CMOVE
    WORD SWAP
    WORD DROP                           ; keep source pointer
    WORD LITERAL
    WORD 80                             ; fill 80 characters
    WORD SP                             ; with spaces
    WORD FILL
    WORD LITERAL
    WORD -80
    WORD PVGA
    WORD ADDSTORE                       ; move position up one line
    WORD EXIT

; EMIT ( c -- )
    DEFWORD EMIT "EMIT"             ; Output a character.
    BASE 10
    WORD DUP
    WORD BS
    WORD EQUAL
    WORD ZBRANCH                        ; if backspace
    WORD EMIT0
    WORD DROP
    WORD NONE
    WORD PVGA
    WORD ADDSTORE                       ; then move to previous character
    WORD BRANCH
    WORD EMIT3
EMIT0
    WORD DUP
    WORD LF
    WORD EQUAL
    WORD ZBRANCH                        ; if line feed
    WORD EMIT1
    WORD DROP
    WORD LITERAL
    WORD 80
    WORD PVGA
    WORD ADDSTORE                       ; then move to next line
    WORD BRANCH
    WORD EMIT3
EMIT1
    WORD DUP
    WORD CR
    WORD EQUAL
    WORD ZBRANCH                        ; if character is carriage return
    WORD EMIT2
    WORD DROP
    WORD PVGA
    WORD FETCH
    WORD DUP
    WORD LITERAL
    WORD 80                             ; then divide by screen width
    WORD DIVMOD
    WORD DROP
    WORD SUB_                           ; and subtract remainder
    WORD PVGA
    WORD STORE
    WORD BRANCH
    WORD EMIT3
EMIT2
    WORD VGA
    WORD ATOCA
    WORD PVGA
    WORD FETCH
    WORD ADD_
    WORD CSTORE                         ; otherwise output character
    WORD ONE
    WORD PVGA
    WORD ADDSTORE                       ; and increment position
EMIT3
    WORD PVGA
    WORD FETCH
    WORD ZLESS
    WORD ZBRANCH                        ; if position is less than zero
    WORD EMIT4
    WORD ZERO
    WORD PVGA
    WORD STORE                          ; then keep it at zero
EMIT4
    WORD PVGA
    WORD FETCH
    WORD LITERAL
    WORD 4800
    WORD EQUAL
    WORD ZBRANCH                        ; if position went off the bottom
    WORD EMIT5
    WORD SCROLL                         ; then scroll the output
EMIT5
    WORD PVGA
    WORD FETCH                          ; get current PVGA
    WORD CURSOR_
    WORD STORE                          ; store into cursor register
    WORD EXIT

; PAGE ( -- )
    DEFWORD PAGE "PAGE"             ; Clear the output.
    BASE 10
    WORD VGA
    WORD ATOCA
    WORD LITERAL
    WORD 4800                           ; 80x60 characters
    WORD SP
    WORD FILL                           ; fill with spaces
    WORD ZERO
    WORD PVGA
    WORD STORE                          ; reset VGA location
    WORD EXIT

; LINE ( -- )
    DEFWORD LINE "LINE"             ; Move to next line.
    WORD CR
    WORD EMIT                           ; output carriage return
    WORD LF
    WORD EMIT                           ; output line feed
    WORD EXIT

; SPACE ( -- )
    DEFWORD SPACE "SPACE"           ; Output a space.
    WORD SP
    WORD EMIT                           ; output space
    WORD EXIT

; SPACES ( n -- )
    DEFWORD SPACES_ "SPACES"        ; Output n spaces.
    WORD RPUSH                          ; setup loop counter
    WORD BRANCH
    WORD SPACES_1
SPACES_0
    WORD SPACE                          ; output space
SPACES_1
    WORD LNEXT
    WORD SPACES_0
    WORD EXIT

; COUNT ( a -- ca l )
    DEFWORD COUNT "COUNT"           ; Convert string address to start length.
    WORD ATOCA                          ; get character address
    WORD DUP
    WORD ONEADD                         ; get first character pointer
    WORD SWAP
    WORD CFETCH                         ; get string length
    WORD EXIT

; CMOVE ( sa da l -- sa da )
    DEFWORD CMOVE "CMOVE"           ; Move l characters.
    WORD RPUSH
    WORD BRANCH
    WORD CMOVE1
CMOVE0
    WORD OVER
    WORD CFETCH                         ; read source
    WORD OVER
    WORD CSTORE                         ; write destination
    WORD ONEADD                         ; increment destination
    WORD SWAP
    WORD ONEADD                         ; increment source
    WORD SWAP
CMOVE1
    WORD LNEXT
    WORD CMOVE0
    WORD EXIT

; FILL ( ca l c -- )
    DEFWORD FILL "FILL"             ; Fill memory region with character.
    WORD SWAP
    WORD RPUSH                          ; setup loop counter
    WORD SWAP
    WORD BRANCH
    WORD FILL1
FILL0
    WORD DDUP
    WORD CSTORE                         ; store character
    WORD ONEADD                         ; increment pointer
FILL1
    WORD LNEXT
    WORD FILL0
    WORD DDROP
    WORD EXIT

; PACKS ( ca l a -- a )
    DEFWORD PACKS "PACKS"           ; Store a string at an address.
    WORD DUP
    WORD RPUSH                          ; save start address
    WORD ATOCA
    WORD OVER
    WORD OVER
    WORD CSTORE                         ; store length
    WORD ONEADD                         ; increment destination
    WORD SWAP
    WORD CMOVE
    WORD DUP
    WORD ONE
    WORD AND_
    WORD ZBRANCH                        ; if odd destination address
    WORD PACKS0
    WORD ZERO
    WORD OVER
    WORD CSTORE                         ; then fill with zero
PACKS0
    WORD DDROP
    WORD RPOP                           ; restore start address
    WORD EXIT

; TYPE ( ca l -- )
    DEFWORD TYPE "TYPE"             ; Output a string.
    WORD RPUSH                          ; setup loop counter
    WORD BRANCH                         ; check condition first
    WORD TYPE1
TYPE0
    WORD DUP
    WORD CFETCH                         ; get character
    WORD EMIT                           ; output character
    WORD ONEADD                         ; next character
TYPE1
    WORD LNEXT
    WORD TYPE0
    WORD DROP
    WORD EXIT

; >CHAR ( c -- c )
    DEFWORD TOCHAR ">CHAR"          ; Convert to printable character.
    BASE 16
    WORD LITERAL
    WORD 7F
    WORD AND_                           ; clear MSB
    WORD DUP
    WORD LITERAL
    WORD 7F
    WORD SP
    WORD WITHIN                         ; check if printable
    WORD ZBRANCH
    WORD TOCHAR0
    WORD DROP                           ; if not printable
    WORD LITERAL
    WORD 2E                             ; then use ASCII '.'
TOCHAR0
    WORD EXIT

; DTYPE ( ca l -- )
    DEFWORD DTYPE ".TYPE"           ; TYPE with non-printable characters.
    WORD RPUSH                          ; setup loop counter
    WORD BRANCH
    WORD DTYPE1
DTYPE0
    WORD DUP
    WORD CFETCH                         ; get character
    WORD TOCHAR                         ; make printable
    WORD EMIT                           ; output character
    WORD ONEADD                         ; next character
DTYPE1
    WORD LNEXT
    WORD DTYPE0
    WORD DROP
    WORD EXIT

    ; ==========================================================================
    ; INTERPRETER WORDS

; EXIT ( -- )
    DEFCODE EXIT "EXIT"             ; Return from the current word.
    POPRS EP                            ; restore execution pointer
    NEXT

; EXECUTE ( a -- )
    DEFCODE EXECUTE "EXECUTE"       ; Execute the word at an address.
    MOV RW WT                           ; get word address
    POPWS WT                            ; pop into stack top
    LOADI RX RW                         ; load code address
    JUC RX                              ; jump into word code routine

; LITERAL ( -- w )
    DEFCODE LITERAL "LITERAL"       ; Push an inline literal onto the stack.
    PUSHWS WT                           ; push stack top
    LOADI WT EP                         ; put inline literal into stack top
    NEXT

; BRANCH ( -- )
    DEFCODE BRANCH "BRANCH"         ; Branch to an inline address.
BRANCH0
    LOAD EP EP                          ; point execution to inline address
    NEXT

; 0BRANCH ( f -- )
    DEFCODE ZBRANCH "0BRANCH"       ; Branch to an inline address if zero.
    CMP WT R0                           ; compare with zero
    POPWS WT                            ; pop into stack top
    BEQ BRANCH0                         ; if zero branch
    ADDI EP 1                           ; else skip over inline address
    NEXT

; NEXT ( -- )
    DEFCODE LNEXT "NEXT"            ; Decrement loop index and exit if negative.
    POPRS RW                            ; pop loop index
    SUBI RW 1                           ; decrement loop index
    PUSHRS RW                           ; push loop index
    BGE BRANCH0                         ; if not negative branch
    POPRS RW                            ; else pop loop index
    ADDI EP 1                           ; and skip over inline address
    NEXT

    ; ==========================================================================
    ; WORKING STACK WORDS

; WP@ ( -- a )
    DEFCODE WPFETCH "WP@"           ; Get the working stack pointer.
    PUSHWS WT                           ; push stack top
    MOV WT WP                           ; put pointer into stack top
    NEXT

; WP! ( a -- )
    DEFCODE WPSTORE "WP!"           ; Set the working stack pointer.
    MOV WP WT                           ; set pointer
    POPWS WT                            ; pop stack top
    NEXT

; DEPTH ( -- w )
    DEFWORD DEPTH "DEPTH"           ; Get the number of items on the stack.
    WORD WPFETCH                        ; get pointer
    WORD WP0_                           ; get start
    WORD SUB_                           ; get the difference
    WORD EXIT

; PICK ( i -- w )
    DEFWORD PICK "PICK"             ; Get the ith word on the stack.
    WORD WPFETCH                        ; get pointer
    WORD ONESUB                         ; skip over index
    WORD ONESUB
    WORD SWAP
    WORD SUB_                           ; subtract index
    WORD FETCH                          ; get word
    WORD EXIT

; DROP ( w1 -- )
    DEFCODE DROP "DROP"             ; Discard the top stack word.
    POPWS WT                            ; pop into stack top
    NEXT

; 2DROP ( w2 w1 -- )
    DEFCODE DDROP "2DROP"           ; Discard the top two stack words.
    POPWS WT                            ; pop into stack top
    POPWS WT                            ; pop into stack top
    NEXT

; DUP ( w1 -- w1 w1 )
    DEFCODE DUP "DUP"               ; Duplicate the top stack word.
    PUSHWS WT                           ; push stack top
    NEXT

; 2DUP ( w2 w1 -- w2 w1 w2 w1 )
    DEFCODE DDUP "2DUP"             ; Duplicate the top two stack words.
    POPWS RW                            ; pop second word
    PUSHWS RW                           ; push second word
    PUSHWS WT                           ; push top word
    PUSHWS RW                           ; push second word
    NEXT

; ?DUP ( w1 -- w1 w1 | 0 )
    DEFCODE QDUP "?DUP"             ; Duplicate if not zero.
    CMP WT R0                           ; compare with zero
    BEQ QDUP0                           ; if zero exit
    PUSHWS WT                           ; else push stack top
QDUP0
    NEXT

; OVER ( w2 w1 -- w2 w1 w2 )
    DEFCODE OVER "OVER"             ; Copy the second stack word to the top.
    POPWS RW                            ; pop second word
    PUSHWS RW                           ; push second word
    PUSHWS WT                           ; push top word
    MOV WT RW                           ; put second word into stack top
    NEXT

; SWAP ( w2 w1 -- w1 w2 )
    DEFCODE SWAP "SWAP"             ; Swap the top two stack words.
    POPWS RW                            ; pop second word
    PUSHWS WT                           ; push top word
    MOV WT RW                           ; put second word into stack top
    NEXT

; ROT ( w3 w2 w1 -- w2 w1 w3 )
    DEFCODE ROT "ROT"               ; Rotate the third stack word to the top.
    POPWS RW                            ; pop second word
    POPWS RX                            ; pop third word
    PUSHWS RW                           ; push second word
    PUSHWS WT                           ; push top word
    MOV WT RX                           ; put third word into stack top
    NEXT

; -ROT ( w3 w2 w1 -- w1 w3 w2 )
    DEFCODE NROT "-ROT"             ; Reverse rotate.
    POPWS RW                            ; pop second word
    POPWS RX                            ; pop third word
    PUSHWS WT                           ; push top word
    PUSHWS RX                           ; push third word
    MOV WT RW                           ; put second word into stack top
    NEXT

; 0 ( -- 0 )
    DEFCODE ZERO "0"                ; Push 0 onto the stack.
    PUSHWS WT                           ; push stack top
    MOVSI WT 0                          ; put 0 into stack top
    NEXT

; 1 ( -- 1 )
    DEFCODE ONE "1"                 ; Push 1 onto the stack.
    PUSHWS WT                           ; push stack top
    MOVSI WT 1                          ; put 1 into stack top
    NEXT

; -1 ( -- -1 )
    DEFCODE NONE "-1"               ; Push -1 onto the stack.
    PUSHWS WT                           ; push stack top
    MOVSI WT -1                         ; put -1 into stack top
    NEXT

    ; ==========================================================================
    ; RETURN STACK WORDS

; RP@ ( -- a )
    DEFCODE RPFETCH "RP@"           ; Get the return stack pointer.
    PUSHWS WT                           ; push stack top
    MOV WT RP                           ; put pointer into stack top
    NEXT

; RP! ( a -- )
    DEFCODE RPSTORE "RP!"           ; Set the return stack pointer.
    MOV RP WT                           ; set pointer
    POPWS WT                            ; pop into stack top
    NEXT

; R> ( W: -- w1  R: w1 -- )
    DEFCODE RPOP "R>"               ; Pop a word off of the return stack.
    PUSHWS WT                           ; push stack top
    POPRS WT                            ; pop word into stack top
    NEXT

; R@ ( -- w )
    DEFCODE RFETCH "R@"             ; Get the top word of the return stack.
    PUSHWS WT                           ; push stack top
    POPRS WT                            ; pop word into stack top
    PUSHRS WT                           ; push word onto return stack
    NEXT

; >R ( W: w1 --  R: -- w1 )
    DEFCODE RPUSH ">R"              ; Push a word onto the return stack.
    PUSHRS WT                           ; push word onto return stack
    POPWS WT                            ; pop into stack top
    NEXT

    ; ==========================================================================
    ; MEMORY ACCESS WORDS

; A>CA ( a -- ca )
    DEFCODE ATOCA "A>CA"            ; Address to character address.
    LSHLI WT 1                          ; get character address
    NEXT

; CA>A ( ca -- a )
    DEFCODE CATOA "CA>A"            ; Character address to address.
    LSHRI WT 1                          ; get word address
    NEXT

; @ ( a -- w )
    DEFCODE FETCH "@"               ; Load a word from memory.
    LOAD WT WT                          ; load word into stack top
    NEXT

; C@ ( ca -- c )
    DEFCODE CFETCH "C@"             ; Load a character from memory.
    BASE 16
    MOV RW WT                           ; move character address
    LSHRI RW 1                          ; get word address
    LOAD WT RW                          ; load word into stack top
    BCS CFETCH0
    LSHRI WT 8                          ; get upper byte
    BUC CFETCH1
CFETCH0
    ANDI WT FF                          ; get lower byte
CFETCH1
    NEXT

; 2@ ( a -- d )
    DEFWORD DFETCH "2@"             ; Load a double word from memory.
    WORD DUP
    WORD ONEADD
    WORD FETCH                          ; load lower word
    WORD SWAP
    WORD FETCH                          ; load upper word
    WORD EXIT

; ! ( w a -- )
    DEFCODE STORE "!"               ; Store a word into memory.
    POPWS RW                            ; pop word
    STOR RW WT                          ; store word at address
    POPWS WT                            ; pop into stack top
    NEXT

; C! ( c ca -- )
    DEFCODE CSTORE "C!"             ; Store a character into memory.
    BASE 16
    POPWS RW                            ; pop character
    LSHRI WT 1                          ; get word address
    LOAD RX WT                          ; load word
    BCS CSTORE0
    ANDI RX FF                          ; clear upper byte
    LSHLI RW 8                          ; shift character into upper byte
    OR RX RW                            ; set upper byte
    BUC CSTORE1
CSTORE0
    LSHRI RX 8
    LSHLI RX 8                          ; clear lower byte
    ANDI RW FF                          ; clear character upper byte
    OR RX RW                            ; set lower byte
CSTORE1
    STOR RX WT                          ; store word
    POPWS WT                            ; pop into stack top
    NEXT

; 2! ( d a -- )
    DEFWORD DSTORE "2!"             ; Store a double word into memory.
    WORD SWAP
    WORD OVER
    WORD STORE                          ; store upper word
    WORD ONEADD
    WORD STORE                          ; store lower word
    WORD EXIT

; +! ( w a -- )
    DEFWORD ADDSTORE "+!"           ; Add a number to the word at an address.
    WORD SWAP
    WORD OVER
    WORD FETCH                          ; fetch word
    WORD ADD_                           ; add number
    WORD SWAP
    WORD STORE                          ; store word
    WORD EXIT

    ; ==========================================================================
    ; COMPARISON WORDS

; 0< ( w -- f )
    DEFCODE ZLESS "0<"              ; Check if word is less than zero.
    CMP WT R0                           ; compare with zero
    SGE WT                              ; set to 1 if greater or equal
    SUBI WT 1                           ; return to 0 if false -1 if true
    NEXT

; 0= ( w -- f )
    DEFCODE ZEQUAL "0="             ; Check if word is equal to zero.
    CMP WT R0                           ; compare with zero
    SNE WT                              ; set to 1 if not equal
    SUBI WT 1                           ; return 0 if false -1 if true
    NEXT

; < ( w w -- f )
    DEFCODE LESS "<"                ; Check if word is less than other word.
    POPWS RW                            ; pop first operand
    CMP RW WT                           ; compare operands
    SGE WT                              ; set to 1 if greater or equal
    SUBI WT 1                           ; return 0 if false -1 if true
    NEXT

; U< ( u u -- f )
    DEFCODE ULESS "U<"              ; Unsigned less than.
    POPWS RW                            ; pop first operand
    CMP RW WT                           ; compare operands
    SHS WT                              ; set to 1 if higher or same as
    SUBI WT 1                           ; return 0 if false -1 if true
    NEXT

; = ( w w -- f )
    DEFCODE EQUAL "="               ; Check if words are equal.
    POPWS RW                            ; pop first operand
    CMP RW WT                           ; compare operands
    SNE WT                              ; set to 1 if not equal
    SUBI WT 1                           ; return 0 if false -1 if true
    NEXT

; /= ( w w -- f )
    DEFCODE NEQUAL "/="             ; Check if words are not equal.
    POPWS RW                            ; pop first operand
    CMP RW WT                           ; compare operands
    SEQ WT                              ; set to 1 if equal
    SUBI WT 1                           ; return 0 if false -1 if true
    NEXT

; MIN ( w w -- w )
    DEFWORD MIN "MIN"               ; Keep the smaller of two words.
    WORD DDUP
    WORD SWAP
    WORD LESS                           ; compare words
    WORD ZBRANCH                        ; if first word is larger
    WORD MIN0
    WORD SWAP                           ; then drop first word
MIN0
    WORD DROP
    WORD EXIT

; MAX ( w w -- w )
    DEFWORD MAX "MAX"               ; Keep the larger of two words.
    WORD DDUP
    WORD LESS                           ; compare words
    WORD ZBRANCH                        ; if first word is smaller
    WORD MAX0
    WORD SWAP                           ; then drop first word
MAX0
    WORD DROP
    WORD EXIT

; WITHIN ( u ul uh -- f )
    DEFWORD WITHIN "WITHIN"         ; Check if ul <= u < uh.
    WORD OVER
    WORD SUB_                           ; find range length
    WORD RPUSH
    WORD SUB_                           ; find range offset
    WORD RPOP
    WORD ULESS                          ; check offset less than length
    WORD EXIT

    ; ==========================================================================
    ; LOGICAL WORDS

; AND ( w w -- w )
    DEFCODE AND_ "AND"              ; Bitwise AND two words.
    POPWS RW                            ; pop first operand
    AND WT RW                           ; put result into stack top
    NEXT

; OR ( w w -- w )
    DEFCODE OR_ "OR"                ; Bitwise OR two words.
    POPWS RW                            ; pop first operand
    OR WT RW                            ; put result into stack top
    NEXT

; XOR ( w w -- w )
    DEFCODE XOR_ "XOR"              ; Bitwise XOR two words.
    POPWS RW                            ; pop first operand
    XOR WT RW                           ; put result into stack top
    NEXT

; NOT ( w -- w )
    DEFCODE NOT "NOT"               ; Bitwise NOT of a word.
    MOVSI RW -1
    XOR WT RW                           ; invert bits
    NEXT

    ; ==========================================================================
    ; ARITHMETIC WORDS

; UM+ ( u u -- u c )
    DEFCODE UMADD "UM+"             ; Add two words and produce carry.
    POPWS RW                            ; pop first operand
    ADD WT RW                           ; put result into stack top
    PUSHWS WT                           ; push stack top
    SCS WT                              ; put carry into stack top
    NEXT

; + ( w w -- w )
    DEFCODE ADD_ "+"                ; Add two words.
    POPWS RW                            ; pop first operand
    ADD WT RW                           ; put result into stack top
    NEXT

; D+ ( d d -- d )
    DEFWORD DADD "D+"               ; Add two double words.
    WORD RPUSH                          ; save second upper word
    WORD SWAP
    WORD RPUSH                          ; save first upper word
    WORD UMADD                          ; add lower words
    WORD RPOP                           ; restore first upper word
    WORD RPOP                           ; restore second upper word
    WORD ADD_                           ; add carry
    WORD ADD_                           ; add upper words
    WORD EXIT

; 1+ ( w -- w )
    DEFWORD ONEADD "1+"             ; Increment a word.
    WORD ONE
    WORD ADD_                           ; add one
    WORD EXIT

; - ( w w -- w )
    DEFCODE SUB_ "-"                ; Subtract two words.
    MOV RW WT                           ; move second operand
    POPWS WT                            ; pop first operand
    SUB WT RW                           ; put result into stack top
    NEXT

; 1- ( w -- w )
    DEFWORD ONESUB "1-"             ; Decrement a word.
    WORD ONE
    WORD SUB_                           ; subtract one
    WORD EXIT

; UM/MOD ( ud u -- ur uq )
    DEFCODE UMDIVMOD "UM/MOD"       ; Divide unsigned double by unsigned word.
    BASE 10
    POPWS RX                            ; pop upper dividend
    POPWS RY                            ; pop lower dividend
    MOV RZ WT                           ; get divisor
    MOVSI RW 16                         ; set loop counter
    MOVSI WT 0                          ; set quotient
    BUC UMDIVMOD1
UMDIVMOD0
    ADD RY RY                           ; left shift lower dividend
    ADDC RX RX                          ; left shift upper dividend
    LSHLI WT 1                          ; left shift quotient
UMDIVMOD1
    CMP RX RZ                           ; compare remainder with divisor
    BLO UMDIVMOD2                       ; if less skip
    SUB RX RZ                           ; else subtract divisor
    ADDI WT 1                           ; and set quotient bit
UMDIVMOD2
    SUBI RW 1                           ; decrement counter
    BGE UMDIVMOD0                       ; repeat until negative
    PUSHWS RX                           ; push remainder
    NEXT

; M/MOD ( sd w -- sr sq )
    DEFWORD MDIVMOD "M/MOD"         ; Divide signed double by signed word.
    WORD DDUP
    WORD ZLESS
    WORD RPUSH                          ; save divisor sign
    WORD ZLESS
    WORD RPUSH                          ; save dividend sign
    WORD ABS                            ; make divisor positive
    WORD RPUSH
    WORD DABS                           ; make dividend positive
    WORD RPOP
    WORD UMDIVMOD                       ; divide
    WORD RFETCH                         ; get dividend sign
    WORD ZBRANCH                        ; if negative
    WORD MDIVMOD0
    WORD SWAP
    WORD NEGATE                         ; then negate the remainder
    WORD SWAP
MDIVMOD0
    WORD RPOP                           ; restore dividend sign
    WORD RPOP                           ; restore divisor sign
    WORD NEQUAL
    WORD ZBRANCH                        ; if signs are different
    WORD MDIVMOD1
    WORD NEGATE                         ; then negate quotient
MDIVMOD1
    WORD EXIT

; /MOD ( w w -- r q )
    DEFWORD DIVMOD "/MOD"           ; Divide two words.
    WORD OVER
    WORD ZLESS                          ; extend dividend sign
    WORD SWAP
    WORD MDIVMOD                        ; divide
    WORD EXIT

; MOD ( w w -- r )
    DEFWORD MOD "MOD"               ; Divide two words and discard quotient.
    WORD DIVMOD                         ; divide
    WORD DROP                           ; drop quotient
    WORD EXIT

; / ( w w -- q )
    DEFWORD DIV "/"                 ; Divide two words and discard remainder.
    WORD DIVMOD                         ; divide
    WORD SWAP
    WORD DROP                           ; drop remainder
    WORD EXIT

; UM* ( u u -- ud )
    DEFCODE UMMUL "UM*"             ; Multiply two unsigned words.
    BASE 10
    POPWS RX                            ; pop multiplicand
    MOV RY WT                           ; get multiplier
    MOVSI RZ 15                         ; set loop counter
    MOVSI RW 0                          ; set lower product
    MOVSI WT 0                          ; set upper product
UMMUL0
    ADD RW RW                           ; left shift lower product
    ADDC WT WT                          ; left shift upper product
    LSHLI RY 1                          ; left shift multiplier
    BCC UMMUL1                          ; if bit is zero skip
    ADD RW RX                           ; else add multiplicand
    ADDC WT R0                          ; and propagate carry
UMMUL1
    SUBI RZ 1                           ; decrement counter
    BGE UMMUL0                          ; repeat until negative
    PUSHWS RW                           ; push lower product
    NEXT

; * ( w w -- w )
    DEFWORD MUL "*"                 ; Multiply two words.
    WORD UMMUL
    WORD DROP                           ; drop upper result
    WORD EXIT

; M* ( w w -- sd )
    DEFWORD MMUL "M*"               ; Multiply two signed words.
    WORD DDUP
    WORD XOR_
    WORD ZLESS                          ; compare signs
    WORD RPUSH                          ; save comparison
    WORD ABS                            ; make operand positive
    WORD SWAP
    WORD ABS                            ; make operand positive
    WORD UMMUL                          ; unsigned multiply
    WORD RPOP                           ; restore comparison
    WORD ZBRANCH                        ; if signs were equal exit
    WORD MMUL0
    WORD DNEGATE                        ; else negate result
MMUL0
    WORD EXIT

; */MOD ( w w w -- r q )
    DEFWORD MULDIVMOD "*/MOD"       ; Scale word by ratio.
    WORD RPUSH                          ; save denominator
    WORD MMUL                           ; multiply numerator
    WORD RPOP                           ; restore denominator
    WORD MDIVMOD                        ; divide by denominator
    WORD EXIT

; */ ( w w w -- q )
    DEFWORD MULDIV "*/"             ; Scale by ratio and discard remainder.
    WORD MULDIVMOD                      ; scale
    WORD SWAP
    WORD DROP                           ; drop remainder
    WORD EXIT

; NEGATE ( w -- w )
    DEFWORD NEGATE "NEGATE"         ; Negate a word.
    WORD NOT                            ; invert word
    WORD ONE
    WORD ADD_                           ; add one
    WORD EXIT

; DNEGATE ( d -- d )
    DEFWORD DNEGATE "DNEGATE"       ; Negate a double word.
    WORD NOT                            ; invert upper word
    WORD RPUSH                          ; save upper word
    WORD NOT                            ; invert lower word
    WORD ONE
    WORD UMADD                          ; add one
    WORD RPOP                           ; restore upper word
    WORD ADD_                           ; add carry
    WORD EXIT

; ABS ( w -- w )
    DEFWORD ABS "ABS"               ; Find the absolute value.
    WORD DUP
    WORD ZLESS
    WORD ZBRANCH                        ; if not negative exit
    WORD ABS0
    WORD NEGATE                         ; else negate word
ABS0
    WORD EXIT

; DABS ( d -- d )
    DEFWORD DABS "DABS"             ; Find the absolute value of double word.
    WORD DUP
    WORD ZLESS
    WORD ZBRANCH                        ; if not negative exit
    WORD DABS0
    WORD DNEGATE                        ; else negate double word
DABS0
    WORD EXIT

    ; ==========================================================================
    ; FPU WORDS

; FPU! ( w w -- )
    DEFCODE FPUSTORE "FPU!"         ; Put operands into the FPU registers.
    POPWS RW                            ; pop first operand
    MOV F0 RW                           ; give first operand to FPU
    MOV F1 WT                           ; give second operand to FPU
    POPWS WT                            ; pop into stack top
    NEXT

    ; ==========================================================================
    ; NUMERIC OUTPUT WORDS

; DECIMAL ( -- )
    DEFWORD DECIMAL "DECIMAL"       ; Set numeric base to 10.
    BASE 10
    WORD LITERAL
    WORD 10
    WORD BASE_
    WORD STORE                          ; store base
    WORD EXIT

; HEX ( -- )
    DEFWORD HEX "HEX"               ; Set numeric base to 16.
    BASE 10
    WORD LITERAL
    WORD 16
    WORD BASE_
    WORD STORE                          ; store base
    WORD EXIT

; DIGIT ( u -- c )
    DEFWORD DIGIT "DIGIT"           ; Convert a word to a digit.
    BASE 10
    WORD LITERAL
    WORD 9
    WORD OVER
    WORD LESS                           ; check if greater than 9
    WORD LITERAL
    WORD 7                              ; offset from ':' to 'A'
    WORD AND_                           ; if greater keep offset
    WORD ADD_                           ; add offset
    WORD LITERAL
    WORD 48                             ; offset to ASCII '0'
    WORD ADD_                           ; add offset
    WORD EXIT

; EXTRACT ( u base -- u c )
    DEFWORD EXTRACT "EXTRACT"       ; Extract least significant digit from word.
    WORD ZERO
    WORD SWAP                           ; extend zeros
    WORD UMDIVMOD                       ; divide
    WORD SWAP                           ; keep quotient
    WORD DIGIT                          ; convert remainder to digit
    WORD EXIT

; PAD ( -- ca )
    DEFWORD PAD "PAD"               ; Get the end of the pad buffer.
    BASE 10
    WORD HERE_                          ; get end of dictionary
    WORD FETCH
    WORD ATOCA                          ; convert to character address
    WORD LITERAL
    WORD 80                             ; pad buffer length
    WORD ADD_                           ; add offset
    WORD EXIT

; <# ( -- )
    DEFWORD NUMSTART "<#"           ; Start numeric output.
    WORD PAD                            ; get end of pad buffer
    WORD HLD
    WORD STORE                          ; reset output pointer
    WORD EXIT

; HOLD ( c -- )
    DEFWORD HOLD "HOLD"             ; Insert character into output.
    WORD HLD
    WORD FETCH
    WORD ONE
    WORD SUB_                           ; decrement output pointer
    WORD DUP
    WORD HLD
    WORD STORE                          ; update output pointer
    WORD CSTORE                         ; store character
    WORD EXIT

; # ( u -- u )
    DEFWORD NUM "#"                 ; Insert one digit into output.
    WORD BASE_
    WORD FETCH
    WORD EXTRACT                        ; extract digit
    WORD HOLD                           ; insert digit into output
    WORD EXIT

; #S ( u -- 0 )
    DEFWORD NUMALL "#S"             ; Insert remaining digits into output.
NUMALL0
    WORD NUM                            ; insert digit
    WORD DUP
    WORD ZBRANCH                        ; if zero exit
    WORD NUMALL1
    WORD BRANCH                         ; else repeat
    WORD NUMALL0
NUMALL1
    WORD EXIT

; SIGN ( w -- )
    DEFWORD SIGN "SIGN"             ; Insert the sign into output.
    BASE 16
    WORD ZLESS
    WORD ZBRANCH                        ; if negative
    WORD SIGN0
    WORD LITERAL
    WORD 2D
    WORD HOLD                           ; then insert minus sign
SIGN0
    WORD EXIT

; #> ( u -- ca l )
    DEFWORD NUMEND "#>"             ; End numeric output and return string.
    WORD DROP
    WORD HLD
    WORD FETCH                          ; get output end
    WORD PAD                            ; get output start
    WORD OVER
    WORD SUB_                           ; get string length
    WORD EXIT

; SSTR ( s -- ca l )
    DEFWORD SSTR "SSTR"             ; Get the output string of signed word.
    WORD DUP
    WORD RPUSH                          ; save word
    WORD ABS                            ; get absolute value
    WORD NUMSTART
    WORD NUMALL                         ; convert digits
    WORD RPOP
    WORD SIGN                           ; add sign
    WORD NUMEND
    WORD EXIT

; S. ( s -- )
    DEFWORD SOUTPUT "S."            ; Output a signed word.
    WORD SSTR
    WORD SPACE                          ; output leading space
    WORD TYPE                           ; output numeric string
    WORD EXIT

; S.R ( s n -- )
    DEFWORD SOUTPUTR "S.R"          ; Output signed word right justified.
    WORD RPUSH                          ; save column width
    WORD SSTR                           ; get string
    WORD RPOP                           ; restore column width
    WORD OVER
    WORD SUB_                           ; subtract string width
    WORD SPACES_                        ; output leading spaces
    WORD TYPE                           ; output string
    WORD EXIT

; USTR ( u -- ca l )
    DEFWORD USTR "USTR"             ; Get the output string of unsigned word.
    WORD NUMSTART
    WORD NUMALL                         ; convert digits
    WORD NUMEND
    WORD EXIT

; U. ( u -- )
    DEFWORD UOUTPUT "U."            ; Output an unsigned word.
    WORD USTR
    WORD SPACE                          ; output leading space
    WORD TYPE                           ; output numeric string
    WORD EXIT

; U.R ( u n -- )
    DEFWORD UOUTPUTR "U.R"          ; Output unsigned word right justified.
    WORD RPUSH                          ; save column width
    WORD USTR                           ; get string
    WORD RPOP                           ; restore column width
    WORD OVER
    WORD SUB_                           ; subtract string width
    WORD SPACES_                        ; output leading spaces
    WORD TYPE                           ; output string
    WORD EXIT

; . ( w -- )
    DEFWORD OUTPUT "."              ; Output word.
    BASE 10
    WORD BASE_
    WORD FETCH                          ; get current numeric base
    WORD LITERAL
    WORD 10
    WORD EQUAL
    WORD ZBRANCH                        ; if numeric base is 10
    WORD OUTPUT0
    WORD SOUTPUT                        ; then output signed word
    WORD EXIT
OUTPUT0
    WORD UOUTPUT                        ; else output unsigned word
    WORD EXIT

; .R ( w n -- )
    DEFWORD OUTPUTR ".R"            ; Output word right justified.
    BASE 10
    WORD BASE_
    WORD FETCH                          ; get current numeric base
    WORD LITERAL
    WORD 10
    WORD EQUAL
    WORD ZBRANCH                        ; if numeric base is 10
    WORD OUTPUTR0
    WORD SOUTPUTR                       ; then output signed word
    WORD EXIT
OUTPUTR0
    WORD UOUTPUTR                       ; else output unsigned word
    WORD EXIT

; ? ( a -- )
    DEFWORD AOUTPUT "?"             ; Output the word at an address.
    WORD FETCH                          ; get word
    WORD OUTPUT                         ; output word
    WORD EXIT

    ; ==========================================================================
    ; UTILITY WORDS

; DM+ ( ca l -- ca )
    DEFWORD DMP "DM+"               ; Output l bytes at ca and return ca+l.
    BASE 10
    WORD OVER
    WORD LITERAL
    WORD 4
    WORD UOUTPUTR                       ; output address
    WORD SPACE
    WORD RPUSH                          ; setup loop counter
    WORD BRANCH
    WORD DMP1
DMP0
    WORD DUP
    WORD CFETCH                         ; get byte
    WORD LITERAL
    WORD 3
    WORD UOUTPUTR                       ; output byte
    WORD ONEADD                         ; increment pointer
DMP1
    WORD LNEXT
    WORD DMP0
    WORD EXIT

; DUMP ( ca l -- )
    DEFWORD DUMP "DUMP"             ; Output memory.
    BASE 10
    WORD BASE_
    WORD FETCH
    WORD RPUSH                          ; save current base
    WORD HEX                            ; set base to 16
    WORD LITERAL
    WORD 16                             ; output 16 bytes per line
    WORD DIV
    WORD RPUSH                          ; setup loop counter
DUMP0
    WORD LINE
    WORD LITERAL
    WORD 16
    WORD DDUP
    WORD DMP                            ; output bytes
    WORD NROT
    WORD SPACE
    WORD SPACE
    WORD DTYPE                          ; output characters
    WORD LNEXT
    WORD DUMP0
    WORD DROP                           ; drop address
    WORD RPOP
    WORD BASE_
    WORD STORE                          ; restore base
    WORD EXIT

WSTACKSTR STRING " <WP"

; .WS ( -- )
    DEFWORD OWSTACK ".WS"           ; Output the working stack.
    WORD DEPTH                          ; get stack depth
    WORD RPUSH                          ; setup loop counter
    WORD BRANCH
    WORD OWSTACK1
OWSTACK0
    WORD RFETCH                         ; get loop index
    WORD PICK                           ; get word at index
    WORD OUTPUT                         ; output word
OWSTACK1
    WORD LNEXT
    WORD OWSTACK0
    WORD LITERAL
    WORD WSTACKSTR
    WORD COUNT
    WORD TYPE                           ; output stack pointer string
    WORD EXIT

; .BASE ( -- )
    DEFWORD OBASE ".BASE"           ; Output the current numeric base.
    WORD BASE_
    WORD FETCH                          ; get base
    WORD DECIMAL                        ; set to base 10
    WORD DUP
    WORD OUTPUT                         ; output base
    WORD BASE_
    WORD STORE                          ; restore base
    WORD EXIT

; .FREE ( -- )
    DEFWORD OFREE ".FREE"           ; Output number of free words.
    WORD WP0_
    WORD HERE_
    WORD FETCH
    WORD SUB_                           ; get free words
    WORD OUTPUT                         ; output number
    WORD EXIT

; .WORDS ( -- )
    DEFWORD OWORDS ".WORDS"         ; Print the list of words.
    WORD LAST
    WORD FETCH                          ; get the last defined word
    WORD BRANCH
    WORD OWORDS1
OWORDS0
    WORD DUP
    WORD TONAME                         ; get word name
    WORD COUNT
    WORD SPACE                          ; output space
    WORD TYPE                           ; output name
    WORD TONEXT                         ; get next word
OWORDS1
    WORD DUP
    WORD ZERO
    WORD EQUAL
    WORD ZBRANCH                        ; if word is zero exit
    WORD OWORDS0
    WORD DROP
    WORD EXIT

    ; ==========================================================================
    ; TEXT INTERPRETER WORDS

; PUT ( c -- )
    DEFWORD PUT "PUT"               ; Put a character into the input buffer.
    BASE 10
    WORD DUP
    WORD NUMTIB
    WORD FETCH                          ; get current number of input characters
    WORD DUP
    WORD LITERAL
    WORD 80
    WORD NEQUAL
    WORD ZBRANCH                        ; if less than 80
    WORD PUT0
    WORD ONE
    WORD NUMTIB
    WORD ADDSTORE                       ; then increment number of characters
    WORD BRANCH
    WORD PUT1
PUT0
    WORD BS
    WORD EMIT                           ; emit backspace
PUT1
    WORD PIN
    WORD FETCH
    WORD ADD_
    WORD CSTORE                         ; store character in input buffer
    WORD EMIT                           ; output character
    WORD EXIT

; BACKSP ( -- )
    DEFWORD BACKSP "BACKSP"         ; Input a backspace character.
    WORD NUMTIB
    WORD FETCH                          ; get current number of input character
    WORD ZERO
    WORD NEQUAL
    WORD ZBRANCH                        ; if not zero
    WORD BACKSP0
    WORD NONE
    WORD NUMTIB
    WORD ADDSTORE                       ; then decrement number of characters
    WORD BS
    WORD EMIT                           ; and emit backspace
    WORD SP
    WORD EMIT                           ; and emit space
    WORD BS
    WORD EMIT                           ; and emit backspace
BACKSP0
    WORD EXIT

; INLINE ( -- )
    DEFWORD INLINE "INLINE"         ; Read an input line.
    WORD ZERO
    WORD NUMTIB
    WORD STORE                          ; reset #TIB
    WORD TIB
    WORD ATOCA
    WORD PIN
    WORD STORE                          ; reset >IN
INLINE0
    WORD KEY
    WORD DUP
    WORD BS
    WORD EQUAL
    WORD ZBRANCH                        ; if key was backspace
    WORD INLINE1
    WORD DROP
    WORD BACKSP                         ; then input backspace
    WORD BRANCH                         ; and get next input
    WORD INLINE0
INLINE1
    WORD DUP
    WORD CR
    WORD EQUAL
    WORD ZBRANCH                        ; if key was carriage return
    WORD INLINE2
    WORD DROP
    WORD SP
    WORD PUT                            ; then put a space in the input
    WORD CR
    WORD PIN
    WORD FETCH
    WORD NUMTIB
    WORD FETCH
    WORD ADD_
    WORD CSTORE                         ; and put terminating carriage return
    WORD EXIT
INLINE2
    WORD PUT                            ; otherwise put character in input
    WORD BRANCH                         ; and get next input
    WORD INLINE0

; SKIP ( c -- )
    DEFWORD SKIP "SKIP"             ; Skip character in input buffer.
SKIP0
    WORD DUP
    WORD PIN
    WORD FETCH                          ; get input pointer
    WORD CFETCH                         ; get input character
    WORD EQUAL
    WORD ZBRANCH                        ; if equal
    WORD SKIP1
    WORD ONE
    WORD PIN
    WORD ADDSTORE                       ; then advance input pointer
    WORD BRANCH                         ; and repeat
    WORD SKIP0
SKIP1
    WORD DROP
    WORD EXIT

; PARSE ( c -- ca l T | 0 )
    DEFWORD PARSE "PARSE"           ; Parse a string terminated by character.
    WORD PIN
    WORD FETCH
    WORD CFETCH                         ; read first character
    WORD CR
    WORD EQUAL                          ; if it is carriage return
    WORD ZBRANCH
    WORD PARSE0
    WORD DROP
    WORD ZERO                           ; push zero flag
    WORD EXIT
PARSE0
    WORD RPUSH                          ; save delimiter
    WORD PIN
    WORD FETCH                          ; get start
    WORD ZERO                           ; initialize length
PARSE1
    WORD OVER
    WORD OVER
    WORD ADD_
    WORD CFETCH                         ; read character
    WORD RFETCH                         ; get delimiter
    WORD NEQUAL
    WORD ZBRANCH                        ; if not equal
    WORD PARSE2
    WORD ONEADD                         ; then increment length
    WORD BRANCH                         ; and repeat
    WORD PARSE1
PARSE2
    WORD RPOP
    WORD DROP
    WORD DUP
    WORD PIN
    WORD FETCH
    WORD ADD_                           ; adjust input pointer
    WORD PIN
    WORD STORE
    WORD NONE                           ; push true flag
    WORD EXIT

; TOKEN ( -- a T | 0 )
    DEFWORD TOKEN "TOKEN"           ; Parse a token.
    WORD SP
    WORD SKIP                           ; skip leading spaces
    WORD SP
    WORD PARSE                          ; parse until space
    WORD ZBRANCH                        ; if parse was successful
    WORD TOKEN0
    WORD HERE_
    WORD FETCH
    WORD PACKS                          ; then copy string to dictionary
    WORD NONE                           ; and push true flag
    WORD EXIT
TOKEN0
    WORD ZERO                           ; otherwise push zero flag
    WORD EXIT

; CHAR ( -- c | 0 )
    DEFWORD CHAR "CHAR"             ; Parse a character.
    WORD SP
    WORD SKIP                           ; skip leading spaces
    WORD SP
    WORD PARSE                          ; parse until space
    WORD ZBRANCH
    WORD CHAR0
    WORD DROP                           ; ignore length
    WORD CFETCH                         ; get first character
    WORD EXIT
CHAR0
    WORD ZERO
    WORD EXIT

; >NAME ( wa -- na )
    DEFWORD TONAME ">NAME"          ; Get word name.
    WORD ONESUB                         ; get name field
    WORD FETCH                          ; read name field
    WORD EXIT

; >NEXT ( wa -- wa )
    DEFWORD TONEXT ">NEXT"          ; Get next word.
    WORD FETCH                          ; read next field
    WORD EXIT

; >CODE ( la -- ca )
    DEFWORD TOCODE ">CODE"          ; Get word code.
    WORD ONEADD                         ; get code field
    WORD EXIT

; SAME? ( na na -- f )
    DEFWORD SAMEQ "SAME?"           ; Check if two words have the same name.
    WORD OVER
    WORD FETCH                          ; get first string word
    WORD OVER
    WORD FETCH                          ; get second string word
    WORD EQUAL
    WORD ZBRANCH                        ; if first words are equal
    WORD SAMEQ3
    WORD OVER
    WORD ATOCA
    WORD CFETCH                         ; then get the number of characters
    WORD CATOA                          ; convert into number of words
    WORD RPUSH
    WORD BRANCH                         ; and compare remaining characters
    WORD SAMEQ1
SAMEQ0
    WORD ONEADD                         ; increment pointer
    WORD SWAP
    WORD ONEADD                         ; increment pointer
    WORD OVER
    WORD FETCH                          ; get word
    WORD OVER
    WORD FETCH                          ; get word
    WORD EQUAL
    WORD ZBRANCH
    WORD SAMEQ2                         ; if words are equal
SAMEQ1
    WORD LNEXT                          ; then repeat
    WORD SAMEQ0
    WORD DDROP
    WORD NONE                           ; until end of strings
    WORD EXIT
SAMEQ2
    WORD RPOP
    WORD DROP
SAMEQ3
    WORD DDROP
    WORD ZERO
    WORD EXIT

; NAME? ( a -- wa T | a 0 )
    DEFWORD NAMEQ "NAME?"           ; Try to find a word in the dictionary.
    WORD LAST
    WORD FETCH                          ; get the last defined word
    WORD RPUSH                          ; save word
    WORD BRANCH
    WORD FIND1
FIND0
    WORD RPOP                           ; restore word
    WORD TONEXT                         ; get next word
    WORD RPUSH                          ; save word
FIND1
    WORD RFETCH                         ; get word
    WORD ZBRANCH                        ; if zero exit
    WORD FIND2
    WORD RFETCH                         ; get word
    WORD TONAME                         ; get word name
    WORD OVER
    WORD SAMEQ                          ; compare names
    WORD ZBRANCH                        ; if equal
    WORD FIND0
    WORD DROP                           ; then clean up stack
    WORD RPOP                           ; and return word
    WORD NONE                           ; and true flag
    WORD EXIT
FIND2
    WORD RPOP                           ; restore word
    WORD DROP                           ; clean up stack
    WORD ZERO                           ; return zero flag
    WORD EXIT

; DIGIT? ( c base -- u f )
    DEFWORD DIGITQ "DIGIT?"         ; Check if character is a digit.
    BASE 10
    WORD RPUSH                          ; save base
    WORD LITERAL
    WORD 48                             ; ASCII '0'
    WORD SUB_                           ; subtract offset (ASCII '0' to 0)
    WORD LITERAL
    WORD 9
    WORD OVER
    WORD LESS
    WORD ZBRANCH                        ; if greater than 9
    WORD DIGITQ0
    WORD LITERAL
    WORD 7                              ; offset from ':' to 'A'
    WORD SUB_                           ; subtract offset (ASCII 'A' to 10)
    WORD DUP
    WORD LITERAL
    WORD 10
    WORD LESS                           ; check for ':' to '@'
    WORD OR_                            ; if so keep -1 else keep number
DIGITQ0
    WORD DUP
    WORD RPOP                           ; restore base
    WORD ULESS                          ; unsigned compare with base
    WORD EXIT

; NUMBER? ( a -- w T | a 0 )
    DEFWORD NUMBERQ "NUMBER?"       ; Try to convert a string to a number.
    BASE 16
    WORD ZERO                           ; number starts at zero
    WORD OVER
    WORD COUNT                          ; get string address/length
    WORD OVER
    WORD CFETCH                         ; get character
    WORD LITERAL
    WORD 2D                             ; ASCII '-'
    WORD EQUAL                          ; check for negative sign
    WORD RPUSH                          ; save sign
    WORD RFETCH
    WORD ADD_                           ; if negative decrement length
    WORD SWAP
    WORD RFETCH
    WORD SUB_                           ; if negative increment pointer
    WORD SWAP
    WORD QDUP
    WORD ZBRANCH                        ; if length is zero exit
    WORD NUMBERQ3
    WORD ONESUB                         ; length is at least one
    WORD RPUSH                          ; setup loop counter
    WORD NONE                           ; number starts out valid
    WORD NROT
NUMBERQ0
    WORD DUP
    WORD RPUSH
    WORD CFETCH                         ; get character
    WORD BASE_
    WORD FETCH                          ; get base
    WORD DIGITQ                         ; check if digit
    WORD NROT
    WORD SWAP
    WORD BASE_
    WORD FETCH                          ; get base
    WORD MUL                            ; multiply base
    WORD ADD_                           ; add digit
    WORD NROT
    WORD AND_                           ; keep valid if valid
    WORD SWAP
    WORD RPOP
    WORD ONEADD                         ; increment pointer
    WORD LNEXT
    WORD NUMBERQ0
    WORD DROP
    WORD RPOP                           ; restore sign
    WORD ZBRANCH                        ; if negative
    WORD NUMBERQ1
    WORD NEGATE                         ; then negate
NUMBERQ1
    WORD SWAP
    WORD ZBRANCH                        ; if number is valid
    WORD NUMBERQ2
    WORD SWAP
    WORD DROP                           ; then drop address
    WORD NONE                           ; and push true flag
    WORD EXIT
NUMBERQ2
    WORD DROP                           ; otherwise drop number
    WORD ZERO                           ; and push zero flag
    WORD EXIT
NUMBERQ3
    WORD RPOP
    WORD DDROP
    WORD EXIT

HELLOSTR STRING "ECE 3710 FORTH"

; HELLO ( -- )
    DEFWORD HELLO "HELLO"           ; Output hello message.
    WORD LITERAL
    WORD HELLOSTR
    WORD COUNT
    WORD TYPE
    WORD EXIT

; RESTART ( -- )
    DEFWORD RESTART "RESTART"       ; Interpreter restart.
    WORD WP0_
    WORD WPSTORE
    WORD DECIMAL
    WORD PAGE
    WORD HELLO
    WORD QUIT

OKSTR STRING " OK"
QSTR STRING "?"

; QUIT ( -- )
    DEFWORD QUIT "QUIT"             ; Text interpreter.
    WORD RP0_
    WORD RPSTORE
QUIT0
    WORD LITERAL
    WORD OKSTR
    WORD COUNT
    WORD TYPE                           ; output ok prompt
    WORD LINE                           ; move to new line
QUIT1
    WORD INLINE                         ; read line of text
QUIT2
    WORD TOKEN                          ; try parse token
    WORD ZBRANCH                        ; if there was a token
    WORD QUIT0
    WORD NAMEQ                          ; try find in dictionary
    WORD ZBRANCH                        ; if found
    WORD QUIT3
    WORD TOCODE                         ; get code address
    WORD EXECUTE                        ; execute word
    WORD BRANCH                         ; goto next token
    WORD QUIT2
QUIT3
    WORD NUMBERQ                        ; try convert number
    WORD ZBRANCH                        ; if number
    WORD QUIT4
    WORD BRANCH                         ; leave on stack goto next token
    WORD QUIT2
QUIT4                                   ; otherwise
    WORD SPACE
    WORD COUNT
    WORD TYPE                           ; output token
    WORD LITERAL
    WORD QSTR
    WORD COUNT
    WORD TYPE                           ; output question string
    WORD WP0_
    WORD WPSTORE                        ; reset stack
    WORD BRANCH                         ; read a new line of text
    WORD QUIT0
QUITEND
