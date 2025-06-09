//
//  ContentView.swift
//  Splay
//
//  Created by Aybars Nazlica on 2025/06/09.
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
