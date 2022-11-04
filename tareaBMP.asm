Assume cs:codigo, ds:datos

;/__________________________________________________________________________________
datos segment

;NOMBRE DE LA IMAGEN
archivo db "peri.bmp",0 ;BMP debe estar en carpeta BIN
artAscii db "art.txt",0 ;Nombre del archivo por crear

;Valores alambrados de la imagen, se deben sacar del header. Falta hacer
inicioDatos dw 202
largo dw 200
anchoAux dw 175

;Mensajes para imprimir
msgColor db "Cantidad de color no es correcta $"
msgInicio db "No es imagen BMP $"
msgLargo db "El largo se sobre sobrepasa de los 480 $"
msgAncho db "El ancho se sobrepasa de los 640 $"
msgError1 db 10,13, "Error no se pudo abrir el archivo $"
msgError2 db 10,13, "Error no se pudo leer el archivo $"

;Variables para la lectura del archivo
handler dw ?
letra db ?,"$"
control dw 201
color db ?
ancho dw 0
BM dw 0
sizePunto dw 0
header label word

;Variables para abrir el archivo y crear asciiart
handleArt dw ?
charImp db 2eh
endl db 10,13

datos ends
;__________________________________________________________________________________

codigo segment

movReadPointer MACRO
    mov ah, 42h
    mov al, 0
    mov bx, handler
    xor cx, cx
    mov dx, control
    int 21h
    
ENDM

compareColor macro colorNum, charCode, siguiente
    cmp al, colorNum
    jne siguiente
    xor ax, ax
    mov al, charCode
    jmp salirGC
    
endm

pushDs MACRO
    mov ax, ds
    push ax
ENDM

cerrarArchivo MACRO archivo
    mov ah, 3eh
    mov bx, archivo
    int 21h ;Cerrar Archivo
ENDM

imprimir Macro letra
    mov ah, 9
    mov dx, offset letra
    int 21h
endm

ModoGrafico Macro
    mov ah, 00h ;Poner en modo gráfico
    mov al, 12h ;640 x 480 16 colores (VGA)
    int 10h
endM

InicializarSegmento Macro
    xor ax,ax
    mov ax, datos
    mov ds,  ax  
endM

Finaliza Macro
    mov ax ,4c00h
    int 21h
endM


;Params: color
;Devuele en al: byte por escribir
getChar proc
    mov bp, sp      ;Pone el bp en la pila
    mov ax, 4-2[bp]

    negro:
    compareColor 00h, 94, azul

    azul:
    compareColor 01h, 39, dorado

    dorado:
    compareColor 02h, 42, gris

    gris:
    compareColor 03h, 50, rojo

    rojo:
    compareColor 04h, 44, pink

    pink:
    compareColor 05h, 43, naranja

    naranja:
    compareColor 06h, 85, papaya

    papaya:
    compareColor 07h, 87, verde

    verde:
    compareColor 08h, 34, turquesa

    turquesa:
    compareColor 09h, 77, lima

    lima:
    compareColor 0ah, 78, menta
    
    menta:
    compareColor 0bh, 45, gris2

    gris2:
    compareColor 0ch, 46, morado

    morado:
    compareColor 0dh, 68, amarillo

    amarillo:
    compareColor 0eh, 61, blanco

    blanco:
    compareColor 0fh, 35, salirGC

    salirGC:
    ret 2
endp


;Params: ds, color, handle, offset charImp
;Devuele en ax: -
PintarAscii proc
    mov bp, sp      ;Pone el bp en la pila
    mov ax, 0ah-2[bp] ;Setea el data segment
    mov ds, ax
    
    mov ax, 8h-2[bp] ;Color
    push ax
    call getChar
    mov bp, sp
    mov di, 4-2[bp]
    mov Byte ptr ds:[di], al    ;Pone el char en la variable charImp

    mov ah, 40h     ;numDe int 21h
    mov bx, 6h-2[bp]; bx: file handle
    mov dx, di      ;Offset de lo que se va a escribir (ds:charImp o ds:dx)
    mov cx, 01h     ;Solo se escribe un byte
    int 21h



    ret 4*2
endp

;Params: ds, offset nombreArchivo
;Devuelve en ax: handle
CrearArchivo proc
    mov bp, sp      ;Pone el bp en la pila
    mov ax, 6-2[bp] ;Setea el data segment
    mov ds, ax

    mov ah, 3ch     ;Numero de funcion del dos de crear archivo
    mov dx, 4-2[bp] ;offset del nombmre que va a tener el archivo
    xor cx, cx      ;cx en 0 porque se crea un archivo normal
    int 21h 

    ret 2*2       ;restaura la pila quitando los dos parametros
endp


;TODO: Error abrir puede usar finalizar para terminar el programa
;Params: ds, offset archivo, offset handler, offset msgError1

AbrirArchivo proc
    mov ah, 3dh
    mov al, 0 ;Indicar que abrimos en modo lectura
    mov dx, offset archivo
    int 21h
    jc  errorAbrir
    mov handler, ax
    ret
    errorAbrir:
        imprimir msgError1
        ret
