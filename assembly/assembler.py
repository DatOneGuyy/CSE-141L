import argparse
import time

start = time.perf_counter()

parser = argparse.ArgumentParser(description="Assembler")
parser.add_argument("name", help="File to read")
parser.add_argument("-o", "--output", help="Output file to write binary to", default="out")

args = parser.parse_args()
print("[INFO] Parsed assembly command line arguments.")

file = open(args.name, "r")
print("[INFO] Found assembly file.")

opcodes = {}
opcodes["jump"] = "001"
opcodes["jumplt"] = "001"
opcodes["call"] = "001"
opcodes["return"] = "001"

opcodes["imm"] = "000"
opcodes["push"] = "000"
opcodes["pop"] = "000"

opcodes["copy"] = "010"

opcodes["dist"] = "011"
opcodes["not"] = "011"
opcodes["and"] = "011"
opcodes["xor"] = "011"
opcodes["addc"] = "011"
opcodes["sub"] = "011"
opcodes["lshiftc"] = "011"
opcodes["halt"] = "011"

opcodes["add"] = "110"

opcodes["lshift"] = "101"
opcodes["rshift"] = "101"

opcodes["load"] = "111"
opcodes["store"] = "111"

opcodes["cmp"] = "100"

def pad_zeroes(input_str, length):
    input_str = "0" * (length - len(input_str)) + input_str
    return input_str

# remove comments and whitespace
data = []
for line in file:
    reduced = line.lstrip()
    if (not reduced.isspace()) and (reduced[:2] != "//") and (reduced != ""):
        left = reduced.split("//")[0].rstrip().replace("\n", "")
        data.append(left)
        # print(left)
        continue
print("[INFO] Removed comments and extra whitespace.")

# identify labels and their addresses
pc = 0
label_count = 1
mapping = {}
delabeled_data = []
for line in data:
    if line[0] == "#":
        if line in mapping.keys():
            print(f"[ERROR] Duplicate label definintion detected at pc value {pc} at line {line}.")
            exit()
        #print(f"Identified label {line} at pc value {pc}")
        mapping[line] = (label_count, pc)
        label_count += 1
    else:
        pc += 1
        delabeled_data.append(line)
print(f"[INFO] Identified {label_count} labels.")
label_memory = ["0" * 13] * 63
label_memory[0] = "0" * 12 + "1"

# detect incorrectly used labels
marked_data = [(line + "`") for line in data]
for entry in mapping:
    token = "none"
    label_memory[mapping[entry][0]] = bin(mapping[entry][1])[2:]
    for line in data:
        if entry in line and len(line.split(" ")) == 2:
            # print(f"first split: {line.split(" ")}")
            token = line.split(" ")[0]
            if token == "jump":
                #print(f"Identified label {entry} as unconditional")
                break
            elif token == "jumplt":
                #print(f"Identified label {entry} as conditional")
                break
            elif token == "call":
                #print(f"Identified label {entry} as a function")
                break

    for line in marked_data:
        if (entry + "`") in line:
            current_token = line.split(" ")[0]
            if current_token != token and current_token[:-1] != entry:
                print(f"[ERROR] Invalid use of label {entry}. First use: {token}, found another use for {current_token}. Labels can only be used with one jump type.")
                exit()
    if token == "none":
        print(f"[WARNING] Label {entry} is never jumped to. Defaulting to unconditional.")
        token = "jump"
    
    label_memory[mapping[entry][0]] = bin(mapping[entry][1])[2:]
    while len(label_memory[mapping[entry][0]]) < 10:
        label_memory[mapping[entry][0]] = "0" + label_memory[mapping[entry][0]]
    match token:
        case "jump":
            label_memory[mapping[entry][0]] += "000"
        case "jumplt":
            label_memory[mapping[entry][0]] += "010"
        case "call":
            label_memory[mapping[entry][0]] += "100"
#for entry in label_memory:
    #print(entry)
print("[INFO] Filled label memory.")

