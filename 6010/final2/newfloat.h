#ifndef NEWFLOAT_H
#define NEWFLOAT_H

#include <math.h>
#include <string.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

// Define constants for special cases
#define NORMAL 0
#define POS_INF 1
#define NEG_INF 2
#define NAN_VAL 3
#define MIN_TOTAL_BITS 8
#define MAX_TOTAL_BITS 64

// Function declarations
double convert(char *bitstring, int totalBits, int mantissaBits);
void minmax(int totalBits, int mantissaBits);
void addHex(char* hex1, char* hex2, int totalBits, int mantissaBits);
int checkSpecialCase(char* binary, int totalBits, int mantissaBits);
void handleSpecialCases(int specialCase1, int specialCase2);
char* hexToBinary(char* hex, int totalBits);
double binaryToFloat(char* binary, int totalBits, int mantissaBits);
char* floatToBinary(double number, int totalBits, int mantissaBits);
char* binaryToHex(char* binary);

#endif // NEWFLOAT_H
