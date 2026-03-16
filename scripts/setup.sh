#!/bin/bash
set -euo pipefail

echo "gm00 Development Setup"
echo "======================"

# Check that Xcode (not just CommandLineTools) is installed and functional
if ! xcodebuild -version &> /dev/null; then
    echo "ERROR: Xcode is not installed or not properly configured."
    echo ""
    echo "The active developer directory may point to CommandLineTools instead of Xcode."
    echo "Install Xcode from the App Store, then run:"
    echo "  sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
    exit 1
fi

XCODE_VERSION=$(xcodebuild -version | head -1)
echo "Found: $XCODE_VERSION"

# Check minimum version (Xcode 16+)
MAJOR=$(echo "$XCODE_VERSION" | grep -o '[0-9]*' | head -1)
if [ -z "$MAJOR" ] || [ "$MAJOR" -lt 16 ]; then
    echo "ERROR: Xcode 16+ required. Found: $XCODE_VERSION"
    exit 1
fi

echo ""
echo "Setup complete! To get started:"
echo "  open gm00/gm00.xcodeproj"
echo ""
echo "Build:  xcodebuild -scheme gm00 -destination 'platform=iOS Simulator,name=iPhone 16' build"
echo "Test:   xcodebuild -scheme gm00 -destination 'platform=iOS Simulator,name=iPhone 16' test"
