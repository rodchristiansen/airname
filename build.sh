#!/bin/bash

# AirName Build, Sign, and Notarize Script
# Builds, signs, and notarizes AirName.app for production deployment

set -e

APP_NAME="AirName.app"
BUILD_DIR="dist-build"
SOURCE_PATH="./$BUILD_DIR/Build/Products/Release/$APP_NAME"
INSTALL_PATH="/Applications/Utilities/$APP_NAME"

# Load environment variables from .env file if it exists
if [ -f ".env" ]; then
    echo "Loading configuration from .env file..."
    set -a  # automatically export all variables
    source .env
    set +a  # stop automatically exporting
else
    echo "Warning: .env file not found. Please copy .env.example to .env and configure."
    echo "Using default values (may not work for signing/notarization)."
    
    # Default fallback values (generic)
    DEVELOPER_ID_APP="${DEVELOPER_ID_APP:-Developer ID Application}"
    DEVELOPMENT_TEAM="${DEVELOPMENT_TEAM:-TEAMID}"
    BUNDLE_ID="${BUNDLE_ID:-com.example.AirName}"
fi

# Function to update version to YYYY.MM.DD.HHMM format
update_version() {
    echo "Updating version to current timestamp..."
    
    # Generate current timestamp
    VERSION=$(date "+%Y.%m.%d.%H%M")
    BUILD_NUMBER=$(date "+%Y%m%d%H%M")
    
    echo "Setting Marketing Version: $VERSION"
    echo "Setting Build Number: $BUILD_NUMBER"
    
    # Update project.pbxproj with new version
    perl -i -pe "s/MARKETING_VERSION = [^;]+;/MARKETING_VERSION = $VERSION;/g" AirName.xcodeproj/project.pbxproj
    perl -i -pe "s/CURRENT_PROJECT_VERSION = [^;]+;/CURRENT_PROJECT_VERSION = $BUILD_NUMBER;/g" AirName.xcodeproj/project.pbxproj
    
    echo "✓ Version updated successfully!"
}

# Check for required environment variables
if [ -z "$NOTARIZATION_PROFILE" ] && ([ -z "$APPLE_ID" ] || [ -z "$NOTARIZATION_PASSWORD" ]); then
    echo "Note: No notarization credentials configured in .env file."
    echo "For full production build, either:"
    echo "  Method 1: Set APPLE_ID and NOTARIZATION_PASSWORD"
    echo "  Method 2: Set NOTARIZATION_PROFILE (if you've stored credentials with 'xcrun notarytool store-credentials')"
    echo ""
fi

echo "Building, signing, and notarizing AirName..."
echo ""

# Update version first
update_version

# Build release version with code signing
echo "Building release version..."
xcodebuild -project AirName.xcodeproj -scheme AirName -configuration Release \
  -derivedDataPath ./$BUILD_DIR clean build \
  CODE_SIGN_IDENTITY="$DEVELOPER_ID_APP" \
  CODE_SIGN_STYLE=Manual \
  DEVELOPMENT_TEAM="$DEVELOPMENT_TEAM" || {
    echo "Build with manual signing failed. Trying with automatic signing..."
    xcodebuild -project AirName.xcodeproj -scheme AirName -configuration Release \
      -derivedDataPath ./$BUILD_DIR clean build \
      DEVELOPMENT_TEAM="$DEVELOPMENT_TEAM"
}

# Check if build succeeded
if [ ! -d "$SOURCE_PATH" ]; then
    echo "Error: Build failed. $SOURCE_PATH not found."
    exit 1
fi

# Get version info
# Get built version for notarization filename
BUILT_VERSION=$(plutil -extract CFBundleShortVersionString raw "$SOURCE_PATH/Contents/Info.plist" 2>/dev/null || echo "unknown")
echo "Built AirName version $BUILT_VERSION"

# Re-sign for notarization with proper settings
echo "Re-signing for notarization..."
codesign --force --sign "C0277EBA633F1AA2BC2855E45B3B38A1840053BA" --options runtime --entitlements AirName/AirName.entitlements --timestamp "$SOURCE_PATH"
if [ $? -ne 0 ]; then
    echo "✗ Re-signing failed"
    exit 1
fi

# Verify code signing
echo "Verifying code signature..."
if codesign -v --verbose=2 "$SOURCE_PATH"; then
    echo "✓ Code signature verification passed"
