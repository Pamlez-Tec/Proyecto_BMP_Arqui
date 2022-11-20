include macroBMP.bmp            ;Incluimos macro

Assume cs:CODIGO, ds:DATOS      ;Le indicamos cual registro pertenece un segmento

DATOS segment                   ;Inicio del segmento de datos

;NOMBRE DE LA IMAGEN POR DEFECTO y NOMBRE DEL ARCHIVO TXT PARA EL ART ASCII
archivo db "playa.bmp",0        ;BMP debe estar en carpeta BIN
artAscii db "art.txt",0         ;Nombre del archivo por crear

;Variables necesarias para representar la imagen
inicioDatos dw 0                ;Donde inician los datos del BMP, se toma del header, de leer el archivo BMP
largo dw 0                      ;Largo de la imagen, tambien se toma del header
anchoAux dw 0                   ;ancho de la image, se toma del header

;Mensajes para imprimir. El 10,13, es para hacer un salto y el $ es para que solo imprima hasta ahi el texto.
msgColor db "Cantidad de color no es correcta $"
msgBMP db "No es imagen BMP $"
msgError1 db 10,13, "Error no se pudo abrir el archivo $" 
msgError2 db 10,13, "Error no se pudo leer el archivo $"

;Variables para la lectura del archivo
handler dw ? 
letra db ?,"$"                  ;Guarda la info del BMP
control dw 53                   ;Esta variable funciona para para que se vaya incrementando y desplegar la imagen hasta que sea igual al inicio de los datos. Inicia en 53 por haber sacado el header primero
color db ?                      ;Variable que guarda el color a desplegar
ancho dw 0                      ;Esta variable sirve para que se vaya incrementando a medida que se grafica la imagen y cuando llegue al anchoAux vuelve a inicial
header db 54 dup("$"), "$"      ;Esta variable guarda los primeros 53 bytes del BMP, donde esta toda la informacion necesaria (Ancho/Alto/Inicio de datos/Colores/TipoDeImagen)

;Variables para abrir el archivo y crear asciiart
handleArt dw ?
charImp db 2eh
endl db 10,13

;Este mensaje es la ayuda que de despliega cuando se pide o cuando el color no es el indicado
ayuda  db "                                               ", 10,13,
    db "                        AYUDA DEL PROYECTO BMP DE 16 COLORES",10,13,
    db "                                               ", 10,13,
    db "-> Para ejecutar se debe escribir: bmp2asc [/A o /a] [/? o /h o /H] [archivo]", 10, 13,
    db "                                               ", 10,13,
    db "-> bmp2asc: es el nombre del programa",10,13,
    db "                                               ", 10,13,
    db "-> Si se escribe solamente  bmp2asc, se despliega una imagen por defecto",10,13,
    db "                                               ", 10,13,
    db "-> Si digita bmp2asc [/A o /a], se convierte la imagen por defecto en ASCII", 10,13,
    db "                                               ", 10,13,
    db "-> Si digita bmp2asc [ /? o /h o /H], se despliega de nuevo esta ayuda", 10,13,
    db "                                               ", 10,13,
    db "-> Si digita bmp2asc [archivo], se despliega el archivo BMP indicado", 10,13,
    db "                                               ", 10,13,
    db "-> Si digita bmp2asc [/A o /a][archivo], se despliega el archivo BMP indicado y en ASCII", 10,13,
    db "                                               ", 10,13,
    db "==============================================", 10,13,
    db "                                               ", 10,13,
    db "$", 10,13,

DATOS ends ;Final del segmento de datos

codigo segment ;Inicio del segmento de codigo

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

    ret 2*2         ;restaura la pila quitando los dos parametros
endp


;Params: ds, offset archivo, offset handler, offset msgError1
AbrirArchivo proc
    mov ah, 3dh             ;Asiganamos a ah el codigo para abrir un fichero
    mov al, 0               ;Indicar que abrimos en modo lectura
    mov dx, offset archivo  ;Sacamos el desplazamiento del archivo a leer
    int 21h                 ;Ejecutamos la ineterrupcion para abrir el archivo
    jc  errorAbrir          ;Si hay un error la bandera del carry se activa y salta a la etiqueta "errorAbrir"
    mov handler, ax         ;Si todo esta bien, en ax estaria el manejador del archivo
    ret                     ;Devolvemos control a SO
    errorAbrir:             ;Etiqueta que llama a una macro y devuelve el control al SO
        imprimir msgError1  ;Macro que recibe como parametro el mensaje de error, que no puede abrir un archivo
        Finaliza
endp

