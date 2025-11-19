title "Proyecto: Galaga" ;codigo opcional. Descripcion breve del programa, el texto entrecomillado se imprime como cabecera en cada página de código
	.model small	;directiva de modelo de memoria, small => 64KB para memoria de programa y 64KB para memoria de datos
	.386			;directiva para indicar version del procesador
	.stack 128 		;Define el tamano del segmento de stack, se mide en bytes
	.data			;Definicion del segmento de datos
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Definición de constantes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Valor ASCII de caracteres para el marco del programa
marcoEsqInfIzq 		equ 	200d 	;'╚'
marcoEsqInfDer 		equ 	188d	;'╝'
marcoEsqSupDer 		equ 	187d	;'╗'
marcoEsqSupIzq 		equ 	201d 	;'╔'
marcoCruceVerSup	equ		203d	;'╦'
marcoCruceHorDer	equ 	185d 	;'╣'
marcoCruceVerInf	equ		202d	;'╩'
marcoCruceHorIzq	equ 	204d 	;'╠'
marcoCruce 			equ		206d	;'╬'
marcoHor 			equ 	205d 	;'═'
marcoVer 			equ 	186d 	;'║'
;Atributos de color de BIOS
;Valores de color para carácter
cNegro 			equ		00h
cAzul 			equ		01h
cVerde 			equ 	02h
cCyan 			equ 	03h
cRojo 			equ 	04h
cMagenta 		equ		05h
cCafe 			equ 	06h
cGrisClaro		equ		07h
cGrisOscuro		equ		08h
cAzulClaro		equ		09h
cVerdeClaro		equ		0Ah
cCyanClaro		equ		0Bh
cRojoClaro		equ		0Ch
cMagentaClaro	equ		0Dh
cAmarillo 		equ		0Eh
cBlanco 		equ		0Fh
;Valores de color para fondo de carácter
bgNegro 		equ		00h
bgAzul 			equ		10h
bgVerde 		equ 	20h
bgCyan 			equ 	30h
bgRojo 			equ 	40h
bgMagenta 		equ		50h
bgCafe 			equ 	60h
bgGrisClaro		equ		70h
bgGrisOscuro	equ		80h
bgAzulClaro		equ		90h
bgVerdeClaro	equ		0A0h
bgCyanClaro		equ		0B0h
bgRojoClaro		equ		0C0h
bgMagentaClaro	equ		0D0h
bgAmarillo 		equ		0E0h
bgBlanco 		equ		0F0h
;Valores para delimitar el área de juego
lim_superior 	equ		1
lim_inferior 	equ		23
lim_izquierdo 	equ		1
lim_derecho 	equ		39
;Valores de referencia para la posición inicial del jugador
ini_columna 	equ 	lim_derecho/2
ini_renglon 	equ 	22

;Valores para la posición de los controles e indicadores dentro del juego
;Lives
lives_col 		equ  	lim_derecho+7
lives_ren 		equ  	4

;Scores
hiscore_ren	 	equ 	11
hiscore_col 	equ 	lim_derecho+7
score_ren	 	equ 	13
score_col 		equ 	lim_derecho+7

;Botón STOP
stop_col 		equ 	lim_derecho+10
stop_ren 		equ 	19
stop_izq 		equ 	stop_col-1
stop_der 		equ 	stop_col+1
stop_sup 		equ 	stop_ren-1
stop_inf 		equ 	stop_ren+1

;Botón PAUSE
pause_col 		equ 	stop_col+10
pause_ren 		equ 	19
pause_izq 		equ 	pause_col-1
pause_der 		equ 	pause_col+1
pause_sup 		equ 	pause_ren-1
pause_inf 		equ 	pause_ren+1

;Botón PLAY
play_col 		equ 	pause_col+10
play_ren 		equ 	19
play_izq 		equ 	play_col-1
play_der 		equ 	play_col+1
play_sup 		equ 	play_ren-1
play_inf 		equ 	play_ren+1

;Botones para movimiento ' <- ' ' -> ' ' space ' 

tecla_izq       equ     4Bh
tecla_der		equ     4Dh

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;////////////////////////////////////////////////////
;Definición de variables
;////////////////////////////////////////////////////
titulo 			db 		"GALAGA"
scoreStr 		db 		"SCORE"
hiscoreStr		db 		"HI-SCORE"
livesStr		db 		"LIVES"
blank			db 		"     "
player_lives 	db 		3
player_score 	dw 		0
player_hiscore 	dw 		0
player_dead		db      0

player_col		db 		ini_columna 	;posicion en columna del jugador
player_ren		db 		ini_renglon 	;posicion en renglon del jugador

enemy_col		db 		ini_columna 	;posicion en columna del enemigo
enemy_ren		db 		3 				;posicion en renglon del enemigo
temp_enemy_ren  db      ?				;variable para guardar el renglon inicial del enemigo
enemy_sen		db      0  				;sentido actual del enemigo

col_aux 		db 		0  		;variable auxiliar para operaciones con posicion - columna
ren_aux 		db 		0 		;variable auxiliar para operaciones con posicion - renglon

conta 			db 		0 		;contador

entrada_tecla   db      ?		;Tecla ingresada por el usuario 

