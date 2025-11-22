//
// ContentView.swift
// Splay
// https://www.github.com/aybarsnazlica/Splay
// See LICENSE for license information.
//

import SwiftUI


struct ContentView: View {
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
