//
// AXWindow.swift
// Splay
// https://www.github.com/aybarsnazlica/Splay
// See LICENSE for license information.
//

import Cocoa

/// A wrapper around `AXUIElement` that provides utilities for querying and manipulating window elements.
///
/// This struct is used to check whether a window is a standard visible window and to animate
/// it to a random nearby position using macOS Accessibility APIs.
struct AXWindow {
    private let element: AXUIElement

    init(_ element: AXUIElement) {
        self.element = element
    }

    /// Determines whether the window is a standard, non-minimized window.
    ///
    /// - Returns: `true` if the window is a standard visible window, otherwise `false`.
    func isStandardVisibleWindow() -> Bool {
        var subrole: CFTypeRef?
        guard
            AXUIElementCopyAttributeValue(
                element,
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
            element,
            kAXMinimizedAttribute as CFString,
            &minimized
        ) == .success,
            let isMinimized = minimized as? Bool
        {
            return !isMinimized
        }

        return true
    }

    /// Retrieves the current size of the window.
    ///
    /// - Returns: The size of the window as `CGSize`, or `nil` if it can't be determined.
    func getSize() -> CGSize? {
        var ref: CFTypeRef?
        guard
            AXUIElementCopyAttributeValue(
                element,
                kAXSizeAttribute as CFString,
                &ref
            ) == .success,
            let axValue = ref,
            CFGetTypeID(axValue) == AXValueGetTypeID(),
            AXValueGetType(axValue as! AXValue) == .cgSize
        else {
            return nil
        }

        var size = CGSize()
        AXValueGetValue(axValue as! AXValue, .cgSize, &size)
        return size
    }

    /// Retrieves the current position of the window on screen.
    ///
    /// - Returns: The position of the window as `CGPoint`, or `nil` if it can't be determined.
    func getPosition() -> CGPoint? {
        var ref: CFTypeRef?
        guard
            AXUIElementCopyAttributeValue(
                element,
                kAXPositionAttribute as CFString,
                &ref
            ) == .success,
            let axValue = ref,
            CFGetTypeID(axValue) == AXValueGetTypeID(),
            AXValueGetType(axValue as! AXValue) == .cgPoint
        else {
            return nil
        }

        var point = CGPoint()
        AXValueGetValue(axValue as! AXValue, .cgPoint, &point)
        return point
    }

    /// Animates the window to a given target position using an ease-in-out animation.
    ///
    /// - Parameter target: The target position to animate the window to.
    func animate(to target: CGPoint) {
        guard let origin = getPosition() else { return }
        let steps = 360
        let duration: TimeInterval = 0.3
        let interval = duration / TimeInterval(steps)
        var step = 0

        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) {
            timer in
            step += 1
            let linearT = CGFloat(step) / CGFloat(steps)
            let t = 0.5 - cos(linearT * .pi) / 2
            var interpolated = CGPoint(
                x: origin.x + (target.x - origin.x) * t,
                y: origin.y + (target.y - origin.y) * t
            )
            if let posValue = AXValueCreate(.cgPoint, &interpolated) {
                AXUIElementSetAttributeValue(
                    element,
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
