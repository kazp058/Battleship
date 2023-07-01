.8086

;Un jugador
;Tablero de 7x7
;Flota de Portaviones (5 celdas), Crucero (4 celdas), Submarino (3 celdas)
;Jugador tiene 21 intentos para hundir la flota

.model small
.stack 100h
.data

  index_x db 0
  index_y db 0
  
  index dw 0
  
  char_boat db 33h
  char_miss db 30h
  char_fire db 58h
            
  msg db "N para salir", 0Dh, 0Ah
      db "S para nueva partida", 0Dh, 0Ah
      db "Jugar de nuevo? (S/N):",0Dh, 0Ah, 24h
  
  map db 69 DUP(?)
  map_print db "x-------------------------------------------x ", 0Dh, 0Ah
            db "|   | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | ", 0Dh, 0Ah
            db "| A | . | . | . | . | . | . | . | . | . | . | ", 0Dh, 0Ah
            db "| B | . | . | . | . | . | . | . | . | . | . | ", 0Dh, 0Ah
            db "| C | . | . | . | . | . | . | . | . | . | . | ", 0Dh, 0Ah
            db "| D | . | . | . | . | . | . | . | . | . | . | ", 0Dh, 0Ah
            db "| E | . | . | . | . | . | . | . | . | . | . | ", 0Dh, 0Ah
            db "| F | . | . | . | . | . | . | . | . | . | . | ", 0Dh, 0Ah
            db "| G | . | . | . | . | . | . | . | . | . | . | ", 0Dh, 0Ah
            db "| H | . | . | . | . | . | . | . | . | . | . | ", 0Dh, 0Ah
            db "| I | . | . | . | . | . | . | . | . | . | . | ", 0Dh, 0Ah
            db "| J | . | . | . | . | . | . | . | . | . | . | ", 0Dh, 0Ah
            db "x-------------------------------------------x ", 0Dh, 0Ah, 24h
            
.CODE
    START: 
        MOV AX, @DATA
        MOV DS, AX                               
        
        ADD INDEX_X, 5
        ADD INDEX_Y, 1
        MOV AL, 30h
        
        CALL CHANGE_VAL_MAP
        
        MOV AH, 02h
        MOV SI, INDEX
        MOV DL, MAP[SI]       
        INT 21H
        
        MOV AX, 0003h
        INT 10h
        
        MOV AH,09h
        LEA DX, map_print
        INT 21h
        
        JMP END
     
     CHANGE_VAL_MAP: ;toma el valor de al y lo inserta en map en index_x e index_y
        MOV DL, AL
        CALL GET_INDEX
        MOV AL, DL
        MOV DL, 00h
        MOV SI, INDEX
        MOV MAP[SI], AL
        RET         
     
     GET_INDEX: ;obtiene el indice para el arreglo y lo guarda en index
        MOV AL, INDEX_Y
        MOV BL, 07h
        MUL BL
        ADD AL, INDEX_X
        MOV BX, INDEX
        XOR INDEX, BX 
        ADD INDEX, AX      
        RET 
     
     FLUSH_INDEX:
        MOV AL, INDEX_Y
        XOR INDEX_Y, AL
        MOV AL, INDEX_X
        XOR INDEX_X, AL
        MOV AX, INDEX
        XOR INDEX, AX
        MOV AX, 00h
        RET  
        
     END:      
        