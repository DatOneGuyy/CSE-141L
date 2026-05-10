cd "$(dirname "$0")"

passed_assembly=$(./test_assembly.sh | grep -c "Passed all assembly tests")
if [ "$passed_assembly" -eq 1 ]; then
    echo "Passed assembly"
else
    echo "Failed assembly"
    exit
fi

passed_arithmetic=$(./test_arithmetic.sh | grep -c "Passed all arithmetic tests") 
if [ "$passed_arithmetic" -eq 1 ]; then
    echo "Passed arithmetic"
else
    echo "Failed arithmetic"
    exit
fi

passed_branching=$(./test_branching.sh | grep -c "Passed all branching tests")
if [ "$passed_branching" -eq 1 ]; then
    echo "Passed branching"
else
    echo "Failed branching"
    exit
fi

echo "Passed all tests"