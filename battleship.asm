.8086

;Un jugador
;Tablero de 7x7
;Flota de Portaviones (5 celdas), Crucero (4 celdas), Submarino (3 celdas)
;Jugador tiene 21 intentos para hundir la flota

.model small
.stack 100h
.data

  indexes db 2 DUP(?)
  ARR  DB   1,2,3,4,5
            
  msg db "N para salir", 0dh, 0ah
      db "S para nueva partida", 0dh, 0ah
      db "Jugar de nuevo? (S/N):",0dh, 0ah, 24h

  
  map db 69 DUP(?)
  map_print db "x-------------------------------------------x ", 0dh, 0ah
            db "|   | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | ", 0dh, 0ah
            db "| A | . | . | . | . | . | . | . | . | . | . | ", 0dh, 0ah
            db "| B | . | . | . | . | . | . | . | . | . | . | ", 0dh, 0ah
            db "| C | . | . | . | . | . | . | . | . | . | . | ", 0dh, 0ah
            db "| D | . | . | . | . | . | . | . | . | . | . | ", 0dh, 0ah
            db "| E | . | . | . | . | . | . | . | . | . | . | ", 0dh, 0ah
            db "| F | . | . | . | . | . | . | . | . | . | . | ", 0dh, 0ah
            db "| G | . | . | . | . | . | . | . | . | . | . | ", 0dh, 0ah
            db "| H | . | . | . | . | . | . | . | . | . | . | ", 0dh, 0ah
            db "| I | . | . | . | . | . | . | . | . | . | . | ", 0dh, 0ah
            db "| J | . | . | . | . | . | . | . | . | . | . | ", 0dh, 0ah
            db "x-------------------------------------------x ", 0dh, 0ah, 24h
            
       


.code
    start: 
        mov ax, @data
        mov ds, ax                               ;sadda==-a\\\\\sd
        
        mov cx, 5
        mov si, 0
        mov ah, 2
        mov dl, map[si]
        add dl, 30h
        int 21h
        
        mov map[si], 1
        mov dl, map[si]
        add dl, 30h
        int 21h
        
     generate_random_numbers:
        mov cx, 0000h
        mov dx, 0000h
        mov ah, 2ch  ; CH = hour. CL = minute. DH = second. DL = 1/100 seconds.
        int 21h
        
        ret
        
        
           
        