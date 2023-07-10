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
  POS_AIRCARRIER DW 0   ; 1 HIDDEN | 2 FIRED
  POS_SUBMARINE DW 0    ; 3 HIDDEN | 4 FIRED
  POS_CRUISER DW 0      ; 5 HIDDEN | 6 FIRED      
  POS_SHIP DW 0 
  
  SIZE_AIRCARRIER DB 0
  SIZE_CRUISER DB 0
  SIZE_SUBMARINE DB 0
  
  SIZE_POINTER DB 0
  SHAPE_POINTER DB 0
  
  CHAR_BOAT DB 33H
  CHAR_MISS DB 30H
  CHAR_FIRE DB 31H
  
  QTY_MISSILE DW 0
  
  MSG_MISSILE DB 0DH, 0AH, "MISIL   ", 24H
  MSG_ASK DB ", INGRESE LA CELDA A ATACAR: ", 24H
  
  MSG_IMPACT DB "..........IMPACTO CONFIRMADO", 0DH, 0AH, 24H
  MSG_NIMPACT DB "..........SIN IMPACTO", 0DH, 0AH, 24H
  MSG_INVALID DB "..........ENTRADA NO VALIDA",0DH,0AH,24H
  MSG_USED DB "..........ELIJE OTRA CELDA A DISPARAR", 0DH,0AH,24H
  
  MSG_SSUB DB "SUBMARINO HUNDIDO!", 0DH, 0AH, 24H
  MSG_SCRU DB "CRUCERO HUNDIDO!", 0DH, 0AH, 24H
  MSG_SACC DB "PORTAAVIONES HUNDIDO!", 0DH, 0AH, 24H 
  
  MSG_WIN DB "GANASTE, DESTRUISTE TODOS LOS BARCOS ENEMIGOS!", 0DH, 0AH, 24H
  MSG_LOST DB "PERDISTE, TE QUEDASTE SIN MISILES!", 0DH, 0AH, 24H
  
  MSG_TITLE DB "BATALLA NAVAL", 0DH, 0AH
            DB "TIENES 21 MISILES PARA DESTRUIR A LA FLOTA ENEMIGA", 0DH, 0AH
            DB "PRESIONA ENTER PARA VISUALIZAR EL TABLERO Y UBICAR LOS BARCOS ALEATOREAMENTE..", 0DH, 0AH
            DB 24H 
            
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

        WAIT_FOR_ENTER:
        MOV AX, 0003H
        INT 10H
        MOV AH, 09H
        LEA DX, [MSG_TITLE]
        INT 21H
        MOV AH, 01H
        INT 21H
        CMP AL, 0DH
        JNE WAIT_FOR_ENTER
        
        ADD SHAPE_POINTER, 31H
        AND RANDOM, 0 
        
        CALL PUT_CARRIER
        MOV AX, POS_SHIP
        ADD POS_AIRCARRIER, AX 
        
        AND SHAPE_POINTER, 0
        ADD SHAPE_POINTER, 33H
        
        CALL PUT_SUBMARINE
        MOV AX, POS_SHIP
        ADD POS_SUBMARINE, AX
        
        AND SHAPE_POINTER, 0
        ADD SHAPE_POINTER, 35H
        
        CALL PUT_CRUISER
        MOV AX, POS_SHIP
        ADD POS_CRUISER, AX 
        
        
        ADD QTY_MISSILE, 1
        CONTINUE_AFTER_PS:
        
        MOV AX, POS_AIRCARRIER
        MOV BX, POS_SUBMARINE 
        MOV CX, POS_CRUISER
        
        RELOAD:
            CALL PRINT_MAP
        
        ASK:
            MOV BX, offset MSG_MISSILE
            MOV AX, QTY_MISSILE
            MOV DH, 0AH
            DIV DH
            ADD AL, 30H
            ADD AH, 30H
            MOV [BX+8],AL
            MOV [BX+9],AH 
            MOV DX, BX
            MOV AH, 09H
            INT 21H
            
            MOV AH, 09H
            LEA DX, MSG_ASK
            INT 21H
             
            MOV BL, SIZE_SUBMARINE
            MOV CL, SIZE_CRUISER
            MOV DL, SIZE_AIRCARRIER 
             
            MOV AH, 01H
            INT 21H
            MOV BH, AL
            MOV AH, 01H
            INT 21H
            MOV BL, AL
        
        CMP BH, 41H
        JB INVALID
        CMP BH, 47H
        JA INVALID
        
        CMP BL, 31H
        JB INVALID
        CMP BL, 37H
        JA INVALID
        
        SUB BH, 41H
        SUB BL, 31H 
                
        AND INDEX_X, 0
        AND INDEX_Y, 0
        ADD INDEX_X, BH
        ADD INDEX_Y, BL
        
        CALL GET_VAL_MAP
        
        CMP AL, 0   ;IMPACTO AL AGUA
        JE WATER_SHOT
        
        CMP AL, 1   ;IMPACTO A PORTAAVIONES
        JE ACC_SHOT
        
        CMP AL, 3   ;IMPACTO A SUBMARINO
        JE SUB_SHOT      
        
        CMP AL, 5   ;IMPACTO A CRUCERO    
        JE CRU_SHOT
        
        JMP CHANGE

        AFTER_SHOT:

        MOV AL, SIZE_AIRCARRIER
        ADD AL, SIZE_CRUISER
        ADD AL, SIZE_SUBMARINE
        
        CMP AL, 0
        JE END_WIN
        
        CMP QTY_MISSILE, 21

        JE END_LOST
        INC QTY_MISSILE      
        
        JMP RELOAD
        
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
            CALL GET_RANDOM
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
            MOV DH, 1
                       
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
                    MOV AL, DH
                    JE CLEAN_STACK
                    JNE LOOP_X                    
                    
                PUT_X:                      
                    MOV CL, SIZE_POINTER
                    LOOP_PUT_X:
                        AND INDEX, 0
                        POP AX
                        CALL MAKE_INDEX 
                        MOV DH, SHAPE_POINTER 
                        CALL SET_VAL_MAPS
                        CMP CL, 0
                        JZ END_PUT
                        DEC CL
                        JA LOOP_PUT_X                                    
            
            END_PUT:
            RET
    
    INVALID:
        MOV AH, 09H
        LEA DX, [MSG_INVALID]
        INT 21H
        JMP ASK
        
    CHANGE:
        MOV AH, 09H
        LEA DX, [MSG_USED]
        INT 21H
        JMP ASK
        
    WATER_SHOT:
        MOV AH, 09H
        LEA DX, [MSG_NIMPACT]
        INT 21H
        
        MOV DH, CHAR_MISS 
        CALL SET_VAL_GAMEMAP
        
        MOV DH, 37H
        CALL SET_VAL_MAP
        JMP AFTER_SHOT
    
    SUB_SHOT:
        MOV AH, 09H
        LEA DX, [MSG_IMPACT]
        INT 21H
        
        MOV DH, CHAR_FIRE 
        CALL SET_VAL_GAMEMAP
        
        MOV DH, 36H
        CALL SET_VAL_MAP
        DEC SIZE_SUBMARINE
        CMP SIZE_SUBMARINE, 0
        JE SUNK_SUB
        JMP AFTER_SHOT
        SUNK_SUB:
            MOV AH, 09H
            LEA DX, [MSG_SSUB]
            INT 21H
            JMP AFTER_SHOT
    
    CRU_SHOT:
        MOV AH, 09H
        LEA DX, [MSG_IMPACT]
        INT 21H
        
        MOV DH, CHAR_FIRE 
        CALL SET_VAL_GAMEMAP
        
        MOV DH, 34H
        CALL SET_VAL_MAP
        DEC SIZE_CRUISER
        CMP SIZE_CRUISER, 0
        JE SUNK_CRU
        JMP AFTER_SHOT
        SUNK_CRU:
            MOV AH, 09H
            LEA DX, [MSG_SCRU]
            INT 21H
            JMP AFTER_SHOT
    
    ACC_SHOT:    
        MOV AH, 09H
        LEA DX, [MSG_IMPACT]
        INT 21H
        
        MOV DH, CHAR_FIRE 
        CALL SET_VAL_GAMEMAP
        
        MOV DH, 32H
        CALL SET_VAL_MAP
        DEC SIZE_AIRCARRIER 
        CMP SIZE_AIRCARRIER, 0
        JE SUNK_ACC
        JMP AFTER_SHOT
        SUNK_ACC:
            MOV AH, 09H
            LEA DX, [MSG_SACC]
            INT 21H
            JMP AFTER_SHOT

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
        JMP PUT_SHIP 
                    
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
        
    END_INTE:
    
    END_WIN:
    
    END_LOST:
        MOV AL, SIZE_SUBMARINE
        MOV BL, SIZE_CRUISER
        MOV CL, SIZE_AIRCARRIER
        JMP END
    
    END:
       