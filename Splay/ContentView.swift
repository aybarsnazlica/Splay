//
// ContentView.swift
// Splay
// https://www.github.com/aybarsnazlica/Splay
// See LICENSE for license information.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Button("Splay Windows") {
                WindowManager.splay()
            }
            .padding()
        }
        .frame(width: 200, height: 100)
    }
}
