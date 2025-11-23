title velhanova
.model small
.stack 100h

.data
    turno db 1 ; 1 = jogador, 2 = IA ou Jogador 2
    modo_jogo db 1 ;1 = vs IA | 2 = vs Jogador 2
    ganha  db 0

    msg_menu db 13,10,'Escolha o modo de jogo:',13,10,'1 - Jogar contra a IA',13,10,'2 - Jogar contra outro jogador',13,10,'Opcao: $'
    msg_player_win db 13,10,'Jogador 1 venceu!$'
    msg_player2_win db 13,10,'Jogador 2 venceu!$'
    msg_ia_win db 13,10,'IA venceu!$'
    msg_empate db 13,10,'Empate!$'

    msg db 13,10,'Jogador 1 - Digite um numero de 1 a 9:  $'
    msg_turno2 db 13,10,'Jogador 2 - Digite um numero de 1 a 9:  $'
    erro db 13,10,'Entrada invalida$'

    pula db 13,10,'$'
    tabu db 0,0,0,0,0,0,0,0,0

    linhas db 0,1,2, 3,4,5, 6,7,8, 0,3,6, 1,4,7, 2,5,8, 0,4,8, 2,4,6
    cantos db 0,2,6,8

.code
main proc
    mov ax,@data
    mov ds,ax

;imprimindo o menu do jogo
menu_jogo:
    lea dx, msg_menu
    mov ah,09h
    int 21h

    mov ah,01h
    int 21h

    cmp al, '1'
    je selecionaIA
    cmp al, '2'
    je selecionaPVP
    jmp menu_jogo

selecionaIA:
    mov byte ptr [modo_jogo], 1
    jmp inicia

selecionaPVP:
    mov byte ptr [modo_jogo], 2
    jmp inicia

;inicializa o ttabuleiro
inicia:
    lea si, tabu
    mov cx, 9
    xor bx, bx
zeraTab:
    mov byte ptr [si+bx], 0
    inc bx
    loop zeraTab

;loop principal
loop_jogo:
    call print_tabu

    mov al, [turno]
    cmp al, 1
    je turno_player1

    ; turno 2 = IA ou Jogador 2
    mov bl, [modo_jogo]
    cmp bl, 1
    je turno_IA
    jmp turno_player2

turno_player1:
    call valida_marca
    jmp dps_jogado

turno_player2:
    call valida_marca_j2
    jmp dps_jogado

turno_IA:
    call IA_jogar
    jmp dps_jogado

dps_jogado:
    call check_ganha
    cmp al,0
    jne houve_ganhador

    call jatem
    cmp al,1
    jne troca_turno

    lea dx, msg_empate
    mov ah,09h
    int 21h
    jmp final_main

houve_ganhador:
    cmp al,1
    je ganhou_p1
    cmp al,2
    je ganhou_p2

ganhou_p1:
    lea dx, msg_player_win
    mov ah,09h
    int 21h
    jmp final_main

ganhou_p2:
    mov bl,[modo_jogo]
    cmp bl,1
    je ganhou_ia

    lea dx, msg_player2_win
    mov ah,09h
    int 21h
    jmp final_main

ganhou_ia:
    lea dx, msg_ia_win
    mov ah,09h
    int 21h
    jmp final_main


troca_turno:
    mov al,[turno]
    cmp al,1
    je set_turno2
    mov byte ptr [turno],1
    jmp loop_jogo

set_turno2:
    mov byte ptr [turno],2
    jmp loop_jogo


final_main:
    mov ah,08h
    int 21h
    mov ah,4Ch
    int 21h
main endp

;imprime o ttabuleiro
print_tabu proc
    push ax bx cx dx si

    mov dl,13
    mov ah,02h
    int 21h
    mov dl,10
    int 21h

    lea si, tabu
    mov cx, 3
    mov bx, 0
linha:
    mov di, 3
coluna:
    mov al,[si+bx]
    cmp al,0
    jne cheio
    mov dl,'1'
    add dl,bl
    mov ah,02h
    int 21h
    jmp aposPrint

cheio:
    cmp al,1
    jne imprimeO
    mov dl,'X'
    mov ah,02h
    int 21h
    jmp aposPrint
imprimeO:
    mov dl,'O'
    mov ah,02h
    int 21h

aposPrint:
    mov dl,' '
    mov ah,02h
    int 21h

    inc bx
    dec di
    jnz coluna

    mov dl,13
    mov ah,02h
    int 21h
    mov dl,10
    int 21h

    dec cx
    jnz linha

    pop si dx cx bx ax
    ret
print_tabu endp

