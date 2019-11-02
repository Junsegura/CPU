%include "io.mac"
BUF_LEN     EQU     50     ;por si el nombre es largo
len           equ     2048 ;marca el tope de la cantidad decaracteres a imprimir 
kilo        EQU     32

.DATA
msg_1           db      "Ingrese el nombre del archivo : ",0
cont            db      "Presione ENTER para continuar. ",0
msg_2           db      "Memoria : ",0
regA            db      "A : ",0
regB            db      "B : ",0
regC            db      "C : ",0
regD            db      "D : ",0
stackP          db      "SP : ",0
PC              db      "PC : ",0
IR              db      "IR : ",0
ZF              db      "ZF : ",0
CF              db      "CF : ",0
SF              db      "SF : ",0
OF              db      "OF : ",0
off             db      "OFFSET. ",0
outPut          db      "Output : ",0 


.UDATA
descriptor      resb    4   ;memory for storing descriptor
buffer          resb    1024
archivo         resb    BUF_LEN
resp            resb    5
memoria         resb    kilo    ;un kilobyte
A               resb    2
B               resb    2
C               resb    2
D               resb    2
tablaSignos     resb    kilo
IPointer        resb    4
tablaPoint      resb    4       ;señala donde va la tabla de signo
offset          resb    4       ;debe haber otra forma
pila            resb    4       ;será el final de la memoria
ZFlag           resb    2
CFlag           resb    2
SFlag           resb    2
OFlag           resb    2
ent             resb    1
codigo          resb    1       ;para impirmir el paratro
par1            resb    1       ;
par2            resb    1
salida          resb    kilo
salPoint        resb    4
; sp = memoria + candidad de celdas


.CODE
    .STARTUP
    
    mov     EDX, memoria
    PutLInt  EDX
    nwln
    mov     EAX, [ZFlag]
    sub     [ZFlag], EAX
    PutInt  [ZFlag]
    mov     EAX, [CFlag]
    sub     [CFlag], EAX
    PutInt  [CFlag]
    mov     EAX, [OFlag]
    sub     [OFlag], EAX
    PutInt  [OFlag]
    mov     EAX, [SFlag]
    sub     [SFlag], EAX
    PutInt  [SFlag]
    mov     EAX, [pila]
    sub     [pila], EAX
    PutInt  [pila]
    mov     EAX, [salPoint]
    sub     [salPoint], EAX
    PutInt  [salPoint]
    ;mov     DWORD [pila], memoria
    add     DWORD [pila],kilo
    dec     DWORD [pila]


    PutStr  msg_1
    GetStr  archivo, 21
    
    mov     EAX,5               ;abre el archivo
    mov     EBX,archivo         ;EBX marca el nombre de archivo
    mov     ECX,0               ;solamente lo lee
    int     80h                 ;realiza lo indicado
    
    mov     [descriptor],EAX    ;storing the descriptor
    
    ;nwln
    mov     EAX,3               ;lee el archivo
    mov     EBX,[descriptor]    ;asigna el resultado EAX
    mov     ECX,buffer
    mov     EDX,len             ;indica la cantidad de leido
    int     80h                 ;realiza lo indicado
    ;en EAX está la cantidad de datos leidos
    mov     [resp],EAX
    
    
    mov   EAX,6
    mov   EBX,[descriptor]      ;your file descriptor
    
    int   80h                   ;close your file
    
    mov         EDX,    buffer  ;muevo a EBX el apuntador del 
    ;mov         ECX,[resp]      ;el largo de la frase
 
    mov         EBX, tablaSignos    ;el inicio de la tabla
    mov         [tablaPoint], EBX
    
    mov         EBX, memoria    ;apunta al inicio de memoria
   
    mov         ECX, offset     
    mov         [ECX], EBX      ;guarda el inicio de memoria en offset
    sub         ECX, ECX
    ;PutLInt     EDX
    
    

    ;guardar ECX
    
vueltaSegmento:
    mov         CL, [ EDX ]     ;mueve un char a CL
    cmp         CL, "."         ;compara si es "."
    je          sigue           ;si es igual salta
    inc         EDX             ;incrementa el apuntador texto
    jmp         vueltaSegmento  ;repite
sigue:
    inc         EDX             ;inc 
    mov         CL, [ EDX ]     ;char
    cmp         CL, "D"         ;compara si es D
    jne         udataSegmento   ;salta a etiqueta
    call        ignorarFin         ;para que salte a siguiente linea
    
    jmp         guardarDatos    ;salta

    ;ignorar hasta la linea de abajo
udataSegmento:
    cmp         CL, "U"         ;compara si es U
    jne         codigoSegmento
    call        ignorar         ;para que salte a siguiente linea
    jmp         guardarVariables
    
codigoSegmento:
    cmp         CL, "C"         ;deberia ser codigo
    jne         vueltaSegmento  ;?
    call        ignorar         ;para que salte a siguiente linea
    jmp         ensamblarCodigo
    
guardarDatos:
    

    
    ;guardar el nombre de la varible, cuando aparezca sustituirlo por un codigo para introducirla a memoria
    ;ebx, apuntaddor del texto
    ;edx, apuntador de memoria
    
    ;inc         EDX             ;EDX+1
    
    mov         CL, [ EDX ]     ;
    ;cmp         CL, 0x22
    cmp         CL, "."         ;

    jne         buscarString    ;
    inc         EDX             ;
    mov         CL, [ EDX ]     ;
    cmp         CL, "U"         ;

    jne         buscarString    ;
    call        ignorarFin
    ;inc         EDX
    mov         CL, [ EDX ]
    
    jmp         guardarVariables
    
    
buscarString:;salta lo que sea hasta llegar al string
    call        guardarEtiqu
    ;PutStr      valores
    inc         EDX                 ;aqui estaria en "

    ;cmp         CL, 0x22            ;el char es "
    ;jne         buscarString
aMemoria:
    inc         EDX
    mov         CL, [ EDX ]
    cmp         CL, 0x22            ;el char es "
    jne         todoNormal
    inc         EDX
    mov         CL, [ EDX ]
    cmp         CL, ","
    jne         todoNormal
    inc         EDX
    mov         CL, [ EDX ]
    cmp         CL, "0"
    jne         todoNormal
    mov         CL, 0
    mov         [ EBX ], CL     ;agrega el cero a memoria
    mov         CL, [ EBX ]

    inc         EBX             ;es para guardar el cero y la sigueinte variable
    
    inc         EDX
    call        ignorar         ;salta a siguiente linea
    jmp         guardarDatos    ;para seguir con los string
todoNormal:
    ;PutCh       "O"
    
    mov         [ EBX ], CL     ;agrega dato a memoria

    inc         EBX    
    
    jmp         aMemoria
    
guardarVariables:
    
    

    ;inc         EDX
    
    
    
    mov         CL, [ EDX ]
    cmp         CL, "."
    jne         buscarEspacio
    inc         EDX
    mov         CL, [ EDX ]
    cmp         CL, "C"
    
    jne         buscarEspacio
    
    
    ;EDX marca a la C  de CODE
    call        ignorarFin
    
    call        ignorar

    call        ignorarFin         ;saltarse el .STARTU

    ;inc         EBX             ;por qué EBX?
    jmp         guardarTabla
    
buscarEspacio:
    call        guardarEtiqu
