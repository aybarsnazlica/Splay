//
// AXWindow.swift
// Splay
// https://www.github.com/aybarsnazlica/Splay
// See LICENSE for license information.
//

import Cocoa

struct AXWindow {
    private let element: AXUIElement

    init(_ element: AXUIElement) {
        self.element = element
    }

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

    func animateToRandomNearbyPosition() {
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame

        let size = getSize() ?? CGSize(width: 400, height: 300)
        let origin =
            getPosition() ?? CGPoint(x: screenFrame.midX, y: screenFrame.midY)

        let delta: CGFloat = 60.0
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

    private func getSize() -> CGSize? {
        var sizeRef: CFTypeRef?
        if AXUIElementCopyAttributeValue(
            element,
            kAXSizeAttribute as CFString,
            &sizeRef
        ) == .success,
            let size = sizeRef,
            CFGetTypeID(size) == AXValueGetTypeID(),
            AXValueGetType(size as! AXValue) == .cgSize
        {
            var result = CGSize()
            AXValueGetValue(size as! AXValue, .cgSize, &result)
            return result
        }
        return nil
    }

    private func getPosition() -> CGPoint? {
        var posRef: CFTypeRef?
        if AXUIElementCopyAttributeValue(
            element,
            kAXPositionAttribute as CFString,
            &posRef
        ) == .success,
            let pos = posRef,
            CFGetTypeID(pos) == AXValueGetTypeID(),
            AXValueGetType(pos as! AXValue) == .cgPoint
        {
            var result = CGPoint()
            AXValueGetValue(pos as! AXValue, .cgPoint, &result)
            return result
        }
        return nil
    }
}
