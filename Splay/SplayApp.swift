//
//  SplayApp.swift
//  Splay
//
//  Created by Aybars Nazlica on 2025/06/09.
//

import SwiftUI

@main
struct SplayApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
