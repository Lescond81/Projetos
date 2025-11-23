title velhanova
.model small
.stack 100h

.data
    turno db 1            ; 1 = jogador, 2 = IA
    ganha  db 0
    msg_player_win db 13,10,'Voce venceu!$'
    msg_ia_win db 13,10,'IA venceu!$'
    msg_empate db 13,10,'Empate!$'
    ; 0 = vazio, 1 = X (jogador), 2 = O (IA)
    tabu db 0,0,0,0,0,0,0,0,0
    msg db 13,10,'Digite um numero de 1 a 9:  $'
    erro db 13,10,'Entrada invalida$'
    pula db 13,10,'$'
    ; tabela de linhas (cada 3 bytes = uma linha/coluna/diagonal)
    linhas db 0,1,2, 3,4,5, 6,7,8, 0,3,6, 1,4,7, 2,5,8, 0,4,8, 2,4,6
    cantos db 0,2,6,8
.code
; MAIN: inicializa e entra no loop de jogo
main proc
    mov ax,@data
    mov ds,ax

    ; inicializar tabuleiro (todos zeros)
    lea si, tabu
    mov cx, 9
    xor bx, bx
loopinicio:
    mov byte ptr [si+bx], 0
    inc bx
    loop loopinicio

loop_jogo:
    ; desenha tabuleiro
    call print_tabu

    ; turno do jogador
    mov al, [turno]
    cmp al, 1
    je turno_player

    ; turno da IA
    call IA_jogar
    jmp dps_jogado

turno_player:
    ; lê e marca movimento do jogador (valida_marca deve validar e escrever 1)
    call valida_marca

dps_jogado:
    ; verificar vencedor
    call check_ganha    ; retorna AL = 0 (nenhum) / 1 (X=jogador) / 2 (O=IA)
    cmp al, 0
    jne ganhador

    ; verificar empate
    call jatem         ; AL = 1 se cheio, 0 se ainda esta vazio
    cmp al, 1
    jne troca_turno

    ; empate
    lea dx, msg_empate
    mov ah, 09h
    int 21h
    jmp final_main

ganhador:
    cmp al, 1
    je print_playerVence
    ; se chegou aqui, al == 2
    lea dx, msg_ia_win
    mov ah,09h
    int 21h
    jmp final_main

print_playerVence:
    lea dx, msg_player_win
    mov ah,09h
    int 21h

final_main:
    ; espera qualquer tecla e encerra
    mov ah, 08h
    int 21h
    mov ah,4Ch
    mov al,0
    int 21h

troca_turno:
    ; troca o turnoo: se era 1 -> 2, senão -> 1
    mov al, [turno]
    cmp al, 1
    je set_IA
    mov byte ptr [turno], 1
    jmp loop_jogo
set_IA:
    mov byte ptr [turno], 2
    jmp loop_jogo

main endp

; imprime a matriz 3x3 (usando AH=02 por caractere)
print_board proc
    lea si,tabu
    mov cx,3          ; linhas
row_loop:
    mov bx,3          ; colunas
col_loop:
    mov dl,[si]
    mov ah,02h
    int 21h
    ; espaço entre colunas
    mov dl,' '
    mov ah,02h
    int 21h
    inc si
    dec bx
    jnz col_loop
    ; CR LF no fim da llinha
    mov dl,13
    mov ah,02h
    int 21h
    mov dl,10
    mov ah,02h
    int 21h
    dec cx
    jnz row_loop
    ret
print_board endp

; rotina simples para imprimir o tabuleiro:
; para cada célula: se 0 -> imprime (idx+1) char; se 1 -> 'X'; se 2 -> 'O'
print_tabu proc
    push ax
    push bx
    push cx
    push dx
    push si

    ; pular uma linha antes do tabuleiro
    mov dl, 13
    mov ah, 02h
    int 21h
    mov dl, 10
    mov ah, 02h
    int 21h

    lea si, tabu
    mov cx, 3          ; linhas
    mov bx, 0          ; índice base
print_row:
    mov di, 3          ; colunas
print_col:
    mov al, [si + bx]  ; valor da célula (0/1/2)
    cmp al, 0
    jne ta_cheio
    ; imprimir número index+1
    mov ah, 0
    mov al, bl
    mov dl, '1'
    add dl, al
    mov ah, 02h
    int 21h
    jmp dps_print
ta_cheio:
    cmp al, 1
    jne print_O
    mov dl, 'X'
    mov ah, 02h
    int 21h
    jmp dps_print
print_O:
    mov dl, 'O'
    mov ah, 02h
    int 21h
dps_print:
    ; espaço
    mov dl, ' '
    mov ah, 02h
    int 21h

    inc bx
    dec di
    jnz print_col

    ; CR LF
    mov dl,13
    mov ah,02h
    int 21h
    mov dl,10
    mov ah,02h
    int 21h

    dec cx
    jnz print_row

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_tabu endp

