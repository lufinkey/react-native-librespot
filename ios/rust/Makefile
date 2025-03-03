ARCHS_IOS = x86_64-apple-ios aarch64-apple-ios aarch64-apple-ios-sim
LIB = libreact_native_librespot.a
DYLIB = libreact_native_librespot.so
XCFRAMEWORK = libreact_native_librespot.xcframework

all: ios

ios: $(XCFRAMEWORK)

.PHONY: $(ARCHS_IOS)
$(ARCHS_IOS): %:
	cargo build --target $@ --release

$(XCFRAMEWORK): $(ARCHS_IOS)
	mkdir -p lib
	lipo -create target/x86_64-apple-ios/release/$(LIB) target/aarch64-apple-ios-sim/release/$(LIB) -output lib/$(LIB)
