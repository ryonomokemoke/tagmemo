//
//  TagSearchInputView.swift
//  Tagmemo
//
//  Created by りょう on 2025/06/11.
//


import SwiftUI

struct TagSearchInputView: View {
    @Binding var tagSearchText: String
    let allTags: [String]
    @Binding var selectedTags: Set<String>

    var matchingTags: [String] {
        guard !tagSearchText.isEmpty else { return [] }
        return allTags.filter { $0.localizedCaseInsensitiveContains(tagSearchText) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("タグを検索・追加", text: $tagSearchText)
                .padding(8)
                .background(Color.white.opacity(0.3))
                .cornerRadius(12)
                .padding(.horizontal)
                .onSubmit {
                    let tag = tagSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !tag.isEmpty && !selectedTags.contains(tag) {
                        selectedTags.insert(tag)
                    }
                    tagSearchText = ""
                }

            if !matchingTags.isEmpty {
                VStack(alignment: .leading) {
                    ForEach(matchingTags, id: \.self) { tag in
                        Button(action: {
                            selectedTags.insert(tag)
                            tagSearchText = ""
                        }) {
                            Text("#\(tag)")
                                .padding(6)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(Capsule())
                                .padding(.horizontal)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
}