instructions = []
#fill in instructions
for line in delabeled_data:
    #print(f"Assembling line {line}")
    tokens = line.split(" ")
    code = opcodes[tokens[0]]
    match tokens[0]:
        case "jump":
            code += pad_zeroes(bin(mapping[tokens[1]][0])[2:], 6)
        case "call":
            code += pad_zeroes(bin(mapping[tokens[1]][0])[2:], 6)
        case "jumplt":
            code += pad_zeroes(bin(mapping[tokens[1]][0])[2:], 6)
        case "cmp":
            code += pad_zeroes(bin(int(tokens[1][1]))[2:], 3)
            code += pad_zeroes(bin(int(tokens[2][1]))[2:], 3)
        case "copy":
            code += pad_zeroes(bin(int(tokens[1][1]))[2:], 3)
            if len(tokens) == 3:
                code += pad_zeroes(bin(int(tokens[2][1]))[2:], 3)
            else:
                code += "000"
        case "push":
            code += "0"
            code += pad_zeroes(bin(int(tokens[1][1]) - 1)[2:], 2)
            code += "000"
        case "pop":
            code += "100000"
        case "return":
            code += "000000"
        case "imm":
            code += pad_zeroes(bin(int(tokens[1][1]))[2:], 3)
            if tokens[2] == "-1":
                code += "111"
            else:
                code += pad_zeroes(bin(int(tokens[2]))[2:], 3)
        case "load":
            code += pad_zeroes(bin(int(tokens[1][1]))[2:], 3)
            code += "1"
            if len(tokens) == 3:
                code += pad_zeroes(bin(int(tokens[2]))[2:], 2)
            else:
                code += "00"
        case "store":
            code += pad_zeroes(bin(int(tokens[1][1]))[2:], 3)
            code += "0"
            if len(tokens) == 3:
                code += pad_zeroes(bin(int(tokens[2]))[2:], 2)
            else:
                code += "00"
        case "add":
            code += pad_zeroes(bin(int(tokens[1][1]))[2:], 3)
            code += pad_zeroes(bin(int(tokens[2][1]))[2:], 3)
        case "lshift":
            code += pad_zeroes(bin(int(tokens[1][1]))[2:], 3)
            code += "0"
            if tokens[2] == "4":
                code += "00"
            else:
                code += pad_zeroes(bin(int(tokens[2]))[2:], 2)
        case "rshift":
            code += pad_zeroes(bin(int(tokens[1][1]))[2:], 3)
            code += "1"
            if tokens[2] == "4":
                code += "00"
            else:
                code += pad_zeroes(bin(int(tokens[2]))[2:], 2)
        case "dist":
            code += pad_zeroes(bin(int(tokens[1][1]))[2:], 3)
            code += "000"
        case "not":
            code += pad_zeroes(bin(int(tokens[1][1]))[2:], 3)
            code += "001"
        case "and":
            code += pad_zeroes(bin(int(tokens[1][1]))[2:], 3)
            code += "010"
        case "xor":
            code += pad_zeroes(bin(int(tokens[1][1]))[2:], 3)
            code += "011"
        case "addc":
            code += pad_zeroes(bin(int(tokens[1][1]))[2:], 3)
            code += "000"
        case "sub":
            code += pad_zeroes(bin(int(tokens[1][1]))[2:], 3)
            code += "001"
        case "lshiftc":
            code += pad_zeroes(bin(int(tokens[1][1]))[2:], 3)
            code += "010"
        case "halt":
            code += "000111"
        case _:
            print(f"[ERROR] Invalid instruction at {line}.")
            exit()
    
    instructions.append(code)
    if len(code) != 9:
        print(f"[ERROR] Instruction length error on line {line}.")
        print(f"[ERROR] Instruction: {code}.")
        exit()
    #print(code)

print("[INFO] Filled instruction memory.")


file.close()

file = open(args.output + ".mif", "w")

file.write("DEPTH = 1024;\n")
file.write("WIDTH = 9;\n")
file.write("ADDRESS_RADIX = DEC;\n")
file.write("DATA_RADIX = BIN;\n")
file.write("CONTENT\n")
file.write("BEGIN\n")

file.write("\n% Beginning of instruction memory\n\n")
for i in range(len(instructions)):
    file.write(f"{i:4d}        : {instructions[i]};\n")
file.write(f"[{len(instructions)}..895]  : 000000000;\n")
file.write("\n% Beginning of label memory\n\n")

start_point = 896
for i in range(len(label_memory)):
    if i >= label_count:
        file.write(f"[{(i * 2 + start_point)}..1023] : 000000000;\n")
        break
    file.write(f"{(i * 2 + start_point):4d}        : {label_memory[i][:9]};\n")
    file.write(f"{(i * 2 + start_point + 1):4d}        : {(label_memory[i][9:])}00000;\n")


file.write("\nEND;")
print(f"[INFO] Saved machine code to {args.output}.mif.")
file.close()

end = time.perf_counter()
print(f"[INFO] Assembling time: {(end - start) * 1000:.3f} ms.")