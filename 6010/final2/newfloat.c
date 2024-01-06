#include "newfloat.h"

// Calculate the exponent from a bitstring, adjusting for the specified bias
int calculateExponent(const char *bitstring, int exponentBits, int bias) {
    int exponent = 0;
    for (int i = 0; i < exponentBits; i++) {
        exponent = exponent * 2 + (bitstring[i + 1] - '0');
    }
    return exponent - bias;
}

// Calculate the exponent from a bitstring, adjusting for the specified bias
double calculateMantissa(const char *bitstring, int mantissaBits, int exponentBits) {
    double mantissa = 1.0; // Implicit leading 1
    for (int i = 0; i < mantissaBits; i++) {
        mantissa += (bitstring[i + 1 + exponentBits] - '0') * pow(2, -1 - i);
    }
    return mantissa;
}

// Check if all mantissa bits in the bitstring are zero
bool isMantissaZero(const char *bitstring, int totalBits, int exponentBits) {
    for (int i = 1 + exponentBits; i < totalBits; i++) {
        if (bitstring[i] != '0') {
            return false;
        }
    }
    return true;
}

// Convert a binary bitstring to its floating-point representation
double convert(char *bitstring, int totalBits, int mantissaBits) {
    if ((int)strlen(bitstring) != totalBits) {
        printf("Error: Bitstring length does not match the specified total bits.\n");
        return 0.0;
    }

    int sign = (bitstring[0] == '0') ? 1 : -1;
    int exponentBits = totalBits - mantissaBits - 1;
    int bias = pow(2, exponentBits - 1) - 1;

    int exponent = calculateExponent(bitstring, exponentBits, bias);
    double mantissa = calculateMantissa(bitstring, mantissaBits, exponentBits);

    bool isAllMantissaZero = isMantissaZero(bitstring, totalBits, exponentBits);

    bool isInfinity = exponent == (1 << exponentBits) - 1 && isAllMantissaZero;
    bool isNaN = exponent == (1 << exponentBits) - 1 && !isAllMantissaZero;

    if (isInfinity) {
        return sign * INFINITY;
    }
    if (isNaN) {
        return NAN;
    }

    return sign * mantissa * pow(2, exponent);
}

// Construct a bitstring representing either the maximum or minimum floating-point value
void constructBitstring(char *bitstring, int totalBits, int exponentBits, int mantissaBits, bool isMax) {
    bitstring[0] = '0'; // Sign bit for positive number

    if (isMax) {
        memset(bitstring + 1, '1', exponentBits - 1);
        bitstring[exponentBits] = '0'; // Avoid infinity
        memset(bitstring + exponentBits + 1, '1', mantissaBits);
    } else {
        memset(bitstring + 1, '0', exponentBits);
        memset(bitstring + exponentBits + 1, '0', mantissaBits - 1);
        bitstring[totalBits - 1] = '1'; // Smallest non-zero mantissa
    }

    bitstring[totalBits] = '\0';
}

// Compute and print the minimum and maximum floating-point values for given bit specifications
void minmax(int totalBits, int mantissaBits) {
    int exponentBits = totalBits - mantissaBits - 1;
    char maxBitstring[totalBits + 1];
    char minBitstring[totalBits + 1];

    constructBitstring(maxBitstring, totalBits, exponentBits, mantissaBits, true);
    constructBitstring(minBitstring, totalBits, exponentBits, mantissaBits, false);

    double minValue = convert(minBitstring, totalBits, mantissaBits);
    double maxValue = convert(maxBitstring, totalBits, mantissaBits);

    printf("Min Positive: %.40f\n", minValue);
    printf("Max: %f\n", maxValue);
}

