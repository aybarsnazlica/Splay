//
// WindowManager.swift
// Splay
// https://www.github.com/aybarsnazlica/Splay
// See LICENSE for license information.
//

import Cocoa

class WindowManager {
    static func splay() {
        let options: NSDictionary = [
            kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true
        ]
        guard AXIsProcessTrustedWithOptions(options) else {
            print("Accessibility permissions not granted.")
            return
        }

        guard
            let windowList = CGWindowListCopyWindowInfo(
                [.optionOnScreenOnly, .excludeDesktopElements],
                kCGNullWindowID
            ) as? [[String: Any]]
        else {
            print("Unable to get window list.")
            return
        }

        for window in windowList {
            guard
                let pid = window[kCGWindowOwnerPID as String] as? pid_t,
                NSRunningApplication(processIdentifier: pid) != nil
            else {
                continue
            }

            let axApp = AXUIElementCreateApplication(pid)

            var axWindows: CFTypeRef?
            let result = AXUIElementCopyAttributeValue(
                axApp,
                kAXWindowsAttribute as CFString,
                &axWindows
            )
            if result != .success || axWindows == nil {
                continue
            }

            guard let axWindowList = axWindows as? [AXUIElement] else {
                continue
            }

            for axWindow in axWindowList {
                var subrole: CFTypeRef?
                if AXUIElementCopyAttributeValue(
                    axWindow,
                    kAXSubroleAttribute as CFString,
                    &subrole
                ) == .success,
                    let subroleStr = subrole as? String,
                    subroleStr == kAXStandardWindowSubrole as String
                {

                    var minimized: CFTypeRef?
                    if AXUIElementCopyAttributeValue(
                        axWindow,
                        kAXMinimizedAttribute as CFString,
                        &minimized
                    ) == .success,
                        let isMinimized = minimized as? Bool,
                        !isMinimized
                    {

                        if let screen = NSScreen.main {
                            let screenFrame = screen.visibleFrame

                            var windowSize = CGSize(width: 400, height: 300)  // default fallback size

                            var sizeRef: CFTypeRef?
                            if AXUIElementCopyAttributeValue(
                                axWindow,
                                kAXSizeAttribute as CFString,
                                &sizeRef
                            ) == .success,
                                let sizeValue = sizeRef,
                                AXValueGetType(sizeValue as! AXValue) == .cgSize
                            {
                                AXValueGetValue(
                                    sizeValue as! AXValue,
                                    .cgSize,
                                    &windowSize
                                )
                            }

                            let xRange =
                                screenFrame
                                .minX...(screenFrame.maxX - windowSize.width)
                            let yRange =
                                screenFrame
                                .minY...(screenFrame.maxY - windowSize.height)

                            var position = CGPoint(
                                x: CGFloat.random(in: xRange),
                                y: CGFloat.random(in: yRange)
                            )

                            if let posValue = AXValueCreate(.cgPoint, &position)
                            {
                                AXUIElementSetAttributeValue(
                                    axWindow,
                                    kAXPositionAttribute as CFString,
                                    posValue
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

