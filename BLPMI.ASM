
TITLE		  "Ballan Luca Protected Mode Interface V. 2.11"
SUBTTL		     	   "Entering in Protected Mode"






.486P
.MODEL SMALL


;*******************************************************************************
;************************ DECLARE CONSTANTS      *******************************
;*******************************************************************************
INCLUDE STRUCT.INC
INCLUDE MACRO.INC


;*****************************************************************
;******************* PM Program Information **********************
;*****************************************************************
extrn Start:dword
extrn Start_Limit:dword
extrn StartData_Limit:dword
public PSP
public LOW_FREE_MEM
public LOW_START_SEG
public LOW_START_MEM
public XMS_FREE_MEM
public XMS_START_MEM
public VENDOR_ID
public CPU_TYPE
public INTEL_PROC
public Svga_Mem
public Svga_VH
public Svga_VL
public SvgaSetLinerar_Buffer


;********************* SEGMENTS ORDER ****************************

Kernel_Code	SEGMENT PUBLIC PARA  USE16 'CODE'	    ; <-- Entry Point
Kernel_Code  	ENDS

Kernel_Data	SEGMENT PUBLIC PARA  USE16 'DATA'
Kernel_Data	ENDS

Global_Data	SEGMENT PUBLIC PARA  USE32 'DATA'
Global_Data	ENDS

Kernel_Stack	SEGMENT PUBLIC PARA  USE32 STACK 'STACK'
Kernel_Stack	ENDS

IDT_Stack	SEGMENT PUBLIC PARA  USE32 STACK 'STACK'
IDT_Stack	ENDS

PM2Real_Stack	SEGMENT PUBLIC PARA  USE32 STACK 'STACK'
PM2Real_Stack	ENDS

Int_Code	SEGMENT PUBLIC PARA  USE32 'INTERRUPT'
Int_Code	ENDS

Int_Data	SEGMENT PUBLIC PARA  USE32 'INTERRUPT'
Int_Data	ENDS



Start_SEG  	SEGMENT PUBLIC PARA  USE32 'CODE'
Start_SEG  	ENDS

Start_Data	SEGMENT PUBLIC PARA  USE32 'DATA'
Start_Data	ENDS

;*****************************************************************


;-----------------------------------------------------------------------------

;--------------------- Selettori del Kernel -----------------------
SelCode	        EQU      Code_Desc      - GDTStart
SelData         EQU      Data_Desc	- GDTStart
SelGlobal	EQU      Global_Desc	- GDTStart
SelStack	EQU      Stack_Desc     - GDTStart
SelIDTStack	EQU      IDTStack_Desc	- GDTStart
SelInterrupt    EQU      Int_Desc       - GDTStart
SelInt_Data	EQU      Int_DDesc	- GDTStart

;------------------ Selettori del Programma in PM -----------------
StartTSS	EQU      StartTSS_Desc  - GDTStart
SelInfo		EQU      Info_Desc	- GDTStart
SelPSP		EQU      PSP_Desc	- GDTStart
SelStart	EQU      Start_Desc	- GDTStart
SelStart_Data	EQU      Start_DescD	- GDTStart

;---------------------- Interrupt Tasks ---------------------------
SelExTSS_0	EQU      Desc_Ex_00	- GDTStart
SelExTSS_1	EQU      Desc_Ex_01	- GDTStart
SelExTSS_2	EQU      Desc_Ex_02	- GDTStart
SelExTSS_3	EQU      Desc_Ex_03	- GDTStart
SelExTSS_4	EQU      Desc_Ex_04	- GDTStart
SelExTSS_5	EQU      Desc_Ex_05	- GDTStart
SelExTSS_6	EQU      Desc_Ex_06	- GDTStart
SelExTSS_7	EQU      Desc_Ex_07	- GDTStart
SelExTSS_8	EQU      Desc_Ex_08	- GDTStart
SelExTSS_9	EQU      Desc_Ex_09	- GDTStart
SelExTSS_10	EQU      Desc_Ex_10	- GDTStart
SelExTSS_11	EQU      Desc_Ex_11	- GDTStart
SelExTSS_12	EQU      Desc_Ex_12	- GDTStart
SelExTSS_13	EQU      Desc_Ex_13	- GDTStart
SelExTSS_14	EQU      Desc_Ex_14	- GDTStart
SelExTSS_16	EQU      Desc_Ex_16	- GDTStart
SelExTSS_17	EQU      Desc_Ex_17	- GDTStart
SelExTSS_Unk	EQU      Desc_Ex_Unk	- GDTStart


;------------------- Selettori della Memoria ----------------------
SelFlat		EQU      Flat_Desc	- GDTStart
SelLowMem	EQU      LOW_Desc	- GDTStart
SelXMS		EQU	 XMS_Desc	- GDTStart
SelCharMap	EQU	 Char_Desc	- GDTStart


;--------------------- Selettori per OUTPUT -----------------------
Sel_VGA_Text    EQU      VGA_Text_Desc  - GDTStart
Sel_VGA_13	EQU	 VGA_13_Desc	- GDTStart
Sel_Svga	EQU	 SVGA_Desc      - GDTStart


;-----------------------------------------------------------------------------



;************************* CONSTANTS ******************************

DIM_STACK 	  EQU 200H
IDT_DIMSTACK	  EQU 200H
DIM_STPM2RM	  EQU 200H
MAX_DESC	  EQU 40
DIM_KB_BUFFER	  EQU 30
PM_PIC1Mask_Init  EQU 0FCH
PM_PIC2Mask_Init  EQU 0FFH



;*******************************************************************************
;************************** KERNEL DATA ****************************************
;*******************************************************************************

Kernel_Stack	SEGMENT PUBLIC PARA USE32 STACK 'STACK'
		DD (DIM_STACK/4) DUP (?)
Kernel_Stack	ENDS

IDT_Stack	SEGMENT PUBLIC PARA USE32 STACK 'STACK'
		DD (IDT_DIMSTACK/4) DUP (?)
IDT_Stack	ENDS

PM2Real_Stack	SEGMENT PUBLIC PARA USE32 STACK 'STACK'
		DD (DIM_STPM2RM/4) DUP (?)
PM2Real_Stack   ENDS



Kernel_Data	SEGMENT PUBLIC PARA USE16 'DATA'

GDTInfo         DW      GDTEnd-GDTStart-1         ; GDT limit
GDTAddr         DD      0                         ; GDT linear start address

IDTInfo         DW      IDTEnd-IDTStart-1         ; IDT limit
IDTAddr         DD      0                         ; IDT linear start address


;*******************************************************************************
;************************* SYSTEM INFORMATION **********************************
;*******************************************************************************

Old_IDTR	DW      ?                         ; Real IDT
		DD      ?
PIC1Mask	DB	?			  ; Real PIC Mask
PIC2Mask	DB	?
P2R_PIC1Mask	DB	? 			  ; PM to RM PIC Mask
P2R_PIC2Mask	DB      ?
PM_PIC1Mask	DB	PM_PIC1Mask_Init	  ; PM PIC Mask
PM_PIC2Mask	DB	PM_PIC2Mask_Init
PSP		DW	?			  ; PSP Segment


;----------------------- PM to Real Function Data --------------------------
ProtESP		DD 	?
ProtStack	DW 	?

Dest_Ind	LABEL	DWORD
	Dest_OFF        DW 	?
	Dest_SEG	DW 	?

;---------------------------------------------------------------------------


LOW_FREE_MEM    DD 	?                         ; Memoria bassa libera
LOW_START_MEM   DD 	?    			  ; Bassa Indirizzo Lineare
LOW_START_SEG   DW 	?			  ; Segmento memoria bassa



XMS_DRIVER_ON	DB 	?
XMS_HANDLE	DW	?

XMS_FREE_MEM	DD 	?			  ; Memoria estesa libera
XMS_START_MEM 	DD 	?			  ; Estesa Indirizzo Lineare

XMS_Control	LABEL	DWORD
	XMS_Control_Offset	DW	?
	XMS_Control_Segment	DW	?



;*******************************************************************************
;****************************** MESSAGES ***************************************
;*******************************************************************************

;--------------------------------- SVGA --------------------------------------
Svga_Mess_1     DB	'Vesa Bios ',11
Svga_VH		DB	0,'.',11
Svga_VL		DB	0,' : ',0

Svga_Mess_2   	DB	13,'Video Memory : ',14
Svga_Mem        DD      0
		DB	' kb.',13,0



;------------------------------ Check CPU ------------------------------------
c8086           DB      'CPU TYPE : 8086/8088 processor.',13,0
c80286          DB      'CPU TYPE : 80286 processor.',13,0
c80386          DB      'CPU TYPE : 80386 processor.',13,0
c80486		DB      'CPU TYPE : 80486 processor.',13,0

c80586		DB      'CPU TYPE : 80586 processor with Vendor ID ',34
VENDOR_ID       DB      12 DUP (?),34,'.',13,0

Pentium_msg     DB      'CPU TYPE : Genuine Intel Pentium(TM) processor.',13,0

INTEL_ID        DB      'GenuineIntel'
CPU_TYPE 	DB	?
INTEL_PROC      DB	0


error_386	DB 13,'Error : 80386 or better required.',13,0
error_v86	DB 13,'Error : System is running in Virtual 8086 mode.',13,0
error_dpmi	DB 13,'Error : System is running under a DPMI server.',13,0
error_win	DB 13,'Error : System is running under Microsoft Windows.',13,0
error_LowMem	DB 13,"Error : All conventional memory is in use.",13,0
error_LowMem_2  DB 13,"Error : Can't free conventional memory.",13,0
error_Extended  DB 13,"Error : Can't use extended memory.",13,0
error_Xms	DB 13,'Error : All Extended memory is in use or the Xms driver is too old.',13
		DB    '        Try to unload the Xms Driver.',13,0
error_Xms2	DB 13,"Error : Can't free XMS memory.",13,0


;----------------------------- INIT MESSAGE ----------------------------------
Start_Message	DB	10,14,'Ballan Luca',10,7,' Protected Mode Interface.   Version '
		DB	10,9,'2.11',13,10,7,'Last update ',??date,' time ',??time,'.',13,0

;-------------------------------- TIMER --------------------------------------
Time_Double	DD	0
		DD	0
Clock_K		DB      0,0,0,0AH,0B0H,0,38H,41H  ; Double di 18,206 ...
Vet		DW      0,31,28,31,30,31,30,31,31,30,31,30,31


Kernel_Data	ENDS





;*******************************************************************************
;*******************************************************************************
;*******************************************************************************
;************************** START CODE *****************************************
;*******************************************************************************
;*******************************************************************************

Kernel_Code	SEGMENT PUBLIC PARA USE16 'CODE'
		ASSUME CS:Kernel_Code,SS:Kernel_Stack
		ASSUME DS:Kernel_Data
		ASSUME ES:Global_Data
		ASSUME GS:Int_Data


;******************************** MAIN *****************************************