;corregir para que sea guardado continuamente
;la varible debe ser guardada en valores
    call        esNumero        ;deja el apuntador hasta donde haya un numero
    call        sumarAMemoria   ;me deja en eax la cantidad de bytes
    
   
    
    call        agregarVacio    ;el ebx está justo despues de donde asigno la memoria
    ;EDX esta en el 4
    
    
    
    ;el edx debe estar marcando un espacio un un nl antes de llamar al ignorar
    
    ;inc         EDX         ;para que no este sorbre el numero, si no despues
    
    call        ignorar      ;ignorar fin para que salte a siguiente linea hasta donde haya un caracter


    
    
    jmp         guardarVariables
    

guardarTabla:
;recorre todo el codigo buscando y guardando las etiquetas para luego utilizarlas

    push        EDX; para luego sacarlo y usarlo para ensamblar el codigo
    push        EBX;la misma idea
    
seguirEtiquetas:
    mov         CL, [EDX]
    cmp         CL, "a"
    jge         esEtiqueta;estaria marcando una etiqueta y se debe de guardar en 
    
    call        ignorar;cl al inicio del codigo
    cmp         CL, "."
    je          terminarEtiqueta
    call        etiquetas
    call        ignorarFin
    jmp         seguirEtiquetas
    
esEtiqueta:
    ;call        etiquetas
    ;call        ignorarFin
    ;PutCh       CL
    
    call        guardarEtiqu
    call        ignorarFin
    jmp         seguirEtiquetas
    
terminarEtiqueta:
    pop     EBX
    pop     EDX
;con lo de abajo asigno el IPointer al inicio de CS
    mov         ECX, [offset]
    mov         [IPointer], EBX
    sub         [IPointer], ECX
    
    


    
ensamblarCodigo:
;aqui compara el inicio de la linea

    mov         CL, [EDX]
    
    cmp         CL, "a"        ;compara que sea distinto de letra
    jl          sigueIns
;eliminar esto de abajo para que sea que solo pase de linea


    ;call        guardarEtiqu    ;guarda la etiqueta, y la posicion de memoria donde debe saltar
    call        ignorarFin      ;ignorar hasta la siguiente linea
    ;EBX está marcando justo despues de los signos "????"
    
sigueIns:
    

    call        ignorar         ;deja a EDX marcando el inicio de la instrucción

    
    mov         CL, [EDX]
    PutCh       CL
    cmp         CL, "."
    
    je          desplegarMemoria; ya está todo ensamblado
    
    ;en CL, YA ESTÁ el caracter
    ;justo aqui asignar el ip, a 
    ;mov         [IP],EBX       ;NO ESTOY SEGURO
    call        instruccion
    ;call        ignorarFin
    ;prueba
    ;call        ignorar
    ;call        instruccion
    
    jmp         ensamblarCodigo
    
    
    
    
    
    
desplegarMemoria:
;debe colocar un cero al final del ensamblado por el .EXIT, indica el final del programa
    PutStr   msg_2
    mov     CL, 0
    mov     [EBX], CL ; deja el cero al final del codigo
    
    mov     EBX, [offset]
    add     EBX, [IPointer]
    mov     CX, [EBX]   ;en CX tengo el PC

    ;call        impriTabla
vueltaCodigo:

    nwln
    PutStr      msg_2
    call        impriMemoria
    
    
    mov     CX, [EBX]
    ;PutInt  CX
    cmp     CX, 0       ;si es cero debe de terminar
    je     term
    
    call        ejecutarInstruccion
    call        impriDatos
    
    GetStr      ent, 1      ;aqui pido el enter
    ;con las lineas de abajo actualiza el PC
    
    
    jmp         vueltaCodigo
    
    
    
;con lo de abajo puedo ir obteniendo el IP
    ;mov         EBX, memoria
    ;add         EBX, [IPointer]
    ;mov        CL, [EBX]
;o tambien asi:
    
;creo que es mejor la segundo porque no va cambiando a EBX

    
      

imprimir:
    ;mov         AL, [ EBX ]     ;mueve un byte a AL
    ;cmp         AL, 03h        ;compara si es el final del texto
    ;je          term           ;salta a terminar
    ;cmp         CL, 0
    ;je          term
    ;call        comentario      ;llama a comentari
    ;PutCh       AL              ;imprime caracter
    ;nwln
    ;inc         EBX             ;EBX+1
    ;loop        imprimir      ;
term:
    
    .EXIT
    
;------------------------------------------------------------------
;la idea es que no muestre los comentarios
    
comentario:
    
    cmp         CL, ';'         ;compara si inicia comentario     
    je          ignorar         ;si son, ignora todo lo que sigue
    ret                         ;si no lo es vuelve donde fue llamad
    

;ignora hasta que llegue a siguiente linea
ignorarFin:
    mov         CL, [ EDX ]
    cmp         CL, 0x0A
    je          tIF
    inc         EDX
    jmp         ignorarFin
tIF:
   
    inc         EDX
    ret
;-----------------------------------------------------------------
;ignora espacios o siguientes lineas
ignorar:
    mov         CL, [EDX]
    
    
    cmp         CL, " "
    je          otroIgno
    cmp         CL, 0x0A
    je          otroIgno
    jmp         termIgno
otroIgno:
    inc         EDX
    jmp         ignorar
termIgno:
  
    ret
    
;-----------------------------------------------------------------
;deja a ebx hasta donde haya un numero

esNumero:
    cmp         CL, "0"
    jl          incrementar
    cmp         CL, "9"
    jg          incrementar
    jmp         encontro
incrementar:
    inc         EDX
    mov         CL, [ EDX ]
    jmp         esNumero
encontro:
    ret

;-----------------------------------------------------------------
;sumar los datos a una memoria y así los agrega a memoria
;CL sale marcando al caracter despues del numero

sumarAMemoria:
    
    ;push        EDX                 ;apunta la texto
    sub         EAX, EAX
    sub         CH,CH               ;para limpiarlo
    jmp         uno
vueltaSumar:
    inc         EDX
    mov         CL, [ EDX ]
uno:
    cmp         CL, "0"
    jl          terminarSumar
    cmp         CL, "9"
    jg          terminarSumar
    sub         CL, "0"
    call        multi10
    add         AX,CX
    
    jmp         vueltaSumar

    
terminarSumar:
    ;pop         EDX
    
    ret
    ;probar lo anterio
;------------------------------------------------------------
multi10:
    push        EDX
    mov         DX, 10
    mul         DX
    pop         EDX
    ret

;---------------------------------------------------------
imprimirElHostio:
    mov     AL, [ EDX ]
    PutCh   AL
    inc     EDX
    loop    imprimirElHostio
    ret
    
;------------------------------------------------------------------
guardarEtiqu:;guarda los valores de DATA y UDATA
    

    mov         ECX, [offset]

    
    mov         [IPointer], EBX
    sub         [IPointer], ECX        ;la dir logica la tengo en EBX

    
    push        EBX
    push        EAX
    mov         EBX, [tablaPoint]        ;ahora ebx, apunta a la tabla de sign

    
vueltaGDU:
    mov         CL, [EDX]
    cmp         CL, "a"
    jl          terminoGE          ;es una etiqueta
    mov         [EBX],CL
    inc         EBX
    inc         EDX
    jmp         vueltaGDU
    ret

    
terminoGE:
    mov         CL, 0
    mov         [EBX], CL           ;pone cero al final
    inc         EBX
