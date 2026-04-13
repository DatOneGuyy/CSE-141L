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

void merge_sort(uint8_t start, uint8_t size, uint8_t* return_index, uint8_t* return_size) {
    if (size < 4) {
        *return_index = start;
        *return_size = size;
        return;
    }

    uint8_t half_length = size / 2;
    uint8_t left_start = start;
    uint8_t right_start = start + new_length

    uint8_t left_index, left_size;
    merge_sort(left_start, half_length, &left_index, &left_size);

    uint8_t right_start, right_size;
    merge_sort(right_start, half_length, &right_index, &right_size);

    uint8_t merged_index, merged_size;
    merge(left_start, half_length, &merged_index, &merged_size);

    *return_index = merged_index;
    *return_size = merged_size;
}

void merge(uint8_t start, uint8_t size, uint8_t* return_index, uint8_t* return_size) {
    
}

int main() {
    initialize();

    return 0;
}