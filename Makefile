# Simple Makefile for testing Jenkins jobs

# Define variables
PROJECT_NAME = test-project
VERSION = 1.0.0

# Default target
all: build

# Clean up generated files
clean:
	@echo "Cleaning up generated files..."
	@rm -f *.o *.class *.jar

# Full clean (more thorough than regular clean)
fclean: clean
	@echo "Full cleaning..."
	@rm -rf build/ target/ dist/

# Build the project
build:
	@echo "Building $(PROJECT_NAME) version $(VERSION)..."
	@mkdir -p build
	@echo "Build completed successfully!" > build/build-result.txt
	@cat build/build-result.txt

# Run tests
tests_run:
	@echo "Running tests for $(PROJECT_NAME)..."
	@mkdir -p build
	@echo "All tests passed successfully!" > build/test-results.txt
	@cat build/test-results.txt

# Rebuild the project
re: fclean all

# Define phony targets (targets that don't represent files)
.PHONY: all clean fclean build tests_run re
