;My Name is Matan Antebi
IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
; --------------------------
;==========================BMP_VARIABLES====================
	filename db 'OPENBMP.bmp',0
	filename2 db 'INSTBMP.bmp',0
	filehandle dw ?
	Header db 54 dup (0)
	Palette db 256*4 dup (0)
	ScrLine db 320 dup (0)
	ErrorMsg db 'Error', 13, 10,'$'
	PianoMsg db 13, 10, 13, 10, "          PIANO BY MATAN ANTEBI $"
	StartMsg db 13, 10,13, 10,13, 10,13, 10,13, 10,13, 10,13, 10,13, 10,13, 10,13, 10,13, 10,13, 10,"           PRESS 'H' FOR HELP $"
	Start2Msg db 13, 10, 13, 10, 13, 10, 13, 10, 13, 10, 13, 10, 13, 10, "        PRESS 'ESC' TO EXIT PIANO $"
	Start3Msg db 13, 10, 13, 10, "   PRESS 'M' TO CHANGE THE PIANO STYLE $"
	colorcounter1 db 15
	colorcounter2 db 15
	colorcounter3 db 15
	colorcounter4 db 15
	colorcounter5 db 15
	colorcounter6 db 15
	colorcounter7 db 15
	colorcounter8 db 15
	colorcounter9 db 15
;==========================SOUND_VARIABLES===================
	Do_Sound dw 1318 ;Do Note Frequency
    Re_Sound dw 1175 ;Re Note Frequency
    Mi_Sound dw 1047 ;Mi Note Frequency
    Fa_Sound dw 988 ;Fa Note Frequency
    Sol_Sound dw 880 ;Sol Note Frequency
    La_Sound dw 784 ;La Note Frequency
    Si_Sound dw 698 ;Si Note Frequency
	Do2_Sound dw 659 ;Do2 Note Frequency
	Re2_Sound dw 587 ;Re2 Note Frequency
	B1_Sound dw 1245 ;Black1 Note Frequency
	B2_Sound dw 1109 ;Black2 Note Frequency
	B3_Sound dw 932 ;Black3 Note Frequency
	B4_Sound dw 831 ;Black4 Note Frequency
	B5_Sound dw 740 ;Black5 Note Frequency
	B6_Sound dw 622 ;Black6 Note Frequency
	Clock equ es:6Ch
CODESEG
;==========================BMP_LOAD=========================
proc OpenFile
; Open file
	mov ah, 3Dh
	xor al, al
	mov dx, offset filename
	int 21h
	jc openerror
	mov [filehandle], ax
	jmp goret
openerror:
	mov dx, offset ErrorMsg
	mov ah, 9h
	int 21h
goret:
	ret
endp OpenFile
proc OpenFile2
; Open file
	mov ah, 3Dh
	xor al, al
	mov dx, offset filename2
	int 21h
	jc openerror2
	mov [filehandle], ax
	jmp goret2
openerror2:
	mov dx, offset ErrorMsg
	mov ah, 9h
	int 21h
goret2:
	ret
