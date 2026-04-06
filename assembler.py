import argparse
import time

parser = argparse.ArgumentParser(description="Assembler")
parser.add_argument("name", help="File to read")

args = parser.parse_args()

file = open(args.name, "r")

opcodes = {}
opcodes["jump"] = "000"
opcodes["jumplt"] = "000"

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
label_memory = [""] * 64
for entry in mapping:
    token = ""
    label_memory[mapping[entry][0]] = bin(mapping[entry][1])[2:]
    for line in data:
        if entry in line:
            token = line.split(" ")[0]
            if token == entry:
                pass
            elif token == "jump":
                print(f"Identified label {entry} as unconditional")
                break
            elif token == "jumplt":
                print(f"Identified label {entry} as conditional")
                break
            elif token == "call":
                print(f"Identified label {entry} as a function")
                break

    for line in data:
        if entry in line:
            current_token = line.split(" ")[0]
            if current_token != entry and current_token != token:
                print(f"Invalid use of label {entry}. First use: {token}, found another use for {current_token}. Labels can only be used with one jump type.")
                exit()
    

instructions = []
#fill in instructions

end = time.perf_counter()
print(f"Assembling time: {(end - start):.6f} seconds")
file.close()