import SwiftUI

struct TagSearchInputView: View {
    @Binding var tagSearchText: String
    let allTags: [String]
    @Binding var selectedTags: Set<String>
    @Binding var negativeSelectedTags: Set<String>
    
    var matchingTags: [String] {
        guard !tagSearchText.isEmpty else { return [] }
        return allTags.filter { $0.localizedCaseInsensitiveContains(tagSearchText) }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // 検索フィールド
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("タグを検索", text: $tagSearchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)
            
            // 検索結果
            if !matchingTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(matchingTags, id: \.self) { tag in
                            SearchResultTagButton(
                                tag: tag,
                                isSelected: selectedTags.contains(tag),
                                isNegative: negativeSelectedTags.contains(tag),
                                selectedTags: $selectedTags,
                                negativeSelectedTags: $negativeSelectedTags,
                                onTap: {
                                    toggleTag(tag)
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 40)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func toggleTag(_ tag: String) {
        if negativeSelectedTags.contains(tag) {
            negativeSelectedTags.remove(tag)
        } else if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
        tagSearchText = ""
    }
}

struct SearchResultTagButton: View {
    let tag: String
    let isSelected: Bool
    let isNegative: Bool
    let selectedTags: Binding<Set<String>>
    let negativeSelectedTags: Binding<Set<String>>
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 2) {
                if isNegative {
                    Image(systemName: "minus.circle.fill")
                        .font(.caption2)
                }
                Text("#\(tag)")
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                isNegative ? Color.red.opacity(0.3) :
                isSelected ? Color.green.opacity(0.3) :
                Color.blue.opacity(0.2)
            )
            .clipShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button(action: {
                // ポジティブ選択
                if isSelected {
                    selectedTags.wrappedValue.remove(tag)
                } else {
                    selectedTags.wrappedValue.insert(tag)
                    negativeSelectedTags.wrappedValue.remove(tag)
                }
            }) {
                Label(
                    isSelected ? "選択を解除" : "このタグを含む",
                    systemImage: isSelected ? "checkmark.circle.fill" : "checkmark.circle"
                )
            }
            
            Button(action: {
                // ネガティブ選択
                if isNegative {
                    negativeSelectedTags.wrappedValue.remove(tag)
                } else {
                    negativeSelectedTags.wrappedValue.insert(tag)
                    selectedTags.wrappedValue.remove(tag)
                }
            }) {
                Label(
                    isNegative ? "除外を解除" : "このタグを含まない",
                    systemImage: isNegative ? "xmark.circle.fill" : "xmark.circle"
                )
            }
        }
    }
}