@STARTUP:

	PUSH DS                                   ; Save PSP

	MOV AX,Kernel_Data
	MOV DS,AX
	POP PSP					  ; Store PSP
	MOV AX,Global_Data
	MOV ES,AX

	MOV AX,Kernel_Stack
	MOV SS,AX			          ; <- RF FLAG
	MOV ESP,DIM_STACK




	Setup_Video			          ; Inizializzazione video

	MOV SI,OFFSET Start_Message	          ; Messaggio di inizio
	CALL R_Cout

	CALL Check_CPU			          ; Controllo Processore
	CALL R_Cout

	MOV AL,CPU_TYPE
	CMP AL,3			          ; Errore se precede l'
	JAE SHORT Cpu_OK			  ; 80386.

	MOV SI,OFFSET error_386


Error:	CALL R_Cout			          ; Esce per errore

	RMSetup_Cursor

	MOV AX,04C01H				  ; Exit with error = 1
	INT 21H

Cpu_OK:

	CALL Check_Win				  ; Controllo Window
	CMP AL,0
	JNZ SHORT Error

	CALL Check_dpmi              		  ; Controllo DPMI
	CMP AL,0
	JNZ SHORT Error

	MOV SI,OFFSET error_v86	     	          ; Controllo VIRTUAL 86
	SMSW AX
	TEST AL,1
	JNZ SHORT Error



;------------------------------- LOW INIT -------------------------------------

	MOV AH,48H
	MOV BX,0FFFFH
	INT 21H                                   ; BX Free paragraph
	PUSH BX
	MOVZX EBX,BX
	SHL EBX,4
	MOV LOW_FREE_MEM,EBX		          ; EBX Low free mem

	POP BX
	MOV SI,OFFSET error_LowMem		  ; Error on BX = 0
	OR BX,BX				  ; Out of memory.
	JZ SHORT Error

	MOV AH,48H				  ; Allocate memory
	INT 21H
	JC SHORT Error				  ; Error on Carry

						  ; AX Start Segment
	MOV LOW_START_SEG,AX
	MOVZX EAX,AX
	SHL EAX,4
	MOV LOW_START_MEM,EAX		          ; EAX Low Mem START



;------------------------------- XMS INIT -------------------------------------

	MOV AX,4300H
	INT 2FH
	CMP AL,80H
	JNE SHORT No_XMS                          ; JMP se no XMS installed
	MOV XMS_DRIVER_ON,1


	PUSH ES
	MOV AX,4310H
	INT 2FH                                   ; Get ES:BX xms code

	MOV XMS_Control_Offset,BX		  ; and save it.
	MOV XMS_Control_Segment,ES
	POP ES


	MOV AH,8
	CALL [XMS_Control]		          ; Get free Memory

	MOV SI,OFFSET error_Xms
	CMP BL,0
	JNZ Error                                 ; JMP on error

	PUSH AX
	MOVZX EAX,AX
	SHL EAX,10
	MOV XMS_FREE_MEM,EAX			  ; Save the Value in bytes

	POP DX					  ; Alloca tutto
	MOV AH,9
	CALL [XMS_Control]

	TEST AX,AX				  ; JMP on error
	JZ Error

	MOV XMS_HANDLE,DX


	MOV AH,0CH			  	  ; Now Lock IT!!
	CALL [XMS_Control]
	TEST AX,AX				  ; JMP on error
	JZ Error

	MOV DI,DX
	SHL EDI,16
	MOV DI,BX

	MOV DWORD PTR XMS_START_MEM,EDI           ; Save the linear address

	JMP SHORT end_xms_init

No_XMS:
	MOV XMS_DRIVER_ON,0

	MOV AH,88H
	INT 15H                                   ; AX numero di K sopra 1 M
	MOV SI,OFFSET error_Extended
	CMP AX,64
	JLE Error
	SUB AX,64				  ; tolgo 64 k di HMA.

	MOVZX EAX,AX
	SHL EAX,10
	MOV XMS_FREE_MEM,EAX			  ; Save the Value in bytes
	MOV DWORD PTR XMS_START_MEM,110000H	  ; Put the start point


end_xms_init:

	MOV SI,OFFSET error_Extended
	MOV EAX,XMS_FREE_MEM			  ; Valore divibile per 4 kb
	AND EAX,0FFFFF000H			  ; per difetto.
	JZ Error				  ; Meno di 4096 bytes
						  ; -> Errore.
	MOV XMS_FREE_MEM,EAX			  ; E correggi effettivo.


;--------------------------- PUSH INFORMATION ---------------------------------

	SIDT FWORD PTR Old_IDTR                   ; Save old Real IDTR

	CALL	Set_GDT				  ; Set GDT & IDT

	IN  AL,PIC1_DATA        	          ; Save Real Mask PIC
	MOV PIC1Mask,AL
	MOV P2R_PIC1Mask,AL

	IN  AL,PIC2_DATA
	MOV PIC2Mask,AL
	MOV P2R_PIC2Mask,AL


;************************ PREPARE FOR PROTECTED MODE ******************************


	CLI                             	  ; No interrupt

	Setup_irq 020H,028H		          ; Put the new IRQ

	MOV AL,PM_PIC1Mask 		          ; Put Protected Mask IRQ
	OUT PIC1_DATA,AL
	MOV AL,PM_PIC2Mask
	OUT PIC2_DATA,AL


	LGDT FWORD PTR GDTInfo	                  ; Load GDTR
	LIDT FWORD PTR IDTInfo	                  ; Load IDTR


	MOV EAX,CR0
	OR AL,1			      	          ; ENTERING PROTECTED
	MOV CR0,EAX

	JMP $+2			      	          ; FLUSH PREFETCH


	MOV AX,SelPSP
	MOV DS,AX
	MOV AX,SelInfo
	MOV ES,AX
	MOV AX,SelStart_Data
	MOV FS,AX
	MOV GS,AX
	MOV AX,SelStack
	MOV SS,AX
	MOVZX ESP,SP				  ; ESP point at the right
						  ; point.


	MOV AX,StartTSS				  ; Start of the new Task
	LTR AX

	PUSH DWORD PTR 000011000000000010b 	  ; Set EFLAGS
	POPFD

	XOR EAX,EAX				  ; Reset all Register
	XOR EBX,EBX
	XOR ECX,ECX
	XOR EDX,EDX
	XOR ESI,ESI
	XOR EDI,EDI
	XOR EBP,EBP



	DB	66H
	DB	67H
	DB      0EAH
	DD      OFFSET Start
	DW	SelStart                          ; RELOAD CS:EIP








;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;--------------------------- GET BACK REAL ------------------------------------
;------------------------------------------------------------------------------
; 		BL    =    return Code

CALL_BACK_REAL_MODE:

	MOV AX,SelData
	MOV DS,AX            			  ; Reload segment register
	MOV ES,AX				  ; with Real Rights
	MOV FS,AX
	MOV GS,AX

	MOV AX,SelStack                           ; Use Stack 32 for
	MOV SS,AX				  ; FLUSH IRQ
	MOV ESP,DIM_STACK			  ; Erase all Data

	CLI

	MOV AL,PIC1Mask                           ; Put IRQ Mask for FLUSH
	OUT PIC1_DATA,AL
	MOV AL,PIC2Mask
	OUT PIC2_DATA,AL


	STI                                       ; FLUSH ALL IRQ
	MOV ECX,10000H
FLUSH:  LOOP FLUSH


	PUSH DWORD PTR 011000000000010b	          ; Reset EFLAGS and
	POPFD					  ; Interrupt flag

	MOV EAX,CR0                               ; Reset Task Switch flag
	AND EAX,0FFFFFFF7H			  ; for same real
	MOV CR0,EAX				  ; applications.



	MOV AX,SelData
	MOV SS,AX            			  ; SS and CS are OK now

	MOV EAX,CR0
	AND AL,NOT 1
	MOV CR0,EAX		        	  ; LETS BACK REAL !!

	DB      0EAH                    	  ; Reload CS and FLUSH
	DW      OFFSET REAL			  ; PREFETCH
	DW	Kernel_Code

REAL:

	MOV AX,Kernel_Data
	MOV DS,AX
	MOV ES,AX                                 ; Read all segment
	MOV FS,AX
	MOV GS,AX
	MOV AX,Kernel_Stack
	MOV SS,AX                       	  ; ESP point at the right
	MOV ESP,DIM_STACK			  ; point? but to be sure ...


	PUSH BX					  ; Save error code

	Setup_irq 08H,70H			  ; Put the REAL IRQ

	MOV AL,PIC1Mask                           ; Put REAL Mask IRQ
	OUT PIC1_DATA,AL
	MOV AL,PIC2Mask
	OUT PIC2_DATA,AL

	LIDT FWORD PTR Old_IDTR          	  ; Put old IDTR ( REAL )

	STI					  ; Put Interrupt ON


;----------------------------- TIMER RESET ------------------------------------

	MOV AX,Int_Data
	MOV GS,AX


	MOV AH,0
	INT 1AH
	MOV AX,CX
	SHL EAX,16
	MOV AX,DX				  ; EAX Clock RM
	ADD EAX,Time
	MOV Time_Double,EAX			  ; Eax e in Time_Double
						  ; numero clock PM + RM

	MOV EBX,1800B0H
	XOR EDX,EDX
	DIV DWORD PTR EBX			  ; Calcolo il modulo

	PUSH EDX
	POP DX
	POP CX
	MOV AH,1
	INT 1AH                                   ; Setto il clock


	WAIT
	FINIT                                     ; Resetta Coprocessore
	WAIT
	FILD QWORD PTR Time_Double
	WAIT
	FDIV QWORD PTR Clock_K
	WAIT					  ; ST(0) Result
	CALL Double2Long
	PUSH DX
	PUSH AX
	POP ESI

	MOV AH,2AH
	INT 21H
	PUSH DX
	MOVZX EDX,DL
	MOV EAX,ESI
	ADD EAX,EDX                               ; EAX Numero giorni totali

	POP DX
	XOR EBX,EBX
	MOV BL,DH                                 ; EBX=Mese
	XOR EDX,EDX				  ; EDX=Anno
	MOV DX,CX



Rip_Go:	CMP AX,Vet[EBX*2]
	JBE SHORT Go_down
	SUB AX,Vet[EBX*2]
	INC EBX
	CMP EBX,12
	JBE SHORT Rip_Go
	INC EDX
	MOV EBX,1
	JMP SHORT Rip_Go

Go_down:
	MOV CX,DX
	MOV DH,BL
	MOV DL,AL
	MOV AH,2BH
	INT 21H


;------------------------------ LOW RESET -------------------------------------

	MOV EAX,LOW_START_MEM
	SHR EAX,4
	MOV ES,AX                                 ; ES low block

	MOV AH,49H
	INT 21H

	JNC SHORT OVER_PASS_1			  ; On Error
	MOV SI,OFFSET error_LowMem_2
	CALL R_Cout

OVER_PASS_1:

;------------------------------ XMS RESET -------------------------------------

	CMP XMS_DRIVER_ON,0			  ; Xms Driver ?
	JZ SHORT _QUIT				  ; No --> JMP

	MOV DX,XMS_HANDLE                         ; Unlock XMS
	MOV AH,0DH
	CALL [XMS_Control]

	TEST AX,AX
	JNZ SHORT OVER_PASS_2

	MOV SI,OFFSET error_Xms2		  ; Error
	CALL R_Cout

