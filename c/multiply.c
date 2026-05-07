#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>

uint8_t* zero_address;
void initialize() {
    srand(time(NULL));
    zero_address = malloc(sizeof(uint8_t) * 256);
    
    for (int i = 0; i < 64; ++i) {
        int r = rand() & 0xFF;
        zero_address[i] = (uint8_t)r;
    }
}

int32_t tester(uint8_t msb1, uint8_t lsb1, uint8_t msb2, uint8_t lsb2) {
    int16_t multiplier = ((int16_t)msb1 << 8) | (int16_t)lsb1;
    int16_t multiplicand = ((int16_t)msb2 << 8) | (int16_t)lsb2;

    int32_t product = (int32_t)multiplier * (int32_t)multiplicand;

    return product;
}

int32_t read_int(uint8_t a, uint8_t b, uint8_t c, uint8_t d) {
    int32_t result = ((int32_t)a << 24) | ((int32_t)b << 16) | ((int32_t)c << 8) | (int32_t)d;

    return result;
}

//register file flag
int is_positive(uint8_t num) {
    return (num < 128);
}

void multiply() {
    uint32_t product = 0;

    uint8_t counter = 16;

    for (; counter != 0; --counter) {
        product = product << 1;

        uint8_t multiplier_msb = zero_address[0];

        if (~is_positive(multiplier_msb)) {
            uint8_t multiplicand_lsb = zero_address[3];

            product += multiplicand_lsb;
        }

        uint8_t multiplier_lsb = zero_address[1];
        zero_address[1] = multiplier_lsb << 1;

        uint8_t lost_bit = multiplier_lsb >> 7;

        multiplier_msb = (multiplier_msb << 1) | lost_bit;
        zero_address[0] = multiplier_msb;
    }

    //copy product back into memory
    zero_address[0] = (product >> 24) & 0xFF;
    zero_address[1] = (product >> 16) & 0xFF;
    zero_address[2] = (product >> 8) & 0xFF;
    zero_address[3] = product & 0xFF;
}

int main() {
    initialize();
    
    printf("Raw: ");
    for (int i = 0; i < 64; i++) {
        uint8_t value = zero_address[i];
        printf("%u ", value);
    }
    printf("\n");

    printf("Input: ");
    for (int i = 0; i < 64; i += 2) {
        int16_t value = ((int16_t)zero_address[i] << 8) | (int16_t)zero_address[i + 1];

        if (value > 32767) value -= 65536;
        printf("%d ", value);
    }
    printf("\n");

    printf("Expected: ");
    for (int i = 0; i < 64; i += 4) {
        int32_t expected = tester(zero_address[i], zero_address[i + 1], zero_address[i + 2], zero_address[i + 3]);

        printf("%d ", expected);
    }
    printf("\n");

    uint8_t max_count = 64;
    uint8_t write_address = max_count;

    for (uint8_t i = 0; i < max_count; i += 4) {
        uint8_t lsb1, lsb2;
        uint8_t msb1 = zero_address[i];
        uint8_t msb2 = zero_address[i + 2];

        uint8_t result_sign = (msb1 ^ msb2) >> 7;

        if (is_positive(msb1)) {
            lsb1 = zero_address[i + 1];
        } else {
            lsb1 = zero_address[i + 1];

            msb1 = ~msb1;
            lsb1 = ~lsb1 + 1;

            //emulate carry addition
            if (lsb1 == 0) {
                msb1++;
            }
        }

        zero_address[0] = msb1;
        zero_address[1] = lsb1;

        if (is_positive(msb2)) {
            lsb2 = zero_address[i + 3];
        } else {
            lsb2 = zero_address[i + 3];


            msb2 = ~msb2;
            lsb2 = ~lsb2 + 1;

            if (lsb2 == 0) {
                msb2++;
            }
        }

        zero_address[2] = msb2;
        zero_address[3] = lsb2;

        multiply();
        
        int32_t product = ((uint32_t)zero_address[3] << 24) | ((uint32_t)zero_address[2] << 16) | ((uint32_t)zero_address[1] << 8) | (uint32_t)zero_address[0];
        if (result_sign) {
            product *= -1;
        }

        zero_address[write_address] = (product >> 24) & 0xFF;
        zero_address[write_address + 1] = (product >> 16) & 0xFF;
        zero_address[write_address + 2] = (product >> 8) & 0xFF;
        zero_address[write_address + 3] = product & 0xFF;

        write_address += 4;
    }    

    printf("Actual: ");
    for (int i = 64; i < 128; i += 4) {
        int32_t actual = read_int(zero_address[i], zero_address[i + 1], zero_address[i + 2], zero_address[i + 3]);
        printf("%d ", actual);
    }
    printf("\n");

    free(zero_address);

    return 0;
}