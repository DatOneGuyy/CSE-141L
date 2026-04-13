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

//hardware operation
int dist(uint8_t a, uint8_t b) {
    int count = 0;
    for (int i = 0; i < 8; ++i) {
        count += (a & 1) ^ (b & 1);
        a = a >> 1;
        b = b >> 1;
    }

    return count;
}

int calculate_distance(uint8_t address1, uint8_t address2) {
    uint8_t msb1 = zero_address[address1];
    uint8_t msb2 = zero_address[address2];

    uint8_t lsb1 = zero_address[address1 + 1];
    uint8_t lsb2 = zero_address[address2 + 1];

    return dist(msb1, msb2) + dist(lsb1, lsb2);
}

int main() {
    initialize();

    uint8_t outer_max = 62;
    uint8_t inner_max = 64;

    uint8_t min_dist = 16;
    uint8_t max_dist = 0;
    
    for (uint8_t outer_count = 0; outer_count < outer_max; outer_count += 2) {
        for (uint8_t inner_count = outer_count + 2; inner_count < inner_max; inner_count += 2) {
            uint8_t current = calculate_distance(outer_count, inner_count);
            if (current < min_dist) {
                min_dist = current;
            }

            if (current > max_dist) {
                max_dist = current;
            }
            count++;
        }
    }

    zero_address[65] = min_dist;
    zero_address[66] = max_dist;

    free(zero_address);

    return 0;
}