// Adds two hexadecimal numbers following the custom floating-point format and prints the results.
void addHex(char* hex1, char* hex2, int totalBits, int mantissaBits) {
    // Convert hexadecimal inputs to binary
    char* binary1 = hexToBinary(hex1, totalBits);
    char* binary2 = hexToBinary(hex2, totalBits);

    // Check for special cases (like Infinity)
    int specialCase1 = checkSpecialCase(binary1, totalBits, mantissaBits);
    int specialCase2 = checkSpecialCase(binary2, totalBits, mantissaBits);

    // Print binary representations of inputs
    printf("Binary 1: %s\n", binary1);
    printf("Binary 2: %s\n", binary2);

    // Determine and print the values of each input
    double float1, float2;
    char* value1Str = (specialCase1 == POS_INF) ? "Inf" : ((specialCase1 == NEG_INF) ? "-Inf" : NULL);
    char* value2Str = (specialCase2 == POS_INF) ? "Inf" : ((specialCase2 == NEG_INF) ? "-Inf" : NULL);

    if (value1Str != NULL) {
        printf("Value 1: %s\n", value1Str);
        float1 = (specialCase1 == POS_INF) ? INFINITY : -INFINITY;
    } else {
        float1 = binaryToFloat(binary1, totalBits, mantissaBits);
        printf("Value 1: %f\n", float1);
    }

    if (value2Str != NULL) {
        printf("Value 2: %s\n", value2Str);
        float2 = (specialCase2 == POS_INF) ? INFINITY : -INFINITY;
    } else {
        float2 = binaryToFloat(binary2, totalBits, mantissaBits);
        printf("Value 2: %f\n", float2);
    }

    // Determine the sum and handle special case for Inf and -Inf
    double sum;
    char* sumBinary;
    char* sumHex;
    if ((specialCase1 == POS_INF && specialCase2 == NEG_INF) || (specialCase1 == NEG_INF && specialCase2 == POS_INF)) {
        sum = NAN; // Result is NaN
        sumBinary = floatToBinary(sum, totalBits, mantissaBits);
        sumHex = binaryToHex(sumBinary);
        printf("Sum: nan\n");
    } else {
        sum = float1 + float2;
        sumBinary = floatToBinary(sum, totalBits, mantissaBits);
        sumHex = binaryToHex(sumBinary);
        if (isinf(sum)) {
            printf("Sum: %s\n", (sum > 0) ? "Inf" : "-Inf");
        } else {
            printf("Sum: %f\n", sum);
        }
    }

    // Print binary and hex sums
    printf("Binary Sum: %s\n", sumBinary);
    printf("Hex Sum: %s\n", sumHex);

    // Cleanup
    free(binary1);
    free(binary2);
    free(sumBinary);
    free(sumHex);
}

// Checks and identifies if the binary number is a special case like Infinity or NaN.
int checkSpecialCase(char* binary, int totalBits, int mantissaBits) {
    int exponentBits = totalBits - mantissaBits - 1;
    char* exponent = (char*)malloc(exponentBits + 1);
    char* mantissa = (char*)malloc(mantissaBits + 1);

    if (!exponent || !mantissa) {
        // Handle memory allocation failure
        free(exponent);
        free(mantissa);
        return -1; // Indicates an error
    }

    strncpy(exponent, binary + 1, exponentBits); // Skip the sign bit
    exponent[exponentBits] = '\0';
    strncpy(mantissa, binary + 1 + exponentBits, mantissaBits);
    mantissa[mantissaBits] = '\0';

    // Check for all exponent bits set to 1 (indicative of special cases)
    int allOnes = 1;
    for (int i = 0; i < exponentBits; ++i) {
        if (exponent[i] != '1') {
            allOnes = 0;
            break;
        }
    }

    if (allOnes) {
        // Check mantissa to differentiate between Inf and NaN
        int allZeros = 1;
        for (int i = 0; i < mantissaBits; ++i) {
            if (mantissa[i] != '0') {
                allZeros = 0;
                break;
            }
        }

        free(exponent);
        free(mantissa);

        if (allZeros) {
            // +Inf or -Inf
            return binary[0] == '0' ? POS_INF : NEG_INF;
        } else {
            // NaN
            return NAN_VAL;
        }
    }

    free(exponent);
    free(mantissa);
    return NORMAL; // Not a special case
}

