#!/usr/bin/env bash

set -x

# Path to the devfile in this sample repository
SAMPLE_PATH="$(pwd)"
DEVFILE_PATH="$SAMPLE_PATH/devfile.yaml"

# Path to the devfile/registry repository (assumed to be cloned as a sibling)
REGISTRY_PATH=${REGISTRY_PATH:-"../registry"}

args=""

if [ ! -z "${1}" ]; then
  args="-odoPath ${1} ${args}"
fi

# Check if devfile exists
if [ ! -f "$DEVFILE_PATH" ]; then
  echo "ERROR: Devfile not found at path $DEVFILE_PATH"
  exit 1
fi

# Check if the devfile/registry test directory exists
if [ ! -d "$REGISTRY_PATH/tests/odov3" ]; then
  echo "ERROR: Registry test directory not found at $REGISTRY_PATH/tests/odov3"
  echo "Please ensure the devfile/registry repository is cloned."
  exit 1
fi

# Get the sample name from the devfile metadata
SAMPLE_NAME=$(yq eval '.metadata.name' "$DEVFILE_PATH")

echo "======================="
echo "Running ODO v3 tests for single sample: ${SAMPLE_NAME}"
echo "Devfile path: ${DEVFILE_PATH}"
echo "Registry path: ${REGISTRY_PATH}"
echo "======================="

# Change to the registry test directory and run the ODO test
cd "$REGISTRY_PATH/tests/odov3"

# Run the ODO test with the single sample
# Note: We pass "." as the stackDirs since we're testing the current sample
ginkgo run --procs 1 \
  --timeout 3h \
  --slow-spec-threshold 120s \
  . -- -stacksPath "$SAMPLE_PATH" -stackDirs "." ${args}

echo "======================="
echo "ODO v3 test completed!"
echo "=======================" 