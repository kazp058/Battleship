.8086

;UN JUGADOR
;TABLERO DE 7X7
;FLOTA DE PORTAVIONES (5 CELDAS), CRUCERO (4 CELDAS), SUBMARINO (3 CELDAS)
;JUGADOR TIENE 21 INTENTOS PARA HUNDIR LA FLOTA

.MODEL SMALL
.STACK 100H
.DATA

  INDEX_X DB 0
  INDEX_Y DB 0
  
  INDEX DW 0
  
  RANDOM DW 0
  LAST_RANDOM DW 0  
                 ;NONE  0 NONE   | 7 FIRED 
  POS_AIRCARRIER DW 0 ; 1 HIDDEN | 2 FIRED
  POS_CRUISER DW 0    ; 3 HIDDEN | 4 FIRED
  POS_SUBMARINE DW 0  ; 5 HIDDEN | 6 FIRED
  POS_SHIP DW 0
  
  SIZE_AIRCARRIER DB 0
  SIZE_CRUISER DB 0
  SIZE_SUBMARINE DB 0
  
  SIZE_POINTER DB 0
  SHAPE_POINTER DB 0
  
  CHAR_BOAT DB 33H
  CHAR_MISS DB 30H
  CHAR_FIRE DB 58H
            
  MSG DB "N PARA SALIR", 0DH, 0AH
      DB "S PARA NUEVA PARTIDA", 0DH, 0AH
      DB "JUGAR DE NUEVO? (S/N):",0DH, 0AH, 24H
  
  MAP DB 69 DUP('0')
  GAME_MAP  DB "X-------------------------------X", 0DH, 0AH
            DB "|   | A | B | C | D | E | F | G |", 0DH, 0AH
            DB "| 1 | . | . | . | . | . | . | . |", 0DH, 0AH
            DB "| 2 | . | . | . | . | . | . | . |", 0DH, 0AH
            DB "| 3 | . | . | . | . | . | . | . |", 0DH, 0AH
            DB "| 4 | . | . | . | . | . | . | . |", 0DH, 0AH
            DB "| 5 | . | . | . | . | . | . | . |", 0DH, 0AH
            DB "| 6 | . | . | . | . | . | . | . |", 0DH, 0AH
            DB "| 7 | . | . | . | . | . | . | . |", 0DH, 0AH
            DB "X-------------------------------X", 0DH, 0AH
            DB 24H
            
.CODE

    START:
        MOV AX, @DATA
        MOV DS, AX
        
        ADD SIZE_AIRCARRIER, 5
        ADD SIZE_CRUISER, 4
        ADD SIZE_SUBMARINE, 3
        
        ADD SHAPE_POINTER, 33H
        AND RANDOM, 0 