// Converts a hexadecimal string to its binary representation.
char* hexToBinary(char* hex, int totalBits) {
    // Allocate memory for the binary string
    char* binary = (char*)malloc(totalBits + 1);
    if (!binary) {
        printf("Memory allocation failed.\n");
        return NULL;
    }

    binary[0] = '\0'; // Start with an empty string

    // Iterate over each hex character and append its binary representation
    for (int i = 0; hex[i] != '\0'; i++) {
        switch (hex[i]) {
            case '0': strcat(binary, "0000"); break;
            case '1': strcat(binary, "0001"); break;
            case '2': strcat(binary, "0010"); break;
            case '3': strcat(binary, "0011"); break;
            case '4': strcat(binary, "0100"); break;
            case '5': strcat(binary, "0101"); break;
            case '6': strcat(binary, "0110"); break;
            case '7': strcat(binary, "0111"); break;
            case '8': strcat(binary, "1000"); break;
            case '9': strcat(binary, "1001"); break;
            case 'A': case 'a': strcat(binary, "1010"); break;
            case 'B': case 'b': strcat(binary, "1011"); break;
            case 'C': case 'c': strcat(binary, "1100"); break;
            case 'D': case 'd': strcat(binary, "1101"); break;
            case 'E': case 'e': strcat(binary, "1110"); break;
            case 'F': case 'f': strcat(binary, "1111"); break;
            default: 
                printf("Invalid hexadecimal character.\n");
                free(binary);
                return NULL;
        }
    }

    int currentLength = strlen(binary);
    if (currentLength > totalBits) {
        printf("Error: Binary representation exceeds total bits.\n");
        free(binary);
        return NULL;
    }

    // Sign extension
    char signBit = binary[0]; // Determine the sign bit from the first bit of the binary string
    while (currentLength < totalBits) {
        // Prepend the sign bit
        memmove(binary + 1, binary, currentLength + 1);
        binary[0] = signBit;
        currentLength++;
    }

    binary[totalBits] = '\0'; // Null-terminate the string
    return binary;
}

// Converts a binary string to its floating-point representation.
double binaryToFloat(char* binary, int totalBits, int mantissaBits) {
    if (!binary) return NAN; // Check for null pointer

    // Extract the sign from the first bit of the binary string
    int sign = (binary[0] == '0') ? 1 : -1;

    // Calculate the number of bits for the exponent
    int exponentBits = totalBits - mantissaBits - 1;
    int exponent = 0;
    int bias = pow(2, exponentBits - 1) - 1;

    // Extract and calculate the exponent value
    for (int i = 0; i < exponentBits; i++) {
        exponent = exponent * 2 + (binary[i + 1] - '0');
    }
    exponent -= bias;

    // Initialize mantissa value and calculate it by iterating over mantissa bits
    double mantissa = 1.0; // Start with 1.0 due to the implicit leading 1 in normalized numbers
    for (int i = 0; i < mantissaBits; i++) {
        mantissa += (binary[i + 1 + exponentBits] - '0') * pow(2, -1 - i);
    }

    // Check if all mantissa bits are zero (used for determining Infinity)
    bool isAllMantissaZero = true;
    for (int i = 1 + exponentBits; i < totalBits; i++) {
        if (binary[i] != '0') {
            isAllMantissaZero = false;
            break;
        }
    }
    
    // Determine if the number is Infinity or NaN
    bool isInfinity = exponent == (1 << exponentBits) - 1 && isAllMantissaZero;
    bool isNaN = exponent == (1 << exponentBits) - 1 && !isAllMantissaZero;
    if (isInfinity) {
        return sign * INFINITY; // Return Infinity with the correct sign
    }
    if (isNaN) {
        return NAN; // Return NaN
    }

    // Calculate and return the final floating-point value
    return sign * mantissa * pow(2, exponent);
}