;; Variables de ayuda para lectura de tiempo del sistema
tick_ms			dw 		55 		;55 ms por cada tick del sistema, esta variable se usa para operación de MUL convertir ticks a segundos
mil		        dw		1000 	;1000 auxiliar para operación DIV entre 1000
diez 			dw 		10 		;10 auxiliar para operaciones
sesenta			db 		60 		;60 auxiliar para operaciones
status 			db 		0 		;0 stop, 1 play, 2 pause
t_mov_enem 	        dw		0 		;Variable para almacenar el número de ticks del sistema y usarlo como referencia
t_atacar_enem           dw              0 		;Tiempo que tarda en hacer un movimiento para bajo la nave enemiga
t_jug_muerto            dw              0    	;Tiempo que transcurre una vez que el jugador muere

;Variables que sirven de parámetros de entrada para el procedimiento IMPRIME_BOTON
boton_caracter 	db 		0
boton_renglon 	db 		0
boton_columna 	db 		0
boton_color		db 		0
boton_bg_color	db 		0


;Auxiliar para calculo de coordenadas del mouse en modo Texto
ocho			db 		8
;Cuando el driver del mouse no está disponible
no_mouse		db 	'No se encuentra driver de mouse. Presione [enter] para salir$'

;////////////////////////////////////////////////////

;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;Macros;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;
;clear - Limpia pantalla
clear macro
	mov ax,0003h 	;ah = 00h, selecciona modo video
					;al = 03h. Modo texto, 16 colores
	int 10h		;llama interrupcion 10h con opcion 00h. 
				;Establece modo de video limpiando pantalla
endm

;posiciona_cursor - Cambia la posición del cursor a la especificada con 'renglon' y 'columna' 
posiciona_cursor macro renglon,columna
	mov dh,renglon	;dh = renglon
	mov dl,columna	;dl = columna
	mov bx,0
	mov ax,0200h 	;preparar ax para interrupcion, opcion 02h
	int 10h 		;interrupcion 10h y opcion 02h. Cambia posicion del cursor
endm 

;inicializa_ds_es - Inicializa el valor del registro DS y ES
inicializa_ds_es 	macro
	mov ax,@data
	mov ds,ax
	mov es,ax 		;Este registro se va a usar, junto con BP, para imprimir cadenas utilizando interrupción 10h
endm

;muestra_cursor_mouse - Establece la visibilidad del cursor del mouser
muestra_cursor_mouse	macro
	mov ax,1		;opcion 0001h
	int 33h			;int 33h para manejo del mouse. Opcion AX=0001h
					;Habilita la visibilidad del cursor del mouse en el programa
endm

;posiciona_cursor_mouse - Establece la posición inicial del cursor del mouse
posiciona_cursor_mouse	macro columna,renglon
	mov dx,renglon
	mov cx,columna
	mov ax,4		;opcion 0004h
	int 33h			;int 33h para manejo del mouse. Opcion AX=0001h
					;Habilita la visibilidad del cursor del mouse en el programa
endm

;oculta_cursor_teclado - Oculta la visibilidad del cursor del teclado
oculta_cursor_teclado	macro
	mov ah,01h 		;Opcion 01h
	mov cx,2607h 	;Parametro necesario para ocultar cursor
	int 10h 		;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
endm

;apaga_cursor_parpadeo - Deshabilita el parpadeo del cursor cuando se imprimen caracteres con fondo de color
;Habilita 16 colores de fondo
apaga_cursor_parpadeo	macro
	mov ax,1003h 		;Opcion 1003h
	xor bl,bl 			;BL = 0, parámetro para int 10h opción 1003h
  	int 10h 			;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
endm

;imprime_caracter_color - Imprime un caracter de cierto color en pantalla, especificado por 'caracter', 'color' y 'bg_color'. 
;Los colores disponibles están en la lista a continuacion;
; Colores:
; 0h: Negro
; 1h: Azul
; 2h: Verde
; 3h: Cyan
; 4h: Rojo
; 5h: Magenta
; 6h: Cafe
; 7h: Gris Claro
; 8h: Gris Oscuro
; 9h: Azul Claro
; Ah: Verde Claro
; Bh: Cyan Claro
; Ch: Rojo Claro
; Dh: Magenta Claro
; Eh: Amarillo
; Fh: Blanco
; utiliza int 10h opcion 09h
; 'caracter' - caracter que se va a imprimir
; 'color' - color que tomará el caracter
; 'bg_color' - color de fondo para el carácter en la celda
; Cuando se define el color del carácter, éste se hace en el registro BL:
; La parte baja de BL (los 4 bits menos significativos) define el color del carácter
; La parte alta de BL (los 4 bits más significativos) define el color de fondo "background" del carácter
imprime_caracter_color macro caracter,color,bg_color
	mov ah,09h				;preparar AH para interrupcion, opcion 09h
	mov al,caracter 		;AL = caracter a imprimir
	mov bh,0				;BH = numero de pagina
	mov bl,color 			
	or bl,bg_color 			;BL = color del caracter
							;'color' define los 4 bits menos significativos 
							;'bg_color' define los 4 bits más significativos 
	mov cx,1				;CX = numero de veces que se imprime el caracter
							;CX es un argumento necesario para opcion 09h de int 10h
	int 10h 				;int 10h, AH=09h, imprime el caracter en AL con el color BL
