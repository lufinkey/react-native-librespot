#!/bin/bash

# Code adapted from https://ospfranco.com/post/2024/05/08/react-native-rust-module-guide/
>&2 echo "Building rust"

if [ -z "$(which cargo)" ]; then
	>&2 echo "Missing cargo command"
	exit 1
fi
if [ -z "$(which xcodebuild)" ]; then
	>&2 echo "Missing xcodebuild command"
	exit 1
fi

LIB_FILE="libreact_native_librespot.a"
XCFRAMEWORK_FILE="react_native_librespot.xcframework"
XCFRAMEWORK_HEADERS_DIR="include"
export RUST_BACKTRACE=full

cd "$(dirname "$0")" || exit $?
cargo build \
	--target "x86_64-apple-ios" \
	--target "aarch64-apple-ios" \
	--target "aarch64-apple-ios-sim" \
	--release || exit $?
mkdir -p lib || exit $?
mkdir -p lib/ios_simulator || exit $?
if [ -f "lib/ios_simulator/$LIB_FILE" ]; then
	rm -rf "lib/ios_simulator/$LIB_FILE" || exit $?
fi
lipo -create "target/x86_64-apple-ios/release/$LIB_FILE" "target/aarch64-apple-ios-sim/release/$LIB_FILE" -output "lib/ios_simulator/$LIB_FILE" || exit $?
if [ -d "lib/$XCFRAMEWORK_FILE" ]; then
	rm -rf "lib/$XCFRAMEWORK_FILE" || exit $?
fi
xcodebuild -create-xcframework -library "target/aarch64-apple-ios/release/$LIB_FILE" -headers "$XCFRAMEWORK_HEADERS_DIR" -library "lib/ios_simulator/$LIB_FILE" -headers "$XCFRAMEWORK_HEADERS_DIR" -output "lib/$XCFRAMEWORK_FILE" || exit $?