OVER_PASS_2:

	MOV AH,0AH				  ; Free XMS
	CALL [XMS_Control]

	TEST AX,AX
	JNZ SHORT OVER_PASS_3

	MOV SI,OFFSET error_Xms2		  ; Error
	CALL R_Cout

OVER_PASS_3:


_QUIT:
	RMSetup_Cursor

	POP AX                                    ; Restore Error Code

	MOV AH,04CH				  ; EXIT
	INT 21H







;*******************************************************************************
;************************** REAL FUNCTIONS *************************************
;*******************************************************************************

Double2Long	PROC	NEAR

		PUSH BP
		MOV BP,SP
		SUB SP,0AH
		WAIT
		FSTCW WORD PTR [BP-2]
		NOP
		WAIT
		MOV AL,[BP-1]
		OR BYTE PTR [BP-1],0CH
		WAIT
		FLDCW WORD PTR [BP-2]
		WAIT
		FISTP QWORD PTR [BP-0AH]
		MOV [BP-1],AL
		WAIT
		FLDCW WORD PTR [BP-2]
		MOV AX,[BP-0AH]
		MOV DX,[BP-8]
		MOV SP,BP
		POP BP
		RET

Double2Long	ENDP

R_Cout		PROC	NEAR
;		0 	End
;	       13	End of Line
;	       10	Set color	--> Byte
;
		PUSH EDI
		PUSH ES
		PUSH GS

		CLD
		MOV AX,Int_Data			  ; Load Segment
		MOV GS,AX
		MOV AX,0B800H
		MOV ES,AX

		XOR DH,DH                         ; Load info
		MOV DL,GS:[CursorX]
		MOV EDI,GS:[PosXY]
		MOV AH,GS:[CurColor]

R_Cout_1:	LODSB  				  ; Start
		CMP AL,0
		JZ SHORT R_Cout_End
		CMP AL,13
		JZ SHORT R_Cout_EOL
		CMP AL,10
		JZ SHORT R_Cout_CC
		STOSW
		INC DL
		INC DL
		CMP DL,160
		JB SHORT R_Cout_1
		XOR DL,DL
		CMP DI,160*25
		JB SHORT R_Cout_1
		CALL RNext_Page
		JMP SHORT R_Cout_1

R_Cout_EOL:
		SUB DI,DX
		ADD DI,160
		XOR DL,DL
						  ; New Page
		CMP DI,160*25
		JB SHORT R_Cout_1
		CALL RNext_Page
		JMP SHORT R_Cout_1

R_Cout_CC:
		LODSB
		MOV AH,AL
		JMP SHORT R_Cout_1

R_Cout_End:
		MOV GS:[CursorX],DL		  ; Save info
		MOV GS:[PosXY],EDI
		MOV GS:[CurColor],AH

		POP GS
		POP ES
		POP EDI
		RET

RNext_Page:
		PUSH SI
		PUSH DI
		PUSH EAX
		PUSH CX
		PUSH DS
		MOV CX,0B800H
		MOV DS,CX

		MOV CX,160*24/4
		XOR DI,DI
		MOV SI,160

		REP MOVSD

		MOV CL,AH
		MOV AL,32
		SHL EAX,16
		MOV AH,CL
		MOV AL,32

		MOV CX,160/4
		REP STOSD

		POP DS
		POP CX
		POP EAX
		POP DI
		POP SI
		SUB DI,160
		RETN

R_Cout		ENDP




Check_dpmi	PROC NEAR

		MOV AX,01687H
		INT 02FH
		CMP AX,0
		JZ SHORT DPMI
		XOR AL,AL			  ; No error
		RET

DPMI:           MOV SI,OFFSET error_dpmi
		MOV AL,1                          ; Error
		RET

Check_dpmi	ENDP

Check_Win	PROC NEAR

		MOV AX,04680H
		INT 02FH
		CMP AX,0
		JZ SHORT Find_Win

		MOV AX,01600H
		INT 02FH
		TEST AL,07FH
		JNZ SHORT Find_Win
		XOR AL,AL			  ; No error
		RET

Find_Win:       MOV SI,OFFSET error_win
		MOV AL,1                          ; Error
		RET

Check_Win	ENDP



Check_CPU	PROC NEAR
	PUSHFD
	CLI

;       Intel 8086 CPU check
;       Bits 12-15 of the FLAGS register are always set on the
;       8086 processor.
;

	PUSHF
	POP AX
	MOV CX,AX				  ; CX Flags
	AND AX,0FFFH				  ; Clear 12 - 15
	PUSH AX
	POPF                    		  ; Put new FLAGS
	PUSHF					  ; Get new FLAGS
	POP AX
	AND AX,0F000H           		  ; if bits 12-15 are
	CMP AX,0F000H				  ; set, then CPU is 8086
	JNZ SHORT Check_80286


	MOV CPU_TYPE,0
	MOV SI,OFFSET c8086
	JMP End_Get_CPUID

;       Intel 286 CPU check
;       Bits 12-15 of the FLAGS register are always clear on the
;       Intel 286 processor in real-address mode.
;
Check_80286:
	OR CX,0F000H            		  ; try to set bits 12-15
	PUSH CX
	POPF					  ; Put new FLAGS
	PUSHF					  ; Get new FLAGS
	POP AX
	AND AX,0F000H           		  ; if bits 12-15 clear,
	JNZ SHORT Check_80386			  ; CPU=80286


	MOV CPU_TYPE,2
	MOV SI,OFFSET c80286
	JMP End_Get_CPUID

;       Intel386 CPU check
;       The AC bit, bit #18, is a new bit introduced in the EFLAGS
;       register on the Intel486 DX CPU to generate alignment faults.
;       This bit cannot be set on the Intel386 CPU.
;
Check_80386:

	PUSHFD
	MOV EBX,ESP
	AND ESP,NOT 3				  ; align stack to avoid
	PUSHFD					  ; AC fault
	POP EAX                 		  ; Get EFLAGS
	XOR EAX,40000H				  ; Cambio bit 18
	MOV ECX,EAX
	PUSH EAX
	POPFD					  ; Put EFLAGS
	PUSHFD
	POP EAX					  ; Get EFLAGS
	MOV ESP,EBX
	POPFD					  ; Restore Flag

	CMP EAX,ECX				  ; Se uguale 486 o superiore
	JZ SHORT check_80486


	MOV CPU_TYPE,3
	MOV SI,OFFSET c80386
	JMP SHORT End_Get_CPUID


;       Intel486 DX CPU, Intel487 SX NDP, and Intel486 SX CPU check
;       Checking for ability to set/clear ID flag (Bit 21) in EFLAGS
;       which indicates the presence of a processor
;       with the ability to use the CPUID instruction.
;
check_80486:
	PUSHFD
	PUSHFD
	POP EAX
	XOR EAX,200000H				  ; Cambia il bit 21
	MOV ECX,EAX
	PUSH EAX
	POPFD			  		  ; Put flags
	PUSHFD
	POP EAX			  		  ; Get flags
	POPFD

	MOV CPU_TYPE,4
	MOV SI,OFFSET c80486

	CMP EAX,ECX
	JNZ SHORT End_Get_CPUID

;       Execute CPUID instruction to determine vendor, family,
;       model and stepping.
;
check_Pentiums:
	PUSH ES
	MOV AX,Kernel_Data
	MOV ES,AX

	CLD				          ; CLEAR DIRECTION FLAG

	XOR EAX,EAX				  ; INPUT OF CPUID ISTRUCTION

	DB 0FH,0A2H				  ; CPUID Istruction

	MOV SI,OFFSET VENDOR_ID

	MOV DWORD PTR [SI],EBX
	MOV DWORD PTR [SI+4],EDX
	MOV DWORD PTR [SI+8],ECX

	MOV DI,OFFSET INTEL_ID
	MOV CX,12

	REPE CMPSB		        	  ; compare vendor id
	JNZ SHORT IsntINTEL			  ; to "GenuineIntel"
						  ; if not zero, not an Intel
						  ; CPU.
	MOV INTEL_PROC, 1

	POP ES

	MOV CPU_TYPE,5
	MOV SI,OFFSET Pentium_msg

	JMP SHORT End_Get_CPUID


IsntINTEL:
	MOV CPU_TYPE,5
	MOV SI,OFFSET c80586

End_Get_CPUID:
	POPFD					  ; Ripristina anche
						  ; INTERRUPT flag
	RET
Check_CPU	ENDP


Set_GDT 	PROC NEAR

	MOV EAX,SEG Global_Data
	SHL EAX,4                                 ; EBX = Flat address of
	MOV EBX,EAX                               ;	  Global Data

	ADD EAX,OFFSET GDTStart			  ; Set GDTR register
	MOV GDTAddr,EAX

	MOV EAX,EBX                               ; Set IDTR register
	ADD EAX,OFFSET IDTStart
	MOV IDTAddr,EAX

	MOV EAX,EBX                               ; Set Global Table
	MOV Global_Desc.Base_0,AX
	SHR EAX,16
	MOV Global_Desc.Base_1,AL

	MOV EAX,EBX				  ; Set Start Task
	ADD EAX,OFFSET Start_TSS
	MOV StartTSS_Desc.Base_0,AX
	SHR EAX,16
	MOV StartTSS_Desc.Base_1,AL

	MOV EAX,SEG Kernel_Code			  ; Set Kernel_Code 16
	SHL EAX,4
	MOV Code_Desc.Base_0,AX
	SHR EAX,16
	MOV Code_Desc.Base_1,AL

	MOV EAX,SEG Kernel_Data			  ; Set Kernel_Data 16
	SHL EAX,4				  ; Info [ROM] 16
	MOV Data_Desc.Base_0,AX
	MOV Info_Desc.Base_0,AX
	SHR EAX,16
	MOV Data_Desc.Base_1,AL
	MOV Info_Desc.Base_1,AL

	MOV EAX,SEG Kernel_Stack		  ; Set Kernel_Stack 32
	SHL EAX,4
	MOV Stack_Desc.Base_0,AX
	SHR EAX,16
	MOV Stack_Desc.Base_1,AL

	MOV EAX,SEG IDT_Stack			  ; Set IDT_Stack 32
	SHL EAX,4
	MOV IDTStack_Desc.Base_0,AX
	SHR EAX,16
	MOV IDTStack_Desc.Base_1,AL

	MOV EAX,SEG Int_Code                      ; Set Interrupt CODE 32
	SHL EAX,4
	MOV Int_Desc.Base_0,AX
	SHR EAX,16
	MOV Int_Desc.Base_1,AL

	MOV EAX,SEG Int_Data			  ; Set Interrupt DATA 32
	SHL EAX,4
	MOV Int_DDesc.Base_0,AX
	SHR EAX,16
	MOV Int_DDesc.Base_1,AL

	MOVZX EAX,PSP				  ; Set Prefisso del segmento
	SHL EAX,4				  ; del programma (PSP).
	MOV PSP_Desc.Base_0,AX
	SHR EAX,16
	MOV PSP_Desc.Base_1,AL
	MOV FS,PSP
	XOR AX,AX
	MOV AL,FS:[80H]
	ADD AX,81H-1H
	MOV PSP_Desc.Limit_0,AX

	MOV EAX,SEG Start_SEG                     ; Set Start code 32
	SHL EAX,4
	MOV Start_Desc.Base_0,AX
	SHR EAX,16
	MOV Start_Desc.Base_1,AL

	MOV EAX,SEG Start_Data			  ; Set Start data 32
	SHL EAX,4
	MOV Start_DescD.Base_0,AX
	SHR EAX,16
	MOV Start_DescD.Base_1,AL



