# Compiler and flags
CC = g++ 
CFLAGS = -Wall -g -std=c++17

# Source and header directories
SRC_DIR = prototype
INC_DIR = prototype
BUILD_DIR = makeBuild

# Source and header files
SRC = $(wildcard $(SRC_DIR)/*.cpp)
HDR = $(wildcard $(INC_DIR)/*.hpp)

# Object files in build directory
OBJ = $(patsubst $(SRC_DIR)/%.cpp, $(BUILD_DIR)/%.o, $(SRC))

# Executable
ifeq ($(OS),Windows_NT)
    TARGET = brainfuck.exe
else
    TARGET = brainfuck
endif

# Ensure build directory exists
$(shell mkdir $(BUILD_DIR) 2> NUL)

# Build the executable
$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) -I $(INC_DIR) -o $(TARGET) $(OBJ)

# Compile .cpp to .o and track headers
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.cpp $(HDR)
	$(CC) $(CFLAGS) -I $(INC_DIR) -c $< -o $@


# Clean build files
clean:
ifeq ($(OS),Windows_NT)
	del /Q $(BUILD_DIR)\*.o 2> NUL || true
	del /Q $(TARGET) 2> NUL || true
	
else
	rm -f $(BUILD_DIR)/*.o
	rm -f $(TARGET)
endif