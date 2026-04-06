import argparse
import random
import time
import itertools

parser = argparse.ArgumentParser(description="Assembly interpreter")
parser.add_argument("name", help="File to read")

args = parser.parse_args()

file = open(args.name, "r")

start = time.perf_counter()
data = []
for line in file:
    reduced = line.lstrip()
    if (not reduced.isspace()) and (reduced[:2] != "//") and (reduced != ""):
        left = reduced.split("//")[0].rstrip().replace("\n", "")
        data.append(left)
        # print(left)
        continue

registers = [0] * 8
stack = []
pc = 0
less = False

data_memory = []
for i in range(64):
    data_memory.append(random.getrandbits(8))
for i in range(64):
    data_memory.append(0)

def dist(a, b):
    a_bin = bin(a)[2:].zfill(16)
    b_bin = bin(b)[2:].zfill(16)

    sum = 0
    for i in range(16):
        if a_bin[i] != b_bin[i]:
            sum += 1

    return sum

def print_mem():
    out = ""
    for i in range(len(data_memory)):
        out = out + f"[{i}, {data_memory[i]}], "

    print(f"Data memory: {out[:-2]}")

def min_max_hamming_dist(byte_list):
    if len(byte_list) != 64:
        raise ValueError(f"Expected exactly 64 integers, got {len(byte_list)}")

    sixteen_bit_nums = [
        (byte_list[i] << 8) | byte_list[i+1] 
        for i in range(0, 64, 2)
    ]
    
    min_dist = float('inf')
    max_dist = -1
    
    for a, b in itertools.combinations(sixteen_bit_nums, 2):
        dist = (a ^ b).bit_count()
        
        if dist < min_dist:
            min_dist = dist
        if dist > max_dist:
            max_dist = dist
            
    return (int(min_dist), int(max_dist))

def unsigned(n):
    if n < 0:
        n += 256
    return n

mapping = {}
delabeled_data = []
for line in data:
    if line[0] == "#":
        print(f"Identified marker {line} at pc value {pc}")
        mapping[line] = pc
    else:
        pc += 1
        delabeled_data.append(line)

solution = min_max_hamming_dist(data_memory[:64])

def parse_memory_to_signed_16bit(byte_list, big_endian=True):
    """
    Takes a list of 64 bytes and converts them into 32 16-bit two's complement integers.
    
    Args:
        byte_list (list): A list of 64 integers, each between 0 and 255.
        big_endian (bool): If True, treats index `i` as MSB and `i+1` as LSB (your assembly logic).
                           If False, treats index `i` as LSB and `i+1` as MSB (ISA spec standard).
    """
    if len(byte_list) != 64:
        raise ValueError(f"Expected exactly 64 bytes, got {len(byte_list)}")
        
    int16_list = []
    
    for i in range(0, 64, 2):
        if big_endian:
            msb = byte_list[i]
            lsb = byte_list[i+1]
        else:
            lsb = byte_list[i]
            msb = byte_list[i+1]
            
        # Combine the two bytes into a 16-bit unsigned integer
        unsigned_val = (msb << 8) | lsb
        
        # Convert to a signed two's complement integer
        # If the highest bit (bit 15) is 1, the number is negative
        if unsigned_val >= 32768:  # 0x8000
            signed_val = unsigned_val - 65536  # 0x10000
        else:
            signed_val = unsigned_val
            
        int16_list.append(signed_val)
        
    return int16_list
def smallest_diff(input):
    min = 65535
    for i in range(len(input) - 1):
        if input[i + 1] - input[i] < min:
            min = input[i + 1] - input[i]
    return min

