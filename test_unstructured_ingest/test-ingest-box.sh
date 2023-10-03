#!/usr/bin/env bash

# Set either BOX_APP_CONFIG (app config json content as string) or
# BOX_APP_CONFIG_PATH (path to app config json file) env var

set -e

SCRIPT_DIR=$(dirname "$(realpath "$0")")
cd "$SCRIPT_DIR"/.. || exit 1
OUTPUT_FOLDER_NAME=box
OUTPUT_DIR=$SCRIPT_DIR/structured-output/$OUTPUT_FOLDER_NAME
DOWNLOAD_DIR=$SCRIPT_DIR/download/$OUTPUT_FOLDER_NAME
max_processes=${MAX_PROCESSES:=$(python3 -c "import os; print(os.cpu_count())")}
CI=${CI:-"false"}

# shellcheck disable=SC1091
source "$SCRIPT_DIR"/cleanup.sh
function cleanup() {
  cleanup_dir "$OUTPUT_DIR"
  if [ "$CI" == "true" ]; then
    cleanup_dir "$DOWNLOAD_DIR"
  fi
}
trap cleanup EXIT

if [ -z "$BOX_APP_CONFIG" ] && [ -z "$BOX_APP_CONFIG_PATH" ]; then
   echo "Skipping Box ingest test because neither BOX_APP_CONFIG nor BOX_APP_CONFIG_PATH env vars are set."
   exit 0
fi

if [ -z "$BOX_APP_CONFIG_PATH" ]; then
    # Create temporary service key file
    BOX_APP_CONFIG_PATH=$(mktemp)
    echo "$BOX_APP_CONFIG" >"$BOX_APP_CONFIG_PATH"
fi

PYTHONPATH=. ./unstructured/ingest/main.py \
    box \
    --download-dir "$DOWNLOAD_DIR" \
    --box-app-config "$BOX_APP_CONFIG_PATH" \
    --remote-url box://utic-test-ingest-fixtures \
    --metadata-exclude coordinates,filename,file_directory,metadata.data_source.date_processed,metadata.last_modified,metadata.detection_class_prob,metadata.parent_id,metadata.category_depth \
    --output-dir "$OUTPUT_DIR" \
    --num-processes "$max_processes" \
    --preserve-downloads \
    --recursive \
    --reprocess \
    --verbose

"$SCRIPT_DIR"/check-diff-expected-output.sh $OUTPUT_FOLDER_NAME