;TODO:  ErrorMsg puede terminar el programa, cambiar jz Fin por call de fin ??
;Params: ds, handler, offset letra, offset msgError2
LeerArchivo proc
    xor dx, dx              ;Limpiamos dx
    xor ax, ax              ;Limpiamos ax
    mov ah, 3fh             ;Pasamos a ah el comando para leer un archivo
    mov bx, handler
    mov dx, offset letra    ;Sacamos el desplazamiento del la variable donde se pondran los caracteres leidos
    mov cx, 1               ;Numero de bytes a leer. En este caso solo uno, para poder imprimir los dos colores
    int 21h                 ;Aplicamos la interrupcion para que lea el archivo
    jc ErrorMsg             ;Si hay un error, bandera carry se activa y salta a la etiqueta "ErrorMsg"
    cmp ax, 0               ;Comparamos, esto significa que hemos llegado al final del archivo
    jz FinLeer              ;Si la anterior comparacion es = bandera ZF se activa y salta a la etiqueta 
    ret                     ;Si nada de lo anterior se cumple, se devuelve control al SO

    FinLeer:                ;Etiqueta que cierra los archivos
        CerrarArchivo handler
        CerrarArchivo handleArt
        mov ah, 3eh         ;Se pasa a ah el comando para cerrar el archivo
        mov bx, handler 
        int 21h             ;Se ejecuta la interrupcion para que vaya y lea ah y cierre el archivo
        mov ah, 01h         ;Para esperar que ingrese una tecla
        int 21h
        ;Ponemos en modo texto
        mov ah, 00h         ;Poner en modo texto
        mov al, 03h         ;80x25x16 texto
        int 10h             ;Interrupcion para poner el modo video (en este caso soporta texto, no grafico)
        mov ax, 4c00h       ;Codigo para finalizar el programa
        int 21h             ;Interrupcion que lee ah y cierra el programa
    ErrorMsg:               ;Etiqueta que llama a una macro y devuelve control al SO
        imprimir msgError2  ;Macro que imprime mensaje de error
        Finaliza 
        ret                 ;Devuelce control al SO
endP

;Se necesita: INT 21h---> ah=3fh, bx=handle, cx=numero de bytes, dx=offset de una variable 
LeerHeader proc 
    xor dx, dx              ;Limpiamos registro dx
    xor ax, ax              ;Limpiamos registro ax
    mov ah, 3fh             ;Pasamos a ah el comando para leer un archivo
    mov bx, handler ;
    mov dx, offset header   ;Sacamos el desplazamiento del la variable(que esta en segmento de datos) donde se pondran los caracteres leidos
    mov cx, 53              ;Numero de bytes a leer del archivo
    int 21h                 ;Leer ah y ejecuta la interrupcion para leer el caracter.
    jc ErrorHeader          ;Si hay un error en la lectura el acarreo se activa y hace un salto a la etiqueta "ErrorHeader" 
;-----------------------------------------------------------------
; INICIO DE LAS COMPARACIONES:
;Como VAR HEADER esta guradando los 53 bytes del header del bmp
;Se guarda al primero al y luego ah, por el orden little-endian
;-----------------------------------------------------------------
;--------------------------------
;COMPARAR SI ES IMAGEN BMP
;--------------------------------  
    mov al, header+0        ;Tomamos el byte 0 del header
    mov ah, header+1        ;Tomamos el byte 1 del header
    cmp ax, 4D42h           ;compara si es una imagen BM
    jnz mensajeBMP          ;Si la comparacion no es igual, salta a la etiqueta del error "mensajeBMP" y finaliza el programa.
;--------------------------------
;COMPARAR SI ES DE 16 COLORES
;-------------------------------- 
    mov al, header+28       ;Tomamos el byte 28 del header
    mov ah, header+29       ;Tomamos el byte 29 del header
    cmp ax, 0004h           ;compara si es una imagen con 16 colores. Se compara con 0004h xq 16 colores ocupan 4bits. Log2(16)
    jnz mensajeColor        ;Si la comparacion no es igual, salta a la etiqueta del error "mensajeColor", despliega la ayuda y finaliza el programa. 
;------------------------------------------------------------------------------------------------------------------
;Si las comparaciones anteriores estan bien, seguidamente se guardan los datos necesarios para desplegar la imagen.
; Ancho - Alto - Inicio de los datos del BMP
;------------------------------------------------------------------------------------------------------------------
    ;INICIO DE LOS DATOS
    mov al, header+10       ;Tomamos el byte 10 del header
    mov ah, header+11       ;Tomamos el byte 11 del header
    mov inicioDatos, ax     ;ax ahora tiene el inicio de los datos del BMP, se los pasa a la variable inicioDatos.
    ;ANCHO
    mov al, header+18       ;Tomamos el byte 18 del header
    mov ah, header+19       ;Tomamos el byte 19 del header
    mov anchoAux, ax        ;ax ahora tiene el ancho del BMP y se lo pasa a la variable anchoAux que nos ayudara a tenerla como referencia para despplegar BMP
    dec anchoAux            ;Disminuimos 1 al ancho xq a la hora graficarlo, simpre se grafica el primer pixel y hay que decrementarlo para que se despliegue bien
    ;ALTO
    mov al, header+22       ;Tomamos el byte 10 del header
    mov ah, header+23       ;Tomamos el byte 11 del header
    mov largo, ax           ;ax ahora tiene el largo del BMP, se lo pasa a la variable largo.
    ret                     ;Devolvemos control al SO

    ErrorHeader:            ;Etiqueta que manda a llamar a una macro pasando como parametro el ensaje de error, en donde no se puede leer el archivo 
        imprimir msgError2  ;Macro que recibe el mensaje de error.
        Finaliza
    mensajeColor:           ;Etiqueta que manda a llamar a 3 macros, la primera que mesanje de error de color, la otra despliega la ayuda y la ultima finaliza programa
        imprimir msgColor   ;Macro que imprime el mensaje de error del color
        imprimir ayuda      ;Macro que despliega la ayuda
        Finaliza            ;Macro que termina el programa
    mensajeBMP:             ;Etiqueta que llama a dos macros
        imprimir msgBMP     ;Macro que imprime mensaje de error indicando que el archivo no es BMP
        Finaliza            ;Macro que finaliza el programa
