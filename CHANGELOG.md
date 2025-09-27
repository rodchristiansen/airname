# Changelog

All notable changes to AirName will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-09-27

### Added
- Swift 6.0 support with strict concurrency checking
- Modern async/await patterns throughout the application
- @MainActor isolation for UI operations
- Structured concurrency with TaskGroup for resource cleanup
- Sendable compliance for thread safety
- Proper workspace notification handling for session changes
- Enhanced tooltip with "Computer Name for AirDrop" description

### Changed
- **BREAKING**: Upgraded minimum macOS requirement to 15.0+
- **BREAKING**: Upgraded Swift version from 5.0 to 6.0
- Completely removed menu interaction functionality
- Redesigned termination handling for multi-user environments
- Improved font styling with semi-bold system font
- Enhanced resource cleanup using structured concurrency

### Fixed
- **CRITICAL**: Fixed loginwindow blocking issues during logout with 60+ user accounts
- Proper handling of TERM and QUIT signals for immediate termination
- Thread safety issues with concurrent access to UI elements
- Memory leaks in notification observers and status item cleanup
- Race conditions during application termination

### Technical Details
- `applicationShouldTerminate()` now returns `.terminateNow` for immediate response
- Async cleanup operations prevent blocking system processes
- Modern Swift concurrency prevents data races and threading issues
- Workspace notifications properly handled with async patterns

### Removed
- Interactive menu functionality (clicking now does nothing)
- Quit menu option and all user interaction
- Legacy completion handler patterns
- Synchronous UI operations that could block the main thread

## [1.0.0] - 2024-11-20

### Added
- Initial release of AirName
- Menu bar display of computer name
- Basic Xcode project structure
- Swift 5.0 implementation
- Interactive menu with quit functionality

### Features
- Shows device name in menu bar
- Tooltip support
- Basic application lifecycle handling
- Xcode project with app icons and entitlements

---

## Migration Guide: v1.x to v2.0

### System Requirements
- Update macOS to 15.0 or later
- Update Xcode to 16.0 or later for development

### Breaking Changes
- **Menu Interaction Removed**: The app no longer responds to clicks. This change was made to prevent accidental interactions and focus purely on display functionality.

- **Swift 6.0 Required**: The codebase has been completely modernized with Swift 6's strict concurrency checking. If extending the app, use modern async/await patterns.

### Benefits of Upgrading
- **Stability**: Eliminates loginwindow blocking issues in multi-user environments
- **Performance**: Modern concurrency patterns provide better responsiveness
- **Safety**: Strict concurrency checking prevents threading issues
- **Future-Proof**: Built on the latest Swift and macOS technologies

### For Developers
If you're extending AirName, note these patterns:
- Use `@MainActor` for UI operations
- Prefer `async/await` over completion handlers  
- Implement `Sendable` for types shared across concurrency boundaries
- Use structured concurrency (`TaskGroup`) for coordinated operations