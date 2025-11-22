//
// WindowManager.swift
// Splay
// https://www.github.com/aybarsnazlica/Splay
// See LICENSE for license information.
//

import Cocoa

/// A utility for managing and repositioning windows using macOS accessibility APIs.
struct WindowManager {
    
    /// The multiplicative factor applied to vectors from the screen center when splaying windows.
    private(set) var scale = 0.0

    /// Moves all standard visible windows radially outward from the screen center.
    ///
    /// This method first checks for accessibility permissions. If granted, it retrieves all
    /// standard visible windows and animates each to a new position scaled relative to the
    /// window's vector from the screen center.
    func splay() {
        guard Accessibility.hasPermission(prompt: true) else {
            print("Accessibility permissions not granted.")
            return
        }

        let windows = WindowQuery.getStandardVisibleWindows()
        let axWindows = windows.map { AXWindow($0) }
        guard let screen = NSScreen.main else { return }
        let frame = screen.visibleFrame
        let center = CGPoint(x: frame.midX, y: frame.midY)

        for axWin in axWindows {
            guard let origin = axWin.getPosition(),
                let size = axWin.getSize()
            else { continue }
            let vector = CGVector(
                dx: origin.x - center.x,
                dy: origin.y - center.y
            )
            
            let scale: CGFloat = 1.0 + scale
            
            var target = CGPoint(
                x: center.x + vector.dx * scale,
                y: center.y + vector.dy * scale
            )
            
            // Clamp to visible frame to prevent moving outside screen
            let clampedX = max(
                frame.minX,
                min(target.x, frame.maxX - size.width)
            )
            let clampedY = max(
                frame.minY,
                min(target.y, frame.maxY - size.height)
            )
            target = CGPoint(x: clampedX, y: clampedY)
            axWin.animate(to: target)
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