;si al inicio de l codigo coloco una bandera el IPointer se asginara al inicio de CODE SEGMENT
    mov         CX, [IPointer]           ;
    mov         [EBX], CX           ;el IP despues del cero
    inc         EBX
    mov         DWORD[tablaPoint], EBX  ;guarda el apuntador de EBX
    pop         EAX                 ;restaura valor
    pop         EBX

    ret

;-----------------------------------------------------------------
;agrega datos que representan el agregarVacio

agregarVacio:
    mov         ECX, EAX
loopAgregar:
    mov         AL, "?"
    mov         [EBX],AL
    inc         EBX
    loop        loopAgregar
    ;PutStr      memoria
    ret
;----------------------------------------------------------------------
impriMemoria:
    nwln
    push        EBX                 ;guarda apuntador memoria
    push        EDX                 ;guarda apuntador del txt
    mov         EBX, memoria        ;marca al inicio de memoria
    jmp         soloHex

impriTabla:
    nwln
    push        EBX                 ;guarda apuntador memoria
    push        EDX                 ;guarda apuntador del txt
    mov         EBX, tablaSignos    ;marca al inicio de memoria
    jmp         soloHex
    
impriIR:
    nwln
    push        EBX                 ;guarda apuntador memoria
    push        EDX                 ;guarda apuntador del txt
    mov         AL, [codigo]        ;marca al inicio de memoria
    call        hexadecimal2
    PutCh       " "
    mov         AL, [par1]
    call        hexadecimal2
    PutCh       " "
    mov         AL, [par2]
    call        hexadecimal2
    ret
    

        

    
soloHex :
    ;PutStr      hexadecimal_msg

    ;push         EDX
    ;mov         EBX, buffer
    sub         EDX, EDX            ;resta EDX, para luego usarlo de contador, 24 char por linea
    mov         ECX, kilo
soloHex2 :
    mov         AL, [EBX]               ;mueve el caracter a AL
    call        hexadecimal2
    
    inc         EBX
    PutCh       ' '
    inc         EDX
    cmp         EDX, 24                 ;imprime 24 caracteres en una linea
    jne         sigueH
    nwln
    mov         EDX, 0
sigueH:
    ;PutLInt     ECX
    loop        soloHex2
    
    
sigueHex :
    ;cmp         BYTE [EBX],0            ;para terminar
    
    ;jne         soloHex2
    nwln
    pop         EDX
    pop         EBX
    
    ret


    

;------------------------------------------------------
hexadecimal2:
; en AL está el valor a imprimir
    push    ECX                      ;guarda CX en pila
    
    mov     AH, AL   ;copia AL en AH
    cmp     AL, 0x00
    jne     noEs0
    PutCh   "0"
    PutCh   "0"
    jmp     impHecha
noEs0:
    shr     AL, 4                   ;mueve los 4 bits más signifivativos a la derecha
    mov     CX, 2                   ;2 en CX
imprimir_digito:
    
    cmp     AL, 9                   ;compara con 9
    jg      A_F                     ;si es mayor salta
    add     AL, '0'                 ;suma '0'
    jmp     paso_hex                ;salto
A_F:
    add     AL, 'A' - 10            ;suma diferencia
paso_hex:
    
    PutCh   AL                      ;imprime el caracter
    
    mov     AL, AH                  ;reestaura AL
    and     AL, 0FH                 ;And a los 4 bits menores
    
    loop    imprimir_digito         ;salto
impHecha:
    
    pop     ECX                      ;reestablece el valor de CX

    ret
;-----------------------------------------------------------------
;indica cual instruccion es y la inserta en la memoria
instruccion:
    inc     EBX             ;incremento para dejar espacio a que codigo de mov es e ir poniendo que registro, o memoria
;esto es para 
esB:    
    ;PutCh   "B"
    cmp     CL, "b"
    jne     esC
    ;si sigue es que es buc
    add     EDX, 4; señala al inicio de la etiqueta
    mov     CL, [EDX]
;antes de buscar tabla cl debe estar marcando el inicio de la etiqueta
    call    buscarTabla
;cl trae el espacio de memoria
    mov     [EBX], CL
    
    dec     EBX
    mov     [EBX], byte 15  ;codigo de buc
    
    add     EBX, 2
    jmp     terminarInstr
    
    

esC:
    ;PutCh   "C"
    cmp     CL, "c"
    jne     esL
    
    inc     EDX
    mov     CL, [EDX]
    cmp     CL, "m"
    jne     esCO
    
    add     EDX, 3
    mov     CL, [EDX]
    call    cualReg
    mov     [EBX], CL
    inc     EBX
    add     EDX, 2; EDX QUEDA MARCANDO AL Inicio del seugndo parametro
    mov     CL, [EDX]
    
    cmp     CL, "["
    jl      esCM_reg
    ;es mem
    inc     EDX
    mov     CL, [EDX]
    cmp     CL, "a"
    jl      esCM_m_r
    call    buscarTabla
;cl trae el espacio de memoria
    mov     [EBX], CL
    jmp     term_esCM_M
    
esCM_m_r:
    ;es memoria registro
    call    cualReg
    mov     [EBX], CL
    
term_esCM_M:
    sub     EBX, 2
    mov     [EBX], byte 16  ;codigo de cmp reg,[reg/mem]
    
    add     EBX, 3
    jmp     terminarInstr
    


esCM_reg:
    cmp     CL, "A"
    jl      esCM_num
    call    cualReg
    mov     [EBX], CL
    sub     EBX, 2
    mov     [EBX], byte 17  ;codigo de cmp reg,[reg/mem]
    
    add     EBX, 3
    jmp     terminarInstr

esCM_num:
    cmp     CL, "0"
    jl      esCM_cha
    
    call    sumarAMemoria
    mov     CL, AL
    ;PutCh   "e"
    mov     [EBX], CL
    sub     EBX, 2
    mov     [EBX], byte 18  ;codigo de cmp reg,[reg/mem]
    
    add     EBX, 3
    jmp     terminarInstr
    
esCM_cha:
    ;por ahora no cmp con char
    
    
    
esCO:
    inc     EDX
    mov     CL, [EDX]
    cmp     CL, "l"
    jne     esCOR
    
    dec     EBX     ;dec porque ya se que codigo de inst es
    mov     [EBX], byte 25  ;codigo de col
    jmp     termCO
    
esCOR:
    dec     EBX     ;dec porque ya se que codigo de inst es
    mov     [EBX], byte 26  ;codigo de cor
    
termCO:
    inc     EBX
    add     EDX, 2
    mov     CL, [EDX]
    call    cualReg
    mov     [EBX], CL
    inc     EBX
    add     EDX, 2
    mov     CL,[EDX]
    call    sumarAMemoria
    mov     CL, AL
    mov     [EBX], CL
    inc     EBX
    jmp     terminarInstr
    
esL:
    cmp     CL, "l"
    jne     esM
    add     EDX, 4
    mov     CL, [EDX]
    
    call    buscarTabla
    mov     [EBX], CL
    dec     EBX
    mov     [EBX], BYTE 27
    add     EBX, 2
    jmp     terminarInstr
    



esM:
    cmp     CL, "m"
    jne     esPE
    inc     EDX
    mov     CL, [EDX]
    cmp     CL,"e"
    jne     esMov
    add     EDX, 3          ;ya sé que es met, y en teoria deberia estar apuntado al inicio del parametro
    mov     CL, [EDX]
    
    call    cualReg
    
    mov     [EBX], CL
    dec     EBX
    mov     [EBX], byte 28
    add     EBX, 2
    
    jmp     terminarInstr
    
    ;continuar instruccion
    