; ----------------------- Setup Task Exception -------------------------------

	MOV EAX,EBX
	ADD EAX,OFFSET Task_Exc_00
	MOV BX,OFFSET Desc_Ex_00
	MOV CX,TSS_EXCEPTION

@@TSS_REP:
	MOV EDX,EAX
	MOV ES:[BX].Base_0,DX
	SHR EDX,16
	MOV ES:[BX].Base_1,DL
	ADD BX,8
	ADD EAX,DIM_TSS
	LOOP SHORT @@TSS_REP

; ---------------------------- Setup LOW -------------------------------------

	MOV EAX,LOW_START_MEM
	MOV LOW_Desc.Base_0,AX
	SHR EAX,16
	MOV LOW_Desc.Base_1,AL
	MOV LOW_Desc.Base_2,AH

	MOV EAX,LOW_FREE_MEM
	DEC EAX
	MOV LOW_Desc.Limit_0,AX
	SHR EAX,16
	OR AL,1000000B
	MOV LOW_Desc.Limit_1,AL



; ---------------------------- Setup XMS -------------------------------------

	MOV EAX,XMS_START_MEM
	MOV XMS_Desc.Base_0,AX
	SHR EAX,16
	MOV XMS_Desc.Base_1,AL
	MOV XMS_Desc.Base_2,AH

	MOV EAX,XMS_FREE_MEM			  ; AX dividibile per 4
	SHR EAX,12                                ; In AX numero di free 4 K.
	DEC EAX					  ; Qui deve essere fatta
						  ; la sottrazione.

	MOV XMS_Desc.Limit_0,AX
	SHR EAX,16
	OR AL,11000000B				  ; Set granularity
	MOV XMS_Desc.Limit_1,AL


	RET

Set_GDT 	ENDP





;*******************************************************************************
;********************* REAL FUNCTIONS CALLED FROM PROTECTED MODE ***************
;*******************************************************************************



Restore_Video	PROC	FAR

		MOV AX,3
		INT 10H
		RETF

Restore_Video	ENDP

Real		PROC FAR

		PUSH DS
		PUSH ES
		PUSH GS
		PUSH FS				  ; Interrupt are OFF

		MOV AX,SelData
		MOV FS,AX			  ; Data Register in FS

		MOV FS:[ProtESP],ESP		  ; Salva old ESP & SS
		MOV FS:[ProtStack],SS

		MOV SS,AX                         ; SS has got real Limit
		MOV AX,SelFlat			  ; Flat Model
		MOV DS,AX
		MOV ES,AX
		MOV GS,AX

		MOV FS:[Dest_OFF],BX		  ; Save the destination
		MOV FS:[Dest_SEG],DX

		MOV EAX,CR0			  ; Back real
		AND AL,NOT 1
		MOV CR0,EAX

		DB      0EAH
		DW      OFFSET @@REAL
		DW	Kernel_Code
@@REAL:

		MOV AX,PM2Real_Stack              ; Get real Stack
		MOV SS,AX
		MOV ESP,DIM_STPM2RM

		Setup_irq 08H,70H		  ; N.B. : Circa 50 clock

		MOV AL,FS:[P2R_PIC1Mask]	  ; Ability all Interrupt
		OUT PIC1_DATA,AL
		MOV AL,FS:[P2R_PIC2Mask]
		OUT PIC2_DATA,AL

		LIDT FWORD PTR FS:[Old_IDTR]

		STI

		;--
			CALL FS:[Dest_Ind]		  ; Gooo !
		;--

		CLI

		Setup_irq 020H,028H

		MOV AX,Kernel_Data
		MOV DS,AX

		MOV AL,PM_PIC1Mask		  ; Ability all Interrupts
		OUT PIC1_DATA,AL
		MOV AL,PM_PIC2Mask
		OUT PIC2_DATA,AL

		LIDT FWORD PTR IDTInfo

		MOV EAX,CR0                       ; Let's back protected
		OR AL,1
		MOV CR0,EAX
		JMP $+2

		MOV SS,ProtStack                  ; Reload SS & ESP
		MOV ESP,ProtESP

		PUSH DWORD PTR 0		  ; Reset FLAGS
		POPFD

		POP FS				  ; And all register
		POP GS
		POP ES
		POP DS


		IRETD

Real		ENDP

SvgaInit_R	PROC FAR

		MOV AX,Kernel_Data
		MOV DS,AX
		MOV AX,SS
		MOV ES,AX
		SUB SP,256
		MOV DI,SP
		MOV AX,4F00H
		INT 10H
		CMP AX,004FH
		JNE SHORT Svga_Error

		CMP BYTE PTR ES:[DI],'V'
		JNE SHORT Svga_Error
		CMP BYTE PTR ES:[DI+1],'E'
		JNE SHORT Svga_Error
		CMP BYTE PTR ES:[DI+2],'S'
		JNE SHORT Svga_Error
		CMP BYTE PTR ES:[DI+3],'A'
		JNE SHORT Svga_Error

		XOR EBX,EBX
		XOR EAX,EAX
		MOV AX,ES:[DI+6]                  ; OEM String
		MOV BX,ES:[DI+8]
		SHL EBX,4
		ADD EBX,EAX

		MOV AL,ES:[DI+4]                  ; Version
		MOV Svga_VL,AL
		MOV AL,ES:[DI+5]
		MOV Svga_VH,AL

		MOV AX,ES:[DI+18]		  ; Video_Mem
		SHL EAX,16
		MOV Svga_Mem,EAX

		MOV CX,Global_Data
		MOV DS,CX
		SHR EAX,12                        ; Set SVGA_Desc
		DEC EAX

ASSUME		DS:Global_Data

		MOV SVGA_Desc.Limit_0,AX
		SHR EAX,16
		OR AL,11000000B			  ; Set granularity
		MOV SVGA_Desc.Limit_1,AL


		ADD SP,256                        ; [EBX] = OEM
		MOV CL,0                          ; CL = ON (0)
		RETF
Svga_Error:     ADD SP,256
		MOV CL,1
		RETF

SvgaInit_R	ENDP

SvgaSetLinerar_Buffer	PROC FAR

		PUSH BX
		PUSH DS
		MOV BX,Global_Data
		MOV DS,BX

		MOV SVGA_Desc.Base_0,AX
		SHR EAX,16
		MOV SVGA_Desc.Base_1,AL
		MOV SVGA_Desc.Base_2,AH

		POP DS
		POP BX
		RETF

SvgaSetLinerar_Buffer   ENDP

ASSUME		DS:Kernel_Data

Kernel_Code	ENDS





;*******************************************************************************
;*************************** GLOBAL DATA ***************************************
;*******************************************************************************

Global_Data	SEGMENT PUBLIC PARA  USE32 'DATA'

Global_Limit_Low	EQU $

;*********************** GLOBAL DESCRIPTOR TABLE *******************************

ALIGN 16						; Allinea a 64 bits

GDTStart 	Seg_Descr <0,0,0,0,0,0>          	; NULL descriptor

_access         = A_PRESENT+A_USER+A_CODE+AC_READ+A_ACCESS
Code_Desc       Seg_Descr <0FFFFH,?,?,_access,0,0>      ; Code segment 16
							; becouse it is
							; the start and the
							; return of PM and
							; we need to restore
							; the CS RIGHTS

_access         = A_PRESENT+A_USER+AD_WRITE+A_ACCESS	; Data segment 16
Data_Desc	Seg_Descr <0FFFFH,?,?,_access,0,0>


_access         = A_PRESENT+A_USER+AD_WRITE+A_ACCESS	; Kernel_Stack 32
Stack_Desc	Seg_Descr <DIM_STACK-1,?,?,_access,40H,0>


_access         = A_PRESENT+A_USER+AD_WRITE+A_ACCESS	; IDT_Stack    32
IDTStack_Desc   Seg_Descr <IDT_DIMSTACK-1,?,?,_access,40H,0>


_access         = A_PRESENT+A_USER+AD_WRITE+A_ACCESS	; Global Table 32
Global_Desc	Seg_Descr <Global_Limit,?,?,_access,40H,0>


_access         = A_PRESENT+A_USER+A_CODE+AC_CONFORM+A_ACCESS
Int_Desc	Seg_Descr <Int_Limit,?,?,_access,40H,0>	; Interrupt Routines
							;	32

_access         = A_PRESENT+A_USER+AD_WRITE+A_ACCESS	; Interrupt
Int_DDesc	Seg_Descr <IntD_Limit,?,?,_access,40H,0>; Data segment 32


_access         = A_PRESENT+A_USER+AD_WRITE+A_ACCESS	; Flat Data    32
Flat_Desc	Seg_Descr <0FFFFH,0,0,_access,0CFH,0>	;   0 --> 4 Gb


_access         = A_PRESENT+ACT_A386			; Task of Program
StartTSS_Desc	Seg_Descr <DIM_TSS-1,?,?,_access,40H,0> ;      32


_access         = A_PRESENT+A_USER+A_ACCESS		; Info for Program
Info_Desc	Seg_Descr <0FFFFH,?,?,_access,0,0>	;    [ROM] 16


_access         = A_PRESENT+A_USER+A_ACCESS		; PSP of Program
PSP_Desc	Seg_Descr <?,?,?,_access,40H,0>		;    [ROM] 32


_access         = A_PRESENT+A_USER+A_CODE+AC_READ+A_ACCESS ; Code Start   32
Start_Desc      Seg_Descr <Start_Limit,?,?,_access,40H,0>


_access         = A_PRESENT+A_USER+AD_WRITE+A_ACCESS	; Data segment 32
Start_DescD	Seg_Descr <StartData_Limit,?,?,_access,40H,0>




;--------------------- Exception Task Gate ------------------------

_access         = A_PRESENT+ACT_A386
Desc_Ex_00 	Seg_Descr <DIM_TSS-1,?,?,_access,40H,0>
Desc_Ex_01 	Seg_Descr <DIM_TSS-1,?,?,_access,40H,0>
Desc_Ex_02 	Seg_Descr <DIM_TSS-1,?,?,_access,40H,0>
Desc_Ex_03 	Seg_Descr <DIM_TSS-1,?,?,_access,40H,0>
Desc_Ex_04 	Seg_Descr <DIM_TSS-1,?,?,_access,40H,0>
Desc_Ex_05 	Seg_Descr <DIM_TSS-1,?,?,_access,40H,0>
Desc_Ex_06 	Seg_Descr <DIM_TSS-1,?,?,_access,40H,0>
Desc_Ex_07 	Seg_Descr <DIM_TSS-1,?,?,_access,40H,0>
Desc_Ex_08 	Seg_Descr <DIM_TSS-1,?,?,_access,40H,0>
Desc_Ex_09 	Seg_Descr <DIM_TSS-1,?,?,_access,40H,0>
Desc_Ex_10 	Seg_Descr <DIM_TSS-1,?,?,_access,40H,0>
Desc_Ex_11 	Seg_Descr <DIM_TSS-1,?,?,_access,40H,0>
Desc_Ex_12 	Seg_Descr <DIM_TSS-1,?,?,_access,40H,0>
Desc_Ex_13 	Seg_Descr <DIM_TSS-1,?,?,_access,40H,0>
Desc_Ex_14 	Seg_Descr <DIM_TSS-1,?,?,_access,40H,0>
Desc_Ex_16 	Seg_Descr <DIM_TSS-1,?,?,_access,40H,0>
Desc_Ex_17 	Seg_Descr <DIM_TSS-1,?,?,_access,40H,0>
Desc_Ex_Unk	Seg_Descr <DIM_TSS-1,?,?,_access,40H,0>