endm

;imprime_caracter_color - Imprime un caracter de cierto color en pantalla, especificado por 'caracter', 'color' y 'bg_color'. 
; utiliza int 10h opcion 09h
; 'cadena' - nombre de la cadena en memoria que se va a imprimir
; 'long_cadena' - longitud (en caracteres) de la cadena a imprimir
; 'color' - color que tomarán los caracteres de la cadena
; 'bg_color' - color de fondo para los caracteres en la cadena
imprime_cadena_color macro cadena,long_cadena,color,bg_color
	mov ah,13h				;preparar AH para interrupcion, opcion 13h
	lea bp,cadena 			;BP como apuntador a la cadena a imprimir
	mov bh,0				;BH = numero de pagina
	mov bl,color 			
	or bl,bg_color 			;BL = color del caracter
							;'color' define los 4 bits menos significativos 
							;'bg_color' define los 4 bits más significativos 
	mov cx,long_cadena		;CX = longitud de la cadena, se tomarán este número de localidades a partir del apuntador a la cadena
	int 10h 				;int 10h, AH=09h, imprime el caracter en AL con el color BL
endm

;lee_mouse - Revisa el estado del mouse
;Devuelve:
;;BX - estado de los botones
;;;Si BX = 0000h, ningun boton presionado
;;;Si BX = 0001h, boton izquierdo presionado
;;;Si BX = 0002h, boton derecho presionado
;;;Si BX = 0003h, boton izquierdo y derecho presionados
; (400,120) => 80x25 =>Columna: 400 x 80 / 640 = 50; Renglon: (120 x 25 / 200) = 15 => 50,15
;;CX - columna en la que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
;;DX - renglon en el que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
lee_mouse	macro
	mov ax,0003h
	int 33h
endm

;comprueba_mouse - Revisa si el driver del mouse existe
comprueba_mouse 	macro
	mov ax,0		;opcion 0
	int 33h			;llama interrupcion 33h para manejo del mouse, devuelve un valor en AX
					;Si AX = 0000h, no existe el driver. Si AX = FFFFh, existe driver
endm
;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;Fin Macros;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;

	.code
inicio:					;etiqueta inicio
	inicializa_ds_es
	comprueba_mouse		;macro para revisar driver de mouse
	xor ax,0FFFFh		;compara el valor de AX con FFFFh, si el resultado es zero, entonces existe el driver de mouse
	jz imprime_ui		;Si existe el driver del mouse, entonces salta a 'imprime_ui'
	;Si no existe el driver del mouse entonces se muestra un mensaje
	lea dx,[no_mouse]
	mov ax,0900h	;opcion 9 para interrupcion 21h
	int 21h			;interrupcion 21h. Imprime cadena.
	jmp teclado		;salta a 'teclado'

imprime_ui:
	clear 					;limpia pantalla
	oculta_cursor_teclado	;oculta cursor del mouse
	apaga_cursor_parpadeo 	;Deshabilita parpadeo del cursor
	call DIBUJA_UI 			;procedimiento que dibuja marco de la interfaz
	muestra_cursor_mouse 	;hace visible el cursor del mouse


;En "mouse_no_clic" se revisa que el boton izquierdo del mouse no esté presionado
;Si el botón está suelto, continúa a la sección "mouse"
;si no, se mantiene indefinidamente en "mouse_no_clic" hasta que se suelte
mouse_no_clic:
	lee_mouse
	test bx,0001h ;Lee el mouse y avanza hasta que se haga clic en el boton izquierdo
	jz mouse_no_clic
mouse:
	lee_mouse
conversion_mouse:
	;Leer la posicion del mouse y hacer la conversion a resolucion
	;80x25 (columnas x renglones) en modo texto
	mov ax,dx 			;Copia DX en AX. DX es un valor entre 0 y 199 (renglon)
	div [ocho] 			;Division de 8 bits
						;divide el valor del renglon en resolucion 640x200 en donde se encuentra el mouse
						;para obtener el valor correspondiente en resolucion 80x25
	xor ah,ah 			;Descartar el residuo de la division anterior
	mov dx,ax 			;Copia AX en DX. AX es un valor entre 0 y 24 (renglon)

	mov ax,cx 			;Copia CX en AX. CX es un valor entre 0 y 639 (columna)
	div [ocho] 			;Division de 8 bits
						;divide el valor de la columna en resolucion 640x200 en donde se encuentra el mouse
						;pa ra obtener el valor correspondiente en resolucion 80x25
	xor ah,ah 			;Descartar el residuo de la division anterior
	mov cx,ax 			;Copia AX en CX. AX es un valor entre 0 y 79 (columna)

	;Aquí se revisa si se hizo clic en el botón izquierdo
	test bx,0001h 		;Para revisar si el boton izquierdo del mouse fue presionado
	jz presionar_play 			;Si el boton izquierdo no fue presionado, vuelve a leer el estado del mouse

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Aqui va la lógica de la posicion del mouse;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Si el mouse fue presionado en el renglon 0
	;se va a revisar si fue dentro del boton [X]
	cmp dx,0
	je boton_x

	;Si el mouse fue presionado en el renglón del botón PLAY
	;se va a revisar si fue en el boton [|>]
	cmp dx, play_ren + 1 
	jne presionar_play

	cmp cx, play_col + 1
	jne presionar_play

	jmp comenzar_juego