endp OpenFile2
proc ReadHeader
; Read BMP file header, 54 bytes
	mov ah,3fh
	mov bx, [filehandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	ret
endp ReadHeader
proc ReadPalette
; Read BMP file color palette, 256 colors * 4 bytes (400h)
	mov ah,3fh
	mov cx,400h
	mov dx,offset Palette
	int 21h
	ret
endp ReadPalette
proc CopyPal
; Copy the colors palette to the video memory
; The number of the first color should be sent to port 3C8h
; The palette is sent to port 3C9h
	mov si,offset Palette
	mov cx,256
	mov dx,3C8h
	mov al,0
; Copy starting color to port 3C8h
	out dx,al
; Copy palette itself to port 3C9h
	inc dx
PalLoop:
; Note: Colors in a BMP file are saved as BGR values rather than RGB.
	mov al,[si+2] ; Get red value.
	shr al,2 ; Max. is 255, but video palette maximal
; value is 63. Therefore dividing by 4.
	out dx,al ; Send it.
	mov al,[si+1] ; Get green value.
	shr al,2
	out dx,al ; Send it.
	mov al,[si] ; Get blue value.
	shr al,2
	out dx,al ; Send it.
	add si,4 ; Point to next color.
; (There is a null chr. after every color.)
	loop PalLoop
	ret
endp CopyPal
proc CopyBitmap
; BMP graphics are saved upside-down.
; Read the graphic line by line (200 lines in VGA format),
; displaying the lines from bottom to top.
	mov ax, 0A000h
	mov es, ax
	mov cx,200
PrintBMPLoop:
	push cx
; di = cx*320, point to the correct screen line
	mov di,cx
	shl cx,6
	shl di,8
	add di,cx
; Read one line
	mov ah,3fh
	mov cx,320
	mov dx,offset ScrLine
	int 21h
; Copy one line into video memory
	cld ; Clear direction flag, for movsb
	mov cx,320
	mov si,offset ScrLine
	rep movsb ; Copy line to the screen
;rep movsb is same as the following code:
;mov es:di, ds:si
;inc si
;inc di
;dec cx
;loop until cx=0
	pop cx
	loop PrintBMPLoop
	ret
endp CopyBitmap
;==============================GRAPHICS==========================================
proc Graphics
	mov ah, 00h
	mov al, 13h
	int 10h
	ret
endp Graphics
;==============================TEXT1==============================================
proc print 
	lea dx, [StartMsg]
    mov ah,09h
    int 21h
	ret
endp print
;==============================TEXT2==============================================
proc printPiano
	lea dx, [PianoMsg]
    mov ah,09h
    int 21h
	ret
endp printPiano
;==============================TEXT3==============================================
proc print3
	lea dx, [Start2Msg]
    mov ah,09h
    int 21h
	ret
endp print3
;==============================TEXT4==============================================
proc print4
	lea dx, [Start3Msg]
    mov ah,09h
    int 21h
	ret
endp print4
;==============================BACKGROUND COLOR==================================
proc ScreenColor
	mov cx, 0 ;col 
	mov dx, 0 ;row
	mov al, 0 ;0= BLACK COLOR
	mov ah, 0ch
	mov dx, 0
paintscreen:
	inc cx
	int 10h
	cmp cx, 320
	jne paintscreen
	mov cx, 0
	inc dx
	cmp dx, 200
	jne paintscreen
	ret
endp ScreenColor
;==============================BORDER1===========================================
proc Border1
	mov cx, 20 ;col 
	mov dx, 30 ;row
	mov al, 0 ;0=BLACK
	mov ah, 0ch
paintDoBorder1:
	inc cx
	int 10h
	cmp cx, 21
	jne paintDoBorder1
	mov cx, 20
	inc dx
	cmp dx, 100
	jne paintDoBorder1
	ret
endp Border1
;==============================BORDER2===========================================
proc Border2
	mov cx, 20 ;col 
	mov dx, 30 ;row
	mov al, 0 ;0=BLACK
	mov ah, 0ch
paintDoBorder2:
	inc cx
	int 10h
	cmp cx, 320
	jne paintDoBorder2
	mov cx, 20
	inc dx
	cmp dx, 31
	jne paintDoBorder2
	ret
endp Border2
;==============================DO_SQRT===========================================
proc Do_Note
	mov cx, 20 ;col 
	mov dx, 30 ;row
	mov al, [colorcounter1] ;color white
	mov ah, 0ch
paintDo:
	inc cx
	int 10h
	cmp cx, 50
	jne paintDo
	mov cx, 20
	inc dx
	cmp dx, 100
	jne paintDo
	ret
endp Do_Note
;==============================DO_BORDER===========================================
proc Do_Border
	mov cx, 50 ;col 
	mov dx, 30 ;row
	mov al, 0 ;0=WHITE
	mov ah, 0ch
paintDoBorder:
	inc cx
	int 10h
	cmp cx, 51
	jne paintDoBorder
	mov cx, 50
	inc dx
	cmp dx, 100
	jne paintDoBorder
	ret
endp Do_Border
;==============================RE_SQRT===========================================
proc Re_Note
	mov cx, 50 ;col 
	mov dx, 30 ;row
	mov al, [colorcounter2] 
	mov ah, 0ch
paintRe:
	inc cx
	int 10h
	cmp cx, 80
	jne paintRe
	mov cx, 50
	inc dx
	cmp dx, 100
	jne paintRe
	ret
endp Re_Note
;==============================RE_BORDER===========================================
proc Re_Border
	mov cx, 80 ;col 
	mov dx, 30 ;row
	mov al, 0 ;0=WHITE
	mov ah, 0ch
paintReBorder:
	inc cx
	int 10h
	cmp cx, 81
	jne paintReBorder
	mov cx, 80
	inc dx
	cmp dx, 100
	jne paintReBorder
	ret
endp Re_Border
;==============================MI_SQRT===========================================
proc Mi_Note
	mov cx, 80 ;col 
	mov dx, 30 ;row
	mov al, [colorcounter3] 
	mov ah, 0ch
paintMi:
	inc cx
	int 10h
	cmp cx, 110
	jne paintMi
	mov cx, 80
	inc dx
	cmp dx, 100
	jne paintMi
	ret
endp Mi_Note
;==============================MI_BORDER===========================================
proc Mi_Border
	mov cx, 110 ;col 
	mov dx, 30 ;row
	mov al, 0 ;0=WHITE
	mov ah, 0ch
paintMiBorder:
	inc cx
	int 10h
	cmp cx, 111
	jne paintMiBorder
	mov cx, 110
	inc dx
	cmp dx, 100
	jne paintMiBorder
	ret
endp Mi_Border
;==============================FA_SQRT===========================================
proc Fa_Note
	mov cx, 110 ;col 
	mov dx, 30 ;row
	mov al, [colorcounter4] ;15=WHITE
	mov ah, 0ch
paintFa:
	inc cx
	int 10h
	cmp cx, 140
	jne paintFa
	mov cx, 110
	inc dx
	cmp dx, 100
	jne paintFa
	ret
endp Fa_Note
;==============================FA_BORDER===========================================
proc Fa_Border
	mov cx, 140 ;col 
	mov dx, 30 ;row
	mov al, 0 ;0=WHITE
	mov ah, 0ch
paintFaBorder:
	inc cx
	int 10h
	cmp cx, 141
	jne paintFaBorder
	mov cx, 140
	inc dx
	cmp dx, 100
	jne paintFaBorder
	ret
endp Fa_Border
;==============================SOL_SQRT===========================================
proc Sol_Note
	mov cx, 140 ;col 
	mov dx, 30 ;row
	mov al, [colorcounter5] ;15=WHITE
	mov ah, 0ch
paintSol:
	inc cx
	int 10h
	cmp cx, 170
	jne paintSol
	mov cx, 140
	inc dx
	cmp dx, 100
	jne paintSol
	ret
endp Sol_Note
;==============================SOL_BORDER===========================================
proc Sol_Border
	mov cx, 170 ;col 
	mov dx, 30 ;row
	mov al, 0 ;0=WHITE
	mov ah, 0ch
paintSolBorder:
	inc cx
	int 10h
	cmp cx, 171
	jne paintSolBorder
	mov cx, 170
	inc dx
	cmp dx, 100
	jne paintSolBorder
	ret
endp Sol_Border
;==============================LA_SQRT===========================================
proc La_Note
	mov cx, 170 ;col 
	mov dx, 30 ;row
	mov al, [colorcounter6] ;15=WHITE
	mov ah, 0ch
paintLa:
	inc cx
	int 10h
	cmp cx, 200
	jne paintLa
	mov cx, 170
	inc dx
	cmp dx, 100
	jne paintLa
	ret
endp La_Note
;==============================LA_BORDER===========================================
proc La_Border
	mov cx, 200 ;col 
	mov dx, 30 ;row
	mov al, 0 ;0=WHITE
	mov ah, 0ch
paintLaBorder:
	inc cx
	int 10h
	cmp cx, 201
	jne paintLaBorder
	mov cx, 200
	inc dx
	cmp dx, 100
	jne paintLaBorder
	ret
endp La_Border
;==============================SI_SQRT===========================================
proc Si_Note
	mov cx, 200 ;col 
	mov dx, 30 ;row
	mov al, [colorcounter7] ;15=WHITE
	mov ah, 0ch
paintSi:
	inc cx
	int 10h
	cmp cx, 230
	jne paintSi
	mov cx, 200
	inc dx
	cmp dx, 100
	jne paintSi
	ret
endp Si_Note
;==============================SI_BORDER===========================================
proc Si_Border
	mov cx, 230 ;col 
	mov dx, 30 ;row
	mov al, 0 ;0=WHITE
	mov ah, 0ch
paintSiBorder:
	inc cx
	int 10h
	cmp cx, 231
	jne paintSiBorder
	mov cx, 230
	inc dx
	cmp dx, 100
	jne paintSiBorder
	ret
endp Si_Border
;==============================DO2_SQRT===========================================
proc Do2_Note
	mov cx, 230 ;col 
	mov dx, 30 ;row
	mov al, [colorcounter8] ;15=WHITE
	mov ah, 0ch
paintDo2:
	inc cx
	int 10h
	cmp cx, 260
	jne paintDo2
	mov cx, 230
	inc dx
	cmp dx, 100
	jne paintDo2
	ret
endp Do2_Note
;==============================DO2_BORDER===========================================
proc Do2_Border
	mov cx, 260 ;col 
	mov dx, 30 ;row
	mov al, 0 ;0=WHITE
	mov ah, 0ch
paintDo2Border:
	inc cx
	int 10h
	cmp cx, 261
	jne paintDo2Border
	mov cx, 260
	inc dx
	cmp dx, 100
	jne paintDo2Border
	ret
endp Do2_Border
;==============================RE2_SQRT===========================================
proc Re2_Note
	mov cx, 260 ;col 
	mov dx, 30 ;row
	mov al, [colorcounter9] ;15=WHITE
	mov ah, 0ch
paintRe2:
	inc cx
	int 10h
	cmp cx, 290
	jne paintRe2
	mov cx, 260
	inc dx
	cmp dx, 100
	jne paintRe2
	ret
endp Re2_Note
;==============================RE2_BORDER===========================================
proc Re2_Border
	mov cx, 290 ;col 
	mov dx, 30 ;row
	mov al, 0 ;0=WHITE
	mov ah, 0ch
paintRe2Border:
	inc cx
	int 10h
	cmp cx, 291
	jne paintRe2Border
	mov cx, 290
	inc dx
	cmp dx, 100
	jne paintRe2Border
	ret
endp Re2_Border
;==============================DO_BLACK===========================================
proc Do_Black
	mov cx, 42 ;col 
	mov dx, 30 ;row
	mov al, 0
	mov ah, 0ch
paintDoB:
	inc cx
	int 10h
	cmp cx, 59
	jne paintDoB
	mov cx, 42
	inc dx
	cmp dx, 70
	jne paintDoB
	ret
endp Do_Black
;==============================RE_BLACK===========================================
proc Re_Black
	mov cx, 72 ;col 
	mov dx, 30 ;row
	mov al, 0
	mov ah, 0ch
paintReB:
	inc cx
	int 10h
	cmp cx, 89
	jne paintReB
	mov cx, 72
	inc dx
	cmp dx, 70
	jne paintReB
	ret
endp Re_Black
;==============================MI_BLACK===========================================
proc Mi_Black
	mov cx, 132 ;col 
	mov dx, 30 ;row
	mov al, 0
	mov ah, 0ch
paintMiB:
	inc cx
	int 10h
	cmp cx, 149
	jne paintMiB
	mov cx, 132
	inc dx
	cmp dx, 70
	jne paintMiB
	ret
endp Mi_Black
;==============================FA_BLACK===========================================
proc Fa_Black
	mov cx, 162 ;col 
	mov dx, 30 ;row
	mov al, 0
	mov ah, 0ch
paintFaB:
	inc cx
	int 10h
	cmp cx, 179
	jne paintFaB
	mov cx, 162
	inc dx
	cmp dx, 70
	jne paintFaB
	ret
endp Fa_Black
;==============================Sol_BLACK===========================================
proc Sol_Black
	mov cx, 192 ;col 
	mov dx, 30 ;row
	mov al, 0
	mov ah, 0ch
paintSolB:
	inc cx
	int 10h
	cmp cx, 209
	jne paintSolB
	mov cx, 192
	inc dx
	cmp dx, 70
	jne paintSolB
	ret
endp Sol_Black
;==============================DO2_BLACK===========================================
proc Do2_Black
	mov cx, 252 ;col 
	mov dx, 30 ;row
	mov al, 0
	mov ah, 0ch
paintDo2B:
	inc cx
	int 10h
	cmp cx, 269
	jne paintDo2B
	mov cx, 252
	inc dx
	cmp dx, 70
	jne paintDo2B
	ret
endp Do2_Black
;==============================yarok===========================================
proc yarok
	mov cx, 282 ;col 
	mov dx, 30 ;row
	mov al, 0
	mov ah, 0ch
paintDo2BY:
	inc cx
	int 10h
	cmp cx, 299
	jne paintDo2BY
	mov cx, 282
	inc dx
	cmp dx, 70
	jne paintDo2BY
	ret
endp yarok
;==============================yarok_gray===========================================
proc yarok_gray
	mov cx, 282 ;col 
	mov dx, 30 ;row
	mov al, 8
	mov ah, 0ch
paintDo2BY2:
	inc cx
	int 10h
	cmp cx, 299
	jne paintDo2BY2
	mov cx, 282
	inc dx
	cmp dx, 70
	jne paintDo2BY2
	ret
endp yarok_gray
;==============================SOUND_COLOR=============================================
proc ReadPixelColor
 mov ah, 0Dh
 int 10h
 ret
endp ReadPixelColor
;==============================SOUND_YAROK=============================================
proc soundyarok
; open speaker
	in al, 61h
	or al, 00000011b
	out 61h, al
; send control word to change frequency
	mov al, 0B6h
	out 43h, al
; play frequency 131Hz
	mov ax, 554 ;
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al
	call yarok_gray
	call BORDER1
	call BORDER2
	call wait1sec ;wait 1 second
	call yarok
	call BORDER1
	call BORDER2
	mov ax, 3h
	int 33h
	ret
endp soundyarok
;==============================SOUND_1=============================================
proc Sound1
; open speaker
	in al, 61h
	or al, 00000011b
	out 61h, al
; send control word to change frequency
	mov al, 0B6h
	out 43h, al
; play frequency 131Hz
	mov ax, [Do_Sound]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al
	call Gray_Do_Note
	call Do_Black
	call BORDER1
	call BORDER2
	call wait1sec ;wait 1 second
	mov ax, 3h
	int 33h
	call Do_Note
	call Do_Black
	call BORDER1
	call BORDER2
	ret
endp Sound1
;==============================SOUND_2=============================================
proc Sound2
; open speaker
	in al, 61h
	or al, 00000011b
	out 61h, al
; send control word to change frequency
	mov al, 0B6h
	out 43h, al
; play frequency 131Hz
	mov ax, [Re_Sound]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al
	call Gray_Re_Note
	call Re_Black
	call Do_Black
	call BORDER1
	call BORDER2
	call Do_Border
	call wait1sec ;wait 1 second
	call Re_Note
	call Do_Black
	call Re_Black
	call BORDER1
	call BORDER2
	call Do_Border
	mov ax, 3h
	int 33h
	ret
endp Sound2
;==============================SOUND_3=============================================
proc Sound3
; open speaker
	in al, 61h
	or al, 00000011b
	out 61h, al
; send control word to change frequency
	mov al, 0B6h
	out 43h, al
; play frequency 131Hz
	mov ax, [Mi_Sound]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al
	call Gray_Mi_Note
	call Re_Black
	call BORDER1
	call BORDER2
	call Re_Border
	call Mi_Border
	call wait1sec ;wait 1 second
	call Mi_Note
	call Re_Black
	call BORDER1
	call BORDER2
	call Re_Border
	call Mi_Border
	mov ax, 3h
	int 33h
	ret
endp Sound3
;==============================SOUND_4=============================================
proc Sound4
; open speaker
	in al, 61h
	or al, 00000011b
	out 61h, al
; send control word to change frequency
	mov al, 0B6h
	out 43h, al
; play frequency 131Hz
	mov ax, [Fa_Sound]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al
	call Gray_Fa_Note
	call Mi_Black
	call BORDER1
	call BORDER2
	call Mi_Border
	call Fa_Border
	call wait1sec ;wait 1 second
	call Fa_Note
	call Mi_Black
	call BORDER1
	call BORDER2
	call Mi_Border
	call Fa_Border
	mov ax, 3h
	int 33h
	ret
endp Sound4
;==============================SOUND_5=============================================
proc Sound5
; open speaker
	in al, 61h
	or al, 00000011b
	out 61h, al
; send control word to change frequency
	mov al, 0B6h
	out 43h, al
; play frequency 131Hz
	mov ax, [Sol_Sound]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al
	call Gray_Sol_Note
	call Mi_Black
	call Fa_Black
	call BORDER1
	call BORDER2
	call Fa_Border
	call Sol_Border
	call wait1sec ;wait 1 second
	call Sol_Note
	call Mi_Black
	call Fa_Black
	call BORDER1
	call BORDER2
	call Fa_Border
	call Sol_Border
	mov ax, 3h
	int 33h
	ret
endp Sound5
;==============================SOUND_6=============================================
proc Sound6
; open speaker
	in al, 61h
	or al, 00000011b
	out 61h, al
; send control word to change frequency
	mov al, 0B6h
	out 43h, al
; play frequency 131Hz
	mov ax, [La_Sound]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al
	call Gray_La_Note
	call Fa_Black
	call Sol_Black
	call BORDER1
	call BORDER2
	call Sol_Border
	call La_Border
	call wait1sec ;wait 1 second
	call La_Note
	call Fa_Black
	call Sol_Black
	call BORDER1
	call BORDER2
	call Sol_Border
	call La_Border
	mov ax, 3h
	int 33h
	ret
endp Sound6
;==============================SOUND_7=============================================
proc Sound7
; open speaker
	in al, 61h
	or al, 00000011b
	out 61h, al
; send control word to change frequency
	mov al, 0B6h
	out 43h, al
; play frequency 131Hz
	mov ax, [Si_Sound]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al
	call Gray_Si_Note
	call Sol_Black
	call BORDER1
	call BORDER2
	call La_Border
	call wait1sec ;wait 1 second
	call Si_Note
	call Sol_Black
	call BORDER1
	call BORDER2
	call La_Border
	mov ax, 3h
	int 33h
	ret
endp Sound7
;==============================SOUND_8=============================================
proc Sound8
; open speaker
	in al, 61h
	or al, 00000011b
	out 61h, al
; send control word to change frequency
	mov al, 0B6h
	out 43h, al
; play frequency 131Hz
	mov ax, [Do2_Sound]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al
	call Gray_Do2_Note
	call Do2_Black
	call BORDER1
	call BORDER2
	call Si_Border
	call Do_Border
	call wait1sec ;wait 1 second
	call Do2_Note
	call Do2_Black
	call BORDER1
	call BORDER2
	call Si_Border
	call Do_Border
	mov ax, 3h
	int 33h
	ret
endp Sound8
;==============================SOUND_9=============================================
proc Sound9
; open speaker
	in al, 61h
	or al, 00000011b
	out 61h, al
; send control word to change frequency
	mov al, 0B6h
	out 43h, al
; play frequency 131Hz
	mov ax, [Re2_Sound]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al
	call Gray_Re2_Note
	call Do2_Black
	call yarok
	call BORDER1
	call BORDER2
	call Do2_Border
	call wait1sec ;wait 1 second
	call Re2_Note
	call Do2_Black
	call yarok
	call BORDER1
	call BORDER2
	call Do2_Border
	mov ax, 3h
	int 33h
	ret
endp Sound9
;==============================SOUND_10=============================================
proc Sound10
; open speaker
	in al, 61h
	or al, 00000011b
	out 61h, al
; send control word to change frequency
	mov al, 0B6h
	out 43h, al
; play frequency 131Hz
	mov ax, [B1_Sound]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al
	call Gray_Do_Black
	call BORDER1
	call BORDER2
	call wait1sec ;wait 1 second
	call Do_Black
	mov ax, 3h
	int 33h
	ret
endp Sound10
;==============================SOUND_11=============================================
proc Sound11
; open speaker
	in al, 61h
	or al, 00000011b
	out 61h, al
; send control word to change frequency
	mov al, 0B6h
	out 43h, al
; play frequency 131Hz
	mov ax, [B2_Sound]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al
	call Gray_Re_Black
	call BORDER1
	call BORDER2
	call wait1sec ;wait 1 second
	call Re_Black
	mov ax, 3h
	int 33h
	ret
endp Sound11
;==============================SOUND_12=============================================
proc Sound12
; open speaker
	in al, 61h
	or al, 00000011b
	out 61h, al
; send control word to change frequency
	mov al, 0B6h
	out 43h, al
; play frequency 131Hz
	mov ax, [B3_Sound]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al
	call Gray_Mi_Black
	call BORDER1
	call BORDER2
	call wait1sec ;wait 1 second
	call Mi_Black
	mov ax, 3h
	int 33h
	ret
endp Sound12
;==============================SOUND_13=============================================
proc Sound13
; open speaker
	in al, 61h
	or al, 00000011b
	out 61h, al
; send control word to change frequency
	mov al, 0B6h
	out 43h, al
; play frequency 131Hz
	mov ax, [B4_Sound]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al
	call Gray_Fa_Black
	call BORDER1
	call BORDER2
	call wait1sec ;wait 1 second
	call Fa_Black
	mov ax, 3h
	int 33h
	ret
endp Sound13
;==============================SOUND_14=============================================
proc Sound14
; open speaker
	in al, 61h
	or al, 00000011b
	out 61h, al
; send control word to change frequency
	mov al, 0B6h
	out 43h, al
; play frequency 131Hz
	mov ax, [B5_Sound]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al
	call Gray_Sol_Black
	call BORDER1
	call BORDER2
	call wait1sec ;wait 1 second
	call Sol_Black
	mov ax, 3h
	int 33h
	ret
endp Sound14
;==============================SOUND_15=============================================
proc Sound15
; open speaker
	in al, 61h
	or al, 00000011b
	out 61h, al
; send control word to change frequency
	mov al, 0B6h
	out 43h, al
; play frequency 131Hz
	mov ax, [B6_Sound]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al
	call Gray_Do2_Black
	call BORDER1
	call BORDER2
	call wait1sec ;wait 1 second
	call Do2_Black
	mov ax, 3h
	int 33h
	ret
endp Sound15
;===========================close speaker====================
proc closespeakers
	in al, 61h
	and al, 11111100b
	out 61h, al
	ret
endp closespeakers
;==============================waitsecond====================
proc wait1sec
; wait for first change in timer
	mov ax, 40h
	mov es, ax
	mov ax, [Clock]
FirstTick:
	cmp ax, [Clock]
	je FirstTick
; count 1 sec
	mov cx, 3 ; 182x0.055sec = ~10sec
DelayLoop:
	mov ax, [Clock]
Tick:
	cmp ax, [Clock]
	je Tick
	loop DelayLoop
	call closespeakers
	mov ah, 6         ; Wait For Keyboard Input 
	mov dl, 255   
	int 21h
	cmp al, 27 ;exit
	jne returm
	mov ah, 0 ; TEXT MODE
	mov al, 2 ; ***
	int 10h   ; ***
	mov ax, 4c00h
	int 21h
returm:
	ret
endp wait1sec
;==============================GRAY_DO_SQRT===========================================
proc Gray_Do_Note
	mov cx, 20 ;col 
	mov dx, 30 ;row
	mov al, 7
	mov ah, 0ch
Gray_paintDo:
	inc cx
	int 10h
	cmp cx, 50
	jne Gray_paintDo
	mov cx, 20
	inc dx
	cmp dx, 100
	jne Gray_paintDo
	ret
endp Gray_Do_Note
;==============================GRAY_RE_SQRT===========================================
proc Gray_Re_Note
	mov cx, 50 ;col 
	mov dx, 30 ;row
	mov al, 7 
	mov ah, 0ch
Gray_paintRe:
	inc cx
	int 10h
	cmp cx, 80
	jne Gray_paintRe
	mov cx, 50
	inc dx
	cmp dx, 100
	jne Gray_paintRe
	ret
endp Gray_Re_Note
;==============================GRAY_MI_SQRT===========================================
proc Gray_Mi_Note
	mov cx, 80 ;col 
	mov dx, 30 ;row
	mov al, 7 
	mov ah, 0ch
Gray_paintMi:
	inc cx
	int 10h
	cmp cx, 110
	jne Gray_paintMi
	mov cx, 80
	inc dx
	cmp dx, 100
	jne Gray_paintMi
	ret
endp Gray_Mi_Note
;==============================GRAY_FA_SQRT===========================================
proc Gray_Fa_Note
	mov cx, 110 ;col 
	mov dx, 30 ;row
	mov al, 7 ;15=WHITE
	mov ah, 0ch
Gray_paintFa:
	inc cx
	int 10h
	cmp cx, 140
	jne Gray_paintFa
	mov cx, 110
	inc dx
	cmp dx, 100
	jne Gray_paintFa
	ret
endp Gray_Fa_Note
;==============================GRAY_SOL_SQRT===========================================
proc Gray_Sol_Note
	mov cx, 140 ;col 
	mov dx, 30 ;row
	mov al, 7 ;15=WHITE
	mov ah, 0ch
Gray_paintSol:
	inc cx
	int 10h
	cmp cx, 170
	jne Gray_paintSol
	mov cx, 140
	inc dx
	cmp dx, 100
	jne Gray_paintSol
	ret
endp Gray_Sol_Note
;==============================GRAY_LA_SQRT===========================================
proc Gray_La_Note
	mov cx, 170 ;col 
	mov dx, 30 ;row
	mov al, 7 ;15=WHITE
	mov ah, 0ch
Gray_paintLa:
	inc cx
	int 10h
	cmp cx, 200
	jne Gray_paintLa
	mov cx, 170
	inc dx
	cmp dx, 100
	jne Gray_paintLa
	ret
endp Gray_La_Note
;==============================GRAY_SI_SQRT===========================================
proc Gray_Si_Note
	mov cx, 200 ;col 
	mov dx, 30 ;row
	mov al, 7 ;15=WHITE
	mov ah, 0ch
Gray_paintSi:
	inc cx
	int 10h
	cmp cx, 230
	jne Gray_paintSi
	mov cx, 200
	inc dx
	cmp dx, 100
	jne Gray_paintSi
	ret
endp Gray_Si_Note
;==============================GRAY_DO2_SQRT===========================================
proc Gray_Do2_Note
	mov cx, 230 ;col 
	mov dx, 30 ;row
	mov al, 7 ;15=WHITE
	mov ah, 0ch
Gray_paintDo2:
	inc cx
	int 10h
	cmp cx, 260
	jne Gray_paintDo2
	mov cx, 230
	inc dx
	cmp dx, 100
	jne Gray_paintDo2
	ret
endp Gray_Do2_Note
;==============================GRAY_RE2_SQRT===========================================
proc Gray_Re2_Note
	mov cx, 260 ;col 
	mov dx, 30 ;row
	mov al, 7 ;15=WHITE
	mov ah, 0ch
Gray_paintRe2:
	inc cx
	int 10h
	cmp cx, 290
	jne Gray_paintRe2
	mov cx, 260
	inc dx
	cmp dx, 100
	jne Gray_paintRe2
	ret
endp Gray_Re2_Note
;==============================GRAY_DO_BLACK===========================================
proc Gray_Do_Black
	mov cx, 42 ;col 
	mov dx, 30 ;row
	mov al, 8
	mov ah, 0ch
Gray_paintDoB:
	inc cx
	int 10h
	cmp cx, 59
	jne Gray_paintDoB
	mov cx, 42
	inc dx
	cmp dx, 70
	jne Gray_paintDoB
	ret
endp Gray_Do_Black
;==============================GRAY_RE_BLACK===========================================
proc Gray_Re_Black
	mov cx, 72 ;col 
	mov dx, 30 ;row
	mov al, 8
	mov ah, 0ch
Gray_paintReB:
	inc cx
	int 10h
	cmp cx, 89
	jne Gray_paintReB
	mov cx, 72
	inc dx
	cmp dx, 70
	jne Gray_paintReB
	ret
endp Gray_Re_Black
;==============================GRAY_MI_BLACK===========================================
proc Gray_Mi_Black
	mov cx, 132 ;col 
	mov dx, 30 ;row
	mov al, 8
	mov ah, 0ch
Gray_paintMiB:
	inc cx
	int 10h
	cmp cx, 149
	jne Gray_paintMiB
	mov cx, 132
	inc dx
	cmp dx, 70
	jne Gray_paintMiB
	ret
endp Gray_Mi_Black
;==============================GRAY_FA_BLACK===========================================
proc Gray_Fa_Black
	mov cx, 162 ;col 
	mov dx, 30 ;row
	mov al, 8
	mov ah, 0ch
Gray_paintFaB:
	inc cx
	int 10h
	cmp cx, 179
	jne Gray_paintFaB
	mov cx, 162
	inc dx
	cmp dx, 70
	jne Gray_paintFaB
	ret
endp Gray_Fa_Black
;==============================GRAY_Sol_BLACK===========================================
proc Gray_Sol_Black
	mov cx, 192 ;col 
	mov dx, 30 ;row
	mov al, 8
	mov ah, 0ch
Gray_paintSolB:
	inc cx
	int 10h
	cmp cx, 209
	jne Gray_paintSolB
	mov cx, 192
	inc dx
	cmp dx, 70
	jne Gray_paintSolB
	ret
endp Gray_Sol_Black
;==============================GRAY_DO2_BLACK===========================================
proc Gray_Do2_Black
	mov cx, 252 ;col 
	mov dx, 30 ;row
	mov al, 8
	mov ah, 0ch
Gray_paintDo2B:
	inc cx
	int 10h
	cmp cx, 269
	jne Gray_paintDo2B
	mov cx, 252
	inc dx
	cmp dx, 70
	jne Gray_paintDo2B
	ret
endp Gray_Do2_Black
;==============================PURIM=================================================
proc purim
	call sound4
	call sound5
	call sound4
	call wait1sec
	call sound4
	call sound5
	call sound4
	call wait1sec
	call sound4
	call sound5
	call sound4
	call sound5
	call sound4
	call sound3
	call sound2
	call wait1sec
	call sound5
	call sound5
	call sound5
	call wait1sec
	call sound5
	call sound5
	call sound5
	call wait1sec
	call sound5
	call sound5
	call sound4
	call sound3
	call sound4
	call wait1sec
	call sound6
	call sound6
	call sound5
	call sound4
	call sound5
	call sound5
	call sound5
	call wait1sec
	call sound5
	call sound5
	call sound4
	call sound3
	call sound4
	call sound4
	call sound4
	call wait1sec
	call sound6
	call sound6
	call sound5
	call sound4
	call sound5
	call sound5
	call sound5
	call wait1sec
	call sound2
	call sound5
	call sound4
	call sound3
	call sound2
	call wait1sec
	call sound2
	ret
endp purim
proc tikva
	call sound2
	call sound3
	call sound4
	call sound5
	call sound6
	call wait1sec
	call sound6
	call wait1sec
	call sound14
	call sound6
	call sound14
	call sound9
	call sound6
	call wait1sec
	call wait1sec
	call sound5
	call wait1sec
	call sound5
	call sound5
	call sound4
	call wait1sec
	call sound4
	call wait1sec
	call sound3
	call sound2
	call sound3
	call sound4
	call sound2
	call wait1sec
	call wait1sec
	call sound2
	call wait1sec
	call sound9
	call wait1sec
	call sound9
	call wait1sec
	call sound9
	call wait1sec
	call sound8
	call sound9
	call sound8
	call sound14
	call sound6
	call wait1sec
	call wait1sec
	call sound2
	call wait1sec
	call sound9
	call wait1sec
	call sound9
	call wait1sec
	call sound9
	call wait1sec
	call sound8
	call sound9
	call sound8
	call sound14
	call sound6
	call wait1sec
	call wait1sec
	call sound8
	call wait1sec
	call sound8
	call sound8
	call sound4
	call wait1sec
	call sound4
	call wait1sec
	call sound5
	call sound6
	call sound14
	call sound8
	call sound6
	call wait1sec
	call sound5
	call sound4
	call sound5
	call wait1sec
	call sound5
	call wait1sec
	call sound4
	call wait1sec
	call sound4
	call wait1sec
	call sound3
	call sound2
	call sound3
	call sound4
	call sound2
	ret
endp tikva
;==============================LITTLE_STAR============================================
proc little_star
	call sound1
	call wait1sec
	call sound1
	call wait1sec
	call sound5
	call wait1sec
	call sound5
	call wait1sec
	call sound6
	call wait1sec
	call sound6
	call wait1sec
	call sound5
	call wait1sec
	call wait1sec
	call sound4
	call wait1sec
	call sound4
	call wait1sec
	call sound3
	call wait1sec
	call sound3
	call wait1sec
	call sound2
	call wait1sec
	call sound2
	call wait1sec
	call sound1
	call wait1sec
	call wait1sec
	call sound5
	call wait1sec
	call sound5
	call wait1sec
	call sound4
	call wait1sec
	call sound4
	call wait1sec
	call sound3
	call wait1sec
	call sound3
	call wait1sec
	call sound2
	call wait1sec
	call wait1sec
	call sound5
	call wait1sec
	call sound5
	call wait1sec
	call sound4
	call wait1sec
	call sound4
	call wait1sec
	call sound3
	call wait1sec
	call sound3
	call wait1sec
	call sound2
	call wait1sec
	call wait1sec
	call sound1
	call wait1sec
	call sound1
	call wait1sec
	call sound5
	call wait1sec
	call sound5
	call wait1sec
	call sound6
	call wait1sec
	call sound6
	call wait1sec
	call sound5
	call wait1sec
	call wait1sec
	call sound4
	call wait1sec
	call sound4
	call wait1sec
	call sound3
	call wait1sec
	call sound3
	call wait1sec
	call sound2
	call wait1sec
	call sound2
	call wait1sec
	call sound1	
	ret
endp little_star
;==============================DOD_MOSHE==============================================
proc dod_moshe
	call sound2
	call sound5
	call sound5
	call sound5
	call sound2
	call sound3
	call sound3
	call sound2
	call wait1sec
	call sound7
	call sound7
	call sound6
	call sound6
	call sound5
	call wait1sec
	call wait1sec
	call sound2
	call sound5
	call sound5
	call sound5
	call sound2
	call sound3
	call sound3
	call sound2
	call wait1sec
	call sound7
	call sound7
	call sound6
	call sound6
	call sound5
	call wait1sec
	call wait1sec
	call sound2
	call sound5
	call sound5
	call sound5
	call sound2
	call sound5
	call sound5
	call sound5
	call wait1sec
	call sound5
	call sound5
	call sound5
	call sound5
	call sound5
	call sound5
	call sound5
	call sound2
	call sound5
	call sound5
	call sound5
	call sound2
	call sound3
	call sound3
	call sound2
	call wait1sec
	call sound7
	call sound7
	call sound6
	call sound6
	call sound5
	ret
endp dod_moshe
;===================================CHANGE_STYLE==============================
proc style
	add [colorcounter1], 7
	call Do_Note
		mov cl,  [colorcounter1]
		mov [colorcounter2], cl
		inc [colorcounter2]
	call Re_Note
		mov cl,  [colorcounter2]
		mov [colorcounter3], cl
		inc [colorcounter3]
	call Mi_Note
		mov cl,  [colorcounter3]
		mov [colorcounter4], cl
		inc [colorcounter4]
	call Fa_Note
		mov cl,  [colorcounter4]
		mov [colorcounter5], cl
		inc [colorcounter5]
	call Sol_Note
		mov cl,  [colorcounter5]
		mov [colorcounter6], cl
		inc [colorcounter6]
	call La_Note
		mov cl,  [colorcounter6]
		mov [colorcounter7], cl
		inc [colorcounter7]
	call Si_Note
		mov cl,  [colorcounter7]
		mov [colorcounter8], cl
		inc [colorcounter8]
	call Do2_Note
		mov cl,  [colorcounter8]
		mov [colorcounter9], cl
		inc [colorcounter9]
	call Re2_Note
	;--
	call Border1
	call Do_Border
	call Re_Border
	call Mi_Border
	call Fa_Border
	call Sol_Border
	call La_Border
	call Si_Border
	call Do2_Border
	call Re2_Border
	call yarok
	call Do_Black
	call Re_Black
	call Mi_Black
	call Fa_Black
	call Sol_Black
	call Do2_Black
	call Border2
	ret
endp style
;==============================BACK_TO_WHITE=========================================
proc style1
	add [colorcounter1], 7
	call Do_Note
		mov cl,  [colorcounter1]
		mov [colorcounter2], cl
		inc [colorcounter2]
	call Re_Note
		mov cl,  [colorcounter2]
		mov [colorcounter3], cl
		inc [colorcounter3]
	call Mi_Note
		mov cl,  [colorcounter3]
		mov [colorcounter4], cl
		inc [colorcounter4]
	call Fa_Note
		mov cl,  [colorcounter4]
		mov [colorcounter5], cl
		inc [colorcounter5]
	call Sol_Note
		mov cl,  [colorcounter5]
		mov [colorcounter6], cl
		inc [colorcounter6]
	call La_Note
		mov cl,  [colorcounter6]
		mov [colorcounter7], cl
		inc [colorcounter7]
	call Si_Note
		mov cl,  [colorcounter7]
		mov [colorcounter8], cl
		inc [colorcounter8]
	call Do2_Note
		mov cl,  [colorcounter8]
		mov [colorcounter9], cl
		inc [colorcounter9]
	call Re2_Note
	;--
	call Border1
	call Do_Border
	call Re_Border
	call Mi_Border
	call Fa_Border
	call Sol_Border
	call La_Border
	call Si_Border
	call Do2_Border
	call Re2_Border
	call yarok
	call Do_Black
	call Re_Black
	call Mi_Black
	call Fa_Black
	call Sol_Black
	call Do2_Black
	call Border2
	ret
endp style1
;==============================CONTINUE===============================================
proc Keyboard
	mov ah, 01h
	int 21h
	ret
endp Keyboard
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here
; --------------------------
	call GRAPHICS
;========================BMP_CALLS=====================
	call OpenFile
	call ReadHeader
	call ReadPalette
	call CopyPal
	call CopyBitmap
loop2:
	mov ah, 6         ; Wait For Keyboard Input 
	mov dl, 255   
	int 21h
waitforkeytostart:
	cmp al, 's' 
	je startfromhere
	cmp al, 'i' 
	je instructions
	jne loop2
;======================================================
instructions:
	call GRAPHICS
	call OpenFile2
	call ReadHeader
	call ReadPalette
	call CopyPal
	call CopyBitmap
loop3:
	mov ah, 6         ; Wait For Keyboard Input 
	mov dl, 255   
	int 21h
waitforkeytostart2:
	cmp al, 's' 
	je startfromhere
	cmp al, 27 
	je start
	jne loop3
startfromhere:
	mov ah, 3Eh ;Close The File To Save Memory
	int 21h  ; ***
	call GRAPHICS
	call ScreenColor
	call Do_Note
	call Re_Note
	call Mi_Note
	call Fa_Note
	call Sol_Note
	call La_Note
	call Si_Note
	call Do2_Note
	call Re2_Note
	call Border1
	call Do_Border
	call Re_Border
	call Mi_Border
	call Fa_Border
	call Sol_Border
	call La_Border
	call Si_Border
	call Do2_Border
	call Re2_Border
	call yarok
	call Do_Black
	call Re_Black
	call Mi_Black
	call Fa_Black
	call Sol_Black
	call Do2_Black
	call BORDER2
	call printPiano
	call print
	call print4
	call print3
	xor ax, ax
	xor bx, bx
	xor cx, cx
	xor dx, dx
	;========================================================
loop1:
	mov ah, 6         ; Wait For Keyboard Input 
	mov dl, 255   
	int 21h
press:
	cmp al, 'q' ;DO
	je dosound
	cmp al, 'm' ;DO
	je changestyle
	cmp al, 'w' ;RE
	je resound
	cmp al, 'e' ;MI
	je misound
	cmp al, 'r' ;FA
	je fasound
	cmp al, 't' ;SOL
	je solsound
	cmp al, 'y' ;LA
	je lasound
	cmp al, 'u' ;SI
	je sisound
	cmp al, 'i' ;DO2
	je do2sound
	cmp al, 'o' ;RE2
	je re2sound
	cmp al, '0' ;yarok
	je yaroksound
	cmp al, '2' ;B1
	je black1sound
	cmp al, '3' ;B2
	je black2sound
	cmp al, '5' ;B3
	je black3sound
	cmp al, '6' ;B4
	je black4sound
	cmp al, '7' ;B5
	je black5sound
	cmp al, '9' ;B6
	je black6sound
	cmp al, 'x' ;TIKVA
	je tikva_play
	cmp al, 'z' ;PURIM
	je purim_play
	cmp al, 'c' ;LITTLE_STARS
	je little_star_play
	cmp al, 'v' ;DOD_MOSHE
	je dod_moshe_play
	cmp al, 'h' ;help
	je helpjmp
	cmp al, 27 ;EXIT
	je exit
	jne loop1
yaroksound:
	call soundyarok
	jmp loop1
changestyle:
	call style
	jmp loop1
dosound:
	call Sound1
	jmp loop1
resound:
	call Sound2
	jmp loop1
misound:
	call Sound3
	jmp loop1
fasound:
	call Sound4
	jmp loop1
solsound:
	call Sound5
	jmp loop1
lasound:
	call Sound6
	jmp loop1
sisound:
	call Sound7
	jmp loop1
do2sound:
	call sound8
	jmp loop1
re2sound:
	call sound9
	jmp loop1
black1sound:
	call sound10
	jmp loop1
black2sound:
	call sound11
	jmp loop1
black3sound:
	call sound12
	jmp loop1
black4sound:
	call sound13
	jmp loop1
black5sound:
	call sound14
	jmp loop1
black6sound:
	call sound15
	jmp loop1
tikva_play:
	call tikva
	jmp loop1
purim_play:
	call purim
	jmp loop1
little_star_play:
	call little_star
	jmp loop1
dod_moshe_play:
	call dod_moshe
	jmp loop1
helpjmp:
	call instructions
exit:
	mov ah, 0 ; TEXT MODE
	mov al, 2 ; ***
	int 10h   ; ***
	mov ax, 4c00h
	int 21h
END start
