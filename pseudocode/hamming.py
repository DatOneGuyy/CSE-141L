def program_1_hamming():
    min_dist = 0xFFFF  # initialized to max possible value
    max_dist = 0x0000  # initialized to 0
    array_end = 64

    # outer loop: iterates through every element
    for i in range(0, array_end - 2, 2):
        
        # inner loop: iterates through every element after i
        for j in range(i + 2, array_end, 2):
            
            # note that dist is implemented in hardware
            dist_msb = dist(mem[i], mem[j])
            dist_lsb = dist(mem[i+1], mem[j+1])
            total_dist = dist_msb + dist_lsb

            # update min
            if total_dist < min_dist:
                min_dist = total_dist
                
            # update max
            if total_dist > max_dist:
                max_dist = total_dist

    # store results sequentially in memory
    mem[64] = min_dist
    mem[65] = max_dist