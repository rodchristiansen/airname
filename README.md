# AirName

A lightweight macOS menu bar application that displays your computer's name for easy identification during AirDrop transfers and network operations.

![AirName in Menu Bar](https://img.shields.io/badge/macOS-15.0+-blue) ![Swift](https://img.shields.io/badge/Swift-6.0-orange) ![License](https://img.shields.io/badge/License-MIT-green)

## Features

- **Clean Menu Bar Display**: Shows your Mac's device name in the menu bar with a semi-bold font
- **AirDrop Friendly**: Quickly identify your computer's name when using AirDrop
- **Lightweight**: Minimal resource usage and system impact
- **System Integration**: Properly handles macOS logout and termination signals
- **Swift 6**: Built with modern Swift concurrency and safety features
- **No User Interaction**: Click-safe design prevents accidental menu interactions

## Why AirName?

When working in environments with multiple Macs (offices, labs, shared spaces), it can be challenging to identify which computer you're trying to AirDrop to. AirName solves this by prominently displaying your computer's name in the menu bar, making it instantly visible when you need it.

Originally created for educational environments with 60+ user accounts, AirName is designed to handle system logout gracefully without blocking the loginwindow process.

## Requirements

- macOS 15.0 or later
- Xcode 16.0 or later (for building from source)

## Installation

### Option 1: Download Release (Coming Soon)
Pre-built releases will be available from the [Releases](https://github.com/rodchristiansen/airname/releases) page.

### Option 2: Build from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/rodchristiansen/airname.git
   cd airname
   ```

2. Open the project in Xcode:
   ```bash
   open AirName.xcodeproj
   ```

3. Build and run the project (⌘+R)

4. The app will appear in your menu bar showing your computer's name

## Usage

Once installed, AirName will:
- Automatically display your computer's name in the menu bar
- Show a tooltip with "Computer Name for AirDrop" when hovering
- Run silently in the background with minimal resource usage
- Handle system logout and termination gracefully

The menu bar item is display-only and doesn't respond to clicks, providing a distraction-free experience.

## Technical Details

### Architecture
- **Swift 6**: Built with strict concurrency checking and Sendable compliance
- **Async/await**: Modern concurrency patterns for responsive UI and safe threading
- **@MainActor**: Proper actor isolation for UI operations
- **Structured Concurrency**: TaskGroup for coordinated cleanup operations

### System Integration
AirName properly implements macOS application lifecycle methods:
- `applicationShouldTerminate()`: Returns `.terminateNow` for immediate response to system signals
- `applicationWillTerminate()`: Performs async cleanup of resources
- Workspace notifications: Handles user session changes gracefully
- Signal handling: Responds to TERM and QUIT signals appropriately

This design prevents the app from blocking system logout processes, which was critical for deployment in multi-user environments.

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

### Development Setup
1. Fork the repository
2. Clone your fork locally
3. Create a feature branch: `git checkout -b feature-name`
4. Make your changes and test thoroughly
5. Submit a pull request

### Code Style
- Follow Swift 6 concurrency best practices
- Use `@MainActor` for UI operations
- Prefer `async/await` over completion handlers
- Maintain Sendable compliance for thread safety

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Rod Christiansen - [@rodchristiansen](https://github.com/rodchristiansen)

## Acknowledgments

- Built for Example Organisation's IT department
- Designed to solve real-world deployment challenges in educational environments
- Inspired by the need for better AirDrop user experience

---

*AirName - Making your Mac easily identifiable, one menu bar at a time.*