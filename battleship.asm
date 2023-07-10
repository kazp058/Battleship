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
        
        PUT_SHIP:
            CALL GET_RANDOM
            ;ADD RANDOM, 12
            MOV AX, RANDOM
            CALL MAKE_INDEX
            
            
            CALL GET_VAL_MAP
            CMP AL, 0
            JNZ PUT_SHIP
            PUSH INDEX
            MOV CH, INDEX_X
            MOV CL, INDEX_X
                       
            LOOP_X:     
                
                REV_IZQ:
                    CMP CH, 0
                    JE REV_DER
                    DEC CH
                    AND INDEX_X, 0
                    ADD INDEX_X, CH
                    CALL GET_VAL_MAP
                    CMP AL, 0
                    JNZ REV_DER
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
                    PUSH INDEX
                    
                CONTINUE_X:
                    MOV AH, CH
                    MOV AL, CL
                    SUB AL, AH
                    MOV AH, SIZE_AIRCARRIER
                    DEC AH
                    CMP AL, AH 
                    JAE PUT_X  ;TERMINA LA REVISION Y COMIENZA A COLOCAR LOS VALORES EN EL MAPA
                    
                    MOV DL, 0  ;CONTINUA LA REVISION                  
                    CMP CH, 0
                    JE  NEXT_CHECK
                    ADD DL, 1
                    
                    NEXT_CHECK:
                    CMP CL, 6
                    JE FINAL_CHECK 
                    ADD DL, 2
                    
                    FINAL_CHECK:
                    CMP DL, 3
                    JNE LOOP_X
                    JE PUT_SHIP
                    
                PUT_X:                      
                    MOV CL, SIZE_AIRCARRIER
                    LOOP_PUT_X:
                        AND INDEX, 0
                        POP AX
                        CALL MAKE_INDEX 
                        MOV DH, CHAR_BOAT 
                        CALL SET_VAL_MAPS
                        CALL PRINT_MAP
                        CMP CL, 0
                        JZ END_PUT
                        DEC CL
                        JA LOOP_PUT_X                                    
                
            ;PRE_LOOP_Y:
            ;MOV AX, 0
            
            
         END_PUT:
                                                             
        
        JMP END
    
    ;FUNCIONES DE MAPA
        
    PRINT_MAP: ;IMPRIME EL MAPA DEL JUEGO
        MOV AH, 09H
        LEA DX, [GAME_MAP]
        INT 21H
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
        LOOP_CONVERT:
            CMP AL, 7
            JB CONTINUE_CONVERT
            MOV BH, 7
            DIV BH
            MOV BL, AL
            JAE LOOP_CONVERT
        CONTINUE_CONVERT:
        AND INDEX_X, 0
        AND INDEX_Y, 0
        
        ADD INDEX_X, AH
        ADD INDEX_Y, AL
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