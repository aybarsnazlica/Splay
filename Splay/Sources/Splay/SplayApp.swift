//
// SplayApp.swift
// Splay
// https://www.github.com/aybarsnazlica/Splay
// See LICENSE for license information.
//

import SwiftUI

/// The main entry point of the Splay application.
///
/// Configures the app's delegate and settings scene. Uses `@main` attribute to indicate the starting point of the app.
@main
struct SplayApp: App {
    /// The application delegate used to handle app-level events and UI setup.
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    /// The main scene of the app, which in this case provides an empty Settings view.
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