esMov:
    ;PutCh   "M"
    
    
    add     EDX, 3          ;en teoria deberia estar apuntando al inicio del parametro
    mov     CL, [EDX]
    
    cmp     CL, "A"
    jl      noReg
    ;mov     CL, 0           ;code A: 00
    cmp     CL, "D"
    jg      noReg
    jmp     esReg
esReg:
    call    cualReg
    mov     [EBX], CL
    inc     EBX             ;incrementarla para despues
    add     EDX, 2          ;apuntan al inicio del segundo parametro
    mov     CL, [EDX]
;comparar el segundo parametro    
    cmp     CL, "A"
    jl      noRR
    cmp     CL, "D"
    jg      noRR
    jmp     esRR

esRR:
    
    call    cualReg
    mov     [EBX], CL       ;inserta el codigo en memoria
    
    sub     EBX, 2          ;para vovlver al espacio de memoria reservado para el codigo de mov
    mov     CL, 10          ;codigo de rr es 10
    mov     [EBX], CL
    add     EBX, 3          ;deja el apuntador justo para insertar la siguiente instruccion
    
    jmp     terminarInstr     ;para que siga con la siguiente linea de codigo y la ensamble
    

noRR:
    
    cmp     CL, "["
    jne     noMem
    inc     EDX
    mov     CL, [EDX]
    cmp     CL, "A"
    jl      esRMv  
    cmp     CL, "D"
    jg      esRMv
    
    call    cualReg
    jmp     esRMr
    
esRMv:
    call    buscarTabla
    ;PutInt  CX
    ;PutCh   "w"
    mov     [EBX], CL
    ;PutInt  CX
    ;PutCh   CL
    sub     EBX, 2
    mov     CL, 12          ;codigo de registro-[memoria]
    mov     [EBX], CL
    add     EBX, 3
    
    jmp     terminarInstr
    
esRMr:
    mov     [EBX], CL
    ;PutInt  CX
    ;PutCh   CL
    sub     EBX, 2
    mov     CL, 19          ;codigo de registro-[registr]
    mov     [EBX], CL
    add     EBX, 3
    
    jmp     terminarInstr
    ;aquí falta lo de la tabla de signos, porque puede ser que lo que este dentro sea una variable y a el valor de registro marcado en memoria
    

noMem:
    
    ;cmp     CL, "0"
    ;jl      esRIm
    cmp     CL, "9"
    jg      esRIm           ;salta si es un nombre
    call    sumarAMemoria
    mov     CL, AL
    mov     [EBX], CL
        sub     EBX, 2
    mov     CL, 11          ;codigo de registro-inmediato
    mov     [EBX], CL
    add     EBX, 3
    jmp     terminarInstr
          
    ;esta hecha para [mem], entonces cuando llama lo primero que hace es restar EDX
esRIm:
    
    ;dec     EDX
    mov     CL, [EDX]
    
    call    buscarTabla     ;en CL tengo el valor, luego lo paso

    mov     [EBX], CL       ;es CH, porque CL es cambiada en "ignorarFin"
    
    ;cambiar CH para que imprima el numero
    ;sub     CH, "0"
    
    ;deja rel mov de arriba solo para cuando sea un numerp
    sub     EBX, 2
    mov     CL, 11          ;codigo de registro-inmediato
    mov     [EBX], CL
    add     EBX, 3
    jmp     terminarInstr
    
;comparar con un inmeditato,0 - 9, o el valor de algo en la tabla de signos
    ;cmp     inmediato
    
    
noReg:
;no es necesaria la comparacion de abajo porque el mov, solo sirve con primer parametro de registro o memomira
    ;cmp     CL, "["
    ;seguir con memoria- inmediato
    ;y memoria - registro
    ;A,6
    inc     EDX         ;porque está marcando el parentesis, ahora marca el valor dentro
    
    call    cualReg
    
    mov     [EBX], CL
    inc     EBX
    add     EDX, 3
    mov     CL, [EDX]
    
    cmp     CL, "9"
    jg      noRegMe            ;si es menor es porque no es mem
    
    call    buscarTabla
    jmp     esMI
 
noRegMe:
    PutCh   "S"
    cmp     CL, "A";si es menor no es registro
    jl      noRegReg
    
    call    cualReg
    
    mov     [EBX], CL
    
    sub     EBX, 2
    mov     [EBX], byte 14
    add     EBX, 3
   
    jmp     terminarInstr
    
noRegReg:
    call    sumarAMemoria
    mov     CL, AL
esMI:
    mov     [EBX], CL
    sub     EBX, 2
    mov     [EBX], byte 13
    add     EBX, 3
    call    ignorarFin
    jmp     terminarInstr
    
esPE: 
    ;PutCh   "P" 
    cmp     CL, "P"
    jne     esR
    
    inc     EDX
    mov     CL, [EDX]
    
    add     EDX, 2          ;marca en el valor
    cmp     CL, "C"
    jne     noPEC
    
    ;es c e imprime un caracter
    mov     CL, [EDX]
    cmp     CL, "A"
    jl      esNum
    ;si sigue es registro 
    call    cualReg 
    mov     [EBX], CL
    dec     EBX
    mov     [EBX], BYTE 21       ;codigo PC, putchar
    jmp     termChar

esNum:
    
    cmp     CL, "1"
    jl      esCom
    ;PutCh   "S"
    call    sumarAMemoria
    mov     CL, AL
    
    jmp     termChar2

esCom:
    inc     EDX
    mov     CL, [EDX]
termChar2:
    mov     [EBX], CL   
    dec     EBX
    ;mov     CL, 20
    mov     [EBX], BYTE 20       ;codigo PC, putchar
termChar:
    add     EBX, 2
    jmp     terminarInstr
    
    
noPEC:
    cmp     CL, "I"
    jne     noPEI
    mov     CL, [EDX]
    cmp     CL, "A"
    jl      esPEIN
    
    call    cualReg
    mov     [EBX], CL
    dec     EBX
    mov     [EBX], BYTE 23
    
    add     EBX, 2
    jmp     terminarInstr
    
esPEIN:
    
    call    sumarAMemoria   
    mov     CL, AL
    
    mov     [EBX], CL
    
    dec     EBX
    mov     [EBX], BYTE 22
    
    add     EBX, 2
    jmp     terminarInstr    
    
    
noPEI:  
;es putSTRIN
    
    
    call    buscarTabla
    
    mov     [EBX], CL
    dec     EBX
    mov     [EBX], byte 24
    add     EBX, 2
    jmp     terminarInstr
    
    
esR:
    ;PutCh   "R"
    cmp     CL, "r"
    jne     esS
    
    inc     EDX
    mov     CL, [EDX]
    
    cmp     CL, "e"
    jne     esRO
    
    inc     EDX,
    mov     CL, [EDX]
    cmp     CL, "s"
    jne     esRET
    
    add     EDX, 2
    mov     CL,[EDX]
    call    cualReg
    mov     [EBX], CL
    inc     EBX, 
    add     EDX, 2
    mov     CL,[EDX]
    call    sumarAMemoria
    mov     CL, AL
    
    mov     [EBX], CL
    sub     EBX,2
    mov     [EBX], byte 49
    add     EBX, 3
    jmp     terminarInstr

    
    
