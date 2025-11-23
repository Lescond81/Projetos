TITLE Jogo da Velha - L
.MODEL SMALL
.STACK 100h

pushall MACRO
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    
ENDM

popall MACRO
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX

ENDM

limpall MACRO 
    XOR AX, AX
    XOR BX, BX
    XOR CX, CX
    XOR DX, DX
    XOR SI, SI
    XOR DI, DI
ENDM

grade macro
    pushall
    mov ax, 10
    mov cx, 200

    g: 
        linha 0, ax, 320, 0dh
        coluna ax, 0, 200, 0dh
        add ax, 10
    loop g

    popall
endm
guia macro

    pixels 0ah, 155, 95
    pixels 0ah, 105, 95
    pixels 0ah, 205, 95

    pixels 0ah, 155, 45
    pixels 0ah, 105, 45
    pixels 0ah, 205, 45

    pixels 0ah, 155, 145
    pixels 0ah, 105, 145
    pixels 0ah, 205, 145
    
endm
linha macro xl,yl,taml,corl
    local VOLTAL
    pushall
    mov bx, taml
    inc BX
    mov cx, xl
    mov dx, yl
    mov al, corl
    voltal:
        pixels al, cx, Dx
        inc cx 
        dec bx
        jnz voltal
    popall
endm
coluna MACRO xc, yc, tamc, corc
    LOCAL VOLTAC
    pushall
    MOV BX, tamc 
    INC BX
    MOV CX, xc
    MOV DX, yc
    MOV AL, corc
    VOLTAC:
        pixels AL, CX, DX
        INC DX
        DEC BX
        JNZ VOLTAC 

    popall
ENDM

string MACRO str, tamstr, xstr, ystr, corstr
    LOCAL STRINGVOLTA
    pushall
    MOV CH, ystr
    MOV CL, xstr
    MOV DL, tamstr
    LEA BX, str
    STRINGVOLTA:
        
        posicursor CH, CL

        MOV AL, [BX]

        printacaracter corstr, AL

        INC BX 

        INC CL

        DEC DL
        JNZ STRINGVOLTA

    popall
ENDM
posicursor MACRO xcu, ycu ; seta o cursor na posição em DH-linha e DL-coluna
    pushall
    MOV AH, 02H
    MOV BH, 0
    MOV DH, xcu
    MOV DL, ycu
    INT 10H
    popall
ENDM

printacaracter MACRO corl, letra ; printa o caracter na posição do cursor
    pushall

    MOV AL, letra
    MOV AH, 09
    MOV BL, corl
    XOR BH, BH
    MOV CX, 1
    INT 10H
    popall
ENDM
pixels MACRO corpix, xp, yp
    pushall
    PUSH BX

    MOV AH, 0CH 
    MOV BH, 0
    MOV AL, corpix 
    MOV CX, xp
    MOV DX, yp
    int 10H

    POP BX 

    popall
ENDM
botaom MACRO corbot, xbi,ybi, xbf,ybf
    LOCAL VOLTABOTAO2
    pushall
    MOV CX, xbi
    MOV DX, ybi
    VOLTABOTAO2:
        pixels corbot, CX, DX
        INC CX 
        CMP CX, xbf
        JBE VOLTABOTAO2
        INC DX
        MOV CX, xbi
        CMP DX, ybf
        JBE VOLTABOTAO2


    popall 
ENDM 
desenho MACRO xd,yd,pixdata
    LOCAL DESECOL, DESELINHA

    pushall
    limpall

    
    MOV DX, yd
    xor bx, bx
    DESELINHA:
     MOV CX, xd
     XOR SI, SI
        DESECOL:
         pixels pixdata[BX][SI], CX, DX
         INC CX 
         INC SI
         CMP SI, gtam
         JB DESECOL
         INC DX 
         INC BX
         CMP BX, gtam
         JB DESELINHA
        
    popall
ENDM
tabuleiro macro
    botaom 0Fh, 75, 15, 235, 175 
    coluna 130, 20, 150, 09h       
    coluna 131, 20, 150, 09h
    coluna 180, 20, 150, 09h       
    coluna 181, 20, 150, 09h
        
    linha 80, 69, 150, 04h
    linha 80, 70, 150, 04h
    linha 80, 120, 150, 04h
    linha 80, 121, 150, 04h

endm
seletor macro xs, ys
    local voltaacols, voltaalins, voltadcols, voltadlins
    pushall
    mov cx, xs
    mov dx, ys
    
    push cx
    add cx, 25
    coluna cx, dx, 50, 0Ah 
    pop cx

    push dx
    add dx, 25
    linha cx, dx, 50, 0Ah 
    pop dx

    popall
