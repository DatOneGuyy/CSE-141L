cd ..
cd assembly

passed1=$(python3 interpreter.py hamming.asm | grep -c "Passed program 1")
passed2=$(python3 interpreter.py pairs.asm | grep -c "Passed program 2")
passed3=$(python3 interpreter.py multiply.asm | grep -c "Passed program 3")
assembler_error=$(python3 assembler.py combined.asm | grep -c -i "ERROR")
assembler_warn=$(python3 assembler.py combined.asm | grep -c -i "WARNING")

if [ "$passed1" -eq 1 ]; then
    echo "Passed program 1"
else
    echo "Failed program 1"
    exit
fi

if [ "$passed2" -eq 1 ]; then
    echo "Passed program 2"
else
    echo "Failed program 2"
    exit
fi

if [ "$passed3" -eq 1 ]; then
    echo "Passed program 3"
else
    echo "Failed program 3"
    exit
fi

if [ "$assembler_error" -gt 0 ]; then
    echo "Failed assembly"
    exit
elif [ "$assembler_warn" -gt 0 ]; then
    echo "Passed assembly with $assembler_warn warnings"
else
    echo "Passed assembly"
fi

echo "Passed all assembly tests"

rm out.mif