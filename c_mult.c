#include <stdio.h>
#include <stdint.h>

// Function to perform 8-bit Booth's Multiplication
int16_t booth_multiply(int8_t multiplicand, int8_t multiplier) {
    int8_t A = 0;              // Accumulator (initialized to 0)
    int8_t M = multiplicand;   // Multiplicand
    int8_t Q = multiplier;     // Multiplier
    int8_t Q_1 = 0;            // "Phantom" bit to the right of Q (initialized to 0)

    printf("Multiplying: M = %d, Q = %d\n", M, Q);
    printf("Initial State:   [A: %02X] [Q: %02X] [Q_1: %d]\n\n", (uint8_t)A, (uint8_t)Q, Q_1);

    // Loop once for each bit in the operands (8 times for 8-bit numbers)
    for (int i = 0; i < 8; i++) {
        int8_t Q_0 = Q & 1; // Extract the least significant bit (LSB) of Q

        // 1. Determine Add/Subtract based on the (Q_0, Q_1) pair
        if (Q_0 == 1 && Q_1 == 0) {
            A = A - M;
            printf("Step %d: 10 -> Sub M: [A: %02X] [Q: %02X] [Q_1: %d]\n", 
                   i+1, (uint8_t)A, (uint8_t)Q, Q_1);
        } 
        else if (Q_0 == 0 && Q_1 == 1) {
            A = A + M;
            printf("Step %d: 01 -> Add M: [A: %02X] [Q: %02X] [Q_1: %d]\n", 
                   i+1, (uint8_t)A, (uint8_t)Q, Q_1);
        } 
        else {
            printf("Step %d: %d%d -> No op:  [A: %02X] [Q: %02X] [Q_1: %d]\n", 
                   i+1, Q_0, Q_1, (uint8_t)A, (uint8_t)Q, Q_1);
        }

        // 2. Arithmetic Right Shift (ARS) of the composite register [A, Q, Q_1]
        Q_1 = Q & 1;            // The LSB of Q shifts into Q_1
        int8_t A_LSB = A & 1;   // Save the LSB of A before shifting

        A = A >> 1;             // Shift A right. (In C, right shifting a signed int usually performs an Arithmetic Shift, preserving the sign bit).
        
        Q = (Q >> 1) & 0x7F;    // Shift Q right logically (clear MSB)
        if (A_LSB) {
            Q |= 0x80;          // The LSB of A shifts into the MSB of Q
        }

        printf("        Shift ->  [A: %02X] [Q: %02X] [Q_1: %d]\n\n", 
               (uint8_t)A, (uint8_t)Q, Q_1);
    }

    // 3. Combine A (upper 8 bits) and Q (lower 8 bits) into a 16-bit result
    int16_t result = ((int16_t)A << 8) | (uint8_t)Q;
    return result;
}

int main() {
    // Example: (-6) * (3) = -18
    // -6 in 8-bit two's complement is FA
    //  3 in 8-bit two's complement is 03
    // -18 in 16-bit two's complement is FFEE
    
    int8_t multiplicand = -6;
    int8_t multiplier = 3;

    int16_t final_product = booth_multiply(multiplicand, multiplier);
    
    printf("Final Product: %d (Hex: %04X)\n", final_product, (uint16_t)final_product);

    return 0;
}