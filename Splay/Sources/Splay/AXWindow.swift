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

    /// Animates the window to a random position near its current location.
    ///
    /// The movement is constrained within the visible screen bounds and uses an ease-in-out animation.
    func animateToRandomNearbyPosition() {
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame

        let size = getSize() ?? CGSize(width: 400, height: 300)
        let origin =
            getPosition() ?? CGPoint(x: screenFrame.midX, y: screenFrame.midY)

        let delta: CGFloat = 120.0
        let xRange =
            max(
                screenFrame.minX,
                origin.x - delta
            )...min(screenFrame.maxX - size.width, origin.x + delta)
        let yRange =
            max(
                screenFrame.minY,
                origin.y - delta
            )...min(screenFrame.maxY - size.height, origin.y + delta)

        let target = CGPoint(
            x: CGFloat.random(in: xRange),
            y: CGFloat.random(in: yRange)
        )

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

    /// Retrieves the current size of the window.
    ///
    /// - Returns: The size of the window as `CGSize`, or `nil` if it can't be determined.
    private func getSize() -> CGSize? {
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
    private func getPosition() -> CGPoint? {
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
}
