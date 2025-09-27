# Contributing to AirName

Thank you for your interest in contributing to AirName! This document provides guidelines and information for contributors.

## Code of Conduct

This project adheres to a code of conduct that we expect project participants to uphold. Please be respectful and constructive in all interactions.

## How to Contribute

### Reporting Bugs

Before creating a bug report, please check the existing issues to see if the problem has already been reported. When creating a bug report, please include:

- A clear and descriptive title
- Steps to reproduce the issue
- Expected vs actual behavior
- Your macOS version and AirName version
- Any relevant console output or screenshots

Use the [bug report template](https://github.com/rodchristiansen/airname/issues/new?template=bug_report.md).

### Suggesting Features

Feature suggestions are welcome! Please use the [feature request template](https://github.com/rodchristiansen/airname/issues/new?template=feature_request.md) and consider:

- Whether the feature aligns with AirName's goals (lightweight, display-only)
- The impact on performance and system resources
- How it would benefit users in multi-user environments

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Follow the development setup** instructions below
3. **Make your changes** following the coding guidelines
4. **Test thoroughly** on macOS 15.0+
5. **Update documentation** if needed
6. **Submit a pull request** with a clear description

## Development Setup

### Prerequisites

- macOS 15.0 or later
- Xcode 16.0 or later
- Swift 6.0 support

### Getting Started

1. Fork and clone the repository:
   ```bash
   git clone https://github.com/[your-username]/airname.git
   cd airname
   ```

2. Open the project in Xcode:
   ```bash
   open AirName.xcodeproj
   ```

3. Build and run the project (⌘+R)

### Project Structure

```
AirName/
├── AirName/
│   ├── AirNameApp.swift       # Main application and AppDelegate
│   ├── ContentView.swift      # Unused SwiftUI view (legacy)
│   ├── Assets.xcassets/       # App icons and assets
│   └── AirName.entitlements   # Sandbox permissions
├── AirNameTests/              # Unit tests (currently minimal)
└── AirNameUITests/            # UI tests (currently minimal)
```

## Coding Guidelines

### Swift 6 Best Practices

AirName uses Swift 6 with strict concurrency checking. Please follow these patterns:

- **Use `@MainActor`** for UI operations:
  ```swift
  @MainActor
  private func updateUI() async {
      // UI updates here
  }
  ```

- **Prefer `async/await`** over completion handlers:
  ```swift
  // Good
  let result = await performAsyncOperation()
  
  // Avoid
  performAsyncOperation { result in
      // completion handler
  }
  ```

- **Implement `Sendable`** for types shared across actors:
  ```swift
  final class MyClass: Sendable {
      // Thread-safe implementation
  }
  ```

- **Use structured concurrency** for coordinated operations:
  ```swift
  await withTaskGroup(of: Void.self) { group in
      group.addTask { await operation1() }
      group.addTask { await operation2() }
  }
  ```

### Code Style

- Follow standard Swift naming conventions
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions focused and single-purpose
- Use proper access control (`private`, `internal`, `public`)

### Performance Considerations

AirName is designed to be lightweight:

- Minimize CPU usage and memory footprint
- Avoid unnecessary background processing  
- Use efficient data structures
- Profile performance-critical code

### System Integration

When working with system APIs:

- Handle termination signals properly
- Clean up resources in `applicationWillTerminate`
- Use appropriate notification patterns
- Test in multi-user environments when possible

## Testing

### Manual Testing

Before submitting:

1. **Build and run** the app successfully
2. **Verify menu bar display** shows computer name correctly
3. **Test termination** with `killall AirName`
4. **Check resource cleanup** (no memory leaks)
5. **Test on different macOS versions** if possible

### Automated Testing

The project uses GitHub Actions for CI:

- Builds are tested on macOS latest
- Both Debug and Release configurations are verified
- SwiftLint checks (when available)

## Documentation

- Update README.md for user-facing changes
- Update CHANGELOG.md following [Keep a Changelog](https://keepachangelog.com/)
- Add inline documentation for public APIs
- Update technical architecture details as needed

## Release Process

Releases are managed by the maintainer:

1. Version bump in Xcode project
2. Update CHANGELOG.md
3. Create release notes
4. Build and notarize release binary
5. Publish on GitHub Releases

## Questions?

- Check existing [Issues](https://github.com/rodchristiansen/airname/issues)
- Start a [Discussion](https://github.com/rodchristiansen/airname/discussions)
- Review the project documentation

Thank you for contributing to AirName!