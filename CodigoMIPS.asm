.data
# Mensajes de texto
menu_msg: .asciiz "\n--- Conversor Decimal-Binario ---\n1. Convertir Decimal a Binario\n2. Convertir Binario a Decimal (8 bits)\n3. Generar un Número Aleatorio\n4. Salir\nElige una opción: "
input_decimal_msg: .asciiz "Introduce un número decimal: "
input_binary_msg: .asciiz "Introduce un número binario de 8 bits: "
binary_result_msg: .asciiz "Binario: "
decimal_result_msg: .asciiz "Decimal: "
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
    li $v0, 4                      # Solicitar número decimal
    la $a0, input_decimal_msg
    syscall

    li $v0, 5                      # Leer número decimal
    syscall
    move $t1, $v0                  # Guardar en $t1

    # Validar rango
    blt $t1, 0, invalid_decimal
    bgt $t1, 255, invalid_decimal

    # Convertir a binario
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
    j main_loop

invalid_decimal:
    li $v0, 4
    la $a0, error_invalid_decimal
    syscall
    j main_loop

# Convertir Binario a Decimal
binary_to_decimal:
    li $v0, 4
    la $a0, input_binary_msg
    syscall

    # Leer binario como cadena (simulación)
    la $a0, input_binary_msg
    syscall

    # Validar longitud 8 bits
    li $t5, 8                      # Longitud esperada
    bne $t5, 8, invalid_binary

    # Convertir a decimal
    li $t2, 0                      # Acumulador decimal
    li $t3, 1                      # Base inicial (2^0)

binary_to_decimal_loop:
    beqz $t1, print_decimal        # Si no hay más bits, imprime resultado
    mul $t4, $t1, $t3              # Multiplicar bit por base
    add $t2, $t2, $t4              # Sumar al acumulador
    mul $t3, $t3, 2                # Incrementar base
    j binary_to_decimal_loop

invalid_binary:
    li $v0, 4
    la $a0, error_invalid_binary
    syscall
    j main_loop

print_decimal:
    li $v0, 4
    la $a0, decimal_result_msg
    syscall

    li $v0, 1
    move $a0, $t2                  # Imprimir resultado decimal
    syscall
    j main_loop

# Generar un Número Aleatorio entre 10 y 50
generate_random:
    li $t0, 10                     # Valor mínimo 10
    li $t1, 41                     # Rango (50 - 10 + 1)
    li $v0, 42                     # Syscall rand
    syscall
    rem $v0, $v0, $t1              # Generar valor entre 0 y rango
    add $v0, $v0, $t0              # Ajustar a rango 10-50

    # Mostrar número aleatorio
    li $v0, 4
    la $a0, random_msg
    syscall

    li $v0, 1
    move $a0, $v0                  # Imprimir número aleatorio
    syscall

    # Convertir a binario
    move $t1, $v0                  # Guardar número aleatorio
    j decimal_to_binary

# Salir del Programa
exit_program:
    li $v0, 4
    la $a0, exit_msg
    syscall

    li $v0, 10
    syscall
