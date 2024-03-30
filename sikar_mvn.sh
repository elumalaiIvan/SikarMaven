#!/bin/bash

SRC_DIR="src/main/java"
OUT_DIR="target/classes"
MAIN_CLASS="App"

GREEN='\033[0;32m'
NC='\033[0m'
# Function to record start time
start_time() {
    start_time=$(date +%s.%N)
}

# Function to record end time and calculate duration
end_time() {
    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc)

    # Extract seconds, milliseconds, and nanoseconds
    seconds=$(echo "$duration" | cut -d '.' -f 1)
    milliseconds=$(echo "$duration * 1000" | bc | cut -d '.' -f 1)
    nanoseconds=$(echo "$duration * 1000000000" | bc | cut -d '.' -f 1)

    # Calculate milliseconds and nanoseconds
    milliseconds=$((milliseconds % 1000))
    nanoseconds=$((nanoseconds % 1000000000))

    echo "time taken => $seconds:$milliseconds:$nanoseconds"
}

compile() {
    echo -e "${GREEN}Compiling...${NC}"
    start_time  # Record start time

    mkdir -p "$OUT_DIR"

    # Compile Java code
    if ! find "$SRC_DIR" -name "*.java" -exec javac -d "$OUT_DIR" {} +; then
        echo "Compilation failed"
        exit 1
    fi

    end_time  # Record end time and calculate duration

    echo "Compilation successful"
}

clean() {
    echo -e "${GREEN}Cleaning...${NC}"
    rm -rf "$OUT_DIR" "$JAR_DIR"  # Remove output directories
    echo "Cleaned successfully"
}

# Function to run compiled Java code
run() {
    echo -e "${GREEN}Running...${NC}"
    start_time  # Record start time

    java -cp "$OUT_DIR" "$MAIN_CLASS"

    end_time  # Record end time and calculate duration
}

package() {
    echo -e "${GREEN}Packaging JAR...${NC}"
    start_time  # Record start time

    mkdir -p "$JAR_DIR"

    # Create JAR file
    if ! jar -cf "$JAR_DIR/$JAR_NAME" -C "$OUT_DIR"; then
        echo "Packaging failed"
        exit 1
    fi

    end_time  # Record end time and calculate duration

    echo "Packaging successful"
}

movePackageToLocalRepo() {
  echo "jar will be moved to local repo"
}

install() {
  main clean compile run package
}

deploy() {
  main clean compile run package movePackageToLocalRepo
}

# Entry point
main() {
    for function_name in "$@"; do
        if declare -f "$function_name" > /dev/null; then
            "$function_name"
        else
            echo "Function '$function_name' does not exist"
        fi
    done
}

main "$@"