presionar_play:
	lee_mouse               ; Leer el nuevo estado del mouse
    test bx,0001h           
    jnz presionar_play      
    jmp mouse_no_clic

boton_x:				;Si el botón X fue presionado antes de comenzar a jugar, salir del juego
	cmp cx,76
	jl presionar_play
	cmp cx,78
	jg presionar_play
	jmp salir


;Lógica para revisar si el mouse fue presionado en [X]
;[X] se encuentra en renglon 0 y entre columnas 76 y 78

mas_botones:
	jmp presionar_play



;Si no se encontró el driver del mouse, muestra un mensaje y el usuario debe salir tecleando [enter]
teclado:
	mov ah,08h
	int 21h
	cmp al,0Dh		;compara la entrada de teclado si fue [enter]
	jnz teclado 	;Sale del ciclo hasta que presiona la tecla [enter]

;====================================================
; Inicio de juego
;====================================================

comenzar_juego:
    lee_mouse           ; leer estado y posición del mouse
    
    shr dx, 3           ; ajustar columna a bloques
    shr cx, 3           ; ajustar renglón a bloques
    
    test bx, 0001h      ; botón izquierdo presionado
    jz continuar        ; si no, seguir juego
    
    cmp dx, 0           ; columna del botón X
    jne continuar       ; fuera de rango, seguir juego
    
    cmp cx, 76          ; límite superior del botón X
    jl continuar        ; fuera de rango, seguir juego
    
    cmp cx, 78          ; límite inferior del botón X
    jg continuar        ; fuera de rango, seguir juego
    
    jmp salir           ; clic sobre el botón X → salir

continuar:
    call LEER_TECLADO    
    call MOV_NAVE
    call MOV_ENEMIGO
    call CHOQUE
    call REVIVIR_JUGADOR
    jmp comenzar_juego

