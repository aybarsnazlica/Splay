//
// AppDelegate.swift
// Splay
// https://www.github.com/aybarsnazlica/Splay
// See LICENSE for license information.
//

import EventKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover = NSPopover()

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

    func showPopover() {
        guard let statusBarButton = statusItem?.button else { return }
        popover.show(
            relativeTo: statusBarButton.bounds,
            of: statusBarButton,
            preferredEdge: .maxY
        )
    }

    func hidePopover(_ sender: Any) {
        popover.performClose(sender)
    }

    @objc func togglePopover(_ sender: Any) {
        if popover.isShown {
            hidePopover(sender)
        } else {
            showPopover()
        }
    }
}
