//
// WindowManager.swift
// Splay
// https://www.github.com/aybarsnazlica/Splay
// See LICENSE for license information.
//

import Cocoa

struct WindowManager {
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

struct Accessibility {
    static func hasPermission(prompt: Bool) -> Bool {
        let options: NSDictionary = [
            kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: prompt
        ]
        return AXIsProcessTrustedWithOptions(options)
    }
}


