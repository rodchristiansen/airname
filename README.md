# AirName

A super lightweight macOS menu bar application that displays your computer's name for easy identification for AirDrop transfers.

Great for shared devices environments like offices, labs, and classrooms.

![AirName in Menu Bar](https://img.shields.io/badge/macOS-15.0+-blue) ![Swift](https://img.shields.io/badge/Swift-6.0-orange) ![License](https://img.shields.io/badge/License-MIT-green)

## Features

- **Clean Menu Bar Display**: Shows your Mac's device name in the menu bar with a semi-bold font
- **AirDrop Friendly**: Quickly identify your computer's name when using AirDrop
- **Lightweight**: Minimal resource usage and system impact
- **Swift 6**: Built with modern Swift concurrency and safety features
- **No User Interaction**: no function other than displaying the computer name
- **Dynamic Versioning**: Automatically versioned with `YYYY.MM.DD.HHMM` timestamp format

## Why AirName?

While this is possible to set with macOS built-in Fast User Switching menu bar 'Full Name' option, it includes showing other accounts and the option to switch users, which may not be desirable in some environments, AirName provides a simple, non-interactive menu bar item for displaying the computer name and nothing more.

## Requirements

- macOS 15.0 or later
- Xcode 16.0 or later (for building from source)

## Usage

Once installed, AirName will:
- Automatically display your computer's name in the menu bar
- Show a tooltip with "Computer Name for AirDrop" when hovering
- Run silently in the background with minimal resource usage

## Quick Build and Installation

For a complete production build with signing and notarization:

1. **Configure Environment**: Copy `.env.example` to `.env` and fill in your organization's details:
   ```bash
   cp .env.example .env
   # Edit .env with your Developer ID certificate and Apple ID
   ```

2. **Run Build Script**:
   ```bash
   ./build.sh
   ```

This script will:
1. Load configuration from `.env` file
2. Update the version to the current timestamp (YYYY.MM.DD.HHMM format)
3. Build the release version with your Developer ID code signing
4. Verify the code signature
5. Submit to Apple for notarization (if credentials are provided)
6. Staple the notarization to the app bundle
7. Offer to install to `/Applications/Utilities/AirName.app`

### Configuration File (.env)

The build script uses a `.env` file for organization-specific settings. **Never commit this file to version control** as it contains private information.

Required settings in `.env`:
```bash
DEVELOPER_ID_APP="Developer ID Application: Your Organization Name (TEAMID)"
DEVELOPMENT_TEAM="TEAMID"
BUNDLE_ID="com.yourorg.yourteam.AirName"
APPLE_ID="your@apple.id"
NOTARIZATION_PASSWORD="your-app-specific-password"
```

**Security Note**: The `.env` file is automatically ignored by git to prevent accidental commits of private credentials. Always use `.env.example` as a template and never commit actual credentials to the repository.

Without these credentials, the app will be built and signed with generic settings but not notarized.

## Technical Details

### Architecture
- **Swift 6**: Built with strict concurrency checking and Sendable compliance
- **Async/await**: Modern concurrency patterns for responsive UI and safe threading
- **@MainActor**: Proper actor isolation for UI operations
- **Structured Concurrency**: TaskGroup for coordinated cleanup operations

### Privacy & Security
- **Sandboxed**: Runs with appropriate entitlements for security
- **Local Data Only**: Only accesses the local computer's hostname
- **No Network**: No network connections or data transmission
- **No User Data**: Doesn't access or store personal information

## Configuration

The app reads your computer's name from the system settings. To change the displayed name:

1. Open **System Settings** → **General** → **About**
2. Click on **Name** and enter your desired computer name
3. Restart AirName to see the updated name

## Troubleshooting

### App Not Showing in Menu Bar
- Ensure you have sufficient menu bar space
- Check that the app is running: `ps aux | grep AirName`
- Restart the app if needed

### Permission Issues
- The app requires standard user permissions
- No special permissions or admin access required

### Building from Source
- Requires Xcode 16.0+ with Swift 6.0 support
- Ensure macOS 15.0+ deployment target
- Check that all project targets use Swift version 6.0

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

### Code Style
- Follow Swift 6 concurrency best practices
- Use `@MainActor` for UI operations
- Prefer `async/await` over completion handlers
- Maintain Sendable compliance for thread safety

### Build & Deployment Workflow

1. **Environment Setup**: Configure `.env` file with your organization's certificates and credentials
2. **Development Build**: Use Xcode for testing and debugging
3. **Production Build**: Run `./build.sh` for complete versioning, signing and notarization
4. **Distribution**: Deploy signed and notarized app to target systems

### Version Management

The app uses dynamic versioning with `YYYY.MM.DD.HHMM` format:
- **Marketing Version**: User-facing version (e.g., `2025.09.27.1510`)
- **Build Number**: Internal build identifier (e.g., `202509271510`)
- **Auto-Update**: `./build.sh` automatically sets both values to current timestamp

## Troubleshooting

### App Not Showing in Menu Bar
- Ensure you have sufficient menu bar space
- Check that the app is running: `ps aux | grep AirName`
- Restart the app if needed

### Permission Issues
- The app requires standard user permissions
- No special permissions or admin access required
- For system installation, use `sudo` as shown in installation steps

### Building from Source
- Requires Xcode 16.0+ with Swift 6.0 support
- Ensure macOS 15.0+ deployment target
- Check that all project targets use Swift version 6.0

### Code Signing Issues
- Verify Developer ID certificate is valid
- Check Team ID matches your Apple Developer account
- Ensure proper entitlements are set
- Use `codesign -dv` to verify signature

### Notarization Failures
- Verify Apple ID credentials are correct
- Check that app-specific password is valid
- Ensure Developer ID certificate is not expired
- Review notarization logs for specific errors

## Educational Institution Deployment

This app is particularly well-suited for educational environments:

### Features for Educational Use
- **Multi-User Ready**: Fixes loginwindow blocking in lab environments
- **Institution Signing**: Can be signed with organizational certificates
- **System Location**: Installs to `/Applications/Utilities/` for all users
- **Minimal Interaction**: No user settings or configuration required

### Deployment Steps for IT Administrators

1. **Certificate Setup**: Obtain Developer ID from Apple Developer Program
2. **Build Configuration**: Use institutional bundle identifier and run `./build.sh`
3. **Mass Deployment**: Use tools like Jamf, Munki, or ARD with signed/notarized app
4. **User Experience**: One-time security approval, then seamless operation

### Known Issues & Solutions
- **Loginwindow Blocking**: Resolved in Swift 6 version with proper termination
- **Security Warnings**: Eliminated with proper notarization
- **Menu Bar Space**: Consider user's menu bar density in labs

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.