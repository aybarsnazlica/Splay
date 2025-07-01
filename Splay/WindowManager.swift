//
// WindowManager.swift
// Splay
// https://www.github.com/aybarsnazlica/Splay
// See LICENSE for license information.
//

import Cocoa

class WindowManager {

    static func splay() {
        guard hasAccessibilityPermission(prompt: true) else {
            print("Accessibility permissions not granted.")
            return
        }

        let windows = getStandardVisibleWindows()
        for window in windows {
            positionWindowRandomly(window)
        }
    }

    private static func hasAccessibilityPermission(prompt: Bool) -> Bool {
        let options: NSDictionary = [
            kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: prompt
        ]
        return AXIsProcessTrustedWithOptions(options)
    }

    private static func getStandardVisibleWindows() -> [AXUIElement] {
        guard
            let windowList = CGWindowListCopyWindowInfo(
                [.optionOnScreenOnly, .excludeDesktopElements],
                kCGNullWindowID
            ) as? [[String: Any]]
        else {
            print("Unable to get window list.")
            return []
        }

        var resultWindows: [AXUIElement] = []

        for window in windowList {
            guard
                let pid = window[kCGWindowOwnerPID as String] as? pid_t,
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
                if isStandardVisibleWindow(axWindow) {
                    resultWindows.append(axWindow)
                }
            }
        }

        return resultWindows
    }

    private static func isStandardVisibleWindow(_ window: AXUIElement) -> Bool {
        var subrole: CFTypeRef?
        guard
            AXUIElementCopyAttributeValue(
                window,
                kAXSubroleAttribute as CFString,
                &subrole
            ) == .success,
            let subroleStr = subrole as? String,
            subroleStr == kAXStandardWindowSubrole as String
        else {
            return false
        }

        var minimized: CFTypeRef?
        if AXUIElementCopyAttributeValue(
            window,
            kAXMinimizedAttribute as CFString,
            &minimized
        ) == .success,
            let isMinimized = minimized as? Bool
        {
            return !isMinimized
        }

        return true
    }

    private static func positionWindowRandomly(_ window: AXUIElement) {
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame

        var windowSize = CGSize(width: 400, height: 300)
        var currentPosition = CGPoint(x: screenFrame.midX, y: screenFrame.midY)

        var sizeRef: CFTypeRef?
        if AXUIElementCopyAttributeValue(
            window,
            kAXSizeAttribute as CFString,
            &sizeRef
        ) == .success,
            let sizeValue = sizeRef,
            AXValueGetType(sizeValue as! AXValue) == .cgSize
        {
            AXValueGetValue(sizeValue as! AXValue, .cgSize, &windowSize)
        }

        var posRef: CFTypeRef?
        if AXUIElementCopyAttributeValue(
            window,
            kAXPositionAttribute as CFString,
            &posRef
        ) == .success,
            let posValue = posRef,
            AXValueGetType(posValue as! AXValue) == .cgPoint
        {
            AXValueGetValue(posValue as! AXValue, .cgPoint, &currentPosition)
        }

        let delta: CGFloat = 30.0
        let xRange =
            max(
                screenFrame.minX,
                currentPosition.x - delta
            )...min(
                screenFrame.maxX - windowSize.width,
                currentPosition.x + delta
            )
        let yRange =
            max(
                screenFrame.minY,
                currentPosition.y - delta
            )...min(
                screenFrame.maxY - windowSize.height,
                currentPosition.y + delta
            )
        let targetPosition = CGPoint(
            x: CGFloat.random(in: xRange),
            y: CGFloat.random(in: yRange)
        )

        let steps = 60
        let duration: TimeInterval = 0.5
        let interval = duration / TimeInterval(steps)
        var step = 0

        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) {
            timer in
            step += 1

            let linearT = CGFloat(step) / CGFloat(steps)
            let t =
                linearT < 0.5
                ? 4 * linearT * linearT * linearT
                : 1 - pow(-2 * linearT + 2, 3) / 2

            var interpolated = CGPoint(
                x: currentPosition.x + (targetPosition.x - currentPosition.x)
                    * t,
                y: currentPosition.y + (targetPosition.y - currentPosition.y)
                    * t
            )

            if let posValue = AXValueCreate(.cgPoint, &interpolated) {
                AXUIElementSetAttributeValue(
                    window,
                    kAXPositionAttribute as CFString,
                    posValue
                )
            }

            if step >= steps {
                timer.invalidate()
            }
        }
    }
}
