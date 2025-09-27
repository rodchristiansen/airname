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

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.