esRET:
    dec     EBX
    mov     [EBX], byte 29;codigo
    inc     EBX
    jmp     terminarInstr
    
    
esRO:
    ;PutCh   "O"
    inc     EDX
    dec     EBX
    mov     CL, [EDX]
    cmp     CL, "l"
    jne     esROR
    PutCh   "L"
    mov     [EBX], byte 30
    jmp     termRO
    
    
esROR:
    ;PutCh   "R"
    mov     [EBX], byte 31
    
termRO:
    inc     EBX
    add     EDX, 2
    mov     CL, [EDX];EDX esta marcando el registro
    call    cualReg
    mov     [EBX], CL
    inc     EBX
    add     EDX, 2
    mov     CL,[EDX]
    call    sumarAMemoria
    mov     CL, AL
    mov     [EBX], CL
    inc     EBX
    jmp     terminarInstr

esS:
    ;PutCh   "S"
    cmp     CL, "s"
    jne     esT
    
    inc     EDX
    mov     CL, [EDX]
    cmp     CL, " "
    jne     esSC
    
    inc     EDX
    mov     CL, [EDX]

    call    buscarTabla
    
    mov     [EBX], CL
    dec     EBX
    mov     [EBX], BYTE 50
    add     EBX, 2
    jmp     terminarInstr
    
esSC:
    cmp     CL, "c"
    jne     esSI
    
    add     EDX, 2
    mov     CL, [EDX]

    call    buscarTabla
    
    mov     [EBX], CL
    dec     EBX
    mov     [EBX], BYTE 32
    add     EBX, 2
    jmp     terminarInstr

esSI:
    cmp     CL, "i"
    jne     esSM
    
    add     EDX, 2
    mov     CL, [EDX]

    call    buscarTabla
    
    mov     [EBX], CL
    dec     EBX
    mov     [EBX], BYTE 33
    add     EBX, 2
    jmp     terminarInstr
    
    
esSM:
    cmp     CL, "m"
    jne     esSN
    
    inc     EDX
    mov     CL, [EDX]
    cmp     CL, "a"
    jne     esSME
    
    add     EDX, 2
    mov     CL, [EDX]

    call    buscarTabla
    
    mov     [EBX], CL
    dec     EBX
    mov     [EBX], BYTE 36
    add     EBX, 2
    jmp     terminarInstr
    
esSME:
    add     EDX, 2
    mov     CL, [EDX]

    call    buscarTabla
    
    mov     [EBX], CL
    dec     EBX
    mov     [EBX], BYTE 37
    add     EBX, 2
    jmp     terminarInstr
    
    
esSN:
    cmp     CL, "n"
    jne     esSU
    
    inc     EDX
    mov     CL, [EDX]
    cmp     CL, "c"
    jne     esSNI
    
    add     EDX, 2
    mov     CL, [EDX]

    call    buscarTabla
    
    mov     [EBX], CL
    dec     EBX
    mov     [EBX], BYTE 34
    add     EBX, 2
    jmp     terminarInstr
    
esSNI:
    add     EDX, 2
    mov     CL, [EDX]

    call    buscarTabla
    
    mov     [EBX], CL
    dec     EBX
    mov     [EBX], BYTE 35
    add     EBX, 2
    jmp     terminarInstr
    
    
    
esSU:
    ;PutCh   "U"
    ;PutCh   "M"
    add     EDX, 3
    mov     CL, [EDX]
    
    call    cualReg
    
    mov     [EBX], CL
    add     EDX, 2
    inc     EBX
    mov     CL, [EDX]
    
    call    sumarAMemoria
    
    mov     CL, AL
    mov     [EBX], CL
    sub     EBX, 2
    mov     [EBX], BYTE 48
    add     EBX, 3
    jmp     terminarInstr
    
    
    
    
    
    
    
    
    
    
    
esT:;
    ;PutCh   "T"
    cmp     CL, "t"
    jne     esY
    inc     EDX
    mov     CL,[EDX]
    
    cmp     CL, "o"
    jne     esTS
    ;PutCh   "O"
    
    add     EDX, 3
    
    mov     CL, [EDX]
    
    call    cualReg
    
    mov     [EBX], CL
    dec     EBX
    mov     [EBX], BYTE 45
    add     EBX, 2
    jmp     terminarInstr
    

esTS:
   ; PutCh   "S"
    add     EDX, 3
    mov     CL, [EDX]
    call    cualReg
    mov     [EBX], CL
    inc     EBX
    add     EDX, 2
    mov     CL, [EDX]
    call    sumarAMemoria
    mov     CL, AL
    mov     [EBX], CL
    sub     EBX, 2
    mov     [EBX], BYTE 46
    add     EBX, 3
    jmp     terminarInstr
    
    
    
    
esY:
    ;PutCh   "Y"
    cmp     CL,"y"
    jne     noY
    
    add     EDX, 2
    mov     CL, [EDX]
    call    cualReg
    mov     [EBX], CL
    inc     EBX
    add     EDX, 2
    mov     CL, [EDX]
    call    sumarAMemoria
    mov     CL, AL
    mov     [EBX], CL
    sub     EBX, 2
    mov     [EBX], BYTE 47
    add     EBX, 3
    jmp     terminarInstr
    
    
    
    
noY:

    
terminarInstr:
    call    ignorarFin
    ret

;-------------------------------------------------------------
;EDX entra marcando al "["
;la idea es buscar el valor en la tabla de signos para luego extraer al posicion
buscarTabla:
    cmp     CL,"["          ;por si es memoria o inmediato
    jne     noIncrementa
    inc     EDX
noIncrementa:
    push    EBX
    ;
    push    EAX     ;creo que no es necesario push de EAX
    ;push    ECX
    ;sub     ECX, ECX
    
    mov     EBX, tablaSignos        ;ya no es memoria, es tabla de signos
;primero buscar el primer caracter en la tabla, cuando alguno coincida se incrementan EDX y EBX, si coinciden de nuevo, se incrementan otra vez. Si se incrementa y no coinciden EDX debe volver al inicio del valor, justo despues del "[" y EBX incrementar para ir comparando.

sonIguales:

    mov     AL, [EDX]
    mov     AH, [EBX]
    cmp     AL, AH
    jne     queCaso
    inc     EDX
    inc     EBX
    jmp     sonIguales
    
queCaso:

    cmp     AH, 0
    jne     restauraReg                ;debe restaura EDX, y dejar a ebx en el siguiente signo
    
    
    cmp     AL,"a"

    jl      encontroSigno           ;aumenta en 2 EBX, y restauta EDX
    
    ;cmp     AL, " "
    ;jne     encontroSigno
    
    jmp     restauraReg2
    
    
restauraReg:
;primero busca al cero
    cmp     AH, 0
    je      restauraReg2
    inc     EBX
    mov     AH, [EBX]
    jmp     restauraReg
    
restauraReg2:
    add     EBX, 2                  ;aumenta en 2 para que marque el siguiente signo
    
    
restauraR:

    cmp     AL, "a"
    jl      hechaRes

    ;cmp     AL, ","
    ;je      hechaRes
    
    dec     EDX
    mov     AL, [EDX]
    jmp     restauraR
hechaRes:
    inc     EDX
    
    jmp     sonIguales






