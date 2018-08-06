Seg_Descr   struc
   Limit_0      dw      0               ; Segment limit, bits 15-0
   Base_0       dw      0               ; Segment base, bits 15-0
   Base_1       db      0               ; Segment base, bits 23-16
   Access       db      0               ; Access rights
   Limit_1      db      0               ; Segment limit+G, bits 19-16
   Base_2       db      0               ; Segment base, bits 31-24
Seg_Descr   ends

IDT_GATE    struc
   Offset_0     dw      0               ; Offset, bits 15-0
   Selector     dw      0               ; Selector
   words        db      0               ; Word count, bits 4-0
   access       db      0               ; Access rights
   Offset_1     dw      0               ; Offset, bits 31-16
IDT_GATE    ends

IDT_TASK_GATE    struc
		dw      0               ; Non usato
   Selector	dw      0               ; Selector of task decriptor in GDT
		db      0               ; Non usato
   access       db      0               ; Access rights
		dw      0               ; Non usato
IDT_TASK_GATE    ends

;--------------------------------------------------------------------------------
;--------------------------------------------------------------------------------
;------------------------- DESCRIPTORS ------------------------------------------
;--------------------------------------------------------------------------------

;		 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0
;		ษอออออออออออออออออออออออออออออออออออออออออออออออป
;		บ		   LIMITI 0-15                  บ  WORD 0
;		ศอออออออออออออออออออออออออออออออออออออออออออออออผ
;		ษอออออออออออออออออออออออออออออออออออออออออออออออป
;		บ                  BASE   0-15                  บ  WORD 1
;		ศอออออออออออออออออออออออออออออออออออออออออออออออผ
;		ษอออออออออออออออออออออออออออออออออออออออออออออออป
;		บ    ACCESS RIGHTS      |     BASE 16-23        บ  WORD 2
;		ศอออออออออออออออออออออออออออออออออออออออออออออออผ
;		ษอออออออออออออออออออออออออออออออออออออออออออออออป
;		บ     BASE 24-31        | G| D| 0| A| LIMT 16-19บ  WORD 3
;		ศอออออออออออออออออออออออออออออออออออออออออออออออผ
;
;		Bit G: Granularity	       (1 yes)
;		Bit D: Default Operand size    (1 32 bit, 0 16 bit)
;			o BIG bit for DATA SEGMENT
;		Bit A: Avaiable for use 	?
;		Bit 0: ?

;--------------------------------------------------------------------------------
;------------------------- ACCESS RIGHTS ----------------------------------------
;--------------------------------------------------------------------------------
;
;		  7  6  5  4  3  2  1  0
;		ษอออออออออออออออออออออออป
;		บ P| DPL | S| C|X1|X2|X3บ
;		ศอออออออออออออออออออออออผ
;
;
;		Bit P : Present Bit (of the segment)
;		Bit S : --> 0 SYSTEM DESCRIPTOR
;			--> 1 APPLICATION DESCRIPTOR
;		Bit C : --> 0 DATA DESCRIPTOR
;			--> 1 CODE DESCRIPTOR
;		BIT X1,X2,X3 : FOR CODE :
;				   X1-> C = Conforming  (1 yes)
;				   X2->	R = Readable    (1 yes)
;				   X3-> A = Accessed    (1 yes)
;			       FOR DATA :
;				   X1-> E = Expand Down (1 Down, 0 Up)
;				   X2->	W = Writable    (1 yes)
;				   X3-> A = Accessed    (1 yes)
;		Bit DPL: Descriptor Privilege Level

;--------------------------------------------------------------------------------
;-------------------------------------------------- ACTION ----------- NO ACT. ---

;---------------------- TYPE ----------------------
A_ACCESS           equ     001h                ; Segment is accessed     (not)
A_CODE             equ     008h                ; Code segment	        (data)
;----------- CODE ------------
AC_CONFORM         equ     004h                ; Code conforming         (not)
AC_READ            equ     002h                ; Code readable           (not)
;----------- DATA ------------
AD_EXP_DOWN        equ     004h                ; Data expands down        (up)
AD_WRITE           equ     002h                ; Data writeable	         (not)

;---------------------- OTHER BITS ----------------
A_USER            equ     010h                 ; User (S)	      (System)
A_PRESENT         equ     080h                 ; Segment is present      (not)

A_DPL              equ     060h                ; Descriptor priority mask
A_DPL0             equ     000h                ; Descriptor priority level 0
A_DPL1             equ     020h                ; Descriptor priority level 1
A_DPL2             equ     040h                ; Descriptor priority level 2
A_DPL3             equ     060h                ; Descriptor priority level 3



;///
ACT_MASK            equ     00Fh                ; System descriptor types
ACT_LDT             equ     002h                ; Local descriptor table type
ACT_TASK            equ     005h                ; Task gate type
ACT_A386            equ     009h                ; 386 TSS types
ACT_B386            equ     00Bh
ACT_CALL386         equ     00Ch                ; 386 gate types
ACT_INT386          equ     00Eh
ACT_TRAP386         equ     00Fh


;============== The 8259 Programmable Interrupt Controller (PIC) =============

DELAY           macro   unused                  ; Perform two nonsense jumps
                dw      0EBh,0EBh               ;   to create a delay
                endm