TSS_EXCEPTION   EQU 18                                  ; Number of Exception




;------------------ Descrittori della Memoria ---------------------

_access         = A_PRESENT+A_USER+AD_WRITE+A_ACCESS	; LOW 32 bit
LOW_Desc	Seg_Descr <?,?,?,_access,?,?>

_access         = A_PRESENT+A_USER+AD_WRITE+A_ACCESS	; XMS 32 bit
XMS_Desc	Seg_Descr <?,?,?,_access,?,?>

_access         = A_PRESENT+A_USER+AD_WRITE+A_ACCESS	; Mappa dei Caratteri
Char_Desc	Seg_Descr <2047,0FA6EH,0FH,_access,40H,0>




;------------------- Descrittori per OUTPUT -----------------------

_access         = A_PRESENT+A_USER+AD_WRITE+A_ACCESS	; Video Mod. 3
VGA_Text_Desc   Seg_Descr <(160*25)-1,8000H,0BH,_access,40H,0>

_access         = A_PRESENT+A_USER+AD_WRITE+A_ACCESS	; Video Mod. 13
VGA_13_Desc     Seg_Descr <(320*200)-1,0000H,0AH,_access,40H,0>

_access         = A_PRESENT+A_USER+AD_WRITE+A_ACCESS	; Svga Linear Buff
SVGA_Desc	Seg_Descr <?,?,?,_access,?,?>		; 	32



;------------------- Descrittori Ausiliari ------------------------

GDT_Desc	EQU $
		 REPT (MAX_DESC)
			Seg_Descr <>
		 ENDM

Last_GDT	DD	GDT_Desc



GDTEnd          EQU     $




;********************* INTERRUPT DESCRIPTOR TABLE ******************************

ALIGN 16                                                ; Allinea a 64 bits

IDTStart	EQU     $

		 IDT_TASK_GATE <0,SelExTSS_0,0,85H,0>
		 IDT_TASK_GATE <0,SelExTSS_1,0,85H,0>
		 IDT_TASK_GATE <0,SelExTSS_2,0,85H,0>
		 IDT_TASK_GATE <0,SelExTSS_3,0,85H,0>
		 IDT_TASK_GATE <0,SelExTSS_4,0,85H,0>
		 IDT_TASK_GATE <0,SelExTSS_5,0,85H,0>
		 IDT_TASK_GATE <0,SelExTSS_6,0,85H,0>
		 IDT_TASK_GATE <0,SelExTSS_7,0,85H,0>
		 IDT_TASK_GATE <0,SelExTSS_8,0,85H,0>
		 IDT_TASK_GATE <0,SelExTSS_9,0,85H,0>
		 IDT_TASK_GATE <0,SelExTSS_10,0,85H,0>
		 IDT_TASK_GATE <0,SelExTSS_11,0,85H,0>
		 IDT_TASK_GATE <0,SelExTSS_12,0,85H,0>
		 IDT_TASK_GATE <0,SelExTSS_13,0,85H,0>
		 IDT_TASK_GATE <0,SelExTSS_14,0,85H,0>
		 IDT_TASK_GATE <0,SelExTSS_Unk,0,85H,0>
		 IDT_TASK_GATE <0,SelExTSS_16,0,85H,0>
		 IDT_TASK_GATE <0,SelExTSS_17,0,85H,0>
		 IDT_TASK_GATE <0,SelExTSS_Unk,0,85H,0>
		 IDT_TASK_GATE <0,SelExTSS_Unk,0,85H,0>
		 IDT_TASK_GATE <0,SelExTSS_Unk,0,85H,0>
		 IDT_TASK_GATE <0,SelExTSS_Unk,0,85H,0>
		 IDT_TASK_GATE <0,SelExTSS_Unk,0,85H,0>
		 IDT_TASK_GATE <0,SelExTSS_Unk,0,85H,0>
		 IDT_TASK_GATE <0,SelExTSS_Unk,0,85H,0>
		 IDT_TASK_GATE <0,SelExTSS_Unk,0,85H,0>
		 IDT_TASK_GATE <0,SelExTSS_Unk,0,85H,0>
		 IDT_TASK_GATE <0,SelExTSS_Unk,0,85H,0>
		 IDT_TASK_GATE <0,SelExTSS_Unk,0,85H,0>
		 IDT_TASK_GATE <0,SelExTSS_Unk,0,85H,0>
		 IDT_TASK_GATE <0,SelExTSS_Unk,0,85H,0>
		 IDT_TASK_GATE <0,SelExTSS_Unk,0,85H,0>


		 IDT_GATE <OFFSET Timer,SelInterrupt,0,8EH,0>	     ; IRQ 0
		 IDT_GATE <OFFSET Keyboard,SelInterrupt,0,8EH,0>     ; IRQ 1
		 IDT_GATE <OFFSET Unused_low,SelInterrupt,0,8EH,0>   ; IRQ 2
		 IDT_GATE <OFFSET Unused_low,SelInterrupt,0,8EH,0>   ; IRQ 3
		 IDT_GATE <OFFSET Unused_low,SelInterrupt,0,8EH,0>   ; IRQ 4
		 IDT_GATE <OFFSET Unused_low,SelInterrupt,0,8EH,0>   ; IRQ 5
		 IDT_GATE <OFFSET Unused_low,SelInterrupt,0,8EH,0>   ; IRQ 6
		 IDT_GATE <OFFSET Unused_low,SelInterrupt,0,8EH,0>   ; IRQ 7
		 IDT_GATE <OFFSET Unused_high,SelInterrupt,0,8EH,0>  ; IRQ 8
		 IDT_GATE <OFFSET Unused_high,SelInterrupt,0,8EH,0>  ; IRQ 9
		 IDT_GATE <OFFSET Unused_high,SelInterrupt,0,8EH,0>  ; IRQ 10
		 IDT_GATE <OFFSET Unused_high,SelInterrupt,0,8EH,0>  ; IRQ 11
		 IDT_GATE <OFFSET Unused_high,SelInterrupt,0,8EH,0>  ; IRQ 12
		 IDT_GATE <OFFSET Unused_high,SelInterrupt,0,8EH,0>  ; IRQ 13
		 IDT_GATE <OFFSET Unused_high,SelInterrupt,0,8EH,0>  ; IRQ 14
		 IDT_GATE <OFFSET Unused_high,SelInterrupt,0,8EH,0>  ; IRQ 15


; -------------------------- System Softaware Interrupt ------------------------

		 IDT_GATE <OFFSET Terminate,SelInterrupt,0,8EH,0>    ; INT 48
		 IDT_GATE <OFFSET New_GDT_Desc,SelInterrupt,0,8EH,0> ; INT 49
		 IDT_GATE <OFFSET Real,SelCode,0,8EH,0>              ; INT 50
		 IDT_GATE <OFFSET Set_PIC,SelInterrupt,0,8EH,0>      ; INT 51


; -------------------------- Device Softaware Interrupt ------------------------

		 IDT_GATE <OFFSET Getch,SelInterrupt,0,8EH,0>        ; INT 52
		 IDT_GATE <OFFSET KbHit,SelInterrupt,0,8EH,0>        ; INT 53
		 IDT_GATE <OFFSET Cout,SelInterrupt,0,8EH,0>         ; INT 54
		 IDT_GATE <OFFSET Locate,SelInterrupt,0,8EH,0>       ; INT 55
		 IDT_GATE <OFFSET GraphTxt,SelInterrupt,0,8EH,0>     ; INT 56
		 IDT_GATE <OFFSET SvgaInit,SelInterrupt,0,8EH,0>     ; INT 57

IDTEnd          EQU     $



;****************************** TASK S *****************************************

ALIGN 16						; Allinea a 64 bits

Start_TSS	Tss386  <0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  \
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0>
DIM_TSS		EQU $-Start_TSS



Task_Exc_00	Tss386  <0,0,IDT_DIMSTACK,SelIDTStack,0,0,0,0,0,0,0,0, \
		OFFSET Exception,0,0,0,0,0,IDT_DIMSTACK,0,	       \
		OFFSET Task_Exc_00.t3BackLink,OFFSET msgDivide,	       \
		SelInt_Data,0,SelInterrupt,0,SelIDTStack,0,SelFlat,0,  \
		SelGlobal,0,0,0,0,0,0>

Task_Exc_01	Tss386  <0,0,IDT_DIMSTACK,SelIDTStack,0,0,0,0,0,0,0,0, \
		OFFSET Exception,0,0,0,0,0,IDT_DIMSTACK,0,             \
		OFFSET Task_Exc_01.t3BackLink,OFFSET msgTrap,          \
		SelInt_Data,0,SelInterrupt,0,SelIDTStack,0,SelFlat,0,  \
		SelGlobal,0,0,0,0,0,0>

Task_Exc_02	Tss386  <0,0,IDT_DIMSTACK,SelIDTStack,0,0,0,0,0,0,0,0, \
		OFFSET Exception,0,0,0,0,0,IDT_DIMSTACK,0,             \
		OFFSET Task_Exc_02.t3BackLink,OFFSET msgNMI,           \
		SelInt_Data,0,SelInterrupt,0,SelIDTStack,0,SelFlat,0,  \
		SelGlobal,0,0,0,0,0,0>

Task_Exc_03	Tss386  <0,0,IDT_DIMSTACK,SelIDTStack,0,0,0,0,0,0,0,0, \
		OFFSET Exception,0,0,0,0,0,IDT_DIMSTACK,0,             \
		OFFSET Task_Exc_03.t3BackLink,OFFSET msgBrPoint,       \
		SelInt_Data,0,SelInterrupt,0,SelIDTStack,0,SelFlat,0,  \
		SelGlobal,0,0,0,0,0,0>

Task_Exc_04	Tss386  <0,0,IDT_DIMSTACK,SelIDTStack,0,0,0,0,0,0,0,0, \
		OFFSET Exception,0,0,0,0,0,IDT_DIMSTACK,0,             \
		OFFSET Task_Exc_04.t3BackLink,OFFSET msgOverflow,      \
		SelInt_Data,0,SelInterrupt,0,SelIDTStack,0,SelFlat,0,  \
		SelGlobal,0,0,0,0,0,0>