endp


;TODO:  ErrorMsg puede terminar el programa, cambiar jz Fin por call de fin ??
;Params: ds, handler, offset letra, offset msgError2

LeerArchivo proc
    xor dx, dx
    xor ax, ax
    mov ah, 3fh
    mov bx, handler
    mov dx, offset letra
    mov cx, 1
    int 21h
    jc ErrorMsg
    cmp ax, 0;significa que hemos llegado al final del archivo
    jz Fin
    ret
    ErrorMsg:
        imprimir msgError2
        ret
endP


; LeerHeader proc
;     xor dx, dx
;     xor ax, ax
;     mov ah, 3fh
;     mov bx, handler
;     mov dx, offset header
;     mov cx, 54
;     int 21h
;     jc ErrorMsg
;     cmp ax, 0;significa que hemos llegado al final del archivo
;     jz Fin_
;     mov ax, header[00h]
;     mov BM, ax
;     cmp BM, 4D42h
;     jnz mensajeInicio

;     mov ax, header[0Ah]
;     add ax, header[0Bh]
;     mov inicioDatos, ax

;     mov ax, header[012h]
;     add ax, header[014h]
;     mov anchoAux, ax
;     add anchoAux,1
;     cmp anchoAux, 640
;     jae mensajeAncho

;     mov ax, header[016h]
;     add ax, header[018h]
;     mov largo, ax
;     cmp largo, 480
;     jae mensajeLargo

;     mov ax, header[01ch]
;     cmp ax, 4
;     jnz mensajeError_

;     mov ah, 3eh
;     mov bx, handler
;     int 21h

;     ret

;     Fin_:
;         Finaliza
;     mensajeError_:
;         imprimir msgColor
;         Finaliza
;     mensajeLargo:
;         imprimir msgLargo
;         Finaliza
;     mensajeAncho:
;         imprimir msgAncho
;         Finaliza
;     mensajeInicio:
;         imprimir msgInicio
;         Finaliza
; endP



;TODO: call impri?, loop?
;Params leerArchivo: leerArchivo: ds, handler, offset letra, offset msgError2

;Params: leerArchivo: ds, handler, offset letra, offset msgError2, inicioDatos, control
leer proc 
    call LeerArchivo
    xor ax, ax
    mov ax, inicioDatos
    cmp control, ax
    jae impri
    inc control
    jmp leer
endP


impri:
    xor ax, ax
    mov ah, letra
    push ax
    jmp grafico

inicio:
    InicializarSegmento
    call AbrirArchivo

    pushDs
    push offset artAscii
    call CrearArchivo ;Devuelve el handle
    mov handleArt, ax

    ;call LeerHeader
    ModoGrafico
    movReadPointer
    call leer
    
Fin:
    CerrarArchivo handler
    CerrarArchivo handleArt

    mov ah, 01h ;Para esperar que ingrese una tecla
    int 21h
    ;Ponemos en modo letra
    mov ah, 00h ;Poner en modo letra
    mov al, 03h ;80x25x16 letra
    int 10h
    mov ax, 4c00h
    int 21h

AnchoIMG proc
    xor ax, ax
    mov ax, anchoAux
    cmp ancho, ax
    ja ajuste
    ret
    ajuste:
        mov ancho, 0
        sub largo, 1
        ; imprimir un new line en el archivo
        mov ah, 40h     ;numDe int 21h
        mov bx, handleart;  file handle
        mov dx, offset endl      ;Offset de lo que se va a escribir (ds:charImp o ds:dx)
        mov cx, 02h     ;se escriben dos bytes
        int 21h
        ret
endp




grafico:
    ;Primer pixel
    and ah,11110000b
    shr ah,4
    mov color, ah
    inc control

    ;Pinta primer pixel
    xor ax, ax
    xor dx, dx
    mov ah, 0ch ; escribe un pixel
    mov al, color; 
    mov dx,largo;en la largo 17
    mov cx, ancho
    xor bh,bh
    int 10h ;Inturrumpcion para pintar el pixel
    inc ancho
    
    xor ax, ax
    pushDs
    xor ax, ax
    mov al, color
    push ax
    push handleart
    lea ax, charimp
    push ax
    call PintarAscii

    call AnchoIMG

    ;Segundo pixel
    pop ax
    and ah,00001111b
    mov color, ah
    ;Pinta segundo pixel
    xor ax, ax
    xor dx, dx
    mov ah, 0ch ; escrine un pixel
    mov al, color;  
    mov dx,largo;en la largo 17
    mov cx, ancho
    xor bh,bh
    int 10h ;Inturrumpcion para pintar el pixel
    inc ancho
    
    xor ax, ax
    pushDs
    xor ax, ax
    mov al, color
    push ax
    push handleart
    lea ax, charimp
    push ax
    call PintarAscii

    call AnchoIMG

    jmp leer
codigo ends

end Inicio