// Converts a floating-point number to its binary string representation.
char* floatToBinary(double number, int totalBits, int mantissaBits) {
    int exponentBits = totalBits - mantissaBits - 1;
    int bias = pow(2, exponentBits - 1) - 1;
    char* binary = (char*)malloc(totalBits + 1);

    if (!binary) {
        printf("Memory allocation failed.\n");
        return NULL;
    }

    // Handling sign bit
    binary[0] = (number < 0) ? '1' : '0';
    number = fabs(number);

    // Handling special cases: zero, infinity, and NaN
    if (number == 0) {
        // Set all bits to 0 for zero
        for (int i = 1; i < totalBits; i++) {
            binary[i] = '0';
        }
    } else if (isinf(number)) {
        // Set exponent bits to 1 and mantissa to 0 for infinity
        for (int i = 1; i <= exponentBits; i++) {
            binary[i] = '1';
        }
        for (int i = 1 + exponentBits; i < totalBits; i++) {
            binary[i] = '0';
        }
    } else if (isnan(number)) {
        // Set exponent bits to 1 and at least one mantissa bit to 1 for NaN
        for (int i = 1; i <= exponentBits; i++) {
            binary[i] = '1';
        }
        binary[1 + exponentBits] = '1';
        for (int i = 2 + exponentBits; i < totalBits; i++) {
            binary[i] = '0';
        }
    } else {
        // Normal case: Normalize the number and calculate exponent and mantissa

        // Normalize the number to get the exponent
        int exponent = 0;
        while (number >= 2.0) {
            number /= 2.0;
            exponent++;
        }
        while (number < 1.0) {
            number *= 2.0;
            exponent--;
        }

        // Adjust exponent with bias
        exponent += bias;

        // Convert exponent to binary
        for (int i = exponentBits; i > 0; i--) {
            binary[i] = (exponent % 2) ? '1' : '0';
            exponent /= 2;
        }

        // Convert mantissa to binary
        number -= 1.0; // Remove leading 1
        for (int i = 1 + exponentBits; i < totalBits; i++) {
            number *= 2.0;
            if (number >= 1.0) {
                binary[i] = '1';
                number -= 1.0;
            } else {
                binary[i] = '0';
            }
        }
    }

    binary[totalBits] = '\0'; // Null-terminate the string
    return binary;
}

// Converts a binary string to its hexadecimal representation.
char* binaryToHex(char* binary) {
    // Calculate the length of the binary string and the corresponding hex string length
    int binaryLength = strlen(binary);
    int hexLength = (binaryLength + 3) / 4; // Each hex digit represents 4 binary digits

    // Allocate memory for the hex string (+1 for the null-terminator)
    char* hex = (char*)malloc(hexLength + 1);
    if (!hex) {
        printf("Memory allocation failed.\n");
        return NULL;
    }

    hex[hexLength] = '\0'; // Null-terminate the string

    // Iterate over each group of 4 binary digits to convert to a hex digit
    for (int i = 0; i < hexLength; i++) {
        int value = 0; // Variable to store the decimal value of each 4-bit binary group
        int pow = 1; // Power of 2 (1, 2, 4, 8)
        for (int j = 0; j < 4; j++) {
            // Calculate the index of the binary digit
            int idx = binaryLength - (i * 4 + j) - 1;

            // Convert and add the binary digit value if the index is within the binary string
            if (idx >= 0) {
                value += (binary[idx] - '0') * pow;
            }
            pow *= 2; // Increment the power of 2 for the next bit
        }

        // Convert the decimal value to a hexadecimal digit and store in the hex string
        if (value < 10) {
            hex[hexLength - 1 - i] = '0' + value; // For 0-9
        } else {
            hex[hexLength - 1 - i] = 'A' + (value - 10); // For A-F
        }
    }

    return hex; // Return the hexadecimal string
}