salir:				;inicia etiqueta salir
	clear 			;limpia pantalla
	mov ax,4C00h	;AH = 4Ch, opción para terminar programa, AL = 0 Exit Code, código devuelto al finalizar el programa
	int 21h			;señal 21h de interrupción, pasa el control al sistema operativo

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;PROCEDIMIENTOS;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	DIBUJA_UI proc
		;imprimir esquina superior izquierda del marco
		posiciona_cursor 0,0
		imprime_caracter_color marcoEsqSupIzq,cAmarillo,bgNegro
		
		;imprimir esquina superior derecha del marco
		posiciona_cursor 0,79
		imprime_caracter_color marcoEsqSupDer,cAmarillo,bgNegro
		
		;imprimir esquina inferior izquierda del marco
		posiciona_cursor 24,0
		imprime_caracter_color marcoEsqInfIzq,cAmarillo,bgNegro
		
		;imprimir esquina inferior derecha del marco
		posiciona_cursor 24,79
		imprime_caracter_color marcoEsqInfDer,cAmarillo,bgNegro
		
		;imprimir marcos horizontales, superior e inferior
		mov cx,78 		;CX = 004Eh => CH = 00h, CL = 4Eh 
	marcos_horizontales:
		mov [col_aux],cl
		;Superior
		posiciona_cursor 0,[col_aux]
		imprime_caracter_color marcoHor,cAmarillo,bgNegro
		;Inferior
		posiciona_cursor 24,[col_aux]
		imprime_caracter_color marcoHor,cAmarillo,bgNegro
		
		mov cl,[col_aux]
		loop marcos_horizontales

		;imprimir marcos verticales, derecho e izquierdo
		mov cx,23 		;CX = 0017h => CH = 00h, CL = 17h 
	marcos_verticales:
		mov [ren_aux],cl
		;Izquierdo
		posiciona_cursor [ren_aux],0
		imprime_caracter_color marcoVer,cAmarillo,bgNegro
		;Inferior
		posiciona_cursor [ren_aux],79
		imprime_caracter_color marcoVer,cAmarillo,bgNegro
		;Limite mouse
		posiciona_cursor [ren_aux],lim_derecho+1
		imprime_caracter_color marcoVer,cAmarillo,bgNegro

		mov cl,[ren_aux]
		loop marcos_verticales

		;imprimir marcos horizontales internos
		mov cx,79-lim_derecho-1 		
	marcos_horizontales_internos:
		push cx
		mov [col_aux],cl
		add [col_aux],lim_derecho
		;Interno superior 
		posiciona_cursor 8,[col_aux]
		imprime_caracter_color marcoHor,cAmarillo,bgNegro

		;Interno inferior
		posiciona_cursor 16,[col_aux]
		imprime_caracter_color marcoHor,cAmarillo,bgNegro

		mov cl,[col_aux]
		pop cx
		loop marcos_horizontales_internos

		;imprime intersecciones internas	
		posiciona_cursor 0,lim_derecho+1
		imprime_caracter_color marcoCruceVerSup,cAmarillo,bgNegro
		posiciona_cursor 24,lim_derecho+1
		imprime_caracter_color marcoCruceVerInf,cAmarillo,bgNegro

		posiciona_cursor 8,lim_derecho+1
		imprime_caracter_color marcoCruceHorIzq,cAmarillo,bgNegro
		posiciona_cursor 8,79
		imprime_caracter_color marcoCruceHorDer,cAmarillo,bgNegro

		posiciona_cursor 16,lim_derecho+1
		imprime_caracter_color marcoCruceHorIzq,cAmarillo,bgNegro
		posiciona_cursor 16,79
		imprime_caracter_color marcoCruceHorDer,cAmarillo,bgNegro

		;imprimir [X] para cerrar programa
		posiciona_cursor 0,76
		imprime_caracter_color '[',cAmarillo,bgNegro
		posiciona_cursor 0,77
		imprime_caracter_color 'X',cRojoClaro,bgNegro
		posiciona_cursor 0,78
		imprime_caracter_color ']',cAmarillo,bgNegro

		;imprimir título
		posiciona_cursor 0,37
		imprime_cadena_color [titulo],6,cAmarillo,bgNegro

		call IMPRIME_TEXTOS

		call IMPRIME_BOTONES

		call IMPRIME_DATOS_INICIALES

		call IMPRIME_SCORES

		call IMPRIME_LIVES

		ret
	endp

	IMPRIME_TEXTOS proc
		;Imprime cadena "LIVES"
		posiciona_cursor lives_ren,lives_col
		imprime_cadena_color livesStr,5,cGrisClaro,bgNegro

		;Imprime cadena "SCORE"
		posiciona_cursor score_ren,score_col
		imprime_cadena_color scoreStr,5,cGrisClaro,bgNegro

		;Imprime cadena "HI-SCORE"
		posiciona_cursor hiscore_ren,hiscore_col
		imprime_cadena_color hiscoreStr,8,cGrisClaro,bgNegro
		ret
	endp

	IMPRIME_BOTONES proc
		;Botón STOP
		mov [boton_caracter],254d		;Carácter '■'
		mov [boton_color],bgAmarillo 	;Background amarillo
		mov [boton_renglon],stop_ren 	;Renglón en "stop_ren"
		mov [boton_columna],stop_col 	;Columna en "stop_col"
		call IMPRIME_BOTON 				;Procedimiento para imprimir el botón
		;Botón PAUSE
		mov [boton_caracter],19d 		;Carácter '‼'
		mov [boton_color],bgAmarillo 	;Background amarillo
		mov [boton_renglon],pause_ren 	;Renglón en "pause_ren"
		mov [boton_columna],pause_col 	;Columna en "pause_col"
		call IMPRIME_BOTON 				;Procedimiento para imprimir el botón
		;Botón PLAY
		mov [boton_caracter],16d  		;Carácter '►'
		mov [boton_color],bgAmarillo 	;Background amarillo
		mov [boton_renglon],play_ren 	;Renglón en "play_ren"
		mov [boton_columna],play_col 	;Columna en "play_col"
		call IMPRIME_BOTON 				;Procedimiento para imprimir el botón
		ret
	endp

	IMPRIME_SCORES proc
		;Imprime el valor de la variable player_score en una posición definida
		call IMPRIME_SCORE
		;Imprime el valor de la variable player_hiscore en una posición definida
		call IMPRIME_HISCORE
		ret
	endp

	IMPRIME_SCORE proc
		;Imprime "player_score" en la posición relativa a 'score_ren' y 'score_col'
		mov [ren_aux],score_ren
		mov [col_aux],score_col+20
		mov bx,[player_score]
		call IMPRIME_BX
		ret
	endp

	IMPRIME_HISCORE proc
	;Imprime "player_score" en la posición relativa a 'hiscore_ren' y 'hiscore_col'
		mov [ren_aux],hiscore_ren
		mov [col_aux],hiscore_col+20
		mov bx,[player_hiscore]
		call IMPRIME_BX
		ret
	endp

	;BORRA_SCORES borra los marcadores numéricos de pantalla sustituyendo la cadena de números por espacios
	BORRA_SCORES proc
		call BORRA_SCORE
		call BORRA_HISCORE
		ret
	endp

	BORRA_SCORE proc
		posiciona_cursor score_ren,score_col+20 		;posiciona el cursor relativo a score_ren y score_col
		imprime_cadena_color blank,5,cBlanco,bgNegro 	;imprime cadena blank (espacios) para "borrar" lo que está en pantalla
		ret
	endp

	BORRA_HISCORE proc
		posiciona_cursor hiscore_ren,hiscore_col+20 	;posiciona el cursor relativo a hiscore_ren y hiscore_col
		imprime_cadena_color blank,5,cBlanco,bgNegro 	;imprime cadena blank (espacios) para "borrar" lo que está en pantalla
		ret
	endp

	;Imprime el valor del registro BX como entero sin signo (positivo)
	;Se imprime con 5 dígitos (incluyendo ceros a la izquierda)
	;Se usan divisiones entre 10 para obtener dígito por dígito en un LOOP 5 veces (una por cada dígito)
	IMPRIME_BX proc
		mov ax,bx
		mov cx,5
	div10:
		xor dx,dx
		div [diez]
		push dx
		loop div10
		mov cx,5
	imprime_digito:
		mov [conta],cl
		posiciona_cursor [ren_aux],[col_aux]
		pop dx
		or dl,30h
		imprime_caracter_color dl,cBlanco,bgNegro
		xor ch,ch
		mov cl,[conta]
		inc [col_aux]
		loop imprime_digito
		ret
	endp

	IMPRIME_DATOS_INICIALES proc
		call DATOS_INICIALES 		;inicializa variables de juego
		;imprime la 'nave' del jugador
		;borra la posición actual, luego se reinicia la posición y entonces se vuelve a imprimir
		call BORRA_JUGADOR
		mov [player_col], ini_columna
		mov [player_ren], ini_renglon
		;Imprime jugador
		call IMPRIME_JUGADOR

		;Borrar posicion actual del enemigo y reiniciar su posicion

		;Imprime enemigo
		call IMPRIME_ENEMIGO

		ret
	endp

	;Inicializa variables del juego
	DATOS_INICIALES proc
		mov [player_score],0
		mov [player_lives], 3
		ret
	endp

	;Imprime los caracteres ☻ que representan vidas. Inicialmente se imprime el número de 'player_lives'
	IMPRIME_LIVES proc
		xor cx,cx
		mov di,lives_col+20
		mov cl,[player_lives]
	imprime_live:
		push cx
		mov ax,di
		posiciona_cursor lives_ren,al
		imprime_caracter_color 2d,cCyanClaro,bgNegro
		add di,2
		pop cx
		loop imprime_live
		ret
	endp

	;Imprime la nave del jugador, que recibe como parámetros las variables ren_aux y col_aux, que indican la posición central inferior
	PRINT_PLAYER proc

		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cBlanco,bgNegro
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cBlanco,bgNegro
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cBlanco,bgNegro
		add [ren_aux],2
		
		dec [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cBlanco,bgNegro
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cBlanco,bgNegro
		inc [ren_aux]
		
		dec [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cBlanco,bgNegro
		
		add [col_aux],3
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cBlanco,bgNegro
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cBlanco,bgNegro
		inc [ren_aux]
		
		inc [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cBlanco,bgNegro
		ret
	endp

	;Borra la nave del jugador, que recibe como parámetros las variables ren_aux y col_aux, que indican la posición central de la barra
	DELETE_PLAYER proc
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color ' ',cNegro,bgNegro
		dec [ren_aux]

		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color ' ',cNegro,bgNegro
		dec [ren_aux]

		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color ' ',cNegro,bgNegro
		add [ren_aux],2

		dec [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color ' ',cNegro,bgNegro
		dec [ren_aux]

		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color ' ',cNegro,bgNegro
		inc [ren_aux]

		dec [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color ' ',cNegro,bgNegro

		add [col_aux],3
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color ' ',cNegro,bgNegro
		dec [ren_aux]

		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color ' ',cNegro,bgNegro
		inc [ren_aux]

		inc [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color ' ',cNegro,bgNegro
		ret
	endp


	;Imprime la nave del enemigo
	PRINT_ENEMY proc

		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cRojo,bgNegro
		inc [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cRojo,bgNegro
		inc [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cRojo,bgNegro
		sub [ren_aux],2
		
		dec [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cRojo,bgNegro
		inc [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cRojo,bgNegro
		dec [ren_aux]
		
		dec [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cRojo,bgNegro
		
		add [col_aux],3
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cRojo,bgNegro
		inc [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cRojo,bgNegro
		dec [ren_aux]
		
		inc [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cRojo,bgNegro
		ret
	endp

	DELETE_ENEMY proc

    ; ===== Columna central (3 bloques) =====
    posiciona_cursor [ren_aux], [col_aux]
    imprime_caracter_color ' ', cNegro, bgNegro

    inc [ren_aux]
    posiciona_cursor [ren_aux], [col_aux]
    imprime_caracter_color ' ', cNegro, bgNegro

    inc [ren_aux]
    posiciona_cursor [ren_aux], [col_aux]
    imprime_caracter_color ' ', cNegro, bgNegro

    sub [ren_aux], 2


    ; ===== Columna izquierda (2 bloques) =====
    dec [col_aux]
    posiciona_cursor [ren_aux], [col_aux]
    imprime_caracter_color ' ', cNegro, bgNegro

    inc [ren_aux]
    posiciona_cursor [ren_aux], [col_aux]
    imprime_caracter_color ' ', cNegro, bgNegro

    dec [ren_aux]


    ; ===== Extremo más izquierdo (1 bloque) =====
    dec [col_aux]
    posiciona_cursor [ren_aux], [col_aux]
    imprime_caracter_color ' ', cNegro, bgNegro


    ; ===== Columna derecha (2 bloques) =====
    add [col_aux], 3
    posiciona_cursor [ren_aux], [col_aux]
    imprime_caracter_color ' ', cNegro, bgNegro

    inc [ren_aux]
    posiciona_cursor [ren_aux], [col_aux]
    imprime_caracter_color ' ', cNegro, bgNegro

    dec [ren_aux]


    ; ===== Extremo más derecho (1 bloque) =====
    inc [col_aux]
    posiciona_cursor [ren_aux], [col_aux]
    imprime_caracter_color ' ', cNegro, bgNegro

    ret
DELETE_ENEMY endp

    


	;procedimiento IMPRIME_BOTON
	;Dibuja un boton que abarca 3 renglones y 5 columnas
	;con un caracter centrado dentro del boton
	;en la posición que se especifique (esquina superior izquierda)
	;y de un color especificado
	;Utiliza paso de parametros por variables globales
	;Las variables utilizadas son:
	;boton_caracter: debe contener el caracter que va a mostrar el boton
	;boton_renglon: contiene la posicion del renglon en donde inicia el boton
	;boton_columna: contiene la posicion de la columna en donde inicia el boton
	;boton_color: contiene el color del boton
	IMPRIME_BOTON proc
	 	;background de botón
		mov ax,0600h 		;AH=06h (scroll up window) AL=00h (borrar)
		mov bh,cRojo	 	;Caracteres en color amarillo
		xor bh,[boton_color]
		mov ch,[boton_renglon]
		mov cl,[boton_columna]
		mov dh,ch
		add dh,2
		mov dl,cl
		add dl,2
		int 10h
		mov [col_aux],dl
		mov [ren_aux],dh
		dec [col_aux]
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color [boton_caracter],cRojo,[boton_color]
	 	ret 			;Regreso de llamada a procedimiento
	endp	 			;Indica fin de procedimiento UI para el ensamblador
	
	BORRA_JUGADOR proc
		mov al,[player_col]
		mov ah,[player_ren]
		mov [col_aux],al
		mov [ren_aux],ah
		call DELETE_PLAYER
		ret 
	endp 

	IMPRIME_JUGADOR proc
		mov al,[player_col]
		mov ah,[player_ren]
		mov [col_aux],al
		mov [ren_aux],ah
		call PRINT_PLAYER
		ret
	endp

	IMPRIME_ENEMIGO proc
		mov al,[enemy_col]
		mov ah,[enemy_ren]
		mov [col_aux],al
		mov [ren_aux],ah
		call PRINT_ENEMY
		ret
	endp

	ELIMINA_ENEMIGO proc
		mov al,[enemy_col]
		mov ah,[enemy_ren]
		mov [col_aux],al
		mov [ren_aux],ah
		call DELETE_ENEMY
		ret
	endp


 LEER_TECLADO proc
    mov ah, 01h
    int 16h
    jz no_tecla

    mov ah, 00h
    int 16h
    mov [entrada_tecla], ah
    ret

no_tecla:
    mov byte ptr [entrada_tecla], 0
    ret

endp

MOV_NAVE proc 

	; Si el jugador está "muerto", no permitir que se mueva
	cmp [player_dead], 1
	je limite_alcanzado

    ; Revisar qué tecla se presionó
    mov al, [entrada_tecla]

    ; Si fue flecha izquierda → mover a la izquierda
    cmp al, tecla_izq
    je mov_izq

    ; Si fue flecha derecha → mover a la derecha
    cmp al, tecla_der
    je mov_der

    ; Si no fue ninguna de esas teclas, salir
    ret 



; Movimiento del jugador hacia la izquierda

mov_izq:
    mov al, [player_col]
    dec al                      ; probar si puede moverse 1 columna a la izquierda
    cmp al, lim_izquierdo + 2   ; revisar si ya llegó al borde
    jle limite_alcanzado        ; si ya no puede moverse, salir

    call BORRA_JUGADOR          ; borrar donde estaba
    dec [player_col]            ; mover realmente al jugador
    call IMPRIME_JUGADOR        ; dibujarlo en la nueva posición
    ret


; Movimiento del jugador hacia la derecha

mov_der:
    mov al, [player_col]
    inc al                      ; probar si puede moverse 1 columna a la derecha
    cmp al, lim_derecho - 2     ; revisar si llegó al borde derecho
    jge limite_alcanzado        ; si ya no puede, salir

    call BORRA_JUGADOR          ; borrar donde estaba
    inc [player_col]            ; mover realmente al jugador
    call IMPRIME_JUGADOR        ; dibujarlo en la nueva posición
    ret



; No se mueve (llegó al límite o está muerto)

limite_alcanzado:
    ret


MOV_NAVE endp


MOV_ENEMIGO proc           

	
    mov ah,00h
    int 1Ah            ; Lee el valor del contador de ticks 

    
    mov ax,dx
    sub ax,[t_mov_enem]
    cmp ax,2           ; Verificar si han pasado 2 ticks
    jb bajar        ; si no han pasado los 2 ticks, la nave enemiga no debe moverse

    ; si ya pasaron los ticks necesarios, actualizar el tiempo de movimiento horizontal
    mov [t_mov_enem], dx

    mov al, [enemy_sen]   
    cmp al, 0  		   ; Para identificar la dirección de la nave enemiga, como enemy_sen = 0, la nave empezara a moverse a la izquierda
    je enem_izq
    jmp enem_der

;Movimiento horizontal
enem_izq:
    mov al, [enemy_col]
    dec al                      ; Probar recorrer la nave un movimiento a la izquierda
    cmp al, lim_izquierdo + 2
    jle cambio_der              ; si ya llegó al limite izquierdo, cambiar el sentido 

   ; Borrar la nave en la posicion actual e imprimirla en la siguiente
    call ELIMINA_ENEMIGO
    dec [enemy_col]
    call IMPRIME_ENEMIGO
    ret

enem_der:
    mov al, [enemy_col]
    inc al                      ; Probar recorrer la nave un movimiento a la derecha
    cmp al, lim_derecho-2
    jge cambio_izq              ; si ya llegó al limite izquierdo, cambiar el sentido 

    ; Borrar la nave en la posicion actual e imprimirla en la siguiente
    call ELIMINA_ENEMIGO
    inc [enemy_col]
    call IMPRIME_ENEMIGO
    ret

cambio_der:
    mov byte ptr [enemy_sen], 1 ; Cambio de sentido de la nava a la derecha
    ret

cambio_izq:
    mov byte ptr [enemy_sen], 0 ; Cambio de sentido de la nava a la izquierda
    ret


;Movimiento vertical

bajar:
    mov ax, dx
    sub ax, [t_atacar_enem]
    cmp ax, 36
    jb no_bajar

    mov [t_atacar_enem], dx ; si han pasado los 3 segundos actualizar el tiempo para bajar


    ; Borrar posicion actual
    
    mov al, [enemy_ren]
    mov [ren_aux], al

    mov al, [enemy_col]
    mov [col_aux], al

    call DELETE_ENEMY


    
    ; Bajar enemigo

    inc [enemy_ren]


    
    ; Imprimir nueva posición 
    
    mov al, [enemy_ren]
    mov [ren_aux], al

    mov al, [enemy_col]
    mov [col_aux], al

    call PRINT_ENEMY




    ; Checar si no ha llegado al limite inferior

    mov al, [enemy_ren]
    cmp al, lim_inferior - 2
    jl no_bajar  ; si no llegó al fondo sigue normal


nuevo_enemigo:

	mov al, [enemy_ren]
    mov [ren_aux], al

    mov al, [enemy_col]
    mov [col_aux], al


    call DELETE_ENEMY
    mov [enemy_ren], 3


    ; Reiniciar coordenadas para imprimir una nueva nave
    mov al, [enemy_ren]
    mov [ren_aux], al

    mov al, [enemy_col]
    mov [col_aux], al

    call PRINT_ENEMY


no_bajar:
    ret



MOV_ENEMIGO endp



REVIVIR_JUGADOR proc

	; Solo funciona si el jugador está muerto
	cmp [player_dead], 1
	jne no_revivir

    ; Lee el valor del contador de ticks 
	mov ah,00h
    int 1Ah

    ; Ver cuánto tiempo ha pasado desde que murió
    mov ax, dx
    sub ax, [t_jug_muerto]

    ; Si ya pasaron 2 segundos, revivir
    cmp ax, 36
    jae revivir

    ; Si aún no pasan 2 segundos, salir
    jmp no_revivir


revivir:
	; Marcar que ya está vivo
 	mov [player_dead], 0

 	; Cargar la posición del jugador
 	mov al, [player_col]
    mov [col_aux], al

    mov al, [player_ren]
    mov [ren_aux], al

	; Volverlo a dibujar en pantalla
    call IMPRIME_JUGADOR

no_revivir:
    ret

REVIVIR_JUGADOR endp



CHOQUE proc

    ; Si el jugador ya está muerto no hubo choque
    cmp [player_dead], 1
    je no_choque

    ; Guardar la posicion del jugador
    mov bl, [player_col]
    mov bh, [player_ren]

    ; Guardar la posicion del enemigo
    mov dl, [enemy_col]
    mov dh, [enemy_ren]


; ================================
; Checar si chocan horizontalmente
; ================================

    ; Revisar si el jugador quedó del lado derecho de la nave enemiga
    mov al, bl
    sub al, 2
    mov ah, dl
    add ah, 2
    cmp al, ah
    ja no_choque

    ; Revisar si el jugador quedó del lado izquierdo de la nave enemiga
    mov al, bl
    add al, 2
    mov ah, dl
    sub ah, 2
    cmp al, ah
    jb no_choque


; ================================
; Checar si chocan verticalmente
; ================================

    ; Revisar si el jugador quedó abajo del enemigo
    mov al, bh
    sub al, 2
    mov ah, dh
    add ah, 2
    cmp al, ah
    ja no_choque

    ; Revisar si el jugador quedó arriba del enemigo
    mov al, bh
    add al, 2
    mov ah, dh
    sub ah, 2
    cmp al, ah
    jb no_choque



    
    ; Sí coinciden hubo choque
    
    mov [player_dead], 1
    call BORRA_JUGADOR

    mov ah,00h
    int 1Ah
    mov [t_jug_muerto], dx


no_choque:
    ret

CHOQUE endp



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;FIN PROCEDIMIENTOS;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
end inicio			;fin de etiqueta inicio, fin de programa