;player 1
valida_marca proc
    lea dx,msg
    mov ah,09h
    int 21h

    mov ah,01h
    int 21h

    cmp al,'1'
    jb inval1
    cmp al,'9'
    ja inval1

    sub al,'1'
    mov bl,al
    mov al,[tabu+bx]
    cmp al,0
    jne ocupado1

    mov byte ptr [tabu+bx],1
    ret

ocupado1:
    lea dx,erro
    mov ah,09h
    int 21h
    ret

inval1:
    lea dx,erro
    mov ah,09h
    int 21h
    ret
valida_marca endp

;player 2
valida_marca_j2 proc
    lea dx,msg_turno2
    mov ah,09h
    int 21h

    mov ah,01h
    int 21h

    cmp al,'1'
    jb inval2
    cmp al,'9'
    ja inval2

    sub al,'1'
    mov bl,al
    mov al,[tabu+bx]
    cmp al,0
    jne ocupado2

    mov byte ptr [tabu+bx],2
    ret

ocupado2:
    lea dx,erro
    mov ah,09h
    int 21h
    ret

inval2:
    lea dx,erro
    mov ah,09h
    int 21h
    ret
valida_marca_j2 endp

;ve quem ganhou
check_ganha proc
    lea si, linhas
    mov cx, 8
    mov al, 0
check_loop:
    mov dl,[si]
    mov dh,[si+1]

    lea di, tabu
    xor bh,bh
    mov bl,[si]
    mov al,[di+bx]
    cmp al,0
    je prox

    xor bh,bh
    mov bl,[si+1]
    mov ah,[di+bx]
    cmp al,ah
    jne prox

    xor bh,bh
    mov bl,[si+2]
    mov ah,[di+bx]
    cmp al,ah
    jne prox

    ret
prox:
    add si,3
    dec cx
    jnz check_loop

    mov al,0
    ret
check_ganha endp

;vendo se o tabu ta cheio
jatem proc
    lea si,tabu
    mov cx,9
    xor bx,bx
loopJ:
    mov al,[si+bx]
    cmp al,0
    je vazio
    inc bx
    loop loopJ
    mov al,1
    ret
vazio:
    mov al,0
    ret
jatem endp


verif_linhaCompletar PROC
    push bx cx dx si di

    mov dl, al
    lea si, linhas
    lea di, tabu
    mov cx, 8
    mov al, 0FFh

vl_loop:
    mov bl, [si]
    xor bh, bh
    mov ah, [di+bx]
    mov bl, [si+1]
    xor bh, bh
    mov al, [di+bx]
    cmp ah, dl
    jne caso2
    cmp al, dl
    jne caso2
    mov bl, [si+2]
    xor bh, bh
    mov al, [di+bx]
    cmp al, 0
    jne caso2
    mov al, [si+2]
    jmp achado

caso2:
    mov bl, [si]
    xor bh, bh
    mov al, [di+bx]
    cmp al, dl
    jne caso3
    mov bl, [si+1]
    xor bh, bh
    mov al, [di+bx]
    cmp al, 0
    jne caso3
    mov bl, [si+2]
    xor bh, bh
    mov al, [di+bx]
    cmp al, dl
    jne caso3
    mov al, [si+1]
    jmp achado

caso3:
    mov bl, [si]
    xor bh, bh
    mov al, [di+bx]
    cmp al, 0
    jne prox1
    mov bl, [si+1]
    xor bh, bh
    mov al, [di+bx]
    cmp al, dl
    jne prox1
    mov bl, [si+2]
    xor bh, bh
    mov al, [di+bx]
    cmp al, dl
    jne prox1
    mov al, [si]
    jmp achado

prox1:
    add si, 3
    dec cx
    jnz vl_loop

    mov al, 0FFh
    jmp fim

achado:
fim:
    pop di si dx cx bx
    ret
verif_linhaCompletar ENDP

IA_jogar PROC
    push ax bx cx dx si di

    mov al, 2
    call verif_linhaCompletar
    cmp al, 0FFh
    jne joga

    mov al, 1
    call verif_linhaCompletar
    cmp al, 0FFh
    jne joga

    lea si, tabu
    mov al, [si+4]
    cmp al, 0
    jne verCantos1
    mov al, 4
    jmp joga

verCantos1:
    lea si, cantos
    lea di, tabu
    mov cx, 4
cantoLoop:
    mov bl,[si]
    mov al,[di+bx]
    cmp al,0
    je cantoAchado
    inc si
    loop cantoLoop

    lea di, tabu
    xor bx,bx
    mov cx,9
outro:
    mov al,[di+bx]
    cmp al,0
    je joga
    inc bx
    loop outro
    jmp fimIA

cantoAchado:
    mov al, bl

joga:
    lea di,tabu
    mov bl, al
    mov byte ptr [di+bx],2

fimIA:
    pop di si dx cx bx ax
    ret
IA_jogar ENDP

end main
