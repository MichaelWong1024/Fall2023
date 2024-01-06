#!/bin/bash

# Define the path to the executable
EXECUTABLE="./newfloat"

# Define a function to test the convert operation
test_convert() {
    echo "Testing convert with total bits: $1, mantissa bits: $2, bitstring: $3"
    echo "Expected outcome: $4"
    $EXECUTABLE $1 $2 convert $3
    echo
}

# Define a function to test the minmax operation
test_minmax() {
    echo "Testing minmax with total bits: $1, mantissa bits: $2"
    echo "Expected min and max values: $3 and $4"
    $EXECUTABLE $1 $2 minmax
    echo
}

# Define a function to test the addHex operation
test_addHex() {
    echo "Testing addHex with total bits: $1, mantissa bits: $2, hex1: $3, hex2: $4"
    echo "Expected sum in hex: $5"
    $EXECUTABLE $1 $2 addhex $3 $4
    echo
}

# Convert Function Tests
test_convert 32 23 "01000000101000000000000000000000" "5.0"
test_convert 32 23 "11000000010000000000000000000000" "-3.0"
test_convert 16 11 "001110110000" "Varies"
test_convert 8 4 "11011000" "Varies"

# Minmax Function Tests
test_minmax 32 23 "Very small" "Very large"
test_minmax 16 11 "Smaller range" "Larger range"
test_minmax 8 4 "Tiny range" "Small range"

# AddHex Function Tests
test_addHex 32 23 1A 2B "Varies"
test_addHex 32 23 3C3C3C 1A2B2B "Varies"
test_addHex 16 11 FF01 0101 "Varies"
test_addHex 8 4 AA BB "Varies"
test_addHex 64 52 1ABCDEF 1234567 "Varies"

echo "Tests completed."
