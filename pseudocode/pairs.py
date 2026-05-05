def program_2_pairs():
    # sort the array in place
    merge_sort(start_index=0, size_in_bytes=64)

    # find the difference between the largest and lowest
    max_val = read_signed_16bit(address=62)
    min_val = read_signed_16bit(address=0)
    mem[66:67] = max_val - min_val

    # find the smallest difference between adjacent elements
    min_diff = 0xFFFF
    
    for i in range(0, 62, 2):
        current_val = read_signed_16bit(address=i)
        next_val = read_signed_16bit(address=i+2)

        # subtract adjacent elements
        diff = next_val - current_val

        if diff < min_diff:
            min_diff = diff

    # store the smallest adjacent difference
    mem[68:69] = min_diff

# functions

def merge_sort(start_index, size):
    if size <= 2: 
        return # base case - array length 1 is already
    
    mid = size / 2
    
    # recursively sort left and right halves
    merge_sort(start_index, mid)
    merge_sort(start_index + mid, mid)
    
    # merge sorted halves back together using temporary array at mem[64]
    merge(start_index, mid)

def merge(start_index, half_size):
    # set up pointers for the two halves
    left_start = start_index
    right_start = start_index + half_size
    
    # set up temporary array write pointer (base address is 64)
    write_ptr = 64 + start_index
    
    # initialize byte counters for the two halves
    left_ptr = 0
    right_ptr = 0
    
    # main merge loop
    while left_ptr < half_size and right_ptr < half_size:
        
        # calculate current memory addresses
        left_addr = left_start + left_ptr
        right_addr = right_start + right_ptr
        
        # read top 8 bits
        left_msb = mem[left_addr]
        right_msb = mem[right_addr]
        
        # signed comparison of MSBs
        if signed_less_than(left_msb, right_msb):
            
            # left is smaller so merge this value
            mem[write_ptr]     = mem[left_addr]
            mem[write_ptr + 1] = mem[left_addr + 1]
            left_ptr += 2
            write_ptr += 2
            
        elif signed_greater_than(left_msb, right_msb):
            
            # right is smaller so merge this value
            mem[write_ptr]     = mem[right_addr]
            mem[write_ptr + 1] = mem[right_addr + 1]
            right_ptr += 2
            write_ptr += 2
            
        else:
            # compare LSBs since MSBs are equal
            left_lsb = mem[left_addr + 1]
            right_lsb = mem[right_addr + 1]
            
            if left_lsb < right_lsb:
                # left is smaller
                mem[write_ptr]     = mem[left_addr]
                mem[write_ptr + 1] = mem[left_addr + 1]
                left_ptr += 2
                write_ptr += 2
            else:
                # right is smaller or equal
                mem[write_ptr]     = mem[right_addr]
                mem[write_ptr + 1] = mem[right_addr + 1]
                right_ptr += 2
                write_ptr += 2
                
    # copy remaining elements from half that is still unfinished
    
    while left_ptr < half_size:
        left_addr = left_start + left_ptr
        mem[write_ptr]     = mem[left_addr]
        mem[write_ptr + 1] = mem[left_addr + 1]
        left_ptr += 2
        write_ptr += 2
        
    while right_ptr < half_size:
        right_addr = right_start + right_ptr
        mem[write_ptr]     = mem[right_addr]
        mem[write_ptr + 1] = mem[right_addr + 1]
        right_ptr += 2
        write_ptr += 2
        
    # copy back to original array
    
    total_size = half_size * 2
    
    for i in range(0, total_size, 2):
        temp_addr = 64 + start_index + i
        orig_addr = start_index + i
        
        mem[orig_addr]     = mem[temp_addr]      # copy MSB
        mem[orig_addr + 1] = mem[temp_addr + 1]  # copy LSB
        
    # Return the new bounds for the parent function
    return start_index, total_size