Task_Exc_05	Tss386  <0,0,IDT_DIMSTACK,SelIDTStack,0,0,0,0,0,0,0,0, \
		OFFSET Exception,0,0,0,0,0,IDT_DIMSTACK,0,             \
		OFFSET Task_Exc_05.t3BackLink,OFFSET msgBounds,        \
		SelInt_Data,0,SelInterrupt,0,SelIDTStack,0,SelFlat,0,  \
		SelGlobal,0,0,0,0,0,0>

Task_Exc_06	Tss386  <0,0,IDT_DIMSTACK,SelIDTStack,0,0,0,0,0,0,0,0, \
		OFFSET Exception,0,0,0,0,0,IDT_DIMSTACK,0,             \
		OFFSET Task_Exc_06.t3BackLink,OFFSET msgOpcode,        \
		SelInt_Data,0,SelInterrupt,0,SelIDTStack,0,SelFlat,0,  \
		SelGlobal,0,0,0,0,0,0>

Task_Exc_07	Tss386  <0,0,IDT_DIMSTACK,SelIDTStack,0,0,0,0,0,0,0,0, \
		OFFSET Exception,0,0,0,0,0,IDT_DIMSTACK,0,             \
		OFFSET Task_Exc_07.t3BackLink,OFFSET msgMathGone,      \
		SelInt_Data,0,SelInterrupt,0,SelIDTStack,0,SelFlat,0,  \
		SelGlobal,0,0,0,0,0,0>

Task_Exc_08	Tss386  <0,0,IDT_DIMSTACK,SelIDTStack,0,0,0,0,0,0,0,0, \
		OFFSET Exception,0,0,1,0,0,IDT_DIMSTACK-4,0,           \
		OFFSET Task_Exc_08.t3BackLink,OFFSET msgDouble,        \
		SelInt_Data,0,SelInterrupt,0,SelIDTStack,0,SelFlat,0,  \
		SelGlobal,0,0,0,0,0,0>

Task_Exc_09	Tss386  <0,0,IDT_DIMSTACK,SelIDTStack,0,0,0,0,0,0,0,0, \
		OFFSET Exception,0,0,0,0,0,IDT_DIMSTACK,0,             \
		OFFSET Task_Exc_09.t3BackLink,OFFSET msgMathOver,      \
		SelInt_Data,0,SelInterrupt,0,SelIDTStack,0,SelFlat,0,  \
		SelGlobal,0,0,0,0,0,0>

Task_Exc_10	Tss386  <0,0,IDT_DIMSTACK,SelIDTStack,0,0,0,0,0,0,0,0, \
		OFFSET Exception,0,0,1,0,0,IDT_DIMSTACK-4,0,           \
		OFFSET Task_Exc_10.t3BackLink,OFFSET msgTSS,           \
		SelInt_Data,0,SelInterrupt,0,SelIDTStack,0,SelFlat,0,  \
		SelGlobal,0,0,0,0,0,0>

Task_Exc_11	Tss386  <0,0,IDT_DIMSTACK,SelIDTStack,0,0,0,0,0,0,0,0, \
		OFFSET Exception,0,0,1,0,0,IDT_DIMSTACK-4,0,           \
		OFFSET Task_Exc_11.t3BackLink,OFFSET msgSegment,       \
		SelInt_Data,0,SelInterrupt,0,SelIDTStack,0,SelFlat,0,  \
		SelGlobal,0,0,0,0,0,0>

Task_Exc_12	Tss386  <0,0,IDT_DIMSTACK,SelIDTStack,0,0,0,0,0,0,0,0, \
		OFFSET Exception,0,0,1,0,0,IDT_DIMSTACK-4,0,           \
		OFFSET Task_Exc_12.t3BackLink,OFFSET msgStack,         \
		SelInt_Data,0,SelInterrupt,0,SelIDTStack,0,SelFlat,0,  \
		SelGlobal,0,0,0,0,0,0>

Task_Exc_13	Tss386  <0,0,IDT_DIMSTACK,SelIDTStack,0,0,0,0,0,0,0,0, \
		OFFSET Exception,0,0,1,0,0,IDT_DIMSTACK-4,0,           \
		OFFSET Task_Exc_13.t3BackLink,OFFSET msgGeneral,       \
		SelInt_Data,0,SelInterrupt,0,SelIDTStack,0,SelFlat,0,  \
		SelGlobal,0,0,0,0,0,0>

Task_Exc_14	Tss386  <0,0,IDT_DIMSTACK,SelIDTStack,0,0,0,0,0,0,0,0, \
		OFFSET Exception,0,0,1,0,0,IDT_DIMSTACK-4,0,           \
		OFFSET Task_Exc_14.t3BackLink,OFFSET msgPage,          \
		SelInt_Data,0,SelInterrupt,0,SelIDTStack,0,SelFlat,0,  \
		SelGlobal,0,0,0,0,0,0>

Task_Exc_16	Tss386  <0,0,IDT_DIMSTACK,SelIDTStack,0,0,0,0,0,0,0,0, \
		OFFSET Exception,0,0,0,0,0,IDT_DIMSTACK,0,             \
		OFFSET Task_Exc_16.t3BackLink,OFFSET msgMathErr,       \
		SelInt_Data,0,SelInterrupt,0,SelIDTStack,0,SelFlat,0,  \
		SelGlobal,0,0,0,0,0,0>

Task_Exc_17	Tss386  <0,0,IDT_DIMSTACK,SelIDTStack,0,0,0,0,0,0,0,0, \
		OFFSET Exception,0,0,1,0,0,IDT_DIMSTACK-4,0,           \
		OFFSET Task_Exc_17.t3BackLink,OFFSET msgAC,            \
		SelInt_Data,0,SelInterrupt,0,SelIDTStack,0,SelFlat,0,  \
		SelGlobal,0,0,0,0,0,0>

Task_Exc_Unk	Tss386  <0,0,IDT_DIMSTACK,SelIDTStack,0,0,0,0,0,0,0,0, \
		OFFSET Exception,0,0,0,0,0,IDT_DIMSTACK,0,             \
		OFFSET Task_Exc_Unk.t3BackLink,OFFSET msgUNKNOWN,      \
		SelInt_Data,0,SelInterrupt,0,SelIDTStack,0,SelFlat,0,  \
		SelGlobal,0,0,0,0,0,0>




Global_Limit	EQU     $-Global_Limit_Low-1

Global_Data	ENDS




;*******************************************************************************
;************************* INTERRUPT CODE **************************************
;*******************************************************************************

Int_Code	SEGMENT PUBLIC PARA USE32 'INTERRUPT'
Int_Limit_Low	EQU $
		ASSUME  CS:Int_Code
		ASSUME  SS:Kernel_Stack
		ASSUME  DS:NOTHING
		ASSUME  ES:NOTHING
		ASSUME  FS:NOTHING
		ASSUME  GS:NOTHING


Exception:
	     MOV BX,FS:[ESI]			  ; No interrupt
	     MOV ES:_N_TASK,BX
	     AND BL,0F8H			  ; Toglie il DPL
	     ADD EBX,OFFSET GDTStart		  ; al selettore.


	     MOV AH,FS:[EBX].Base_2		  ; FS:EBX indirizzo del
	     MOV AL,FS:[EBX].Base_1		  ; selettore del task.
	     SHL EAX,16			  	  ; Esso risiede solo
	     MOV AX,FS:[EBX].Base_0		  ; nella GDT, quindi
	     MOV ESI,EAX			  ; solo in Global_Data.
						  ; DS:ESI Task



	     ADD ESI,OFFSET t3EIP		  ; DS -> ES: []
	     LODSD
	     MOV ES:_EIP,EAX
	     LODSD
	     MOV ES:_EFLAG,EAX
	     MOV ES:_FLAGL,AL
	     MOV ES:_FLAGH,AH
	     LODSD
	     MOV ES:_EAX,EAX
	     LODSD
	     MOV ES:_ECX,EAX
	     LODSD
	     MOV ES:_EDX,EAX
	     LODSD
	     MOV ES:_EBX,EAX
	     LODSD
	     MOV ES:_ESP,EAX
	     LODSD
	     MOV ES:_EBP,EAX
	     LODSD
	     MOV ES:_ESI,EAX
	     LODSD
	     MOV ES:_EDI,EAX
	     LODSD
	     MOV ES:_ES,AX
	     LODSD
	     MOV ES:_CS,AX
	     MOV ES:_CS_2,AX
	     LODSD
	     MOV ES:_SS,AX
	     LODSD
	     MOV ES:_DS,AX
	     LODSD
	     MOV ES:_FS,AX
	     LODSD
	     MOV ES:_GS,AX
	     CMP CL,0
	     JZ SHORT No_Error 		          ; No Error Code
	     POP ES:_ERROR
	     MOV ES:_ErrPre,13
No_Error:

	     MOV EBX,OFFSET Restore_Video	  ; Video Restoring
	     MOV EDX,SEG Kernel_Code
	     INT 50


	     MOV EAX,SelInt_Data
	     MOV DS,EAX
	     MOV EAX,SelGlobal
	     MOV ES,EAX

	     XOR EAX,EAX		          ; Put Cursore
	     INT 55
	     MOV ESI,OFFSET R_Color		  ; Restore color
	     INT 54
	     MOV ESI,EDI                          ; DS:ESI Messaggio
	     INT 54


	     MOV ESI,OFFSET Debug		  ; Print Debug Info
	     INT 54
	     MOV AX,DS:_DS  			  ; Pick DS
	     CALL Pick_Info

	     MOV ESI,OFFSET _SSInit               ; Print SS Info
	     INT 54
	     MOV AX,DS:_SS  			  ; Pick SS
	     CALL Pick_Info

	     MOV ESI,OFFSET _ESInit               ; Print ES Info
	     INT 54
	     MOV AX,DS:_ES  			  ; Pick ES
	     CALL Pick_Info

	     MOV ESI,OFFSET _GSInit               ; Print GS Info
	     INT 54
	     MOV AX,DS:_GS  			  ; Pick GS
	     CALL Pick_Info

	     MOV ESI,OFFSET _FSInit               ; Print FS Info
	     INT 54
	     MOV AX,DS:_FS  			  ; Pick FS
	     CALL Pick_Info

	     MOV ESI,OFFSET _CSInit               ; Print CS Info
	     INT 54
	     MOV AX,DS:_CS_2			  ; Pick CS
	     CALL Pick_Info

	     MOV ESI,OFFSET _StTask		  ; Print Task & Error
	     INT 54
	     MOV ESI,OFFSET _StFlag		  ; Print EFlags
	     INT 54


	     MOV BL,0FFH			  ; Error FFH to RM
	     DB 0EAH
	     DD OFFSET CALL_BACK_REAL_MODE
	     DW	SelCode

;-----------------------------------------------------------------------------

Pick_Info	PROC NEAR

	     TEST AL,100b
	     JZ SHORT Is_GDT
						  ; Is an LDT descriptor
	     MOV ESI,OFFSET _iLdt		  ; so print it.
	     INT 54
	     RET

Is_GDT:	     AND AL,0F8H
	     MOVZX EAX,AX
	     ADD EAX,OFFSET GDTStart	          ; ES:EAX Descrittore
	     CMP EAX,OFFSET GDTEnd-4
	     JB SHORT Is_OK

	     MOV ESI,OFFSET _iUnk		  ; Invalid Descriptor
	     INT 54
	     RET

