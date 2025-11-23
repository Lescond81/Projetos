title velhanova
.model small
.stack 100h

.data
    turn    db 1            ; 1 = jogador, 2 = IA/segundo jogador
    mode    db 1            ; 1 = jogador vs IA (padrão), 0 = 2 jogadores
    winner  db 0
    msg_player_win db 13,10,'Voce venceu!$'
    msg_ia_win     db 13,10,'IA venceu!$'
    msg_draw       db 13,10,'Empate!$'
    ; 0 = vazio, 1 = X (jogador), 2 = O (IA/2º jogador)
    tabu db 0,0,0,0,0,0,0,0,0
    msg db 13,10,'Digite um numero de 1 a 9:  $'
    erro db 13,10,'Entrada invalida$'
    pula db 13,10,'$'
    ; tabela de linhas (cada 3 bytes = uma linha/coluna/diagonal)
    linhas db 0,1,2, 3,4,5, 6,7,8, 0,3,6, 1,4,7, 2,5,8, 0,4,8, 2,4,6
    cantos db 0,2,6,8
.code

MAIN PROC
    mov ax,@data
    mov ds,ax

    ; inicializar tabuleiro (todos zeros)
    lea si, tabu
    mov cx, 9
    xor bx, bx
.init_loop:
    mov byte ptr [si+bx], 0
    inc bx
    loop .init_loop

game_loop:
    ; desenha tabuleiro
    call print_tabu

    ; turno do jogador 1?
    mov al, [turn]
    cmp al, 1
    je .player_turn

    ; turno do segundo jogador: se mode==1 -> IA, se mode==0 -> humano
    mov al, [mode]
    cmp al, 1
    je .ia_turn
    ; humano segundo jogador
    call player2_turn
    jmp .after_move

.ia_turn:
    call IA_jogar
    jmp .after_move

.player_turn:
    ; jogador 1
    call player1_turn

.after_move:
    ; verificar vencedor
    call check_winner    ; retorna AL = 0 (nenhum) / 1 (X jogador) / 2 (O IA)
    cmp al, 0
    jne .have_winner

    ; verificar empate
    call is_full         ; AL = 1 se cheio, 0 se ainda há vazio
    cmp al, 1
    jne .toggle_and_continue

    ; empate
    lea dx, msg_draw
    mov ah, 09h
    int 21h
    jmp .end_game

.have_winner:
    cmp al, 1
    je .print_player_win
    ; se chegou aqui => al == 2
    lea dx, msg_ia_win
    mov ah,09h
    int 21h
    jmp .end_game

.print_player_win:
    lea dx, msg_player_win
    mov ah,09h
    int 21h

.end_game:
    ; espera qualquer tecla e encerra
    mov ah, 08h
    int 21h
    mov ah,4Ch
    mov al,0
    int 21h

.toggle_and_continue:
    ; alterna turno: se era 1 -> 2, senão -> 1
    mov al, [turn]
    cmp al, 1
    je .set_ia
    mov byte ptr [turn], 1
    jmp game_loop
.set_ia:
    mov byte ptr [turn], 2
    jmp game_loop

MAIN ENDP

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
    ; CR LF ao final da linha
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

    ; pular uma linha antes do tabuleiro (CR LF)
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
    jne not_empty
    ; imprimir número index+1
    mov ah, 0
    mov al, bl
    mov dl, '1'
    add dl, al
    mov ah, 02h
    int 21h
    jmp after_print
not_empty:
    cmp al, 1
    jne print_O
    mov dl, 'X'
    mov ah, 02h
    int 21h
    jmp after_print
print_O:
    mov dl, 'O'
    mov ah, 02h
    int 21h
after_print:
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

; Wrapper para jogador 1: prepara marca=1 em DL e chama rotina genérica
player1_turn PROC
    push dx
    mov dl, 1
    call read_and_mark_mark
    pop dx
    ret
player1_turn ENDP

; Wrapper para jogador 2 (modo 2-jogadores): prepara marca=2 em DL e chama rotina genérica
player2_turn PROC
    push dx
    mov dl, 2
    call read_and_mark_mark
    pop dx
    ret
player2_turn ENDP

; read_and_mark_mark: DL = marca a gravar (1 ou 2)
; lê tecla '1'..'9', converte para índice, verifica se livre e grava DL no tabu
read_and_mark_mark PROC
    push ax
    push bx
    push cx
    push dx
    push si

    ; prompt
    lea dx, msg
    mov ah, 09h
    int 21h

    mov ah, 01h
    int 21h        ; AL = tecla lida

    cmp al,'1'
    jb .inval
    cmp al,'9'
    ja .inval

    sub al,'1'      ; AL = 0..8
    xor bx, bx
    mov bl, al      ; BX = índice
    lea si, tabu
    mov al, [si + bx]
    cmp al, 0
    jne .pos_ocupada

    ; gravar marca (DL) em tabu[index]
    mov al, dl
    mov [si + bx], al

    ; sucesso -> retorna
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