endm
coloca macro desx, desy, quem
    LOCAL DES0
    cmp quem, 0
    je DES0
    
    desenho desx, desy, OXIS

    DES0:
     desenho desx, desy, ABOLA
    ret
endm
telainicio macro cf1J, cp1J, cf2J, cp2J
    string titu, 13, 15, 5, 0Fh
        
    botaom cf1J, 104, 84, 234, 104
    botaom cp1J, 100, 80, 230, 100
    string modo1, 13, 14, 11, 0Eh
    botaom cf2J, 101, 134, 231, 154
    botaom cp2J, 97, 130, 227, 150
    string modo2, 11, 15, 17, 0Eh
endm
.DATA
 TAB DW 01, 02, 03
     DW 04, 05, 06
     DW 07, 08, 09

 PULA DB 10,13,'$'
 
 titu db 'JOGO da VELHA'
 modo2 db '2 Jogadores'
 modo1 db 'Jogador VS IA'
 corsf1 db 04h
 corsp1 db 0Ch
 corsf2 db 09h
 corsp2 db 0Bh

 JX db 1
 J0 db 0

 gtam dw 50

 OXIS db 2 dup (0fh), 4 dup (0ah), 38 dup (0fh), 4 dup (0ah), 2 dup (0fh)
      db 0fh, 6 dup (0h), 36 dup (0fh), 6 dup (0ah), 0fh
      db 0fh, 7 dup (0h), 34 dup (0fh), 7 dup (0ah), 0fh
      db 2 dup (0fh), 7 dup (0ah), 32 dup (0fh), 7 dup (0ah), 2 dup (0fh)
      db 2 dup (0fh), 8 dup (0ah), 30 dup (0fh), 8 dup (0ah), 2 dup (0fh)
      db 3 dup (0fh), 8 dup (0ah), 28 dup (0fh), 8 dup (0ah), 3 dup (0fh)
      db 3 dup (0fh), 9 dup (0ah), 26 dup (0fh), 9 dup (0ah), 3 dup (0fh)   
      db 4 dup (0fh), 9 dup (0ah), 24 dup (0fh), 9 dup (0ah), 4 dup (0fh)  
      db 5 dup (0fh), 9 dup (0ah), 22 dup (0fh), 9 dup (0ah), 5 dup (0fh)
      db 6 dup (0fh), 9 dup (0ah), 20 dup (0fh), 9 dup (0ah), 6 dup (0fh)
      db 7 dup (0fh), 9 dup (0ah), 18 dup (0fh), 9 dup (0ah), 7 dup (0fh)
      db 8 dup (0fh), 9 dup (0ah), 16 dup (0fh), 9 dup (0ah), 8 dup (0fh)
      db 9 dup (0fh), 9 dup (0ah), 14 dup (0fh), 9 dup (0ah), 9 dup (0fh)
      db 10 dup (0fh), 9 dup (0ah), 12 dup (0fh), 9 dup (0ah), 10 dup (0fh)
      db 11 dup (0fh), 9 dup (0ah), 10 dup (0fh), 9 dup (0ah), 11 dup (0fh)
      db 12 dup (0fh), 9 dup (0ah), 8 dup (0fh), 9 dup (0ah), 12 dup (0fh)
      db 13 dup (0fh), 9 dup (0ah), 6 dup (0fh), 9 dup (0ah), 13 dup (0fh)
      db 14 dup (0fh), 9 dup (0ah), 4 dup (0fh), 9 dup (0ah), 14 dup (0fh)
      db 15 dup (0fh), 9 dup (0ah), 2 dup (0fh), 9 dup (0ah), 15 dup (0fh)
      db 16 dup (0fh), 18 dup (0ah), 16 dup (0fh)
      db 17 dup (0fh), 16 dup (0ah), 17 dup (0fh)
      db 18 dup (0fh), 14 dup (0ah), 18 dup (0fh)
      db 18 dup (0fh), 14 dup (0ah), 18 dup (0fh)
      db 19 dup (0fh), 12 dup (0ah), 19 dup (0fh)
      db 19 dup (0fh), 12 dup (0ah), 19 dup (0fh)
      db 19 dup (0fh), 12 dup (0ah), 19 dup (0fh)
      db 19 dup (0fh), 12 dup (0ah), 19 dup (0fh)
      db 18 dup (0fh), 14 dup (0ah), 18 dup (0fh)
      db 18 dup (0fh), 14 dup (0ah), 18 dup (0fh)
      db 17 dup (0fh), 16 dup (0ah), 17 dup (0fh)
      db 16 dup (0fh), 18 dup (0ah), 16 dup (0fh)
      db 15 dup (0fh), 9 dup (0ah), 2 dup (0fh), 9 dup (0ah), 15 dup (0fh)
      db 14 dup (0fh), 9 dup (0ah), 4 dup (0fh), 9 dup (0ah), 14 dup (0fh)
      db 13 dup (0fh), 9 dup (0ah), 6 dup (0fh), 9 dup (0ah), 13 dup (0fh)
      db 12 dup (0fh), 9 dup (0ah), 8 dup (0fh), 9 dup (0ah), 12 dup (0fh)
      db 11 dup (0fh), 9 dup (0ah), 10 dup (0fh), 9 dup (0ah), 11 dup (0fh)
      db 10 dup (0fh), 9 dup (0ah), 12 dup (0fh), 9 dup (0ah), 10 dup (0fh)
      db 9 dup (0fh), 9 dup (0ah), 14 dup (0fh), 9 dup (0ah), 9 dup (0fh)
      db 8 dup (0fh), 9 dup (0ah), 16 dup (0fh), 9 dup (0ah), 8 dup (0fh)
      db 7 dup (0fh), 9 dup (0ah), 18 dup (0fh), 9 dup (0ah), 7 dup (0fh)
      db 6 dup (0fh), 9 dup (0ah), 20 dup (0fh), 9 dup (0ah), 6 dup (0fh) 
      db 5 dup (0fh), 9 dup (0ah), 22 dup (0fh), 9 dup (0ah), 5 dup (0fh) 
      db 4 dup (0fh), 9 dup (0ah), 24 dup (0fh), 9 dup (0ah), 4 dup (0fh) 
      db 3 dup (0fh), 9 dup (0ah), 26 dup (0fh), 9 dup (0ah), 3 dup (0fh) 
      db 3 dup (0fh), 8 dup (0ah), 28 dup (0fh), 8 dup (0ah), 3 dup (0fh) 
      db 2 dup (0fh), 8 dup (0ah), 30 dup (0fh), 8 dup (0ah), 2 dup (0fh)
      db 2 dup (0fh), 7 dup (0ah), 32 dup (0fh), 7 dup (0ah), 2 dup (0fh)
      db 0fh, 7 dup (0fh), 34 dup (0fh), 7 dup (0ah), 0fh
      db 0fh, 6 dup (0fh), 36 dup (0fh), 6 dup (0ah), 0fh
      db 2 dup (0fh), 4 dup (0ah), 38 dup (0fh), 4 dup (0ah), 2 dup (0fh)
      
 ABOLA db 23 dup (0fh), 4 dup (0ah), 23 dup (0fh)