;-----------------------------------------------------------------------------
; The following defines the addresses of the primary and secondary 8259 PICs
;  in I/O space.  These are referred to PIC1 and PIC2, respectively.
;-----------------------------------------------------------------------------

PIC1_CMND       equ     020h                    ; PIC1 addresses
PIC1_DATA       equ     021h
PIC2_DATA       equ     0A1h                    ; PIC2 addresses
PIC2_CMND       equ     0A0h



;-----------------------------------------------------------------------------
; The following equates are used for the initialization and control of the
;  8259 PIC.  Initialization requires up to four Initialization Command
;  Words (ICWs), the first being written to the Command Port and the rest
;  being written to the Data Port.  These are referred to as ICW1 through
;  ICW4, and have the following format:
;
;       ICW1:   +----+----+----+----+----+----+----+----+
;               |A7  |A6  |A5  |1   |LITM|ADI |SNGL|ICW4|
;               +----+----+----+----+----+----+----+----+
;
;       ICW2:   +----+----+----+----+----+----+----+----+
;               |A15 |A14 |A13 |A12 |A11 |A10 |A9  |A8  | (MCS80/85 MODE)
;               |T7  |T6  |T5  |T4  |T3  |x   |x   |x   | (8086/88 MODE)
;               +----+----+----+----+----+----+----+----+ x = Don't care
;
;       ICW3:   +----+----+----+----+----+----+----+----+
;               |S7  |S6  |S5  |S4  |S3  |S2  |S1  |S0  | (Master device)
;               |0   |0   |0   |0   |0   |ID2 |ID1 |ID0 | (Slave device)
;               +----+----+----+----+----+----+----+----+
;
;       ICW4:   +----+----+----+----+----+----+----+----+
;               |0   |0   |0   |SFNM|BUF |M/S |AEOI|uPM |
;               +----+----+----+----+----+----+----+----+
;
; After initialization, the PIC can be commanded to operate in various modes
;  through the Operation Command Words (OCWs).  These take various forms.
;  OCW1, the interrupt mask register, is read from and written to the
;  Data Port directly.  It indicates inhibited (M=1) and enabled (M=0)
;  channels in the 8259 PIC.
;
;       OCW4:   +----+----+----+----+----+----+----+----+
;               |M7  |M6  |M5  |M4  |M3  |M2  |M1  |M0  |
;               +----+----+----+----+----+----+----+----+
;
; Both OCW2 and OCW3 are not used very much.  The equate PIC_EOI to signal
;  End Of Interrupt is defined, and at this time the only useful command.
;-----------------------------------------------------------------------------

ICW1_ICW4       equ     001h                    ; ICW4 (not) needed
ICW1_SINGLE     equ     002h                    ; Single (cascade) mode
ICW1_INTERVAL4  equ     004h                    ; Call address interval 4 (8)
ICW1_LEVEL      equ     008h                    ; Level triggered (edge) mode
ICW1_INIT       equ     010h                    ; Initialization - required!


ICW4_8086       equ     001h                    ; 8086/88 (MCS-80/85) mode
ICW4_AUTO       equ     002h                    ; Auto (normal) EOI
ICW4_BUF_SLAVE  equ     008h                    ; Buffered mode/slave
ICW4_BUF_MASTER equ     00Ch                    ; Buffered mode/master
ICW4_SFNM       equ     010h                    ; Special fully nested (not)



;-----------------------------------------------------------------------------
; Now define some useful commands to be sent.
;-----------------------------------------------------------------------------

PIC_EOI         equ     020h                    ; End Of Interrupt

;=========================== Task State Segments =============================


Tss386          STRUC
	t3BackLink   DW   ?	                  ; Previous TSS backlink
		     DW	  0		          ; Reserved
	t3ESP0       DD   ?                       ; Stack 0 pointer (CPL=0)
	t3SS0        DW   ?                       ; Stack 0 segment
		     DW   0                       ; Reserved
	t3ESP1       DD   ?                       ; Stack 1 pointer (CPL=1)
	t3SS1        DW   ?                       ; Stack 1 segment
		     DW   0                       ; Reserved
	t3ESP2       DD   ?                       ; Stack 2 pointer (CPL=2)
	t3SS2        DW   ?                       ; Stack 2 segment
		     DW   0                       ; Reserved
	t3CR3        DD   ?                       ; CR3
	t3EIP        DD   ?                       ; Instruction pointer
	t3EFlags     DD   ?                       ; Extended flags

	t3EAX        DD   ?                       ; Task general registers
	t3ECX        DD   ?
	t3EDX        DD   ?
	t3EBX        DD   ?
	t3ESP        DD   ?
	t3EBP        DD   ?
	t3ESI        DD   ?
	t3EDI        DD   ?

	t3ES         DW   ?                       ; Task segment registers
		     DW   0                       ; Reserved
	t3CS         DW   ?
		     DW   0                       ; Reserved
	t3SS         DW   ?
		     DW   0                       ; Reserved
	t3DS         DW   ?
		     DW   0                       ; Reserved
	t3FS         DW   ?
		     DW   0                       ; Reserved
	t3GS         DW   ?
		     DW   0                       ; Reserved
	t3LDT        DW   ?                       ; Task local descriptor table
		     DW   0                       ; Reserved

	t3Trap       DW   ?                       ; Holds debug trap bit (T)

	t3IOOfs      DW   0		          ; I/O map address offset

Tss386          ENDS


