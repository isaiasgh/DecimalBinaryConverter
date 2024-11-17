.data
binary_input: .space 9          # Espacio para leer hasta 8 bits más el terminador nulo '\0'
binary_array: .space 8           # Espacio para almacenar 8 bits
newline_msg: .asciiz "\n"

# Mensajes de texto
menu_msg: .asciiz "\n--- Conversor Decimal-Binario ---\n1. Convertir Decimal a Binario\n2. Convertir Binario a Decimal (8 bits)\n3. Generar un Número Aleatorio\n4. Salir\nElige una opción: "
input_decimal_msg: .asciiz "Introduce un número decimal: "
input_binary_msg: .asciiz "Introduce un número binario de 8 bits: "
binary_result_msg: .asciiz "Binario: "
decimal_result_msg: .asciiz "\nDecimal: "
error_msg:          .asciiz "Error: entrada inválida.\n"
random_msg: .asciiz "Número aleatorio generado: "
error_invalid_decimal: .asciiz "Error: El número debe estar entre 0 y 255.\n"
error_invalid_binary: .asciiz "Error: El número binario debe tener exactamente 8 bits.\n"
invalid_option_msg: .asciiz "Opción no válida. Por favor, elige una opción del menú.\n"
exit_msg: .asciiz "Saliendo del programa...\n"

.text
.globl main

main:
    # Bucle principal del menú
main_loop:
    li $v0, 4                      # Imprimir menú
    la $a0, menu_msg
    syscall

    li $v0, 5                      # Leer opción del usuario
    syscall
    move $t0, $v0                  # Guardar opción en $t0

    # Evaluar opción
    beq $t0, 1, decimal_to_binary  # Opción 1
    beq $t0, 2, binary_to_decimal  # Opción 2
    beq $t0, 3, generate_random    # Opción 3
    beq $t0, 4, exit_program       # Opción 4

    # Opción inválida
    li $v0, 4
    la $a0, invalid_option_msg
    syscall
    j main_loop

# Convertir Decimal a Binario
decimal_to_binary:
    # Si $t1 ya contiene un número válido, saltar a la conversión
    bgtz $t1, start_convertion     # Si $t1 > 0, saltar a la conversión
    
    # Solicitar un número decimal al usuario
    li $v0, 4                      # Syscall para imprimir mensaje
    la $a0, input_decimal_msg
    syscall

    li $v0, 5                      # Syscall para leer un número entero
    syscall
    move $t1, $v0                  # Guardar número decimal en $t1

    # Validar que el número esté en el rango 0-255
    blt $t1, 0, invalid_decimal    # Si $t1 < 0, mostrar error
    bgt $t1, 255, invalid_decimal  # Si $t1 > 255, mostrar error

start_convertion:
    # Mensaje inicial para el binario
    li $v0, 4                      # Syscall para imprimir mensaje
    la $a0, binary_result_msg
    syscall

    # Preparar para la conversión a binario
    li $t2, 8                      # Número de bits (siempre 8 bits)
    la $t5, binary_array           # Apuntar al array donde se guardarán los bits
    addi $t5, $t5, 7               # Apuntar al último espacio del array (orden inverso)

convert_to_binary:
    beqz $t2, print_binary         # Si se procesaron 8 bits, terminar la conversión
    div $t1, $t1, 2                # Dividir número decimal entre 2
    mfhi $t4                       # Obtener el bit menos significativo (resto)
    sb $t4, 0($t5)                 # Guardar el bit en el array
    addi $t5, $t5, -1              # Mover al espacio anterior del array
    mflo $t1                       # Actualizar $t1 con el cociente
    subi $t2, $t2, 1               # Decrementar el contador de bits
    j convert_to_binary            # Continuar la conversión

print_binary:
    # Imprimir los bits en orden correcto
    la $t5, binary_array           # Volver al inicio del array
    li $t2, 8                      # Reiniciar contador a 8 bits

