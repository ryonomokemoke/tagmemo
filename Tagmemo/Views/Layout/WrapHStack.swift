//
//  WrapHStack.swift
//  Tagmemo
//
//  Created by りょう on 2025/06/10.
//


import SwiftUI

struct WrapHStack<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            FlowLayout(width: width, content: content)
        }
    }
}
