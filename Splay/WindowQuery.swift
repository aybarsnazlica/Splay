//
// WindowQuery.swift
// Splay
// https://www.github.com/aybarsnazlica/Splay
// See LICENSE for license information.
//

import Cocoa

struct WindowQuery {
    static func getStandardVisibleWindows() -> [AXUIElement] {
        guard
            let windowList = CGWindowListCopyWindowInfo(
                [.optionOnScreenOnly, .excludeDesktopElements],
                kCGNullWindowID
            ) as? [[String: Any]]
        else {
            print("Unable to get window list.")
            return []
        }

        var result: [AXUIElement] = []

        for window in windowList {
            guard let pid = window[kCGWindowOwnerPID as String] as? pid_t,
                NSRunningApplication(processIdentifier: pid) != nil
            else {
                continue
            }

            let axApp = AXUIElementCreateApplication(pid)
            var axWindows: CFTypeRef?
            if AXUIElementCopyAttributeValue(
                axApp,
                kAXWindowsAttribute as CFString,
                &axWindows
            ) != .success || axWindows == nil {
                continue
            }

            guard let axWindowList = axWindows as? [AXUIElement] else {
                continue
            }

            for axWindow in axWindowList {
                if AXWindow(axWindow).isStandardVisibleWindow() {
                    result.append(axWindow)
                }
            }
        }

        return result
    }
}
