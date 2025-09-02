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
    var body: some View {
        ZStack {
            VStack {
                Button("Splay Windows ✨") {
                    WindowManager.splay()
                }
                .padding()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
        .frame(width: 200, height: 100)
    }
}