Is_OK:
	     MOV BX,ES:[EAX].Limit_0
	     MOV DS:_SLL,BX
	     MOV BL,ES:[EAX].Limit_1
	     MOV DS:_SLH,BL			  ; Save Limit


	     MOV BH,ES:[EAX].Base_2
	     MOV BL,ES:[EAX].Base_1
	     SHL EBX,16
	     MOV BX,ES:[EAX].Base_0
	     MOV DS:_SB,EBX                       ; Save Base

	     MOV BL,ES:[EAX].Access
	     MOV DS:_SA,BL                        ; Save Access

	     MOV ESI,OFFSET _Inf		  ; Print It
	     INT 54
	     RET

Pick_Info	ENDP


;-----------------------------------------------------------------------------

		ASSUME  DS:Int_Data


;******************************** IRQ *****************************************

;-----------------------------------------------------------------------------
; Clock - (IRQ 0)
;-----------------------------------------------------------------------------
Timer:                                            ; Mantiene il conteggio per
		PUSH EAX			  ; 7 anni di funzionamento.
		PUSH DS
		MOV EAX,SelInt_Data
		MOV DS,EAX
		INC DWORD PTR Time
		MOV AL,PIC_EOI
		OUT PIC1_CMND,AL
		POP DS
		POP EAX
		IRETD

;-----------------------------------------------------------------------------
; Keyboard - (IRQ 1)
;-----------------------------------------------------------------------------
Keyboard:
		PUSH EAX
		PUSH EBX
		PUSH DS

		IN AL,60H
		MOV AH,AL			  ;AH Codice Scansione
		IN AL,61h
		OR AL,80H			  ;Segnale riconoscimento
		OUT 61H,AL
		AND AL,7FH
		OUT 61H,AL			  ;Azzera segnale riconoscimento

		MOV BL,AH
		MOV EAX,SelInt_Data
		MOV DS,EAX
		MOV AL,BL

		CMP AL,29			  ; Controllo per CTRL
		JNZ SHORT KB_1
		MOV CTRL,1
KB_1:		CMP AL,29+128
		JNZ SHORT KB_2
		MOV CTRL,0
KB_2:

		TEST AL,80H
		JNZ SHORT KB_Exit		  ; RELASED
		MOV EBX,OFFSET ScanTable
		XLATB
		CMP AL,0 			  ; Not a caracter
		JZ SHORT KB_Exit

		TEST CTRL,1
		JZ SHORT KB_12
		CMP AL,'C'
		JNZ SHORT KB_12

		POP DS				  ; CTRL - C break
		POP EBX
		POP EAX

		JMP SHORT CTRL_C_BREAK

KB_12:

		MOV EBX,Puntatore
		CMP BL,DIM_KB_BUFFER
		JAE SHORT KB_Exit		  ; fine buffer

		MOV [Buffer+EBX],AL
		INC EBX
		MOV Puntatore,EBX
KB_Exit:
		MOV AL,20H			  ;Send 'EOI'
		OUT 20H,AL

		POP DS
		POP EBX
		POP EAX
		IRETD

;-----------------------------------------------------------------------------
; CTRL C BREAK
;-----------------------------------------------------------------------------


CTRL_C_BREAK:
		PUSHAD				  ; Save Regs
		MOV EBX,DS			  ; Save DS
		MOV EAX,SelInt_Data		  ; Mem-> IntData
		MOV DS,EAX

		POP _EDI			  ; --> Mem
		POP _ESI
		POP _EBP
		POP EAX				  ; NO ESP
		POP _EBX
		POP _EDX
		POP _ECX
		POP _EAX

		POP _EIP
		POP AX
		MOV _CS,AX
		MOV _CS_2,AX

		INC ESP
		INC ESP
		POP EAX                           ; EFLAGS
		MOV _EFLAG,EAX
		MOV _FLAGL,AL
		MOV _FLAGH,AH

		MOV _ESP,ESP			  ; ESP POINT
						  ; AT THE RIGHT POINT
						  ; BUT ... (Privilege)

		MOV _DS,BX			  ; get saved ds
		MOV _ES,ES			  ; and other
		MOV _SS,SS
		MOV _GS,GS
		MOV _FS,FS

		MOV EDI,OFFSET msgCTRL_C

		STR AX
		MOV _N_TASK,AX

		JMP No_Error


;-----------------------------------------------------------------------------
; Unused IRQ
;-----------------------------------------------------------------------------

Unused_low:     PUSH EAX
		MOV AL,PIC_EOI
		OUT PIC1_CMND,AL
		POP EAX
		IRETD

Unused_high:    PUSH EAX
		MOV AL,PIC_EOI
		OUT PIC2_CMND,AL
		POP EAX
		IRETD


;*******************************************************************************
;************************** FUNCTION DATA & CODE *******************************
;*******************************************************************************


Terminate	PROC 	FAR

		MOV BL,AL
		DB      0EAH
		DD      OFFSET CALL_BACK_REAL_MODE
		DW	SelCode

Terminate	ENDP


ASSUME  DS:Global_Data

New_GDT_Desc	PROC 	FAR

		; INPUT :
		;		EAX = 32 bit BASE
		; 		EBX = 24 bit Limit + G
		; 		CL  = Access
		; OUTPUT :
		;               EAX = 16 bit Selettore con DPL 0

		PUSH EDX
		MOV EDX,SelGlobal
		MOV DS,EDX

		MOV EDX,[Last_GDT]
		CMP EDX,MAX_DESC*8+OFFSET GDT_Desc
		JNZ SHORT _Mem_Ok
		POP EDX
		XOR EAX,EAX
		IRETD
_Mem_Ok:
		MOV [EDX].Base_0,AX
		SHR EAX,16
		MOV [EDX].Base_1,AL
		MOV [EDX].Base_2,AH
		MOV [EDX].Limit_0,BX
		SHR EBX,16
		MOV [EDX].Limit_1,BL
		MOV [EDX].Access,CL

		MOV EAX,EDX
		ADD EDX,8
		MOV [Last_GDT],EDX

		POP EDX

		IRETD

New_GDT_Desc	ENDP


ASSUME  DS:Kernel_Data

Set_PIC		PROC 	FAR			  ; AL = 0 Set PM
						  ;	 1 Set RM2PM
		PUSH DS				  ; BL = PIC1
		CMP AL,0			  ; BH = PIC2
		JZ SHORT Set_PM			  ; Modificato EAX

		MOV EAX,SelData			  ; Set PM to RM
		MOV DS,EAX
		MOV [P2R_PIC1Mask],BL
		MOV [P2R_PIC2Mask],BH
		JMP SHORT Set_Ed

	Set_PM: MOV EAX,SelData
		MOV DS,EAX
		MOV [PM_PIC1Mask],BL
		MOV [PM_PIC2Mask],BH

		MOV AL,BL		          ; Put PM Mask IRQ
		OUT PIC1_DATA,AL
		MOV AL,BH
		OUT PIC2_DATA,AL

	Set_Ed: POP DS
		IRETD

Set_PIC		ENDP


ASSUME  DS:Int_Data


GraphTxt	PROC	FAR             	  ; DH Color
						  ; DS:ESI Caratteri
						  ; ES:EDI Start Point
						  ; FS:EAX Char Map    (Interno)
						  ; Modifica DX, ESI, EDI
		PUSH FS
		PUSH EAX
		PUSH ECX

		MOV EAX,SelCharMap
		MOV FS,EAX

Car_RD:		LODSB
		CMP AL,0
		JZ SHORT Txt_end

		PUSH EDI

		MOVZX EAX,AL
		SHL EAX,3

		MOV CL,8
Print_Single:
		MOV DL,FS:[EAX]
		PUSH EDI

		MOV CH,8
Print_Riga:
		SHL DL,1
		JNC SHORT Blank
		MOV BYTE PTR ES:[EDI],DH
Blank:
		INC EDI
		DEC CH
		JNZ SHORT Print_Riga


		POP EDI
		ADD EDI,320
		INC EAX
		DEC CL
		JNZ SHORT Print_Single


		POP EDI
		ADD EDI,8
		JMP SHORT Car_RD

Txt_end:
		POP ECX
		POP EAX
		POP FS

		IRETD

GraphTxt	ENDP

KbHit		PROC	FAR

		STI
		PUSH DS
		MOV EAX,SelInt_Data
		MOV DS,EAX

		MOV EAX,Puntatore

		POP DS

		IRETD

KbHit		ENDP

Getch		PROC	FAR

		PUSH EBX
		PUSH ECX
		PUSH DS

		MOV EAX,SelInt_Data
		MOV DS,EAX
		STI

No_Key:         MOV ECX,Puntatore
		OR CL,CL
		JZ SHORT No_Key

		MOV AL,Buffer			  ; Prende il carattere

		MOV EBX,OFFSET Buffer
		INC EBX

Scroll:		MOV AH,[EBX]
		MOV [EBX-1],AH
		INC EBX
		DEC ECX
		JNZ SHORT Scroll

		DEC Puntatore			  ; Watch

		POP DS
		POP ECX
		POP EBX

		IRETD

Getch		ENDP

Locate		PROC	FAR

		PUSH DS
		PUSH EBX
		PUSH ECX

		MOV EBX,SelInt_Data
		MOV DS,EBX

		MOV CL,AH
		SHL CL,1
		MOVZX EAX,AL
		MOV EBX,EAX

		SHL EAX,7
		SHL EBX,5
		ADD EBX,EAX
		MOV AL,CL
		MOVZX EAX,AL

		ADD EBX,EAX

		MOV [PosXY],EBX
		MOV [CursorX],CL

		POP ECX
		POP EBX
		POP DS

		IRETD
Locate		ENDP

Cout		PROC	FAR
;		0 	End
;	       13	End of Line
;	       10	Set color	--> Byte
;		1	Print Byte  H   --> Byte
;		2	Print Word  H   --> Word
;		4       Print Dword H   --> Dword
;	       11	Print Byte  D   --> Byte       without zero
;	       12	Print Word  D   --> Word       without zero
;	       14       Print Dword D   --> Dword      without zero
;	       15	Print Byte  D   --> Byte       with    zero
;  	       21	Print Byte  B   --> Byte
;
		PUSH EAX
		PUSH EBX
		PUSH ECX
		PUSH EDX

		PUSH EDI
		PUSH ES
		PUSH GS

		CLD
		MOV EAX,SelInt_Data		  ; Load Segment
		MOV GS,EAX
		MOV EAX,Sel_VGA_Text
		MOV ES,EAX

		XOR DH,DH                         ; Load info
		MOV DL,GS:[CursorX]
		MOV EDI,GS:[PosXY]
		MOV AH,GS:[CurColor]

Cout_1:		LODSB				  ; Start
		CMP AL,0
		JZ SHORT Cout_End
		CMP AL,13
		JZ SHORT Cout_EOL
		CMP AL,10
		JZ SHORT Cout_CC
		CMP AL,21
		JBE SHORT Cout_Num
		STOSW
		INC DL
		INC DL
		CMP DL,160
		JB SHORT Cout_1
		XOR DL,DL
		; New Page
		CMP EDI,160*25
		JB SHORT Cout_1
		CALL Next_Page
		JMP SHORT Cout_1

