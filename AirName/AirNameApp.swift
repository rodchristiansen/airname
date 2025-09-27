//
//  AirNameApp.swift
//  AirName
//
//  Created by Rod Christiansen on 2024-11-20.
//

import SwiftUI
import Foundation

@main
struct DeviceNameMenuBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            // Optionally, add settings here
        }
    }
}

// Swift 6: Make AppDelegate conform to Sendable for concurrency safety
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, Sendable {
    var statusItem: NSStatusItem?

    nonisolated func applicationDidFinishLaunching(_ notification: Notification) {
        Task { @MainActor in
            await setupApplication()
        }
    }
    
    @MainActor
    private func setupApplication() async {
        // Create the status item with variable length
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            // Fetch device name asynchronously
            let deviceName = await getDeviceName()

            // Define semi-bold font with desired size
            let fontSize: CGFloat = 14
            let semiBoldFont = NSFont.systemFont(ofSize: fontSize, weight: .semibold)

            // Define attributes with semi-bold font
            let attributes: [NSAttributedString.Key: Any] = [
                .font: semiBoldFont
            ]

            // Create attributed string with semi-bold attributes
            let attributedTitle = NSAttributedString(string: deviceName, attributes: attributes)

            // Set the attributed title to the button
            button.attributedTitle = attributedTitle

            // Optional: Add tooltip
            button.toolTip = "Computer Name for AirDrop"
            
            // No menu functionality - clicking does nothing
        }

        // Set activation policy to accessory to hide Dock icon
        NSApp.setActivationPolicy(.accessory)
        
        // Register for system notifications to handle logout gracefully
        await setupLogoutNotifications()
    }
    
    @MainActor
    private func getDeviceName() async -> String {
        // Swift 6: Use async/await pattern for potentially slow operations
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let deviceName = Host.current().localizedName ?? "Mac"
                continuation.resume(returning: deviceName)
            }
        }
    }
    
    // Menu functionality completely removed - no interaction when clicked
    // All system termination handlers (applicationShouldTerminate, etc.) remain intact
    
    @MainActor
    private func setupLogoutNotifications() async {
        // Swift 6: Use modern notification handling with async
        let workspaceNotificationCenter = NSWorkspace.shared.notificationCenter
        
        workspaceNotificationCenter.addObserver(
            self,
            selector: #selector(handleLogout),
            name: NSWorkspace.sessionDidBecomeActiveNotification,
            object: nil
        )
        
        workspaceNotificationCenter.addObserver(
            self,
            selector: #selector(handleLogout),
            name: NSWorkspace.sessionDidResignActiveNotification,
            object: nil
        )
        
        // Listen for application termination signals
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTermination),
            name: NSApplication.willTerminateNotification,
            object: nil
        )
    }
    
    @objc nonisolated func handleLogout() {
        // Perform cleanup before logout using async pattern
        Task { @MainActor in
            await cleanupResources()
        }
    }
    
    @objc nonisolated func handleTermination() {
        // Ensure clean termination using async pattern
        Task { @MainActor in
            await cleanupResources()
        }
    }
    
    @MainActor
    private func cleanupResources() async {
        // Swift 6: Async cleanup with proper concurrency handling
        await withTaskGroup(of: Void.self) { group in
            group.addTask { @MainActor in
                // Remove status item
                if let statusItem = self.statusItem {
                    NSStatusBar.system.removeStatusItem(statusItem)
                    self.statusItem = nil
                }
            }
            
            group.addTask {
                // Remove observers on background thread
                await MainActor.run {
                    NSWorkspace.shared.notificationCenter.removeObserver(self)
                    NotificationCenter.default.removeObserver(self)
                }
            }
        }
    }

    nonisolated func applicationWillTerminate(_ notification: Notification) {
        // Ensure cleanup happens with async pattern
        Task { @MainActor in
            await cleanupResources()
        }
    }
    
    // CRITICAL: Override to allow termination
    nonisolated func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        Task { @MainActor in
            await cleanupResources()
        }
        return .terminateNow
    }
    
    // Handle sudden termination gracefully
    nonisolated func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false // Don't quit when windows close, as this is a menu bar app
    }
}
