#!/usr/bin/env bash

set -o pipefail

BUILD_DIR='build/zip'
DIST_DIR='dist'
lib_dir='build/lib'  # constant


function ensure_dir() {
    [[ -d "$1" ]] || mkdir -p "$1"
}

function clean_dir() {
    rm -rf "$1" && ensure_dir "$1"
}

function log() {
    echo "$@"
}

function indent() {
    sed 's/^/  /'
}

function build_requirements() {
    pip install -r requirements.txt -t "$BUILD_DIR" 2>&1 | indent
    local rc=$?

    return $rc
}

function build_project() {
    clean_dir "$lib_dir"
    python setup.py build 2>&1 | indent
    local rc=$?
    cp -r $lib_dir/* "$BUILD_DIR"

    if [ $? -ne 0 ]; then
        return $?
    else
        return $rc
    fi
}

function pack_zip() {
    local dist_dir=$(realpath $DIST_DIR)
    local pkg_name=$(get_package_name)
    local dest_path="${dist_dir}/${pkg_name}.zip"
    echo "zip to $dest_path" | indent

    cd "$BUILD_DIR" && \
        zip -qr "$dest_path" . 2>&1 | indent
}

function get_package_name() {
    tail -n1 <(python setup.py --fullname)
}

function check_failed() {
    if [ $1 -ne 0 ]; then
        echo "Last command failed, exit $1"
        exit $1
    fi
}


ensure_dir "$BUILD_DIR"
ensure_dir "$DIST_DIR"

log "Build requirements..."
build_requirements
check_failed $?

log "Build project..."
build_project
check_failed $?

log "Pack Zip..."
pack_zip
check_failed $?

echo "Done."