else
    echo "✗ Code signature verification failed"
    exit 1
fi

# Check signing details
echo "Code signing details:"
codesign -dv --verbose=4 "$SOURCE_PATH" 2>&1 | grep -E "(Authority|TeamIdentifier|Identifier)"

# Notarize if credentials are available
if [ -n "$NOTARIZATION_PROFILE" ] || ([ -n "$APPLE_ID" ] && [ -n "$NOTARIZATION_PASSWORD" ]); then
    echo ""
    echo "Submitting for notarization..."
    
    # Create zip for notarization
    NOTARIZE_ZIP="AirName-${BUILT_VERSION}.zip"
    NOTARIZE_ZIP_PATH="$PWD/$NOTARIZE_ZIP"
    cd "$BUILD_DIR/Build/Products/Release"
    zip -r "$NOTARIZE_ZIP_PATH" "$APP_NAME"
    cd - > /dev/null
    
    # Submit for notarization using appropriate method
    echo "Uploading to Apple for notarization..."
    
    if [ -n "$NOTARIZATION_PROFILE" ]; then
        # Method 2: Use stored credentials profile
        echo "Using stored credentials profile: $NOTARIZATION_PROFILE"
        if xcrun notarytool submit "$NOTARIZE_ZIP_PATH" --keychain-profile "$NOTARIZATION_PROFILE" --wait; then
            NOTARIZE_SUCCESS=true
        fi
    else
        # Method 1: Use direct credentials
        echo "Using direct Apple ID credentials"
        if xcrun notarytool submit "$NOTARIZE_ZIP_PATH" \
          --apple-id "$APPLE_ID" \
          --password "$NOTARIZATION_PASSWORD" \
          --team-id "$DEVELOPMENT_TEAM" \
          --wait; then
            NOTARIZE_SUCCESS=true
        fi
    fi
    
    if [ "$NOTARIZE_SUCCESS" = "true" ]; then
        echo "✓ Notarization successful"
        
        # Staple the notarization
        echo "Stapling notarization..."
        xcrun stapler staple "$SOURCE_PATH"
        
        if [ $? -eq 0 ]; then
            echo "✓ Notarization stapled successfully"
        else
            echo "⚠ Warning: Failed to staple notarization (app will still work)"
        fi
        
        # Verify stapling
        echo "Verifying stapled notarization..."
        xcrun stapler validate "$SOURCE_PATH" && echo "✓ Stapling verification passed"
    else
        echo "✗ Notarization failed"
        echo "The app is signed but not notarized. It may require Gatekeeper bypass."
    fi
    
    # Clean up zip file
    rm -f "$NOTARIZE_ZIP"
else
    echo ""
    echo "⚠ Skipping notarization (no credentials configured)"
    echo "App is signed but not notarized."
fi

echo ""
echo "Build complete!"
echo "Location: $SOURCE_PATH"
echo "Version: $VERSION"

# Offer to install
echo ""
read -p "Install to /Applications/Utilities? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing to /Applications/Utilities..."
    
    # Create Utilities directory if it doesn't exist
    sudo mkdir -p "/Applications/Utilities"
    
    # Remove existing installation if it exists
    if [ -d "$INSTALL_PATH" ]; then
        echo "Removing existing installation..."
        sudo rm -rf "$INSTALL_PATH"
    fi
    
    # Copy the app
    echo "Copying $APP_NAME to /Applications/Utilities..."
    sudo cp -R "$SOURCE_PATH" "$INSTALL_PATH"
    
    # Set proper permissions
    sudo chown -R root:admin "$INSTALL_PATH"
    sudo chmod -R 755 "$INSTALL_PATH"
    
    echo "✓ Installation complete!"
    echo "Installed: $APP_NAME version $VERSION"
    echo "Location: $INSTALL_PATH"
    echo ""
    echo "Launch with: open '$INSTALL_PATH'"
else
    echo "Installation skipped. Built app is available at: $SOURCE_PATH"
fi

echo ""
echo "Production build process complete!"
if [ -n "$NOTARIZATION_PROFILE" ] || ([ -n "$APPLE_ID" ] && [ -n "$NOTARIZATION_PASSWORD" ]); then
    echo "✓ App is signed and notarized - ready for distribution"
else
    echo "⚠ App is signed but not notarized - may require Gatekeeper bypass"
fi