;        
;        CALL PUT_CARRIER
;        MOV AX, POS_SHIP
;        ADD POS_AIRCARRIER, AX 
;        
;        AND SHAPE_POINTER, 0
;        ADD SHAPE_POINTER, 32H
;        
;        CALL PUT_SUBMARINE
;        MOV AX, POS_SHIP
;        ADD POS_SUBMARINE, AX
;        
;        AND SHAPE_POINTER, 0
;        ADD SHAPE_POINTER, 31H
;        
;        CALL PUT_CRUISER
;        MOV AX, POS_SHIP
;        ADD POS_CRUISER, AX 
;        
;        CONTINUE_AFTER_PS:
;        
;        MOV AX, POS_AIRCARRIER
;        MOV BX, POS_SUBMARINE 
;        MOV CX, POS_CRUISER

        ADD RANDOM, 1CH
        CALL PUT_CARRIER
        
        AND SHAPE_POINTER, 0
        ADD SHAPE_POINTER, 32H
        
        AND RANDOM, 0
        ADD RANDOM, 19H
        CALL PUT_SUBMARINE
        
        AND SHAPE_POINTER, 0
        ADD SHAPE_POINTER, 31H
        
        AND RANDOM, 0
        ADD RANDOM, 15H
        CALL PUT_CRUISER        
        
        
        JMP END
        
        PUT_SUBMARINE:
            AND SIZE_POINTER, 0
            MOV AL, SIZE_SUBMARINE
            ADD SIZE_POINTER, AL
            JMP PUT_SHIP
        
        PUT_CARRIER:
            AND SIZE_POINTER, 0
            MOV AL, SIZE_AIRCARRIER
            ADD SIZE_POINTER, AL
            JMP PUT_SHIP
        
        PUT_CRUISER:
            AND SIZE_POINTER, 0
            MOV AL, SIZE_CRUISER
            ADD SIZE_POINTER, AL
            JMP PUT_SHIP
        
        
        PUT_SHIP:
            ;CALL GET_RANDOM
            MOV AX, RANDOM
            AND POS_SHIP, 0
            ADD POS_SHIP, AX
            CALL MAKE_INDEX
            
            
            CALL GET_VAL_MAP
            CMP AL, 0
            JNZ PUT_SHIP
            PUSH INDEX
            MOV CH, INDEX_X ;IZQUIERDA
            MOV CL, INDEX_X ;DERECHA
            MOV DX, 1
                       
            LOOP_X:
                MOV DL, DH ;DH GUARDA EL NUMERO DE ELEMENTOS EN EL STACK EN LA ITERACION I
                REV_IZQ:   ;DL GUARDA EL NUMERO DE ELEMENTOS EN EL STACK EN LA ITERACION I-1
                    CMP CH, 0
                    JE REV_DER
                    DEC CH
                    AND INDEX_X, 0
                    ADD INDEX_X, CH
                    CALL GET_VAL_MAP
                    CMP AL, 0
                    JNZ REV_DER
                    ADD DH, 1
                    PUSH INDEX
                    
                    
                REV_DER:
                    CMP CL, 6
                    JE CONTINUE_X
                    INC CL
                    AND INDEX_X, 0
                    ADD INDEX_X, CL
                    CALL GET_VAL_MAP
                    CMP AL, 0
                    JNZ CONTINUE_X
                    ADD DH, 1
                    PUSH INDEX
                    
                CONTINUE_X:
                    MOV AH, SIZE_POINTER
                    CMP DH, AH 
                    JA POP_DIFF
                    JE PUT_X  ;TERMINA LA REVISION Y COMIENZA A COLOCAR LOS VALORES EN EL MAPA
                    
                    MOV AH, DH
                    SUB AH, DL
                    CMP AH, 0
                    JE CLEAN_STACK
                    JNE LOOP_X 
                    