pc = 0
data = delabeled_data
counter = 0
flag_count = 0
input_memory = [i for i in data_memory[:64]]
while pc < len(data):
    counter += 1
    line = data[pc]    
    print(f"[{pc:03d}] Current line: {line}")
    tokens = line.split(" ")

    if line == "pause":
        input()

    match tokens[0]:
        case "flag":
            flag_count += 1
        case "not":
            registers[0] = ~registers[int(tokens[1][1:])] & 0xFF
            print(f"Registers: {registers}")
        case "imm":
            registers[int(tokens[1][1:])] = int(tokens[2])
            print(f"Registers: {registers}")
        case "lshift":
            registers[0] = registers[int(tokens[1][1:])] << int(tokens[2])
            print(f"Registers: {registers}")
        case "rshift":
            registers[0] = (registers[int(tokens[1][1:])] % 0x100) >> int(tokens[2])
            print(f"Registers: {registers}")
        case "copy":
            if (len(tokens) == 2):
                registers[int(tokens[1][1:])] = registers[0]
            else:
                registers[int(tokens[1][1:])] = registers[int(tokens[2][1:])]
            print(f"Registers: {registers}")
        case "store":
            if len(tokens) == 2:
                data_memory[registers[int(tokens[1][1:])]] = registers[0]
            else:
                data_memory[registers[int(tokens[1][1:])] + int(tokens[2])] = registers[0]
            print_mem()
        case "add":
            registers[0] = (registers[int(tokens[1][1:])] + registers[int(tokens[2][1:])]) % 256
            print(f"Registers: {registers}")
        case "push":
            frame = registers[1:]
            frame.append(int(tokens[1][1]))

            stack.append(frame)
            print(f"Stack: {stack}")
        case "pop":
            items = stack.pop()
            print(f"Popped {items} from the stack")

            for i in range(1, 8):
                if i >= items[7]:
                    registers[i] = items[i - 1]

            print(f"Registers: {registers}")
            print(f"Stack: {stack}")
        case "call":
            label = tokens[1]
            target = mapping[label]
            stack[-1].append(pc + 1)

            pc = target
            print(f"Stack: {stack}")
            continue
        case "load":
            if len(tokens) == 2:
                registers[0] = data_memory[registers[int(tokens[1][1:])]]
            else:
                registers[0] = data_memory[registers[int(tokens[1][1:])] + int(tokens[2])]
            print(f"Registers: {registers}")
        case "dist":
            registers[0] = dist(registers[int(tokens[1][1:])], registers[0])
            print(f"Registers: {registers}")
        case "cmp":
            less = unsigned(registers[int(tokens[1][1:])]) < unsigned(registers[int(tokens[2][1:])])
            print(f"Flag => less: {less}")
        case "jumplt":
            if less:
                if tokens[1][0] != "#":
                    pc += int(tokens[1])
                    continue
                else:
                    pc = mapping[tokens[1]]
                    continue
        case "jump":
            if tokens[1][0] != "#":
                pc += int(tokens[1])
                continue
            else:
                pc = mapping[tokens[1]]
                continue
        case "return":
            pc = stack[-1][-1]
            print(f"Returned to {pc}")
            continue

    pc += 1
end = time.perf_counter()
print(f"Simulation time: {end - start:.6f} seconds")
print(f"Instructions executed: {counter}")
print(f"Flag count: {flag_count}")
print(f"Original input: {parse_memory_to_signed_16bit(input_memory)}")
print(f"Lower memory: {parse_memory_to_signed_16bit(data_memory[:64])}")
print(f"Upper memory: {parse_memory_to_signed_16bit(data_memory[64:])}")
sorted = parse_memory_to_signed_16bit(input_memory)
sorted.sort()
print(f"Solution: {sorted}")
n = sorted[31] - sorted[0]
m = smallest_diff(sorted)
print(f"Expected: {n}, {m}")
print(f"Result: {data_memory[66] * 256 + data_memory[67]}, {data_memory[68] * 256 + data_memory[69]}")

hamming_solution = min_max_hamming_dist(input_memory)
print(f"\nExpected: {hamming_solution}")
print(f"Result: ({data_memory[64]}, {data_memory[65]})")

"""
print(f"mem[64, 65]: {data_memory[64]:08b}, {data_memory[65]:08b}")
print(f"Solution   : {solution[0]:08b}, {solution[1]:08b}")
"""
file.close()