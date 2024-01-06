# Compiler settings
CC = gcc
CFLAGS = -Wall -Wextra -std=c99

# Libraries to link
LIBS = -lm

# Source files
SOURCES = newfloat.c main.c

# Object files
OBJECTS = $(SOURCES:.c=.o)

# Header files
HEADERS = newfloat.h

# Executable name
EXECUTABLE = newfloat

# Default rule
all: $(EXECUTABLE)

# Linking the program
$(EXECUTABLE): $(OBJECTS)
	$(CC) $(CFLAGS) $(OBJECTS) -o $(EXECUTABLE) $(LIBS)

# Compiling the source files
%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) -c $< -o $@

# Clean up
clean:
	rm -f $(EXECUTABLE) $(OBJECTS)
