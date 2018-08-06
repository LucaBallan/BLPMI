;ддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
;дддддддддддддддддддддддддддд MACRO дддддддддддддддддддддддддддддддддддддддддддд
;ддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд

Setup_Video	MACRO

	MOV AH,0FH			          ; Setting Up Video
	INT 10H
	CMP AL,3
	JZ SHORT Vinit_1
	MOV AX,3
	INT 10H
Vinit_1:

	MOV AX,Int_Data
	MOV GS,AX
	MOV AH,3
	XOR BH,BH			          ; Get cursor position
	INT 10H

	SHL DL,1

	MOV AL,DH
	CBW
	CWDE
	MOV EBX,EAX

	SHL EAX,7
	SHL EBX,5
	ADD EBX,EAX
	MOV AL,DL
	CBW
	CWDE
	ADD EBX,EAX

	MOV PosXY,EBX
	MOV CursorX,DL	         	          ; Save cursor position


	MOV AH,1			          ; Set No Cursor
	MOV CX,2000H
	INT 10H

	ENDM


;ддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд

Setup_irq	MACRO master,slave

		MOV AL,11H		          ; Set IRQ0..IRQ7 to master
		OUT 20H,AL			  ; 1
		JMP $ + 2
		MOV AL,master
		OUT 21H,AL                        ; 2
		JMP $ + 2
		MOV AL,4H
		OUT 21H,AL                        ; 3
		JMP $ + 2
		MOV AL,1H
		OUT 21H,AL                        ; 4
		JMP $ + 2

		MOV AL,11H			  ; Set IRQ8..IRQF to slave
		OUT 0A0H,al
		JMP $ + 2
		MOV AL,slave
		OUT 0A1H,AL
		JMP $ + 2
		MOV AL,2H
		OUT 0A1H,AL
		JMP $ + 2
		MOV AL,1H
		OUT 0A1H,AL
		JMP $ + 2

		ENDM


;ддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд

RMSetup_Cursor		MACRO

	MOV AX,Int_Data
	MOV GS,AX

	MOV EAX,PosXY
	MOV CL,CursorX                            ; GET posizione cursore PM
						  ; CL X
	SHR CL,1

	MOV CH,160
	DIV CH				          ; AL Y


	MOV DH,AL				  ; Put position to DOS
	MOV DL,CL
	MOV AH,2
	XOR BH,BH
	INT 10H

	MOV AH,1                                  ; Put visible Cursor
	MOV CX,0607H
	INT 10H

	ENDM



;ммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм
