include macroMtx.mtx                        ;Incluimos el archivo de macros que se van a utilizar a lo largo del programa

Datos Segment                               ;Inicio del segmento de datos
    ;--------------------------------Variables para el programa en general--------------------------------------------
    asciiControl db 20                      ;Para el ascii, escogemos el ascii segun se vaya aumentando esta variable
    text db "texto a imprimir en negro"
    bucleNum dw 65000                       ;Usarlo para el despliegue se haga lento 

    ;Colores                 
    verde db 0ah
    negro db 00h

    ;-------------------------------Explicacion del uso de las variables en los ciclos---------------------------------
    ;ControlFila : con estas variables nos aseguramos de que se imprima el caracter abajo. Se va aumentando 160 en 160. Se definen varias por que
    ;Necesitamos controlar el despliegue de varias columnas en tiempos diferentes.
    ;Validar : Variables que me indican el momento en que se debe comenzar a desplegar las siguientes columnas. Ya sea en negro o en verde
    ;Control : Estas variables me indican si ya recorri toda la fila

    ;#1
    controlFila dw 40                       
    control1 dw 0                           
    ;#2
    validar dw 0                            
    controlFila2 dw 16                       
    control2 dw 0                           
    ;#3
    validar3 dw 0                            
    controlFila3 dw 20                       
    ;#4
    validar4 dw 0                            
    controlFila4 dw 0                        
    ;#5
    controlFila5 dw 0
    validar5 dw 0
    ;#6
    controlFila0 dw 0
    validar0 dw 0

Datos ends                     

Codigo segment 

    assume CS:codigo, DS:datos          

despliegueVerde proc                        ;Procedimiento que llama a una macro para que pinte el ascci en verde, dependiendo de la posicion 
    pintarDi verde                          ;Que indica el Di
    ret
endP

despliegueNegro proc                        ;Procedimiento que llama a una macro para que pinte el ascci en negro, dependiendo de la posicion
    pintarDi negro                          ;Que indica el Di
    ret
endP

primerCiclo proc                           ;Procedimiento que despliega un conjunto de caracteres, la cantidad la define control1 y el lugar di
    inc asciiControl                       ;Se incrementa variable para que se escoja un caracter ascii diferente
    call despliegueVerde                   ;Llamamos al procedimiento que despliega en verde el caracter indicado por la variable anterior. Lo despliega en la posicion di
    add di, 40                             ;Se aumenta para que se despliegue en esa otra posicion 
    add control1, 40                       ;Variable controla la cantidad de despliegues. Que no sea mas de 120 xq si se sobrepasa se comienza a desplegar mal 
    cmp control1, 120                      ;Se hace la comparacion, si ya llego a la posicion 120 de la pantalla, para que finalice
    jnz primerCiclo                        ;Si todavia no llega, salta al mismo procedimiento

    mov control1, 0                        ;Inicializamos de nuevo la variable de control de la fila actual
    add controlFila, 160                   ;Sumamos 160 para que la siguiente vez que despliegue, lo haga abajo

    cmp controlFila, 3880                  ;Compara si ya recorrimos todo el largo
    jz ajustePrimerCiclo                   ;Si comparacion anterior es verdadera y ya recorrio toda el largo, ajusta los valores de las variables
    ret                                    ;Devuelve el control si todavia no llega al final

    ajustePrimerCiclo:
        xor di, di                         ;Limpia registro
        mov controlFila, 40                ;Le indicamos donde debe iniciar de nuevo
        mov control1, 0                    ;Inicializa variable que controla fila actual
        mov validar, 6                     ;Esta validacion se utiliza mas adelante en los despliegues de las otras columnas
        ret                                ;Se pone en esa cantidad para que la comparacion sea correcta y se sigan desplegando y hagan como una cadena de desplieges
endP

segundoCiclo proc                                            
    cmp validar, 5                         ;Comparacion para saber si ya se sobrepaso la fila 5 e iniciar el despliegue
    jng sale                               ;Si todavia no se llega y van por las primeras filas, se sale. Pero si ya la fila es mas grande a 5, se inicia con el despliegue
    
    inc asciiControl                       ;Se incrementa variable para que se escoja un caracter ascii diferente               
    call despliegueVerde                   ;Despliega ascii en color verde, la posicion la indica el di
    add di, 16                             ;Pasamos a la siguiente posicion de la misma fila
    add control2, 16                       ;Variable controla la cantidad de despliegues en la misma fila 
    cmp control2, 144                      ;Para que el despliegue no sea mayor a 144. Si se sobrepasa y no se controla, se despliega mal
    jnz segundoCiclo                       ;Si todavia no se llega al final de la fila actual, sigue desplegando

    mov control2, 0                        ;Inicializa variable de fila actual
    add controlFila2, 160                  ;Sumamos 160 para que la siguiente vez que despliegue, lo haga abajo
    cmp controlFila2, 3856                 ;Compara si ya recorrimos todo el largo       
    jz ajusteSegundoCiclo                  ;Si ya llegamos, salta a la etiqueta que setea variables necesarias para este despliegue              
    ret

    ajusteSegundoCiclo:
        mov controlFila2, 16               ;Le indicamos donde debe iniciar, en el siguiente despliegue. O sea en la primera fila
        mov control2, 0                    ;Inicializamos variable que controla la fila actual
        mov validar, 6                     ;Se setea en 6 para que en la comparacion del siguiente despliege, se cumpla y lo despliegue
    sale:
        ret                                ;Devolvemos el control
endP

tercerCiclo proc
    cmp validar3, 15                      ;Comparacion para saber si ya se sobrepaso la fila 15 e iniciar el despliegue
    jng sale2                             ;Si todavia no se llega y van por las primeras filas, se sale. Pero si ya la fila es mas grande a 15, se inicia con el despliegue
    
    inc asciiControl                      ;Se incrementa variable para que se escoja un caracter ascii diferente
    pintaTercero                          ;Macro que despliega un conjunto de caracteres en posiciones asignadas especificamente, esto para que no se despliegue mal. Despliega tanto en negro como en verde   
                              
    add controlFila3, 160                 ;Sumamos 160 para que la siguiente vez que despliegue, lo haga abajo
    cmp controlFila3, 3860                ;Compara si ya recorrimos todo el largo
    jz ajusteTercerCiclo                  ;Si ya llegamos, salta a la etiqueta que setea variables necesarias para este despliegue
    ret 
    ajusteTercerCiclo:
        mov controlFila3, 20              ;Le indicamos donde debe iniciar, en el siguiente despliegue. O sea en la primera fila
        mov validar3, 16                  ;Se setea en en esta cantidad para que en la comparacion del siguiente despliege, se cumpla
    sale2:
        ret                               ;Devolvemos el control       
endP

cuartoCiclo proc
    cmp validar4, 20                      ;Comparacion para saber si ya se sobrepaso la fila 20 e iniciar el despliegue
    jng sale3                             ;Si todavia no se llega y van por las primeras filas, se sale. Pero si ya la fila es mas grande a 20, se inicia con el despliegue
    inc asciiControl                      ;Se incrementa variable para que se escoja un caracter ascii diferente
  
    pintaCuarto                           ;Macro que despliega un conjunto de caracteres en posiciones asignadas especificamente, esto para que no se despliegue mal. Despliega tanto en negro como en verde

    add controlFila4, 160                 ;Sumamos 160 para que la siguiente vez que despliegue, lo haga abajo
    cmp controlFila4, 3840                ;Compara si ya recorrimos todo el largo
    jz ajusteCuartoCiclo                  ;Si ya llegamos, salta a la etiqueta que setea variables necesarias para este despliegue
    ret
    ajusteCuartoCiclo:
        mov controlFila4, 0               ;Le indicamos donde debe iniciar, en el siguiente despliegue. O sea en la primera fila
        mov validar4, 21                  ;Se setea en en esta cantidad para que en la comparacion del siguiente despliege, se cumpla
    sale3:
        ret                               ;Devolvemos el control   
endP