; Exemplo de leitura de entrada e marcação (usa representação 0/1/2)
; lê tecla '1'..'9', converte para índice, verifica se livre (0) e marca com '1' (jogador)
valida_marca proc
    ; imprime prompt e lê AL (AH=01h)
    lea dx,msg
    mov ah,09h
    int 21h

    mov ah,01h
    int 21h  ; AL = tecla lida
    

    cmp al,'1'
    jb inval
    cmp al,'9'
    ja inval

    sub al,'1'      ; AL = 0...8
    mov bl, al      ; guarda índice em BL
    xor bx,bx
    mov bl, al
    mov al, [tabu + bx]
    cmp al, 0
    jne pos_ocupada

    ; marcar como jogador (1)
    mov byte ptr [tabu + bx], 1
    ret

pos_ocupada:
    ; mensagem simples de erro (poderia reiniciar leitura)
    lea dx,erro
    mov ah,09h
    int 21h
    ret

inval:
    lea dx,erro
    mov ah,09h
    int 21h
    ret
valida_marca endp

; checa vencedor: usa tabela 'linhas' (3 índices por combinação)
; retorna AL = 0 (nenhum), 1 (X) ou 2 (O)
check_ganha proc
    lea si, linhas
    mov cx, 8
    mov al, 0
check_loopGeral:
    mov dl, [si]        ; idx1
    mov dh, [si+1]      ; idx2

    lea di, tabu        ; DI = base de tabu
    xor bh, bh
    mov bl, [si]        ; offset = idx1
    mov al, [di+bx]
    cmp al, 0
    je proximo

    xor bh, bh
    mov bl, [si+1]      ; offset = idx2
    mov ah, [di+bx]
    cmp al, ah
    jne proximo

    xor bh, bh
    mov bl, [si+2]      ; offset = idx3
    mov ah, [di+bx]
    cmp al, ah
    jne proximo

    ; vencedor em AL (1 ou 2)
    ret

proximo:
    add si, 3
    dec cx
    jnz check_loopGeral

    mov al, 0
    ret
check_ganha endp

; jatem: AL=1 se tabu cheio, AL=0 se existe algum vazio
jatem proc
    lea si, tabu
    mov cx, 9
    xor bx, bx
ta_loop:
    mov al, [si+bx]
    cmp al, 0
    je vazio_fim
    inc bx
    loop ta_loop
    mov al, 1
    ret
vazio_fim:
    mov al, 0
    ret
jatem endp

verif_linhaCompletar PROC
    ; preserva regs, mas NÃO AX — AL tem o índice de retorno
    push bx
    push cx
    push dx
    push si
    push di

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
    jne proximo1
    mov bl, [si+1]
    xor bh, bh
    mov al, [di+bx]
    cmp al, dl
    jne proximo1
    mov bl, [si+2]
    xor bh, bh
    mov al, [di+bx]
    cmp al, dl
    jne proximo1
    mov al, [si]
    jmp achado

proximo1:
    add si, 3
    dec cx
    jnz vl_loop

    mov al, 0FFh
    jmp feito

achado:
    ; AL já tem o índice de retorno

feito:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    ret
verif_linhaCompletar ENDP

IA_jogar PROC
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ; primeiro tenta ganhar
    mov al, 2
    call verif_linhaCompletar
    cmp al, 0FFh
    jne joga_index

    ; dps tenta bloquear
    mov al, 1
    call verif_linhaCompletar
    cmp al, 0FFh
    jne joga_index

    ; por fim jjoga no centro (4)
    lea si, tabu
    mov al, [si+4]
    cmp al, 0
    jne ver_cantos
    mov al, 4
    jmp joga_index

ver_cantos:
    lea si, cantos
    lea di, tabu
    mov cx, 4
cantos_loop:
    mov bl, [si]
    xor bh, bh
    mov al, [di+bx]
    cmp al, 0
    je achado_corner
    inc si
    loop cantos_loop

    lea di, tabu
    xor bx, bx
    mov cx, 9
outroLoop:
    mov al, [di+bx]
    cmp al, 0
    jne proximo2
    mov al, bl
    jmp joga_index
proximo2:
    inc bx
    loop outroLoop
    jmp final_IA

achado_corner:
    mov al, bl

joga_index:
    ; AL = índice escolhido
    lea di, tabu
    xor bx, bx
    mov bl, al
    mov byte ptr [di+bx], 2    ; marca posição com 2 (IA)

    call print_tabu ; pra ver o que a IA fez

    ; NÃO alterar [turno] aqui

final_IA:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
IA_jogar ENDP
end main
