.data
menu_msg:           .asciiz "\n--- Conversor Decimal-Binario ---\n1. Convertir Decimal a Binario\n2. Convertir Binario a Decimal (8 bits)\n3. Generar un Número Aleatorio\n4. Salir\nElige una opción: "
input_decimal_msg:  .asciiz "Introduce un número decimal: "
input_binary_msg:   .asciiz "Introduce un número binario de 8 bits: "
binary_result_msg:  .asciiz "Binario: "
decimal_result_msg: .asciiz "Decimal: "
error_msg:          .asciiz "Error: entrada inválida.\n"
random_msg:         .asciiz "Número aleatorio generado: "
invalid_option_msg: .asciiz "Opción no válida. Por favor, elige una opción del menú.\n"
exit_msg:           .asciiz "Saliendo del programa.\n"

.text
.globl main

main:
    # Bucle principal del menú
main_loop:
    li $v0, 4                      # syscall para imprimir string
    la $a0, menu_msg               # cargar mensaje del menú
    syscall

    li $v0, 5                      # syscall para leer entero
    syscall
    move $t0, $v0                  # guardar opción del usuario en $t0

    # Evaluar opción del menú
    beq $t0, 1, decimal_to_binary  # Opción 1: Decimal a binario
    beq $t0, 2, binary_to_decimal  # Opción 2: Binario a decimal
    beq $t0, 3, generate_random    # Opción 3: Generar número aleatorio
    beq $t0, 4, exit_program       # Opción 4: Salir

    # Mensaje de opción inválida
    li $v0, 4
    la $a0, invalid_option_msg
    syscall
    j main_loop

# Función para convertir de decimal a binario
decimal_to_binary:
    li $v0, 4
    la $a0, input_decimal_msg
    syscall

    li $v0, 5                      # Leer número decimal
    syscall
    move $t1, $v0                  # Guardar número decimal en $t1

    # Validación: si decimal es menor a 0 o mayor a 255, es inválido
    blt $t1, 0, show_error
    bgt $t1, 255, show_error

    # Convertir a binario (solo primeros 8 bits)
    li $t2, 0                      # Índice del array temporal para bits
    li $t3, 8                      # Tamaño del array para 8 bits

    # Preparar mensaje de binario
    li $v0, 4
    la $a0, binary_result_msg
    syscall

convert_to_binary_loop:
    # Si decimal es 0 y todos los bits están calculados, salta a imprimir
    beq $t1, 0, print_binary
    divu $t1, $t1, 2               # Dividir decimal por 2
    mfhi $t4                       # Resto de la división (bit)
    addi $t2, $t2, 1               # Incrementar índice de bit

    # Imprimir cada bit de derecha a izquierda
    li $v0, 1
    move $a0, $t4
    syscall
    j convert_to_binary_loop

# Imprimir resultado de conversión binaria
print_binary:
    j main_loop                    # Volver al menú principal

# Función para convertir de binario a decimal (8 bits)
binary_to_decimal:
    li $v0, 4
    la $a0, input_binary_msg
    syscall

    li $v0, 5                      # Leer número binario (como string de 8 bits)
    syscall
    move $t1, $v0                  # Guardar cadena binaria en $t1

    # Validación de longitud de 8 bits
    li $t5, 8                      # Longitud esperada de 8 bits
    bne $t5, 8, show_error         # Si no es de 8 bits, muestra error

    # Convertir binario a decimal
    li $t2, 0                      # Acumulador decimal
    li $t3, 1                      # Base inicial (2^0)

convert_binary_to_decimal_loop:
    beq $t1, 0, print_decimal      # Si no hay más bits, salta a imprimir
    mul $t4, $t1, $t3              # Multiplica bit por base
    add $t2, $t2, $t4              # Suma al acumulador decimal
    mul $t3, $t3, 2                # Incrementa base en potencia de 2

    j convert_binary_to_decimal_loop

print_decimal:
    li $v0, 4
    la $a0, decimal_result_msg
    syscall

    li $v0, 1
    move $a0, $t2                  # Imprimir resultado decimal
    syscall
    j main_loop

# Función para generar un número aleatorio entre 10 y 50
generate_random:
    li $t0, 10                     # Valor mínimo 10
    li $t1, 41                     # Rango (50 - 10 + 1)
    li $v0, 42                     # syscall para rand
    syscall

    divu $v0, $t1                  # Resto de la división
    add $v0, $t0                   # Sumar mínimo

    # Mostrar el número aleatorio en decimal
    li $v0, 4
    la $a0, random_msg
    syscall

    li $v0, 1
    move $a0, $v0
    syscall

    # Convertir a binario el número aleatorio
    move $t1, $v0                  # Guardar número en $t1 para conversión a binario
    li $t2, 0                      # Índice del array temporal
    li $t3, 8                      # Tamaño del array de 8 bits

generate_random_to_binary_loop:
    beq $t1, 0, print_binary       # Si es 0, salta a imprimir
    divu $t1, $t1, 2               # Dividir entre 2
    mfhi $t4                       # Bit
    addi $t2, $t2, 1               # Incrementa índice

    # Imprimir cada bit de derecha a izquierda
    li $v0, 1
    move $a0, $t4
    syscall
    j generate_random_to_binary_loop

show_error:
    li $v0, 4
    la $a0, error_msg
    syscall
    j main_loop                    # Volver al menú principal

# Finalizar el programa
exit_program:
    li $v0, 4
    la $a0, exit_msg
    syscall
    li $v0, 10                    # Salir del programa
    syscall
