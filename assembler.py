import argparse
import time

parser = argparse.ArgumentParser(description="Assembler")
parser.add_argument("name", help="File to read")

args = parser.parse_args()

file = open(args.name, "r")

opcodes = {}
opcodes["jump"] = "000"
opcodes["jumplt"] = "000"
opcodes["call"] = "000"

opcodes["cmp"] = "001"

opcodes["copy"] = "010"

opcodes["return"] = "011"
opcodes["push"] = "011"
opcodes["pop"] = "011"
opcodes["imm"] = "011"

opcodes["load"] = "100"
opcodes["store"] = "100"

opcodes["add"] = "101"

opcodes["lshift"] = "110"
opcodes["rshift"] = "110"

opcodes["dist"] = "111"
opcodes["not"] = "111"

def pad_zeroes(input_str, length):
    input_str = "0" * (length - len(input_str)) + input_str
    return input_str

start = time.perf_counter()

# remove comments and whitespace
data = []
for line in file:
    reduced = line.lstrip()
    if (not reduced.isspace()) and (reduced[:2] != "//") and (reduced != ""):
        left = reduced.split("//")[0].rstrip().replace("\n", "")
        data.append(left)
        # print(left)
        continue

# identify labels and their addresses
pc = 0
label_count = 0
mapping = {}
delabeled_data = []
for line in data:
    if line[0] == "#":
        if line in mapping.keys():
            print(f"Duplicate label definintion detected at pc value {pc}. Exiting")
            exit()
        print(f"Identified label {line} at pc value {pc}")
        mapping[line] = (label_count, pc)
        label_count += 1
    else:
        pc += 1
        delabeled_data.append(line)
print(f"Identified {label_count} labels")
label_memory = ["000000000000"] * 64

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
                print(f"Identified label {entry} as unconditional")
                break
            elif token == "jumplt":
                print(f"Identified label {entry} as conditional")
                break
            elif token == "call":
                print(f"Identified label {entry} as a function")
                break

    for line in marked_data:
        if (entry + "`") in line:
            current_token = line.split(" ")[0]
            if current_token != token and current_token[:-1] != entry:
                print(f"Invalid use of label {entry}. First use: {token}, found another use for {current_token}. Labels can only be used with one jump type.")
                exit()
    if token == "none":
        print(f"Label {entry} is never jumped to. Defaulting to unconditional.")
        token = "jump"
    
    label_memory[mapping[entry][0]] = bin(mapping[entry][1])[2:]
    while len(label_memory[mapping[entry][0]]) < 10:
        label_memory[mapping[entry][0]] = "0" + label_memory[mapping[entry][0]]
    match token:
        case "jump":
            label_memory[mapping[entry][0]] += "00"
        case "jumplt":
            label_memory[mapping[entry][0]] += "01"
        case "call":
            label_memory[mapping[entry][0]] += "10"
#for entry in label_memory:
    #print(entry)
print("Filled label memory.")

instructions = []
#fill in instructions
for line in delabeled_data:
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
            code += pad_zeroes(bin(tokens[1][1])[2:], 3)
            code += pad_zeroes(bin(tokens[2][1])[2:], 3)
    
    instructions.append(code)

for line in instructions:
    print(line)

end = time.perf_counter()
print(f"Assembling time: {(end - start):.6f} seconds")
file.close()