;si se encuentra un null en EBX, EBX se incrementa en 2
;cl debe retornar con el dato despues del cero en la tabla de signos
encontroSigno:
    inc     EBX
    sub     EBX, 2
    mov     CL, [EBX]       ;la dir en tabla de signos que da en CL
    ;PutCh   CL
    nwln
    add     EBX, 2
    mov     CL, [EBX]       ;la dir en tabla de signos que da en CL
    ;PutCh   CL
    ;PutCh   "B"
    pop     EAX
    pop     EBX
    ret

    
    

    
;-----------------------------------------------------------------
;retorna en CL el codigo del registro
cualReg:
    mov     CL, [EDX]
    cmp     CL,"A"
    jne     cRB
    mov     CL,0
    jmp     seReg
cRB:
    cmp     CL,"B"
    jne     cRC
    mov     CL,1
    jmp     seReg
cRC:
    cmp     CL,"C"
    jne     cRD
    mov     CL,2
    jmp     seReg
cRD:
    cmp     CL,"D"
    mov     CL,3
    
seReg:
    ret
    
;---------------------------------------------------------------
;esto es para que vaya sumandoa EDX y EBX, guardar las etiquetas antes

etiquetas:
    
    cmp     CL,"y";y 3
    jl      eT
    
    jmp     sumar3
    
    
eT:
    cmp     CL,"t"
    jl      eSS
    inc     EDX
    mov     CL, [EDX]
    cmp     CL,"s"
    jl      eTO
    ;tst 3
    jmp     sumar3
    
eTO:   ;tom 2
    jmp     sumar2

    
eSS:
    cmp     CL,"s"
    jl     eR
    inc     EDX
    mov     CL, [EDX]
    cmp     CL,"u"
    jl      eSS_noU
    ;sum 3
    jmp     sumar3
    
eSS_noU:;saltos 2
    jmp     sumar2
    
eR:
    cmp     CL,"r"
    jl      eP
    inc     EDX
    mov     CL, [EDX]
    cmp     CL,"o"
    jl      eRE
    ;rol,ror 3
    jmp     sumar3
    
eRE:
    inc     EDX
    mov     CL, [EDX]
    cmp     CL,"t"
    jl      eRES
    ;ret 1
    jmp     sumar1
    
eRES:;res 3
    jmp     sumar3
    
eP:;PC,PS,PI 2
    cmp     CL,"p"
    jl      eM
    jmp     sumar2
    
eM:
    cmp     CL,"m"
    jl      eG
    inc     EDX
    mov     CL, [EDX]
    cmp     CL,"o"
    jl      eME
    ;mov 3
    jmp     sumar3

eME:;met 2
    jmp     sumar2
    
eG:;GI,GS, lla 2
    cmp     CL,"g"
    jl      eC
    jmp     sumar2
    
eC:;cmp, col, cor 3
    cmp     CL,"c"
    jl      eB
    jmp     sumar3
    
eB:;buc 2
    jmp     sumar2
    
    
    
    
    
sumar3:
    add     EBX, 3
    jmp     terminarEtiquetas

sumar2:
    add     EBX, 2
    jmp     terminarEtiquetas

sumar1:
    add     EBX, 1
    jmp     terminarEtiquetas
    
    
terminarEtiquetas:
    ;PutCh   "R"
    ;PutCh   "W"

    ret
    
    
;-----------------------------------------------------------------
;imprimi todo los demas datos, registros, banderas, PC, SP, IR

impriDatos:
    nwln
    PutStr      regA
    PutInt      [A]
    PutCh       " "
    PutCh       "/"
    PutStr      regB
    PutInt      [B]
    PutCh       " "
    PutCh       "/"
    PutStr      regC
    PutInt      [C]
    PutCh       " "
    PutCh       "/"
    PutStr      regD
    PutInt      [D]
    nwln
    PutStr      ZF
    PutInt      [ZFlag]
    PutCh       " "
    PutCh       "/"
    PutStr      CF
    PutInt      [CFlag]
    PutCh       " "
    PutCh       "/"
    PutStr      OF
    PutInt      [OFlag]
    PutCh       " "
    PutCh       "/"
    PutStr      SF
    PutInt      [SFlag]
    PutCh       " "
    PutCh       "/"
    nwln
    PutStr      stackP
    PutInt      [pila]
    PutCh       " "
    PutCh       "/"
    PutStr      PC
    PutLInt      [IPointer]
    PutCh       " "
    PutCh       "/"
    PutStr      IR
    ;call        impriIR
    PutStr      outPut
    PutStr      salida
    nwln
    PutStr      cont
    nwln
    ret

;------------------------------------------------------
;
ejecutarInstruccion:
    push    EDX
    sub     CH,CH
    PutCh   "["
    PutInt  CX      ;imprime el codigo de operacion
    PutCh   "]"
    mov     [codigo],CL
    
es10:
    cmp     CL, 10
    jne     es11
    
    
    inc     EBX
    mov     CL,[EBX]
    call    valorDirReg ;dir del reg en EDX
    mov     EAX, EDX    ;"respaldo en eax"
    inc     EBX
    mov     CL,[EBX]    ;en cl tengo cual registro
    call    valorReg    ; EN dx
    mov     [EAX],DX
    jmp     termInstr
    
es11:
    cmp     CL, 11
    jne     es12
    PutCh   "!"
siEs11:
    inc     EBX
    mov     CL,[EBX]
    call    valorDirReg ;dir del reg en EDX
    mov     EAX, EDX    ;"respaldo en eax"
    inc     EBX
    mov     CL,[EBX]    ;en cl tengo el numero
    mov     [EAX],CL
    jmp     termInstr
    
    
es12:
    cmp     CL, 12
    jne     es13
    PutCh   "W"
    
    inc     EBX
    mov     CL,[EBX]
    call    valorDirReg ;dir del reg en EDX
    mov     EAX, EDX    ;"respaldo en eax"
    inc     EBX
    mov     ECX, [EBX]  ;En ECX tengo la dir log mem
    
    add     ECX, memoria;le sumo el offset
    
    mov     EDX, [ECX]  ;muevo el contenido de celda a ECX
    and     DX, 0x00FF  ;es necesaria la mascara
   
    mov     [EAX], DX  ;y ahora lo muevo al registro

    PutCh   "W"
    jmp     termInstr
    
    
    
es13:
    cmp CL, 13
    jne es14
    
    inc     EBX
    mov     CL,[EBX]
    call    valorDirReg     ;dir del reg en EDX
    mov     EAX, [EDX]      ;en EAX tengo la dir de memoria
    add     EAX, memoria  ;
    inc     EBX
    mov     CL, [EBX]       ;En ECX tengo la dir log mem
    call    valorDirReg     ;dir del reg en EDX
    mov     ECX, [EDX]
    mov     [EAX], ECX       ;y ahora lo muevo al registro

    jmp     termInstr
    
    
    
es14:
    cmp     CL, 14
    jne     es15
    PutCh   "E"
    inc     EBX
    mov     CL,[EBX]
    call    valorDirReg     ;dir del reg en EDX
    mov     EAX, [EDX]      ;en EAX tengo la dir de memoria
    and     EAX, 0x000000FF
    
    add     EAX, memoria  ;
    
    inc     EBX
    mov     CL, [EBX]       ;En ECX tengo el numero
    call    valorDirReg     ;dir del reg en EDX
    
    mov     ECX, [EDX]
    PutCh   "/"
    
    and     ECX, 0x000000FF
    
    mov     [EAX], CL       ;y ahora lo muevo al registro
    PutCh   [EAX]           ;al meter cosas en celdas solo deben ser de 8 bits
    PutLInt ECX
    PutCh   "E"
    jmp     termInstr
    