.pos_ocupada:
    lea dx, erro
    mov ah, 09h
    int 21h
    jmp .done

.inval:
    lea dx, erro
    mov ah, 09h
    int 21h

.done:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
read_and_mark_mark ENDP

; checa vencedor: usa tabela 'linhas' (3 índices por combinação)
; retorna AL = 0 (nenhum), 1 (X) ou 2 (O)
check_winner proc
    lea si, linhas
    mov cx, 8
    mov al, 0
.chk_loop:
    mov dl, [si]        ; idx1
    mov dh, [si+1]      ; idx2
    ; idx3 is at [si+2] and will be read when needed

    lea di, tabu        ; DI = base of board (tabu)
    xor bh, bh
    mov bl, [si]        ; offset = idx1
    mov al, [di+bx]
    cmp al, 0
    je .next_combo

    xor bh, bh
    mov bl, [si+1]      ; offset = idx2
    mov ah, [di+bx]
    cmp al, ah
    jne .next_combo

    xor bh, bh
    mov bl, [si+2]      ; offset = idx3
    mov ah, [di+bx]
    cmp al, ah
    jne .next_combo

    ; vencedor em AL (1 ou 2)
    ret

.next_combo:
    add si, 3
    dec cx
    jnz .chk_loop

    mov al, 0
    ret
check_winner endp

; is_full: AL=1 se tabu cheio, AL=0 se existe vazio
is_full proc
    lea si, tabu
    mov cx, 9
    xor bx, bx
.is_loop:
    mov al, [si+bx]
    cmp al, 0
    je .not_full
    inc bx
    loop .is_loop
    mov al, 1
    ret
.not_full:
    mov al, 0
    ret
is_full endp

verificar_linha_para_completar PROC
    ; preserva regs, mas NÃO AX — AL contém o índice de retorno
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
    jne .case2
    cmp al, dl
    jne .case2
    mov bl, [si+2]
    xor bh, bh
    mov al, [di+bx]
    cmp al, 0
    jne .case2
    mov al, [si+2]
    jmp .found

.case2:
    mov bl, [si]
    xor bh, bh
    mov al, [di+bx]
    cmp al, dl
    jne .case3
    mov bl, [si+1]
    xor bh, bh
    mov al, [di+bx]
    cmp al, 0
    jne .case3
    mov bl, [si+2]
    xor bh, bh
    mov al, [di+bx]
    cmp al, dl
    jne .case3
    mov al, [si+1]
    jmp .found

.case3:
    mov bl, [si]
    xor bh, bh
    mov al, [di+bx]
    cmp al, 0
    jne .nextl
    mov bl, [si+1]
    xor bh, bh
    mov al, [di+bx]
    cmp al, dl
    jne .nextl
    mov bl, [si+2]
    xor bh, bh
    mov al, [di+bx]
    cmp al, dl
    jne .nextl
    mov al, [si]
    jmp .found

.nextl:
    add si, 3
    dec cx
    jnz vl_loop

    mov al, 0FFh
    jmp .doner

.found:
    ; AL já contém o índice de retorno

.doner:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    ret
verificar_linha_para_completar ENDP

IA_jogar PROC
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ; 1) tentar ganhar
    mov al, 2
    call verificar_linha_para_completar
    cmp al, 0FFh
    jne .play_index

    ; 2) tentar bloquear jogador
    mov al, 1
    call verificar_linha_para_completar
    cmp al, 0FFh
    jne .play_index

    ; 3) centro (4)
    lea si, tabu
    mov al, [si+4]
    cmp al, 0
    jne .try_cantos
    mov al, 4
    jmp .play_index

.try_cantos:
    lea si, cantos
    lea di, tabu
    mov cx, 4
.corner_loop:
    mov bl, [si]
    xor bh, bh
    mov al, [di+bx]
    cmp al, 0
    je .found_corner
    inc si
    loop .corner_loop

    lea di, tabu
    xor bx, bx
    mov cx, 9
.any_loop:
    mov al, [di+bx]
    cmp al, 0
    jne .next_any
    mov al, bl
    jmp .play_index
.next_any:
    inc bx
    loop .any_loop
    jmp .end_ia

.found_corner:
    mov al, bl

.play_index:
    ; AL = índice escolhido
    lea di, tabu
    xor bx, bx
    mov bl, al
    mov byte ptr [di+bx], 2    ; marca posição com 2 (IA)

    ; redesenha para visualizar jogada
    call print_tabu

    ; NÃO alterar [turn] aqui — toggle_and_continue faz a alternância
    ; mov byte ptr [turn], 1  ; <-- removido

.end_ia:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
IA_jogar ENDP
end main