quintoCiclo proc
    cmp validar5, 35                     ;Comparacion para saber si ya se sobrepaso la fila 35 e iniciar el despliegue
    jng sale4                            ;Si todavia no se llega y van por las primeras filas, se sale. Pero si ya la fila es mas grande a 35, se inicia con el despliegue

    pintaQuinto                          ;Macro que despliega un conjunto de caracteres en posiciones asignadas especificamente, esto para que no se despliegue mal. Despliega en negro

    add controlFila5, 160                ;Sumamos 160 para que la siguiente vez que despliegue, lo haga abajo
    cmp controlFila5, 3840               ;Compara si ya recorrimos todo el largo
    jz ajusteQuintoCiclo                 ;Si ya llegamos, salta a la etiqueta que setea variables necesarias para este despliegue
    ret
    ajusteQuintoCiclo:
        mov controlFila5, 0              ;Le indicamos donde debe iniciar, en el siguiente despliegue. O sea en la primera fila
        mov validar5, 36                 ;Se setea en en esta cantidad para que en la comparacion del siguiente despliege, se cumpla
    sale4:
        ret                              ;Devolvemos el control 

;Esta ultima es para rellenar espacios que quedaron vacios
ultimoCiclo proc
    cmp validar0, 1                      ;Comparacion para saber si ya se sobrepaso la fila 1 e iniciar el despliegue
    jng sale0                            ;Si todavia no se llega y van por las primeras filas, se sale. Pero si ya la fila es mas grande a 1, se inicia con el despliegue
    inc asciiControl                     ;Se incrementa variable para que se escoja un caracter ascii diferente

    pintaUltimo                          ;Macro que despliega un conjunto de caracteres en posiciones asignadas especificamente, esto para que no se despliegue mal. Despliega en verde

    add controlFila0, 160                ;Sumamos 160 para que la siguiente vez que despliegue, lo haga abajo
    cmp controlFila0, 3840               ;Compara si ya recorrimos todo el largo
    jz ajusteUltimoCiclo                 ;Si ya llegamos, salta a la etiqueta que setea variables necesarias para este despliegue
    ret
    ajusteUltimoCiclo:
        mov controlFila0, 0              ;Le indicamos donde debe iniciar, en el siguiente despliegue. O sea en la primera fila
        mov validar0, 2                  ;Se setea en en esta cantidad para que en la comparacion del siguiente despliege, se cumpla
    sale0:
        ret                              ;Devolvemos el control
endP

    Inicio:
        ;Llamada a macros
        inicializarSD                           ;Inicializamos segmento de datos
        inicializarVideo                        ;Nos situamos en la memoria de video
        limpiarP                                ;Limpiamos pantalla

        Desplegar:
            mov di, controlFila                 ;Usamos el registro di. Le pasamos la posicion en donde debe iniciar    
            call primerCiclo                    ;Llamada al procedimiento de despliegue de la primera fila
            ;Como ya se desplego una fila con el procedimiento anterior, aumentamos variables que nos ayudaran a desplegar los siguientes caracteres
            ;Pero en el momento indicado, para que se vea desigual el despliegue y de el efecto de "lluvia matrix"
            inc validar
            inc validar3
            inc validar4
            inc validar5
            inc validar0

            ;Las siguientes llamadas hacen lo mismo que la llamada inicial anterior. Pasan la posicion donde debe iniciar a pintar el caracter al
            ;Registro di, pero estas se controlan con las variables "validar" anteriormente definidas. Pues cada uno llama a un procedimiento 
            ;Que pregunta si ya es momento de desplegar, si no, se sale y pasa a la siguiente llamada y asi sucesivamente hasta llegar al 
            ;jmp que vuelve a saltar a la etiqueta desplegar, por lo tanto hace un ciclo infinito, para que se haga la animacion.

            mov di, controlFila2               
            call segundoCiclo

            mov di, controlFila3
            call tercerCiclo

            mov di, controlFila4
            call cuartoCiclo

            mov di, controlFila5
            call quintoCiclo

            mov di, controlFila0
            call ultimoCiclo

            esperarMacro                        ;Macro que sirve para que la animacion vaya mas lento. Hace varios ciclos

            jmp Desplegar

Codigo ends
    end inicio                          ;Le indicamos al programa que comience en la etiqueta "Inicio"