;                    MOV DL, 0  ;REVISA SI SE ALCANZO EL MINIMO HACIA LA IZQ                  
;                    CMP CH, 0
;                    JNE  NEXT_CHECK
;                    ADD DL, 1
;                    
;                    NEXT_CHECK:
;                    CMP CL, 6 ;REVISA SI SE ALCANZO EL MAXIMO HACIA LA DER
;                    JNE FINAL_CHECK 
;                    ADD DL, 2
;                    
;                    FINAL_CHECK:
;                    MOV AL, CL
;                    SUB AL, CH
;                    DEC AL
;                    CMP DH, 3
;                    JE CLEAN_STACK
;                    CMP DL, 3
;                    JNE LOOP_X                    
                    
                PUT_X:                      
                    MOV CL, SIZE_POINTER
                    LOOP_PUT_X:
                        AND INDEX, 0
                        POP AX
                        CALL MAKE_INDEX 
                        MOV DH, SHAPE_POINTER 
                        CALL SET_VAL_MAPS
                        CALL PRINT_MAP
                        CMP CL, 0
                        JZ END_PUT
                        DEC CL
                        JA LOOP_PUT_X                                    
            
                
                    
            END_PUT:
            RET
    
    ;FUNCIONES DE MAPA
        
    PRINT_MAP: ;IMPRIME EL MAPA DEL JUEGO
        MOV AH, 09H
        LEA DX, [GAME_MAP]
        INT 21H
        RET
        
    POP_DIFF:
        POP AX
        JMP PUT_X
        
    CLEAN_STACK: ;LIMPIA EL STACK, HACIENDO POP AL VECES
        LOOP_CS:
            POP BX
            CMP AL, 0
            JE ENDLOOP_CS
            DEC AL 
            JNE LOOP_CS
        ENDLOOP_CS:
        RET 
                    
    CLEAR_SCREEN: ;LIMPIA LA PANTALLA
        MOV AX, 0003H
        INT 10H
        RET
    
    GET_VAL_MAP:  ;RETORNA EL VALOR DEL MAPA EN INDEX
        CALL MAKE_INDEX_MAP
        MOV SI, INDEX
        MOV AL, MAP[SI]
        SUB AL, 30H
        RET
    
    GET_VAL_GAMEMAP: ;RETORNA EL VALOR DEL GAMEMAP EN INDEX
        CALL MAKE_INDEX_GAMEMAP
        MOV SI, INDEX
        MOV AL, GAME_MAP[SI]
        RET
        
    SET_VAL_MAP: ;TOMO EL VALOR EN DH Y LO INSERTA EN EL INDICE DE MAP
        CALL MAKE_INDEX_MAP
        MOV SI, INDEX
        MOV MAP[SI], DH
        RET
    
    SET_VAL_GAMEMAP: ;TOMA EL VALOR EN DH Y LO INSERTA EN EL INDICE DE GAMEMAP
        CALL MAKE_INDEX_GAMEMAP
        MOV SI, INDEX
        MOV GAME_MAP[SI], DH
        RET                 
    
    SET_VAL_MAPS:
        CALL SET_VAL_GAMEMAP
        CALL SET_VAL_MAP
        RET
    ;FUNCIONES DE INDICE
        
    MAKE_INDEX_GAMEMAP:
        MOV AX, 0
        MOV AL, INDEX_X
        MOV BL, 4
        MUL BL
        MOV BL, AL
        MOV AX,0
        MOV AL, INDEX_Y
        MOV BH, 35
        MUL BH
        ADD AX, 76
        MOV BH, 0
        ADD AX, BX
        AND INDEX, 0
        ADD INDEX, AX
        RET
        
    MAKE_INDEX_MAP:
        MOV AX, 0
        MOV AL, INDEX_Y
        MOV BL, 07
        MUL BL
        ADD AL, INDEX_X
        AND INDEX, 0
        ADD INDEX, AX
        RET
    
    MAKE_INDEX:    ;CONVIERTE EL INDICE EN AX EN COORDENADAS X Y Y.
        CMP AL, 7
        JB CONTINUE_CONVERT
        MOV BH, 7
        DIV BH
        MOV BH, AL
        MOV AL, AH
        DEC AH
        MOV AH, BH
        CONTINUE_CONVERT:
        AND INDEX_X, 0
        AND INDEX_Y, 0
        
        ADD INDEX_X, AL
        ADD INDEX_Y, AH
        RET
    
    ;FUNCIONES DE NUMERO ALEATORIO
    
    GET_RANDOM: ;GENERA UN NUMERO ALTEARIO BASADO EN LA FECHA Y HORA DEL ORDENADOR
        AND LAST_RANDOM, 0
        MOV AX, RANDOM
        ADD LAST_RANDOM, AX
        AND RANDOM, 0
        
        MOV AH, 2CH ;LLAMADO AL SISTEMA PARA OBTENER LA HORA DEL ORDENADOR
        INT 21H
        
        MOV AH, 0        
        
        ADD AH, CH
        SUB AH, DH
        
        ADD AL, CL
        SUB AL ,DL
        
        ADD RANDOM, AX
        
        MOV AH, 2AH ;LLAMADO AL SISTEMA PARA OBTENER LA FECHA DEL ORDENADOR
        INT 21H
        
        MOV BL, AL
        MOV AX, RANDOM
        
        ADD AH, DH
        ADD AL, DL
        
        SUB AH, CH
        SUB AL, CL
        
        ADD AL, AH
        
        SUB AX, LAST_RANDOM
        
        LOOP_CHECK:  ;SE DIVIDE AL NUMERO HASTA OBTENER UN VALOR ENTRE 0 Y 68
            ADD AL, AH
            MOV AH, 0
            CMP AL, 69
                JB CONTINUE_CHECK
                
                MOV BL, 7
                DIV BL
                JAE LOOP_CHECK
        CONTINUE_CHECK:
        MOV AH, 0
        AND RANDOM, 0
        ADD RANDOM, AX
        RET
        
    END:   