print_binary_loop:
    beqz $t2, end_conversion       # Si se imprimieron todos los bits, terminar
    lb $t4, 0($t5)                 # Cargar un bit del array
    addi $t4, $t4, 48              # Convertir 0/1 a ASCII ('0' o '1')
    li $v0, 11                     # Syscall para imprimir carácter
    move $a0, $t4
    syscall
    addi $t5, $t5, 1               # Mover al siguiente bit en el array
    subi $t2, $t2, 1               # Decrementar el contador de bits
    j print_binary_loop            # Continuar imprimiendo

end_conversion:
    # Volver al menú principal
    j main_loop

invalid_decimal:
    # Mensaje de error si el número no está en el rango permitido
    li $v0, 4
    la $a0, error_invalid_decimal
    syscall
    j main_loop


# Convertir Binario a Decimal
binary_to_decimal:
    # Imprimir mensaje solicitando el número binario
    li $v0, 4
    la $a0, input_binary_msg
    syscall

    # Leer cadena binaria desde el usuario
    li $v0, 8                      # Syscall para leer cadena
    la $a0, binary_input           # Buffer donde se almacenará la entrada
    li $a1, 9                      # Tamaño del buffer (8 bits + terminador nulo)
    syscall

    # Validar longitud de la entrada (debe ser exactamente 8 bits)
    la $t1, binary_input           # Cargar dirección del buffer
    li $t2, 0                      # Contador de longitud
    
validate_length:
    lb $t3, 0($t1)                 # Leer un byte de la cadena
    beqz $t3, convert_to_decimal   # Si es nulo ('\0'), salir del bucle
    addi $t2, $t2, 1               # Incrementar contador
    addi $t1, $t1, 1               # Avanzar al siguiente carácter
    j validate_length

convert_to_decimal:
    bne $t2, 8, invalid_binary     # Si la longitud no es 8, mostrar error

    # Convertir de binario a decimal
    la $t1, binary_input           # Dirección de la cadena binaria
    li $t4, 0                      # Acumulador decimal
    li $t5, 128                    # Base inicial (2^7)

binary_conversion_loop:
    lb $t3, 0($t1)                 # Leer un carácter de la cadena
    beqz $t3, print_decimal        # Si es nulo, salir del bucle
    sub $t3, $t3, 48               # Convertir carácter ('0' o '1') a valor numérico
    beqz $t3, skip_add             # Si es 0, omitir la suma
    add $t4, $t4, $t5              # Sumar la potencia de 2 al acumulador
    
skip_add:
    srl $t5, $t5, 1                # Dividir la base por 2 (desplazamiento a la derecha)
    addi $t1, $t1, 1               # Avanzar al siguiente carácter
    j binary_conversion_loop

invalid_binary:
    # Mostrar mensaje de error
    li $v0, 4
    la $a0, error_invalid_binary
    syscall
    j main_loop

print_decimal:
    # Mostrar el resultado en decimal
    li $v0, 4
    la $a0, decimal_result_msg
    syscall

    li $v0, 1                      # Syscall para imprimir número entero
    move $a0, $t4                  # Imprimir el acumulador decimal
    syscall
    j main_loop

# Generar un Número Aleatorio entre 10 y 50
generate_random:
 # Configurar el rango de números aleatorios
    li $v0, 42             # Syscall para random int range
    li $a0, 1              # ID del generador (puedes usar cualquier valor)
    li $a1, 41             # Rango (50 - 10 + 1)
    syscall                # Generar el número aleatorio en $a0

    addi $a0, $a0, 10      # Ajustar al rango [10, 50]
    move $t2, $a0          # Guardar el número generado en $t2

    # Imprimir el número aleatorio generado
    li $v0, 4              # Syscall para imprimir mensaje
    la $a0, random_msg
    syscall

    li $v0, 1              # Syscall para imprimir el número
    move $a0, $t2          # Número aleatorio en $t2
    syscall

    # Salto de línea
    li $v0, 4
    la $a0, newline_msg
    syscall

    # Llamar a la función decimal_to_binary
    move $t1, $t2          # Pasar el número generado en $t2 a $a0
    j decimal_to_binary  # Llamar a la función


# Salir del Programa
exit_program:
    li $v0, 4
    la $a0, exit_msg
    syscall

    li $v0, 10
    syscall