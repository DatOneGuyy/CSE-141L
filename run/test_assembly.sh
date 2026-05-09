passed1=$(python assembly/interpreter.py assembly/hamming.asm | grep -c "Passed program 1")
passed2=$(python assembly/interpreter.py assembly/pairs.asm | grep -c "Passed program 2")
passed3=$(python assembly/interpreter.py assembly/multiply.asm | grep -c "Passed program 3")
assembler_error=$(python assembly/assembler.py assembly/combined.asm | grep -c "ERROR")
assembler_warn=$(python assembly/assembler.py assembly/combined.asm | grep -c "WARNING")

if [ "$passed1" -eq 1 ]; then
    echo "Passed program 1"
else
    echo "Failed program 1"
fi

if [ "$passed2" -eq 1 ]; then
    echo "Passed program 2"
else
    echo "Failed program 2"
fi

if [ "$passed3" -eq 1 ]; then
    echo "Passed program 3"
else
    echo "Failed program 3"
fi

if [ "$assembler_error" -gt 0 ]; then
    echo "Failed assembly"
elif [ "$assembler_warn" -gt 0 ]; then
    echo "Passed assembly with $assembler_warn warnings"
else
    echo "Passed assembly"
fi

rm out.mif