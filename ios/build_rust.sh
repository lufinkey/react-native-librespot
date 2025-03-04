#!/bin/bash

if [ -z "$(which make)" ]; then
	>&2 echo "Missing make command"
	exit 1
fi

if [ -z "$(which cargo)" ]; then
	>&2 echo "Missing cargo command"
	exit 1
fi

LIB_FILE="libreact_native_librespot.a"
export RUST_BACKTRACE=full

cd "$(dirname "$0")/rust" || exit $?
cargo build \
	--target "x86_64-apple-ios" \
	--target "aarch64-apple-ios" \
	--target "aarch64-apple-ios-sim" \
	--release || exit $?
mkdir -p lib || exit $?
lipo -create "target/x86_64-apple-ios/release/$LIB_FILE" "target/aarch64-apple-ios-sim/release/$LIB_FILE" -output "lib/$LIB_FILE" || exit $?