es15:
    
    cmp CL,15   ; es bucle
    jne es16
    PutCh   "R"
    
    ;hace el bucle
    inc     EBX
    sub     [C], WORD 1
    cmp     [C], WORD 0
    jne     cambiarIP
    ;no altera IPointer
    inc     EBX
    
    PutInt  [EBX]
    jmp     termInstr
    
cambiarIP:
    
    mov     ECX, [EBX]
    dec     ECX
    mov     EBX, ECX
    add     EBX, memoria
    PutInt   [EBX]
    
    jmp     termInstr

es16:
    cmp     CL,16 ;cmp reg/mem
    jne     es17
    PutCh   "c"
    
    inc     EBX
    mov     CL,[EBX]
    call    valorReg
    ;ya tengo en dx el valor de cualquier registro
    mov     AX, DX      ;AX sera el primer para, EDX el segundo
    
    inc     EBX
    mov     CL,[EBX]
    sub     EDX, EDX
    call    valorReg
    PutCh   "("
    PutLInt  EDX
    PutCh   ")"
    
    add     EDX,memoria
    PutCh   "("
    PutLInt  EDX
    PutCh   ")"
    PutCh   "*"
    mov     CX,[EDX]
    and     CX,0X00FF
    call    alteraFlag
    
    PutCh   "c"
    jmp     termInstr

    
es17:;reg reg
    cmp     CL,17
    jne     es18
    
    inc     EBX
    mov     CL,[EBX]
    call    valorReg
    ;ya tengo en dx el valor de cualquier registro
    mov     AX, DX      ;AX sera el primer para, EDX el segundo
    
    inc     EBX
    mov     CL,[EBX]
    call    valorReg
    
    mov     CX,DX
    and     CX,0X00FF
    call    alteraFlag
    
    PutCh   "c"
    jmp     termInstr
    

es18:;reg num
    cmp     CL,18
    jne     es19
    
    inc     EBX
    mov     CL,[EBX]
    call    valorReg
    ;ya tengo en dx el valor de cualquier registro
    mov     AX, DX      ;AX sera el primer para, EDX el segundo
    
    inc     EBX
    mov     CL,[EBX]

    and     CX,0X00FF
    call    alteraFlag
    
    PutCh   "c"
    jmp     termInstr
    
es19:
    cmp     CL,19
    jne     es20
    
    PutCh   "d"
    
    inc     EBX
    mov     CL,[EBX]
    call    valorDirReg ;dir del reg en EDX
    mov     EAX, EDX    ;"respaldo en eax"
    inc     EBX
    mov     CL, [EBX]  ;En ECX tengo la dir log mem
    call    valorDirReg;en edx
    mov     ECX, [EDX]
    add     ECX, memoria;le sumo el offset
    
    mov     EDX, [ECX]  ;muevo el contenido de celda a ECX
    and     DX, 0x00FF  ;es necesaria la mascara
    PutCh   "/"
    mov     [EAX], DX  ;y ahora lo muevo al registro
    PutCh   "d"
    jmp     termInstr
    
    

es20:;PutCh Num
    cmp     CL,20
    jne     es21
    
    inc     EBX
    mov     CL, [EBX]
    ;poner un PutCh o hacer un "Pantalla"
    mov     EAX, [salPoint]
    add     EAX, salida
    mov     [EAX], CL
    inc     dword [salPoint]
    jmp     termInstr
    

es21:;PutCh reg
    cmp     CL,21
    jne     es22  
    
    inc     EBX
    mov     CL, [EBX]
    call    valorReg
    ;poner un PutCh o hacer un "Pantalla"
    mov     EAX, [salPoint]
    add     EAX, salida
    mov     [EAX], DX
    inc     dword [salPoint]
    jmp     termInstr

es22:   ;PutInt num                                   
    cmp     CL,22
    jne     es23
    inc     EBX
    ;mov     EBX,CL
    ;sub     CH,CH
    PutInt  CX

    

es23:
    cmp     CL,23
    jne     es24   
    PutCh   "X"
    inc     EBX
    mov     CL, [EBX]   ;en CX tengo el codigo de registro
    call    valorDirReg ;con esto extraigo el contenido del registro en EDX
    PutCh   "("
    PutInt [EDX]
    PutCh   ")"
    jmp     termInstr
   
es24:
    
    cmp     CL,24
    jne     es25 
    
    

es25:;shl
    cmp     CL,25
    jne     es26
    
    inc     EBX
    mov     CL, [EBX]
    call    valorDirReg;en EDX, est la dir deol registro
    inc     EBX
    mov     CL, [EBX]
    mov     AL, [EDX]
    shl     AL,CL
    mov     [EDX],AL
    call    estadoCarry;deberia cambiar el valor de la bandera
    jmp     termInstr

es26:;shr
    cmp     CL,26
    jne     es27  
    
    inc     EBX
    mov     CL, [EBX]
    call    valorDirReg;en EDX, est la dir deol registro
    inc     EBX
    mov     CL, [EBX]
    mov     AL, [EDX]
    shr     AL,CL
    mov     [EDX],AL
    call    estadoCarry;deberia cambiar el valor de la bandera
    jmp     termInstr
    

es27:
    cmp     CL,27
    jne     es28
    
es28:;push
    cmp     CL,28
    jne     es29
    
    inc     EBX
    mov     CL, [EBX]
    call    valorReg; EN Dx tengo el dato a hacer push
    
    ;[pila]+memoria= actual SP
    mov     EAX, [pila]
    add     EAX, memoria
    sub     dH,dH
    PutCh   "."
    PutInt   DX
    PutCh   "."
    mov     [EAX], DL
    dec     DWORD [pila]
    
    jmp     termInstr

es29:
    cmp     CL,29
    jne     es30
    
es30:;rol
    cmp     CL,30
    jne     es31
    
    inc     EBX
    mov     CL, [EBX]
    call    valorDirReg;en EDX, est la dir deol registro
    inc     EBX
    mov     CL, [EBX]
    mov     AL, [EDX]
    PutInt  CX
    rol     AL,CL
    PutCh   "/"
    PutInt  CX

    mov     [EDX],AL
    call    estadoCarry;deberia cambiar el valor de la bandera
    jmp     termInstr

es31:;ror
    cmp     CL,31
    jne     es32
    PutCh   ":"
    PutCh   ":"
    inc     EBX
    mov     CL, [EBX]
    call    valorDirReg;en EDX, est la dir deol registro
    inc     EBX
    mov     CL, [EBX]
    mov     AL, [EDX]
    PutInt  CX
    ror     AL,CL
    PutCh   "/"
    PutInt  CX

    mov     [EDX],AL
    call    estadoCarry;deberia cambiar el valor de la bandera
    jmp     termInstr

es32:;jz
    cmp     CL,32
    jne     es33
    
igualA32:

    inc     EBX
    mov     ECX, [ZFlag]
    cmp     ECX, 1
    jne     noHayCero   
    ;hay que cambiar ip
    mov     CL, [EBX]
    dec     CL
    and     ECX,0X000000FF
    mov     EBX, ECX
    add     EBX, memoria

    
noHayCero:
    jmp     termInstr
    
                ; SC
es33:;je
    cmp     CL,33
    jne     es34
    
    jmp     igualA32
    
es34:
    cmp CL,34
    jne es35
    