; posições para os seletorees referentes a posição do tabuleiro, referentes aos cantos superiores esquerdos de cada setor
 smx dw 130 ; seletor meio x
 smy dw 70 ; seletor meio y
 scsex dw 80 ; seletor c superior esquerdo x
 scsey dw 20 ;seletor c superior esquerdo y
 scx dw 130 ; seletor cima x
 scy dw 20 ; seletor cima y
 scsdx dw 180 ; seletor c superior direito x
 scsdy dw 20 ; seletor c superior direito y
 sex dw 80 ; seletor esquerdo x
 sey dw 70 ; seletor esquerdo y
 sdx dw 180 ; seletor direito x
 sdy dw 70 ; seletor direito y
 sciex dw 80 ; seletor c inferior esquerdo x
 sciey dw 120 ; seletor c inferior esquerdo y
 sbx dw 130 ; seletor baixo x
 sby dw 120 ; seletor bairo y
 scidx dw 180 ;seletor c inferior direito x
 scidy dw 120 ; seletor c inferior direito y

.CODE
    ;description
    MAIN PROC
       
        MOV AX, @DATA
        MOV DS, AX
        
        MOV AX,13
        INT 10h ; seta no modo video 320x200 256 color graphics
        
        MOV AH,0Bh ; DETERMINA COR DE FUNDO EM BL
        MOV BL,07h
        INT 10h

        

        telai1:
         telainicio corsf1, corsp1, corsf2, corsp2
         mov ah, 1
         int 21h
         cmp al, 13
         je Jogador1
         cmp al, 's'
         je telai2
         jmp telai1
         Jogador1:
            jmp J1
         telai2:
          telainicio corsf2, corsp2, corsf1, corsp1
          int 21h
          cmp al, 'w'
          je Pti1
          cmp al, 13
          ;je Jogador2
            Pti1:
                jmp telai1
        jmp telai2

        ;call limpatela
        ;grade 

        J1:
         tabuleiro
         mov ah, 1
         mov bh, JX ; indica qual simbolo sera jogado, x (JX) ou 0 (J0)
         MOV CX, 5
         indica:
            call meio
         LOOP INDICA



        ;guia


        MOV AH,4Ch
        INT 21h

    MAIN ENDP
    
    limpatela PROC
        pushall
        mov ah,06h	;clear screen instruction
        mov al,00h	;number of lines to scroll
        mov bh,07h	;display attribute - colors
        mov ch,00d	;start row
        mov cl,00d	;start col
        mov dh,24d	;end of row
        mov dl,79d	;end of col
        int 10h		;BIOS interrupt
        popall
        ret
    limpatela ENDP
    
    meio proc
       m: 
        seletor smx, smy
        int 21h
        cmp al, 13
        je colom
        
        cmp al, 'w'
        jne cm
         call cima
         ret
        cm:
        cmp al, 'a'
        jne em
         call esquerda
         ret
        em:
        cmp al, 's'
        jne bm
         call baixo
         ret
        bm:
        cmp al, 'd'
        jne dm
          call direita
          ret
        dm:
       jmp m 
       colom:
        coloca smx, smy, bh
        
        
    endp    

    cima proc
       c: 
        seletor scx, scy
        int 21h
        cmp al, 13
        je coloc

        cmp al, 'a'
        jne ce
         call supesq
         ret
        ce:
        cmp al, 's'
        jne cb
         call meio
         ret
        cb:
        cmp al, 'd'
        jne cd
         call supdir
         ret
        cd:
       jmp c
        coloc:
         coloca scx, scy, bh

    endp

    esquerda proc
       e: 
        seletor sex, sey
        int 21h
        cmp al, 13
        je coloe

        cmp al, 'w'
        je ec

        cmp al, 'd'
        je ed
        
        cmp al, 's'
        je eb
       jmp e

        ec:
         call supesq
        ret

        ed:
         call meio
        ret

        eb:
         call infesq
        ret

        coloe:
         coloca sex, sey, bh
    endp

    baixo proc
       b: 
        seletor sbx, sby
        int 21h
        cmp al, 13
        je colob
        cmp al, 'a'
        je be
        cmp al, 'w'
        je bc
        cmp al, 'd'
        je bd
       jmp b

        be: 
         call infesq
        ret

        bc:
         call meio
        ret

        bd:
         call infdir
        ret

        colob:
         coloca sbx, sby, bh
    endp

    direita proc
       d: 
        seletor sdx, sdy
        int 21h
        cmp al, 13
        je colod
        cmp al, 'a'
        je de
        cmp al, 'w'
        je dc
        cmp al, 's'
        je dba
       jmp d 

        de: 
         call meio
        ret

        dc:
         call supdir
        ret

        dba:
         call infdir
        ret

        colod: 
         coloca sdx, sdy, bh
    endp

    supesq proc
       se:
        seletor scsex, scsey
        int 21h
        cmp al, 13
        je colose
        cmp al, 'd'
        je sed
        cmp al, 's'
        je seb
       jmp se

        sed:
         call cima
        ret

        seb:
         call esquerda
        ret

        colose:
         coloca scsex, scsey, BH
    endp

    infesq proc
       ie:
        seletor sciex, sciey
        int 21h
        cmp al, 13
        je coloie
        cmp al, 'w'
        je iec
        cmp al, 'd'
        je ied  
       jmp ie

        iec: 
         call esquerda
        ret

        ied:
         call baixo
        ret

        coloie:
         coloca sciex, sciey, bh
    endp

    infdir proc
       id:
        seletor scidx, scidy
        int 21h
        cmp al, 13
        je coloid
        cmp al, 'a'
        je ide
        cmp al, 'w'
        je idc
       jmp id

        ide:
         call baixo
        ret

        idc:
         call direita
        ret

        coloid:
         coloca scidx, scidy, bh
    endp

    supdir proc
       sd:
        seletor scsdx, scsdy
        int 21h
        cmp al, 13 
        je colosd
        cmp al, 'a'
        je sde
        cmp al, 's'
        je sdb
       jmp sd

        sde:
         call cima
        ret

        sdb:
         call direita
        ret

        colosd:
         coloca scsdx, scsdy, bh
    endp 

END MAIN
