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
  
  CHAR_BOAT DB 33H
  CHAR_MISS DB 30H
  CHAR_FIRE DB 58H
            
  MSG DB "N PARA SALIR", 0DH, 0AH
      DB "S PARA NUEVA PARTIDA", 0DH, 0AH
      DB "JUGAR DE NUEVO? (S/N):",0DH, 0AH, 24H
  
  MAP DB 69 DUP('$')
  MAP_PRINT DB "X-------------------------------X", 0DH, 0AH
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
        
        CALL GET_RANDOM_SEED
        MOV AX, RANDOM
        ADD  POS_AIRCARRIER, AX
        CALL MAKE_INDEX
        
        MOV DH, CHAR_BOAT 
        CALL CHANGE_VAL_GAMEMAP
        
        CALL PRINT_MAP   
        
        JMP END
     
     PRINT_MAP:
        MOV AH, 09H
        LEA DX, [MAP_PRINT]
        INT 21H
        RET
        
     CHECK_VAL:
        MOV AL, INDEX_X
        MOV BL, INDEX_Y
           
     
     PUT_SHIP:
        MOV AX, POS_SHIP
        
        MOV BX, INDEX
        XOR INDEX, BX  
        
        ADD INDEX,AX
        
        CALL MAKE_INDEX
        
        CMP INDEX_X, DL
        JAE CHECK_AC_LEFT
        JB  CHECK_AC_RIGHT
        
        REGEN_RANDOM:
            CALL GET_RANDOM_SEED
            JMP PUT_SHIP  
        
        CHECK_AC_LEFT:
            MOV CL, INDEX_X
            
            LOOP_AC_LEFT:
                MOV BH, INDEX_X
                XOR INDEX_X, BH
                
                ADD INDEX_X, CL
                
                CALL CHECK_VAL 
                
                MOV DH, CL
                SUB DH, DL
                              
                CMP BL, 0
                JNE CHECK_AC_RIGHT
                
                CMP CL, 0
                JE AC_PUT_LEFT
                
                CMP BL, 0
                DEC CL
                JE LOOP_AC_LEFT 
                        
            AC_PUT_LEFT:
                MOV CH, 00
                MOV CX, POS_SHIP
                
                AC_PUT_LEFT_LOOP:
                    MOV BX, INDEX
                    XOR INDEX, BX
                    
                    ADD INDEX, CX
                    CALL MAKE_INDEX
                    
                    CALL CHANGE_VAL_MAP 
                    
                    CALL GET_INDEX_GAMEMAP 
                    CALL CHANGE_VAL_GAMEMAP
                    CMP CL, 0
                
                    JE END_PUT
                    DEC CL
                    JNE AC_PUT_LEFT_LOOP 

        CHECK_AC_RIGHT:
            MOV CL, INDEX_X
            
            LOOP_AC_RIGHT:
                MOV BH, INDEX_X
                XOR INDEX_X, BX
                
                ADD INDEX_X, CL
                
                CALL CHECK_VAL
                
                MOV DH, DL
                SUB DH, CL
                
                CMP BL, 0
                JNE CHECK_AC_UP
                
                CMP CL, 0
                JE AC_PUT_RIGHT
                
                CMP BL, 0
        
        JMP CONTINUE_PUT_AC 
        
        CONTINUE_PUT_AC:
        
        END_PUT:
        RET
        
        
     GET_INDEX_GAMEMAP: ;GENERA UN INDICE PARA MODIFICAR EL MAPA QUE SE VISUALIZA
        MOV AX, 0
        MOV DX, 0
        
        MOV AL, INDEX_X
        
        MOV DL, 4
        MUL DL
                
        MOV DL, AL
        
        MOV AX, 0
        MOV BH, 35
        MOV AL, INDEX_Y
        MUL BH
        
        ADD AX, 76
        
        ADD AX, DX  
     
     GET_VAL_MAP:
        MOV SI, INDEX
        MOV AL, MAP[SI]
        RET
     
     GET_VAL_GAMEMAP:
        CALL GET_INDEX_GAMEMAP
        
        MOV SI, AX
        MOV AL, MAP_PRINT[SI]
        RET
       
     CHANGE_VAL_GAMEMAP:  ;TOMA EL VALOR DE CL Y LO INSERTA EN EL STRING EN INDEX_X E INDEX_Y
        CALL GET_INDEX_GAMEMAP
        
        MOV SI, AX
        MOV MAP_PRINT[SI], DH
        RET
     
     CLEAR_SCREEN:
        MOV AX, 0003H
        INT 10H
        RET
     
     CHANGE_VAL_MAP: ;TOMA EL VALOR DE AL Y LO INSERTA EN MAP EN INDEX
        MOV SI, INDEX
        MOV MAP[SI], DH
        RET          
     
     GET_INDEX: ;OBTIENE EL INDICE PARA EL ARREGLO Y LO GUARDA EN INDEX
        MOV AL, INDEX_Y
        MOV DL, 07
        MUL DL
        ADD AL, INDEX_X
        MOV DX, INDEX
        XOR INDEX, DX 
        ADD INDEX, AX     
        RET        
         
     MAKE_INDEX: ;TRANSFORMA EL INDEX EN POSICIONES X Y Y PARA EL ARREGLO
        MOV AX, INDEX         
        LOOP_CONVERT:
            CMP AL, 7
            JB CONTINUE_CONVERT
            MOV CH, 7
            DIV CH           
            MOV CL, AL 
            JAE LOOP_CONVERT
        CONTINUE_CONVERT:
        
        MOV CH, INDEX_X
        XOR INDEX_X, CH
                      
        MOV CH, INDEX_Y
        XOR INDEX_Y, CH
        
        ADD INDEX_Y, AL
        ADD INDEX_X, AH     
                    
        RET          
     
     FLUSH_INDEX:
        MOV AL, INDEX_Y
        XOR INDEX_Y, AL
        MOV AL, INDEX_X
        XOR INDEX_X, AL
        MOV AX, INDEX
        XOR INDEX, AX
        MOV AX, 00H
        RET
        
     GET_RANDOM_SEED: ;GENERA UN NUMERO ALEATORIO BASADO EN LA FECHA Y HORA EN EL ORDENADOR     
        MOV AX, LAST_RANDOM
        XOR LAST_RANDOM, AX
        
        MOV AX, RANDOM
        
        ADD LAST_RANDOM, AX        
        MOV AX, RANDOM
        XOR RANDOM, AX 
        
        MOV AH, 2CH
        INT 21H
        
        MOV AH, 0
        
        ADD AH, CH  
        SUB AH, DH 
        
        ADD AL, CL
        SUB AL, DL
        
        ADD RANDOM, AX
        
        MOV AH, 2AH
        INT 21H
        
        MOV BL, AL
        MOV AX, RANDOM
        
        ADD AH, DH
        ADD AL, DL
        
        SUB AH, CH
        SUB AL, CL
        
        ADD AL, AH
        
        SUB AX, LAST_RANDOM
        
        LOOP_CHECK:
            ADD AL, AH
            MOV AH, 00
            CMP AL, 69
            JB CONTINUE_CHECK
            MOV CL, 7
            DIV CL
            JAE LOOP_CHECK
        CONTINUE_CHECK:
        
        MOV AH, 00
        MOV CX, RANDOM
        XOR RANDOM, CX
        
        ADD RANDOM, CX              
        
        RET
         
        
     END:      
        