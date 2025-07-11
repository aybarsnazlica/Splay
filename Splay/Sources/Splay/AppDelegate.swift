//
// AppDelegate.swift
// Splay
// https://www.github.com/aybarsnazlica/Splay
// See LICENSE for license information.
//

import EventKit
import SwiftUI

/// The application delegate for the Splay app.
///
/// Responsible for setting up the menu bar item, configuring the popover UI, and handling
/// mouse events to toggle visibility of the popover.
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover = NSPopover()

    /// Called when the application has finished launching.
    ///
    /// Sets up the status bar item, popover content, and global mouse event monitor
    /// to handle closing the popover when clicking outside.
    ///
    /// - Parameter notification: The launch notification.
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength
        )
        statusItem?.button?.image = NSImage(named: "StatusBarIcon")
        statusItem?.button?.target = self
        statusItem?.button?.action = #selector(togglePopover)

        let contentView = ContentView()
        popover.contentSize = NSSize(width: 200, height: 100)
        popover.contentViewController = NSHostingController(
            rootView: contentView
        )

        NSEvent.addGlobalMonitorForEvents(matching: [
            .leftMouseDown, .rightMouseDown,
        ]) { [weak self] event in
            guard let self = self else { return }

            if self.popover.isShown {
                self.hidePopover(event)
            }
        }
    }

    /// Displays the popover below the status bar item.
    func showPopover() {
        guard let statusBarButton = statusItem?.button else { return }
        popover.show(
            relativeTo: statusBarButton.bounds,
            of: statusBarButton,
            preferredEdge: .maxY
        )
    }

    /// Hides the currently visible popover.
    ///
    /// - Parameter sender: The object that initiated the hide action.
    func hidePopover(_ sender: Any) {
        popover.performClose(sender)
    }

    /// Toggles the visibility of the popover.
    ///
    /// - Parameter sender: The object that initiated the toggle action.
    @objc func togglePopover(_ sender: Any) {
        if popover.isShown {
            hidePopover(sender)
        } else {
            showPopover()
        }
    }
}
