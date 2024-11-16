.data
binary_input: .space 9          # Espacio para leer hasta 8 bits más el terminador nulo '\0'
newline_msg: .asciiz "\n"
error_invalid_range: .asciiz "Error: El rango para el número aleatorio no es válido.\n"

# Mensajes de texto
menu_msg: .asciiz "\n--- Conversor Decimal-Binario ---\n1. Convertir Decimal a Binario\n2. Convertir Binario a Decimal (8 bits)\n3. Generar un Número Aleatorio\n4. Salir\nElige una opción: "
input_decimal_msg: .asciiz "Introduce un número decimal: "
input_binary_msg: .asciiz "Introduce un número binario de 8 bits: "
binary_result_msg: .asciiz "Binario: "
decimal_result_msg: .asciiz "\nDecimal: "
random_msg: .asciiz "Número aleatorio generado: "
error_invalid_decimal: .asciiz "Error: El número debe estar entre 0 y 255.\n"
error_invalid_binary: .asciiz "Error: El número binario debe tener exactamente 8 bits.\n"
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
    la $a0, error_invalid_binary
    syscall
    j main_loop

# Convertir Decimal a Binario
decimal_to_binary:
    # Si $t1 ya contiene un número válido, saltar a la conversión
    bgez $t1, start_conversion     # Si $t1 >= 0, saltar a la conversión

    # Solicitar un número decimal al usuario
    li $v0, 4
    la $a0, input_decimal_msg
    syscall

    li $v0, 5                      # Leer número decimal
    syscall
    move $t1, $v0                  # Guardar en $t1

    # Validar rango
    blt $t1, 0, invalid_decimal
    bgt $t1, 255, invalid_decimal

start_conversion:
    # Convertir $t1 a binario
    li $t2, 0                      # Contador de bits
    li $t3, 8                      # Máximo 8 bits
    la $a0, binary_result_msg      # Imprimir texto
    li $v0, 4
    syscall

convert_to_binary:
    beq $t2, $t3, print_binary     # Fin si contador alcanza 8
    div $t1, $t1, 2                # División
    mfhi $t4                       # Resto (bit actual)
    li $v0, 1                      # Imprimir bit
    move $a0, $t4
    syscall
    addi $t2, $t2, 1               # Incrementar contador
    j convert_to_binary

print_binary:
    # Limpiar $t1 después de la conversión
    li $t1, -1
    j main_loop

invalid_decimal:
    li $v0, 4
    la $a0, error_invalid_decimal
    syscall
    j main_loop

# Convertir Binario a Decimal
binary_to_decimal:
    # Imprimir mensaje solicitando el número binario
    li $v0, 4
    la $a0, binary_result_msg
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
    li $t0, 10                     # Valor mínimo (10)
    li $t1, 41                     # Rango (50 - 10 + 1)

    # Asegurar que el rango no sea negativo
    blez $t1, invalid_range         # Si el rango no es positivo, mostrar error

    # Configurar rango para syscall 42
    li $v0, 42                      # Syscall rand
    move $a1, $t1                   # Establecer rango en $a1
    syscall

    # Ajustar número al rango 10-50
    rem $t2, $v0, $t1               # Resto para obtener un número dentro del rango
    add $t2, $t2, $t0               # Ajustar el resultado al mínimo (10)

    # Mostrar número aleatorio generado
    li $v0, 4
    la $a0, random_msg
    syscall

    li $v0, 1
    move $a0, $t2                   # Imprimir número aleatorio
    syscall

    # Salto de línea después de imprimir
    li $v0, 4
    la $a0, newline_msg
    syscall

    # Convertir el número aleatorio a binario
    move $t1, $t2                   # Guardar el número generado en $t1
    j decimal_to_binary             # Saltar a la función de conversión
    
invalid_range:
    li $v0, 4
    la $a0, error_invalid_range
    syscall
    j main_loop                     # Regresar al menú principal
    
# Salir del Programa
exit_program:
    li $v0, 4
    la $a0, exit_msg
    syscall

    li $v0, 10
    syscall