Cout_EOL:
		SUB DI,DX
		ADD DI,160
		XOR DL,DL
		; New Page
		CMP EDI,160*25
		JB SHORT Cout_1
		CALL Next_Page
		JMP SHORT Cout_1

Cout_CC:
		LODSB
		MOV AH,AL
		JMP SHORT Cout_1

Cout_End:
		MOV GS:[CursorX],DL		  ; Save info
		MOV GS:[PosXY],EDI
		MOV GS:[CurColor],AH

		POP GS
		POP ES
		POP EDI
		POP EDX
		POP ECX
		POP EBX
		POP EAX

		IRETD

Cout_Num:
		CMP AL,4
		JBE SHORT Cout_Num_Hex
		CMP AL,15
		JBE SHORT Cout_Num_Dec
						  ; Binario Byte
		LODSB
		MOV BL,AL
		MOV CL,8

Cout_Bin:	XOR AL,AL
		SHL BL,1
		ADC AL,'0'

		STOSW

		INC DL
		INC DL
		CMP DL,160
		JB SHORT Cout_Bin_3
		XOR DL,DL
		; New Page
		CMP EDI,160*25
		JB SHORT Cout_Bin_3
		CALL Next_Page

Cout_Bin_3:	DEC CL
		JNZ SHORT Cout_Bin
		JMP Cout_1
Cout_Num_Hex:

		AND AL,0FH
		MOV EBX,[ESI]		          ; Legge dato in EBX
		XOR ECX,ECX
		MOV CL,AL		          ; ECX numero Byte

		ADD ESI,ECX		          ; 1 --> 24 	32 - X*8
						  ; 2 --> 16    ^-- Num Bits
						  ; 3 -->  8
						  ; 4 -->  0
		SHL CL,3

		ADD CL,-32
		NEG CL                            ; CL Numero di shiftamenti

		SHL EBX,CL
		MOV CL,AL
		SHL CL,1

		; Ciclo Principale    -->  CL numero di Byte*2
Cout_Hex_1:
		ROL EBX,4
		MOV AL,BL
		AND AL,0FH
		CMP AL,9
		JLE SHORT Cout_Hex_2
		ADD AL,'A'-'9'-1
Cout_Hex_2:
		ADD AL,'0'

		STOSW

		INC DL
		INC DL
		CMP DL,160
		JB SHORT Cout_Hex_3
		XOR DL,DL
		; New Page
		CMP EDI,160*25
		JB SHORT Cout_Hex_3
		CALL Next_Page

Cout_Hex_3:
		DEC CL
		JNZ SHORT Cout_Hex_1

		JMP Cout_1

Cout_Num_Dec:
		CMP AL,15
		JNE SHORT Aw_zero
		MOV GS:[ZERO_KEEP],1
		SUB AL,4
		JMP SHORT Aw_zero2
Aw_zero:        MOV GS:[ZERO_KEEP],0
Aw_zero2:

		XOR ECX,ECX
		SUB AL,10

		MOV EBX,100
		MOV CL,[ESI]
		CMP AL,1
		JZ SHORT Cout_Dec_1A
		MOV EBX,10000
		MOV CX,[ESI]
		CMP AL,2
		JZ SHORT Cout_Dec_1A
		MOV EBX,1000000000
		MOV ECX,[ESI]
Cout_Dec_1A:
		PUSH EAX
		MOVZX EAX,AL
		ADD ESI,EAX
		POP EAX
Cout_Dec_1:
		PUSH EAX
		PUSH EDX

		MOV EAX,ECX
		XOR EDX,EDX
		DIV EBX			          ; Num / Div

		PUSH ECX

		MOV ECX,0AH
		XOR EDX,EDX		          ; % 10
		DIV ECX
		MOV GS:[Result],DL                ; DL RESULT

		XOR EDX,EDX
		MOV EAX,EBX
		DIV ECX
		MOV EBX,EAX 		          ; EBX/=10

		POP ECX
		POP EDX
		POP EAX
		MOV AL,GS:[Result]

		CMP GS:[ZERO_KEEP],0
		JNE SHORT Acc_ON
		CMP AL,0
		JE SHORT Acc_OFF
Acc_ON2:	MOV GS:[ZERO_KEEP],1

Acc_ON:		ADD AL,'0'
		STOSW

		INC DL
		INC DL
Acc_OFF:
		CMP DL,160
		JB SHORT Cout_Dec_3
		XOR DL,DL
		; New Page
		CMP EDI,160*25
		JB SHORT Cout_Dec_3
		CALL Next_Page

Cout_Dec_3:
		OR EBX,EBX
		JNZ SHORT Cout_Dec_1
		CMP GS:[ZERO_KEEP],0
		JE SHORT Acc_ON2
		JMP Cout_1

Next_Page:
		PUSH ESI
		PUSH EDI
		PUSH EAX
		PUSH ECX
		PUSH DS
		MOV ECX,Sel_VGA_Text
		MOV DS,ECX

		MOV ECX,160*24/4
		XOR EDI,EDI
		MOV ESI,160

		REP MOVSD

		MOV CL,AH
		MOV AL,32
		SHL EAX,16
		MOV AH,CL
		MOV AL,32

		MOV ECX,160/4
		REP STOSD

		POP DS
		POP ECX
		POP EAX
		POP EDI
		POP ESI
		SUB EDI,160
		DB 0C3H

Cout		ENDP



SvgaInit	PROC FAR

		MOV EBX,OFFSET SvgaInit_R
		MOV EDX,SEG Kernel_Code
		INT 50

		CMP CL,1
		JE SHORT Fine_Svga

		PUSH DS
		MOV EAX,SelData
		MOV DS,EAX
		PUSH DS

		MOV ESI,OFFSET Svga_Mess_1
		INT 54

		MOV EAX,SelFlat
		MOV DS,EAX
		MOV ESI,EBX
		INT 54

		POP DS
		MOV ESI,OFFSET Svga_Mess_2
		INT 54

		POP DS

Fine_Svga:
		MOV AL,CL
		IRETD

SvgaInit	ENDP



Int_Limit	EQU     $-Int_Limit_Low-1

Int_Code	ENDS



Int_Data	SEGMENT PUBLIC PARA USE32 'INTERRUPT'

IntD_Limit_Low	EQU 	$

;--------------------------- IDT ERROR MESSAGE -------------------------------
R_Color		DB	10,7,0
msgDivide       DB      'EXCEPTION 0 : Divide fault at',0
msgTrap         DB      'EXCEPTION 1 : Debug Trap at',0
msgNMI          DB      'EXCEPTION 2 : NMI at',0
msgBrPoint	DB      'EXCEPTION 3 : Break Point at',0
msgOverflow     DB      'EXCEPTION 4 : INTO Detected Overflow at',0
msgBounds       DB      'EXCEPTION 5 : BOUND Range Exceeded at',0
msgOpcode       DB	'EXCEPTION 6 : Invalid Opcode at',0
msgMathGone     DB	'EXCEPTION 7 : Coprocessor Not Available fault at',0
msgDouble       DB	'EXCEPTION 8 : Double Fault abort at',0
msgMathOver     DB	'EXCEPTION 9 : Coprocessor Segment Overrun abort at',0
msgTSS          DB	'EXCEPTION 10 : Invalid Task State Segment fault at',0
msgSegment      DB	'EXCEPTION 11 : Segment Not Present fault at',0
msgStack        DB	'EXCEPTION 12 : Stack Fault at',0
msgGeneral      DB	'EXCEPTION 13 : General Protection fault at',0
msgPage         DB	'EXCEPTION 14 : Page Fault at',0
msgMathErr      DB      'EXCEPTION 16 : Math Coprocessor error fault at',0
msgAC		DB	'EXCEPTION 17 : Alignment Check fault at',0
msgUNKNOWN 	DB 	'EXCEPTION ?? : Unknown Exception at',0
msgCTRL_C	DB 	'CTRL - C Break was calling at',0

;------------------------- DEBUG ERROR MESSAGE -------------------------------

Debug 	DB ' ',2
_CS	DW  ?
	DB ':',4
_EIP	DD  ?
	DB '.',13,'          EAX = ',4
_EAX    DD  ?
	DB 'h, EBX = ',4
_EBX    DD  ?
	DB 'h, ECX = ',4
_ECX    DD  ?
	DB 'h, EDX = ',4
_EDX    DD  ?
	DB 'h','              ESI = ',4
_ESI    DD  ?
	DB 'h, EDI = ',4
_EDI    DD  ?
	DB 'h, EBP = ',4
_EBP    DD  ?
	DB 'h, ESP = ',4
_ESP    DD  ?


	DB 'h','              DS = ',2
_DS     DW  ?
	DB 'h  ->  ',0


_SSInit	DB 13,'          SS = ',2
_SS     DW  ?
	DB 'h  ->  ',0


_ESInit	DB 13,'          ES = ',2
_ES     DW  ?
	DB 'h  ->  ',0


_GSInit	DB 13,'          GS = ',2
_GS     DW  ?
	DB 'h  ->  ',0


_FSInit	DB 13,'          FS = ',2
_FS     DW  ?
	DB 'h  ->  ',0


_CSInit	DB 13,'          CS = ',2
_CS_2   DW  ?
	DB 'h  ->  ',0


_StTask DB 13,'          TASK = ',2
_N_TASK DW  ?
	DB 'h'
_ErrPre DB  0,'          ERROR CODE = ',2
_ERROR  DW  ?
	DB 'h',0


_StFlag	DB 13,'          EFLAGS = ',4
_EFLAG	DD  ?
	DB 'h,  FLAG = ',21
_FLAGH	DB  ?,' ',21
_FLAGL  DB  ?,'b'
	DB 13,13,0


_Inf	DB  'Base = ',4
_SB	DD  ?
	DB  'h  Limit = ',1
_SLH	DB  ?,2
_SLL	DW  ?
	DB  'h  Access = ',1
_SA     DB  ?,'h',0

_iLdt	DB 'Is in LDT.',0
_iUnk   DB 'Invalid Selector.',0


;------------------------------------------------------------------------------
;-------------------------- KEYBOARD IRQ 1 ------------------------------------
ScanTable	DB 	0,0,'1234567890-=',8,9,'QWERTYUIOP[]',0DH,0
		DB 	'ASDFGHJKL;',39,0,0,'\ZXCVBNM,./',0,0,0
		DB 	' ',0,0,0,0,0,0,0,0,0,0,0,0,0
		DB      '789-456+1230.'

Buffer		DB 	DIM_KB_BUFFER DUP (?)	; 0 -> 49 MAX 256
Puntatore  	DD      0			; I suoi 3 bytes alti sono 0
CTRL		DB	0

;------------------------------------------------------------------------------
;---------------------------- COUT -------------------------------------------
CurColor	DB	7
CursorX		DB      0
PosXY		DD	0
Result		DB	?
ZERO_KEEP	DB 	0

;------------------------------------------------------------------------------
;--------------------------- TIMER IRQ 0 --------------------------------------
Time		DD	0


IntD_Limit	EQU     $-IntD_Limit_Low-1

Int_Data	ENDS

END
