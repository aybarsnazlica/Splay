//
// WindowManager.swift
// Splay
// https://www.github.com/aybarsnazlica/Splay
// See LICENSE for license information.
//

import Cocoa

/// A utility for managing and repositioning windows using macOS accessibility APIs.
struct WindowManager {
    /// Moves all standard visible windows to random nearby positions on the screen.
    ///
    /// This method first checks for accessibility permissions. If granted, it retrieves all standard
    /// visible windows and animates each to a randomly offset position.
    static func splay() {
        guard Accessibility.hasPermission(prompt: true) else {
            print("Accessibility permissions not granted.")
            return
        }

        let windows = WindowQuery.getStandardVisibleWindows()
        for window in windows {
            AXWindow(window).animateToRandomNearbyPosition()
        }
    }
}

/// A helper for checking and requesting macOS accessibility permissions.
struct Accessibility {
    /// Checks whether the app has accessibility permissions.
    ///
    /// - Parameter prompt: If `true`, the system may prompt the user to grant accessibility permissions.
    /// - Returns: `true` if the app is trusted to use accessibility features, otherwise `false`.
    static func hasPermission(prompt: Bool) -> Bool {
        let options: NSDictionary = [
            kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: prompt
        ]
        return AXIsProcessTrustedWithOptions(options)
    }
}