endP                       

;TODO: call impri?, loop?
;Params leerArchivo: leerArchivo: ds, handler, offset letra, offset msgError2

;Params: leerArchivo: ds, handler, offset letra, offset msgError2, inicioDatos, control
Leer proc 
    call LeerArchivo        ;Se llama al procedimiento para leer un archivo
    xor ax, ax              ;Limpiamos ax
    mov ax, inicioDatos     ;Colocamos en ax en donde iniciaran los datos del BMP para desplegarlo
    cmp control, ax         ;comparamos si la variable control, que inicialmente esta en 53, es igual al valor donde iniciaran los datos para pintarlos
    jae ImprimirPixel       ;Salta si bandera CF se activa y se la comparacion anterior es igual o mayor. Si es mayor o igual quiere decir que ya llegamos a los datos que nos interesan del bmp y comenzaremos a pintar pixeles
    inc control             ;incrementamos para que control vaya moviendose y pueda alcanzar el inicio de los datos a desplegar
    jmp Leer                ;volvemos a ejecutar el ciclo, hasta que comparacion se cumpla
endP

;Procedimiento que ajusta el ancho de la imagen 
AnchoIMG proc
    xor ax, ax              ;Limpiamos registro ax
    mov ax, anchoAux        ;Movemos al registro ax el anchoAux, este contiene el ancho original que tiene la imagen
    cmp ancho, ax           ;Compara si el ancho actual que tiene la imagen al desplegar los pixeles ya alcanzo su ancho original
    ja ajuste               ;Salta si ancho es mayor a anchoAux.
    ret                     ;Devolvemos control al SO si comparacion no se cumple, por lo que no se hace el ajuste
    ajuste:                 ;Inicio de la etiqueta ajuste
        mov ancho, 0        ;Ajustamos el ancho actual, para qe vuelva a 0 e inicie de nuevo a pintar 
        dec largo           ;Decrementa el largo en 1 para que la fila se mueva y pinte en la columna 0 pero en la fila (fila-1)
        ; imprimir un new line en el archivo
        mov ah, 40h         ;numDe int 21h
        mov bx, handleart   ;file handle
        mov dx, offset endl ;Offset de lo que se va a escribir (ds:charImp o ds:dx)
        mov cx, 02h         ;se escriben dos bytes
        int 21h
        ret
endp

;Prodimeinto que pinta un pixel de un color, en modo grafico
PintarPixel proc 
    xor ax, ax              ;Limpiamos registro 
    xor dx, dx              ;Limpiamos registro
    mov ah, 0ch             ;escribe un pixel
    mov al, color; 
    mov dx,largo            ;en la largo 17
    mov cx, ancho
    xor bh,bh
    int 10h                 ;Inturrumpcion para pintar el pixel
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
    ret

endP

;Funcion que guarda pixel optimo para desplegar y salta a etiqueta para pintar pixel
ImprimirPixel proc
    xor ax, ax              ;Limpia ax
    mov ah, letra           ;Guarda pixel en la parte alta del registro ax
    push ax                 ;Mete en la pila ax para guardar el pixel 
    jmp Grafico             ;Salta a la etiqueta para pintar el pixel
endP

;En esta etiqueta se pintan los pixeles del byte del archivo.
Grafico proc
    ;Primer pixel
    primerPixel color, control

    ;Pinta primer pixel
    call PintarPixel

    ;Segundo pixel
    segundoPixel color
    ;Pinta segundo pixel
    call PintarPixel
    jmp Leer
    ret 
endP

;Etiqueta en donde inicia el programa, se define al final.
Inicio:
    InicializarSegmento datos       ;Llama a la macro que inicializa el segmento de datos
    call AbrirArchivo               ;Llama al procedimiento que abre un archivo
    pushDs
    push offset artAscii    
    call CrearArchivo               ;Devuelve el handle
    mov handleArt, ax
    call LeerHeader                 ;Llama al procedimiento donde lee el header del BMP
    ModoGrafico                     ;Se llama a la macro que inicializa el modo grafico
    movReadPointer handler, control 
    call Leer                       ;Llamamos al procedimiento que lee el archivo BMP

codigo ends

end Inicio
