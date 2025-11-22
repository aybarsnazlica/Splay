//
// ContentView.swift
// Splay
// https://www.github.com/aybarsnazlica/Splay
// See LICENSE for license information.
//

import SwiftUI


/// The main content view of the Splay app's popover UI.
///
/// Displays buttons for triggering the window "splay" action and quitting the application.
struct ContentView: View {
    /// The content and layout of the view.
    ///
    /// Provides a vertical stack containing two buttons: one to invoke window splaying
    /// and another to terminate the application.
    @State private var scale = 5
    
    var body: some View {
        ZStack {
            VStack {
                Stepper(
                    value: $scale,
                    in: 0...25
                    
                ) {
                    Text("Scale by: \(scale)%")
                        .font(.headline)
                }
                .padding(.bottom)
                
                Button("Splay✨") {
                    let normalizedScale = Double(scale) / 100
                    let windowManager = WindowManager(scale: normalizedScale)
                    windowManager.splay()
                }
                .padding(.bottom)
                
                Divider()
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
        .frame(width: 150, height: 150)
    }
}
