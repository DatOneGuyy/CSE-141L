def program_3_multiply():
    read_ptr = 0
    write_ptr = 64

    # loop through the first 64 bytes (16 pairs of 16-bit numbers)
    while read_ptr < 64:
        num1 = read_signed_16bit(read_ptr)
        num2 = read_signed_16bit(read_ptr + 2)

        # determine final product's sign
        is_negative = sign_bit(num1) ^ sign_bit(num2)

        # make values positive
        abs_num1 = absolute_value(num1)
        abs_num2 = absolute_value(num2)

        # get unsigned 32-bit product
        product_32bit = multiply_unsigned_16bit(abs_num1, abs_num2)

        # apply sign to the result
        if is_negative:
            product_32bit = negate_32bit(product_32bit)

        # store the result and update the pointers
        write_32bit(write_ptr, product_32bit)
        
        read_ptr += 4
        write_ptr += 4

def multiply_unsigned_16bit(multiplier, multiplicand):
    product = 0
    
    # multiply by shifting from left to right and adding at each step
    for _ in range(16):
        product = product << 1
        
        # check MSB of multiplier using jumppos
        if msb_is_1(multiplier):
            product = product + multiplicand
            
        multiplier = multiplier << 1
        
    return product