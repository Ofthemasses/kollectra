#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)";
TESTS_DIR="$SCRIPT_DIR/../tests";
GENERATED_DIR="$SCRIPT_DIR/../generated";
BUILD_DIR="$SCRIPT_DIR/../build";
ULX3S_CONSTRAINTS="$SCRIPT_DIR/../constraints/ulx3s_v20.lpf"

REQUIRED_COMMANDS=("yosys" "nextpnr-ecp5" "ecppack");

for cmd in ${REQUIRED_COMMANDS[@]}; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "Verified $cmd";
      else
        echo "$cmd cannot be found";
        echo "Exiting..."
        exit 1
    fi
done

# Populate build directories with folders for each output of tests
# Generate Netlists, Config and Bitsreams
generate_bitstreams() {
    local output;
    for dir in "$TESTS_DIR"/*/; do
        dir="${dir%/}";
        dir="${dir##*/}";
        output="$BUILD_DIR/tests/$dir/${dir}_test";
        mkdir -p "$BUILD_DIR/tests/$dir";
        yosys -p "read_verilog $GENERATED_DIR/*;
            read_verilog $TESTS_DIR/$dir/*;
            synth_ecp5 -json $output.json -top Top"
		nextpnr-ecp5 \
			--json "${output}.json" \
			--lpf "${ULX3S_CONSTRAINTS}" \
			--textcfg "${output}.config" \
			--85k \
			--package CABGA381
        ecppack $output.config $output.bit
    done
}

generate_bitstreams;
