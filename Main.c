#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

void decimalToBinary(int decimal) {
    int binary[8];
    int index = 0;

    for (int i = 0; i < 8; i++) {
        binary[i] = 0;
    }
    while (decimal > 0 && index < 8) {
        binary[index++] = decimal % 2;
        decimal /= 2;
    }

    printf("Binario: ");
    for (int i = 7; i >= 0; i--) {
        printf("%d", binary[i]);
    }
    printf("\n");
}

int binaryToDecimal(char *binary) {
    int decimal = 0;
    int base = 1; // 2^0

    if (strlen(binary) != 8) {
        printf("Error: el número binario debe tener exactamente 8 bits.\n");
        return -1;
    }
    for (int i = 0; i < 8; i++) {
        if (binary[i] != '0' && binary[i] != '1') {
            printf("Error: el número binario solo debe contener '0' y '1'.\n");
            return -1;
        }
    }

    for (int i = 7; i >= 0; i--) {
        if (binary[i] == '1') {
            decimal += base;
        }
        base *= 2;
    }

    return decimal;
}

void generateRandomNumber() {
    int randomNumber = 10 + rand() % 41;
    printf("Número aleatorio generado: %d\n", randomNumber);
    printf("Conversión a binario:\n");
    decimalToBinary(randomNumber);
}


int main() {
    int choice;
    srand(time(0));

    do {
        printf("\n--- Conversor Decimal-Binario ---\n");
        printf("1. Convertir Decimal a Binario\n");
        printf("2. Convertir Binario a Decimal (8 bits)\n");
        printf("3. Generar un Número Aleatorio\n");
        printf("4. Salir\n");
        printf("Elige una opción: ");
        
        while (scanf("%d", &choice) != 1) {
            printf("Error: Por favor, introduce un número válido.\n");
            while (getchar() != '\n');
            printf("Elige una opción: ");
        }

        switch (choice) {
            case 1: {
                int decimal;
                printf("Introduce un número decimal: ");
                
                while (scanf("%d", &decimal) != 1) {
                    printf("Error: Por favor, introduce un número decimal válido.\n");
                    while (getchar() != '\n');
                    printf("Introduce un número decimal: ");
                }

                if (decimal < 0) {
                    printf("Error: el número debe ser positivo.\n");
                } else if (decimal > 255) { 
                    printf("Error: el número debe estar entre 0 y 255 para convertirlo en 8 bits.\n");
                } else {
                    decimalToBinary(decimal);
                }
                break;
            }
            case 2: {
            char binary[9];
            printf("Introduce un número binario de 8 bits: ");
            
            while (1) {
                scanf("%s", binary);
                
                while (getchar() != '\n');

                if (strlen(binary) == 8) {
                    break;
                } else {
                    printf("Error: Debes ingresar un número binario de exactamente 8 bits.\n");
                    printf("Introduce un número binario de 8 bits: ");
                }
            }

            int decimal = binaryToDecimal(binary);
            if (decimal != -1) {
                printf("Decimal: %d\n", decimal);
            }
            break;
        }

            case 3: {
                generateRandomNumber();
                break;
            }
            case 4:
                printf("Saliendo del programa...\n");
                break;
            default:
                printf("Opción no válida. Por favor, elige una opción del menú.\n");
                break;
        }
    } while (choice != 4);

    return 0;
}