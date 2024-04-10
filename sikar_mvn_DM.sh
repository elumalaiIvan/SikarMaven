#!/bin/bash
# hosted in ln -s ~/Workspace/Sikar/Learning/SikarMaven/sikar_mvn_DM.sh /usr/local/bin/smvn

# Get the directory of the main script
main_script_dir="$(dirname "$(readlink -f "$0")")"
# imports external scripts
source "$main_script_dir/settings.sh"

# Get the current working directory
current_dir="$(pwd)"
# Load configuration from application.properties
source "$current_dir/pom.sikar"

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

# Function to compile Java files
compile() {
    echo -e "${GREEN}Compiling...${NC}"
    start_time  # Record start time

    mkdir -p "$OUT_DIR"
    CLASSPATH="$OUT_DIR"
    # Add external JAR files to the classpath
    for jar in "${EXTERNAL_JARS[@]}"; do
        jar_path="$JAR_DIR_REPO/$jar"
        if [ -f "$jar_path" ]; then
            CLASSPATH="$CLASSPATH:$jar_path"
        else
            echo "Specified JAR not found: $jar_path"
            exit 1
        fi
    done

    echo "classpath --> $CLASSPATH"

    # Compile Java code
    if ! javac -cp "$CLASSPATH" -Xlint:unchecked -d "$OUT_DIR" $(find "$SRC_DIR" -name "*.java"); then
      echo "Compilation failed"
      exit 1
    fi

    end_time  # Record end time and calculate duration

    echo "Compilation successful"
}

clean() {
    echo -e "${GREEN}Cleaning...${NC}"
    rm -rf "$OUT_DIR" "$JAR_DIR"  # Remove output directories
    echo "Cleaned successfully from $OUT_DIR"
}

# Function to run compiled Java code
run() {
    echo -e "${GREEN}Running...${NC}"
    start_time  # Record start time

    java -cp "$CLASSPATH" "$MAIN_CLASS"

    end_time  # Record end time and calculate duration
}

package() {
    echo -e "${GREEN}Packaging JAR...${NC}"
    start_time  # Record start time

    mkdir -p "$JAR_DIR"

    # Create JAR file (append version information)
    if ! jar -cf "$JAR_DIR/$APPLICATION_NAME-$VERSION.jar" -C "$OUT_DIR" .; then
        echo "Packaging failed"
        exit 1
    fi

    end_time  # Record end time and calculate duration

    echo "Packaging successful"
}

movePackageToLocalRepo() {
    echo "JAR will be moved to local repository"
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
