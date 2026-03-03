#!/bin/bash
set -e

echo "gm00 Development Setup"
echo "======================"

# Check Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "ERROR: Xcode is not installed. Install from the App Store."
    exit 1
fi

XCODE_VERSION=$(xcodebuild -version | head -1)
echo "Found: $XCODE_VERSION"

# Check minimum version (Xcode 16+)
MAJOR=$(echo "$XCODE_VERSION" | grep -o '[0-9]*' | head -1)
if [ "$MAJOR" -lt 16 ]; then
    echo "ERROR: Xcode 16+ required. Found: $XCODE_VERSION"
    exit 1
fi

echo ""
echo "Setup complete! To get started:"
echo "  open gm00/gm00.xcodeproj"
echo ""
echo "Build:  xcodebuild -scheme gm00 -destination 'platform=iOS Simulator,name=iPhone 16' build"
echo "Test:   xcodebuild -scheme gm00 -destination 'platform=iOS Simulator,name=iPhone 16' test"
