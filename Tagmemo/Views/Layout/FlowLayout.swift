//
//  FlowLayout.swift
//  Tagmemo
//
//  Created by りょう on 2025/06/10.
//


import SwiftUI

struct FlowLayout<Content: View>: View {
    let width: CGFloat
    let content: () -> Content

    init(width: CGFloat, @ViewBuilder content: @escaping () -> Content) {
        self.width = width
        self.content = content
    }

    var body: some View {
        let elements = Array(Mirror(reflecting: content()).children)

        var totalWidth: CGFloat = 0
        var rows: [[AnyView]] = [[]]

        for element in elements {
            if let view = element.value as? View {
                let anyView = AnyView(view)
                let size = CGSize(width: 80, height: 32) // だいたいの想定サイズ
                if totalWidth + size.width > width {
                    totalWidth = 0
                    rows.append([])
                }
                rows[rows.count - 1].append(anyView)
                totalWidth += size.width
            }
        }

        return VStack(alignment: .leading, spacing: 8) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack(spacing: 8) {
                    ForEach(0..<rows[rowIndex].count, id: \.self) { itemIndex in
                        rows[rowIndex][itemIndex]
                    }
                }
            }
        }
    }
}
