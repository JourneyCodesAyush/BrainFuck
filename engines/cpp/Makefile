# Compiler and flags
CC = g++ 
CFLAGS = -Wall -g -std=c++17

# Source and header directories
SRC_DIR = src
INC_DIR = src
BUILD_DIR = makeBuild

# Target executable
ifeq ($(OS),Windows_NT)
    TARGET = brainfuck.exe
    MKDIR = if not exist $(BUILD_DIR) mkdir $(BUILD_DIR)
    # recursively find all .cpp and .hpp files
    SRC = $(shell dir /B /S $(SRC_DIR)\*.cpp)
    HDR = $(shell dir /B /S $(SRC_DIR)\*.hpp)
else
    TARGET = brainfuck
    MKDIR = mkdir -p $(BUILD_DIR)
    SRC = $(shell find $(SRC_DIR) -name '*.cpp')
    HDR = $(shell find $(SRC_DIR) -name '*.hpp')
endif

# Flatten object files into makeBuild/
OBJ = $(patsubst %.cpp,$(BUILD_DIR)/%.o,$(notdir $(SRC)))
OBJ := $(subst \,/,$(OBJ))

# Ensure build directory exists
$(shell $(MKDIR))

# Build executable
$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) -I $(INC_DIR) -o $(TARGET) $(OBJ)

# Compile each source file into makeBuild/*.o automatically
define make_compile_rule
$(BUILD_DIR)/$(notdir $(1:.cpp=.o)): $(1)
	$(CC) $(CFLAGS) -I $(INC_DIR) -c $(1) -o $$@
endef

# Generate rules for all sources
$(foreach src,$(SRC),$(eval $(call make_compile_rule,$(src))))

# Clean build files
clean:
ifeq ($(OS),Windows_NT)
	del /Q $(BUILD_DIR)\*.o 2> NUL || true
	del /Q $(TARGET) 2> NUL || true

else
	rm -f $(BUILD_DIR)/*.o
	rm -f $(TARGET)
endif