igualA34:

    inc     EBX
    mov     ECX, [ZFlag]
    cmp     ECX, 1
    je      hayCero   
    ;hay que cambiar ip
    mov     CL, [EBX]
    dec     CL
    and     ECX,0X000000FF
    mov     EBX, ECX
    add     EBX, memoria
    
hayCero:
    jmp     termInstr
    
    
es35:;jne
    cmp CL,35
    jne es36   
    
    jmp     igualA34
    
    
es36:;jg
    cmp CL,36
    jne es37
    
    inc     EBX
    mov     ECX, [SFlag]
    cmp     ECX, 1
    je      noSalta   
    ;hay que cambiar ip
    mov     CL, [EBX]
    dec     CL
    and     ECX,0X000000FF
    mov     EBX, ECX
    add     EBX, memoria
    
noSalta:
    jmp     termInstr
    
    
    
es37:;jl
    cmp CL,37
    jne es45 
    
    inc     EBX
    mov     ECX, [SFlag]
    cmp     ECX, 1
    jne      noSalta2   
    ;hay que cambiar ip
    mov     CL, [EBX]
    dec     CL
    and     ECX,0X000000FF
    mov     EBX, ECX
    add     EBX, memoria
    
noSalta2:
    jmp     termInstr
    
es45:
    cmp CL,45
    jne es46
    
    inc     EBX
    mov     CL, [EBX]
    call    valorDirReg; EN Dx tengo el dato a hacer push
    
    ;[pila]+memoria= actual SP
    inc     dword [pila]
    mov     EAX, [pila]
    add     EAX, memoria
    
    
    mov     ECX, [EAX]
    PutInt  [EAX]
    sub     CH,CH
    PutCh   "."
    PutInt   CX
    PutCh   "."  
    mov     [EDX], CL
    ;inc     DWORD [pila]
    
    jmp     termInstr
    
    
    
es46:
    cmp CL,46
    jne es47 
    
    inc     EBX
    mov     CL, [EBX]
    call    valorDirReg;en EDX, est la dir deol registro
    inc     EBX
    mov     CL, [EBX]
    mov     AL, [EDX]
    
    test     AL,CL
    call    estadoZero
    

    mov     [EDX],AL
    call    estadoCarry;deberia cambiar el valor de la bandera
    jmp     termInstr
    
es47:;y
    cmp     CL,47
    jne     es48 
    
    inc     EBX
    mov     CL, [EBX]
    call    valorDirReg;en EDX, est la dir deol registro
    inc     EBX
    mov     CL, [EBX]
    mov     AL, [EDX]
    PutInt  AX
    and     AL,CL
    PutCh   "/"
    PutInt  AX

    mov     [EDX],AL
    call    estadoCarry;deberia cambiar el valor de la bandera
    jmp     termInstr
    
es48:;sum
    cmp     CL,48
    jne     es49 
    
    inc     EBX
    mov     CL, [EBX]
    call    valorDirReg;en EDX tengo la dir 
    
    inc     EBX
    mov     CL, [EBX]
    add     [EDX], CL
    jmp     termInstr
    
es49:;res
    cmp     CL,49
    jne     es50 
    
    inc     EBX
    mov     CL, [EBX]
    call    valorDirReg;en EDX tengo la dir
    inc     EBX
    mov     CL, [EBX]
    sub     [EDX], CL
    jmp     termInstr

es50:
    cmp     CL,50
    jne     es51

    inc     EBX
    mov     CL, [EBX]
    dec     CL
    and     ECX,0X000000FF
    mov     EBX, ECX
    add     EBX, memoria

    jmp     termInstr
    
es51:
    
termInstr:
;AQUI CAMBIAR EL IP PARA QUE CUANDO SALGA SE IMPRIMA EL CORRECTO
    inc     EBX
    ;con lo de abajo cambia el IP
    mov     ECX, [offset]
    mov     [IPointer], EBX
    sub     [IPointer], ECX
    pop     EDX
    PutCh   "e"
    ret 

;---------------------------------------------------------------------------------------------------------------------
;altera las banderas
alteraFlag:
    
    PutCh   "%"
    PutInt  [ZFlag]
    PutCh   " "
    PutInt  [CFlag]
    PutCh   " "
    PutInt  [OFlag]
    PutCh   " "
    PutInt  [SFlag]
    PutCh   " "
    
esZero:
    
    
    PutCh   "("
    PutInt  AX
    PutCh   "="
    PutInt  CX
    PutCh   ")"
    cmp     AX,CX
    jz     zeFlag
    mov    BYTE [ZFlag],0x00
    
    
esCarry:
    
    PutCh   "("
    PutInt  AX
    PutCh   "="
    PutInt  CX
    PutCh   ")"
    cmp     AX,CX
    jc      CaFlag
    mov     BYTE [CFlag],0x00
    
    
esOver:
    
    PutCh   "("
    PutInt  AX
    PutCh   "="
    PutInt  CX
    PutCh   ")"
    cmp     AX,CX
    jo      OverFlag
    mov     BYTE [OFlag],0x00
    
    
esSign:
    
    PutCh   "("
    PutInt  AX
    PutCh   "="
    PutInt  CX
    PutCh   ")"
    cmp     AX,CX
    js      SignFlag
    mov     BYTE [OFlag],0x00
    
    jmp     termFlag
    
    
zeFlag:
    mov     BYTE [ZFlag],0x01
    PutCh "Y"
    
    jmp     esCarry


CaFlag:
    mov     BYTE [CFlag],0x01
    
    jmp     esOver

OverFlag:
    mov     BYTE [OFlag],0x01
    
    jmp     esSign
    
SignFlag:
    mov     BYTE [SFlag],0x01
    
    jmp     termFlag
    

termFlag:

    PutInt  [ZFlag]
    PutCh   " "
    PutInt  [CFlag]
    PutCh   " "
    PutInt  [OFlag]
    PutCh   " "
    PutInt  [SFlag]
    PutCh   " "
    ret
;-------------------------------
;asigna el valor que esta en el registro a DX, cualquier regsitro
valorReg:
    cmp CL, 0
    jne esB3
    mov DX, [A]
    jmp termValor
    
esB3:
    cmp CL, 1
    jne esC3
    mov DX, [B]
    jmp termValor
esC3:
    cmp CL, 2
    jne esD3
    mov DX, [C]
    jmp termValor
esD3:
    cmp CL, 3
    mov DX, [D]
termValor:
    ret
;-------------------------------------------------------------------------
;asigna La dir de registro en EDX
valorDirReg:
    cmp CL, 0
    jne esB2
    mov EDX, A
    jmp termValor2
    
esB2:
    cmp CL, 1
    jne esC2
    mov EDX, B
    jmp termValor2
esC2:
    cmp CL, 2
    jne esD2
    mov EDX, C
    jmp termValor2
esD2:
    cmp CL, 3
    mov EDX, D
termValor2:
    ret
    
;-----------------------------------------------
;me indica el valor de la CF
estadoCarry:
    jc  hayCarry
    mov     BYTE [CFlag],0x00
    jmp     termCarry
    
hayCarry:
    mov     BYTE [CFlag],0x01
    
termCarry:
    ret
    
;-----------------------------------------------
;me indica el valor de la ZF
estadoZero:
    jz      hayZero
    mov     BYTE [ZFlag],0x00
    jmp     termCarry
    
hayZero:
    mov     BYTE [ZFlag],0x01
    
termZero:
    ret
    
    
    
    
