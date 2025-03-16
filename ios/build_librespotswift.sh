#!/bin/sh

action="$1"
if [ -z "$action" ]; then
	action="build"
fi

script_dir="$(cd "$(dirname "$0")" && pwd)"
>&2 echo "Executing in $script_dir"
for config in "Debug" "Release"; do
	for platform in "iphonesimulator" "iphoneos"; do
		>&2 echo ""
		>&2 echo ""
		>&2 echo "Building $config $platform"
		xcodebuild -project "$script_dir/../external/LibrespotSwift/xcode/LibrespotSwift.xcodeproj" -scheme LibrespotSwift -configuration "$CONFIGURATION" -sdk "$platform" "CONFIGURATION_BUILD_DIR=$script_dir/LibrespotSwift/build/$config/$platform" "$action" || exit $?
	done
done
