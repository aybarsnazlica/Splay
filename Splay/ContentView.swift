//
// ContentView.swift
// Splay
// https://www.github.com/aybarsnazlica/Splay
// See LICENSE for license information.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            VStack {
                Button("Splay Windows ✨") {
                    WindowManager.splay()
                }
                .padding(.top)

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .padding()

            }
        }
        .frame(width: 200, height: 100)
    }
}
