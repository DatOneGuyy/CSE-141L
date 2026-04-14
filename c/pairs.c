#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

uint8_t* zero_address;
void initialize() {
    srand(time(NULL));
    zero_address = malloc(sizeof(uint8_t) * 256);
    
    for (int i = 0; i < 64; ++i) {
        int r = rand() & 0xFF;
        zero_address[i] = (uint8_t)r;
    }
}

//software implementation of hardware signed comparison
int lts(uint8_t a, uint8_t b) {
    int8_t signed_a, signed_b;
    memcpy(&signed_a, &a, sizeof(a));
    memcpy(&signed_b, &b, sizeof(b));

    return signed_a < signed_b;
}

int gts(uint8_t a, uint8_t b) {
    int8_t signed_a, signed_b;
    memcpy(&signed_a, &a, sizeof(a));
    memcpy(&signed_b, &b, sizeof(b));

    return signed_a > signed_b;
}

void merge(uint8_t start, uint8_t size, uint8_t* return_index, uint8_t* return_size) {
    int left_index = 0;
    int right_index = 0;

    int left_start = start;
    int right_start = start + size;

    int write_position = start + 64;

    while (left_index < size && right_index < size) {
        uint8_t right_msb = zero_address[right_start + right_index];
        uint8_t left_msb = zero_address[left_start + left_index];

        uint8_t right_lsb = zero_address[right_start + right_index + 1];
        uint8_t left_lsb = zero_address[left_start + left_index + 1];

        //printf("Sources: %d, %d | ", left_start + left_index, right_start + right_index);
        //printf("Read %u/%u, %u/%u\n", left_msb, left_lsb, right_msb, right_lsb);
        
        //printf("Comparing %u/%u, %u/%u\n", left_msb, left_lsb, right_msb, right_lsb);
        //printf("lts: %d\n", lts(left_msb, right_msb));
        //printf("gts: %d\n", gts(left_msb, right_msb));
        //printf("lt: %d\n", left_lsb < right_lsb);
        //printf("start: %u, size: %u, write: %u\n", start, size, write_position);

        if (lts(left_msb, right_msb)) {
            left_index += 2;

            zero_address[write_position] = left_msb;
            zero_address[write_position + 1] = left_lsb;
        } else if (gts(left_msb, right_msb)) {
            right_index += 2;

            zero_address[write_position] = right_msb;
            zero_address[write_position + 1] = right_lsb;
        } else {
            if (left_lsb < right_lsb) {
                left_index += 2;

                zero_address[write_position] = left_msb;
                zero_address[write_position + 1] = left_lsb;
            } else {
                right_index += 2;

                zero_address[write_position] = right_msb;
                zero_address[write_position + 1] = right_lsb;
            }
        }

        write_position += 2;
    }

    while (left_index < size) {
        //printf("[left] start: %u, size: %u, write: %u\n", start, size, write_position);
        uint8_t left_msb = zero_address[left_start + left_index];
        uint8_t left_lsb = zero_address[left_start + left_index + 1];

        zero_address[write_position] = left_msb;
        zero_address[write_position + 1] = left_lsb;

        left_index += 2;
        write_position += 2;
    }

    while (right_index < size) {
        //printf("[right] start: %u, size: %u, write: %u\n", start, size, write_position);
        uint8_t right_msb = zero_address[right_start + right_index];
        uint8_t right_lsb = zero_address[right_start + right_index + 1];

        zero_address[write_position] = right_msb;
        zero_address[write_position + 1] = right_lsb;

        right_index += 2;
        write_position += 2;
    }

    *return_index = start;
    *return_size = size << 1;

    int copy_index = left_start;
    int copy_bound = copy_index + (size << 1);

    while (copy_index < copy_bound) {
        zero_address[copy_index] = zero_address[copy_index + 64];
        zero_address[copy_index + 1] = zero_address[copy_index + 65];

        copy_index += 2;
    }

    return;
}

void merge_sort(uint8_t start, uint8_t size, uint8_t* return_index, uint8_t* return_size) {
    if (size < 4) {
        *return_index = start;
        *return_size = size;
        return;
    }

    uint8_t half_length = size / 2;
    uint8_t left_start = start;
    uint8_t right_start = start + half_length;

    uint8_t left_index, left_size;
    merge_sort(left_start, half_length, &left_index, &left_size);

    uint8_t right_index, right_size;
    merge_sort(right_start, half_length, &right_index, &right_size);

    uint8_t merged_index, merged_size;
    merge(left_start, half_length, &merged_index, &merged_size);

    *return_index = merged_index;
    *return_size = merged_size;
}

void subtract(uint8_t msb1, uint8_t lsb1, uint8_t msb2, uint8_t lsb2, uint8_t* result_msb, uint8_t* result_lsb) {
    uint16_t num1 = (uint16_t)msb1;
    num1 = (num1 << 8) | (uint16_t)lsb1;

    uint16_t num2 = (uint16_t)msb2;
    num2 = (num2 << 8) | (uint16_t)lsb2;

    uint16_t difference = num1 - num2;
    *result_msb = (uint8_t)((difference & 0xFF00) >> 8);
    *result_lsb = (uint8_t)(difference & 0xFF);
}

void print_results() {
    printf("Memory: ");
    for (int i = 0; i < 64; ++i) {
        printf("%d ", zero_address[i]);
    }
}

int main() {
    initialize();
    //print_results();

    uint8_t temp;
    merge_sort(0, 64, &temp, &temp);
    uint8_t max_msb;
    uint8_t max_lsb;

    subtract(zero_address[0], zero_address[1], zero_address[62], zero_address[63], &max_msb, &max_lsb);
    zero_address[66] = max_msb;
    zero_address[67] = max_lsb;

    uint8_t min_diff_msb = 0xFF;
    uint8_t min_diff_lsb = 0xFF;
    for (uint8_t index = 0; index < 62; index += 2) {
        uint8_t first_msb = zero_address[index];
        uint8_t first_lsb = zero_address[index + 1];
        uint8_t second_msb = zero_address[index + 2];
        uint8_t second_lsb = zero_address[index + 3];

        uint8_t current_diff_msb;
        uint8_t current_diff_lsb;
        subtract(first_msb, first_lsb, second_msb, second_lsb, & current_diff_msb, &current_diff_lsb);

        if (current_diff_msb < min_diff_msb) {
            min_diff_msb = current_diff_msb;
            min_diff_lsb = current_diff_lsb;
        } else if (current_diff_msb == min_diff_msb) {
            if (current_diff_lsb < min_diff_lsb) {
                min_diff_msb = current_diff_msb;
                min_diff_lsb = current_diff_lsb;
            }
        }
    }

    zero_address[68] = min_diff_msb;
    zero_address[69] = min_diff_lsb;

    //print_results();
    uint16_t min_diff = (uint16_t)(zero_address[66]);
    min_diff = (min_diff << 8) | (uint16_t)(zero_address[67]);
    uint16_t max_diff = (uint16_t)(zero_address[68]);
    max_diff = (max_diff << 8) | (uint16_t)(zero_address[69]);

    printf("Smallest difference: %u\n", min_diff);
    printf("Largest difference: %u\n", max_diff);

    return 0;
}