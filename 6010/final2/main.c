#include "newfloat.h"

void printUsage(char *programName);
int validateParameters(int totalBits, int mantissaBits);
void handleConvert(char *programName, int argc, char *bitstring, int totalBits, int mantissaBits);
void handleMinMax(int totalBits, int mantissaBits);
void handleAddHex(char *programName, int argc, char **argv, int totalBits, int mantissaBits);

int main(int argc, char *argv[]) {
    if (argc < 3) {
        printUsage(argv[0]);
        return 1;
    }

    int totalBits = atoi(argv[1]);
    int mantissaBits = atoi(argv[2]);

    if (!validateParameters(totalBits, mantissaBits)) {
        return 1;
    }

    if (strcmp(argv[3], "convert") == 0) {
        handleConvert(argv[0], argc, argv[4], totalBits, mantissaBits);
    } else if (strcmp(argv[3], "minmax") == 0) {
        handleMinMax(totalBits, mantissaBits);
    } else if (strcmp(argv[3], "addhex") == 0) {
        handleAddHex(argv[0], argc, argv, totalBits, mantissaBits);
    } else {
        fprintf(stderr, "Invalid operation specified.\n");
        return 1;
    }

    return 0;
}

void printUsage(char *programName) {
    fprintf(stderr, "Usage: %s <totalBits> <mantissaBits> <operation> [additional arguments]\n", programName);
}

int validateParameters(int totalBits, int mantissaBits) {
    if (totalBits < MIN_TOTAL_BITS || totalBits > MAX_TOTAL_BITS || mantissaBits < 1 || mantissaBits >= totalBits) {
        fprintf(stderr, "Invalid number of bits specified.\n");
        return 0;
    }
    return 1;
}

void handleConvert(char *programName, int argc, char *bitstring, int totalBits, int mantissaBits) {
    if (argc != 5) {
        fprintf(stderr, "Usage: %s <totalBits> <mantissaBits> convert <bitstring>\n", programName);
        return;
    }
    double result = convert(bitstring, totalBits, mantissaBits);
    printf("%.10f\n", result);
}

void handleMinMax(int totalBits, int mantissaBits) {
    minmax(totalBits, mantissaBits);
}

void handleAddHex(char *programName, int argc, char **argv, int totalBits, int mantissaBits) {
    if (argc != 6) {
        fprintf(stderr, "Usage: %s <totalBits> <mantissaBits> addhex <hex1> <hex2>\n", programName);
        return;
    }
    addHex(argv[4], argv[5], totalBits, mantissaBits);
}
