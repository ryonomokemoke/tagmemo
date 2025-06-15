//
//  SelectedTagListView.swift
//  Tagmemo
//
//  Created by りょう on 2025/06/11.
//


import SwiftUI

struct SelectedTagListView: View {
    @Binding var selectedTags: Set<String>

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(Array(selectedTags), id: \.self) { tag in
                    Button(action: {
                        selectedTags.remove(tag)
                    }) {
                        Text("#\(tag)")
                            .font(.caption)
                            .padding(6)
                            .background(Color.green.opacity(0.3))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                if !selectedTags.isEmpty {
                    Button("クリア") {
                        selectedTags.removeAll()
                    }
                    .font(.caption)
                    .padding(6)
                }
            }
            .padding(.horizontal)
        }
    }
}
