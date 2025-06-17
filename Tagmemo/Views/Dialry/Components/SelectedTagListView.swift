import SwiftUI

struct SelectedTagListView: View {
    @Binding var selectedTags: Set<String>
    @Binding var negativeSelectedTags: Set<String>
    
    var body: some View {
        if !selectedTags.isEmpty || !negativeSelectedTags.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // ポジティブタグ
                    ForEach(Array(selectedTags).sorted(), id: \.self) { tag in
                        TagChip(
                            tag: tag,
                            isNegative: false,
                            selectedTags: $selectedTags,
                            negativeSelectedTags: $negativeSelectedTags,
                            onRemove: {
                                selectedTags.remove(tag)
                            }
                        )
                    }
                    
                    // ネガティブタグ
                    ForEach(Array(negativeSelectedTags).sorted(), id: \.self) { tag in
                        TagChip(
                            tag: tag,
                            isNegative: true,
                            selectedTags: $selectedTags,
                            negativeSelectedTags: $negativeSelectedTags,
                            onRemove: {
                                negativeSelectedTags.remove(tag)
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 40)
            .background(Color.gray.opacity(0.1))
        }
    }
}

struct TagChip: View {
    let tag: String
    let isNegative: Bool
    @Binding var selectedTags: Set<String>
    @Binding var negativeSelectedTags: Set<String>
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            if isNegative {
                Image(systemName: "minus.circle.fill")
                    .font(.caption)
            }
            Text("#\(tag)")
                .font(.caption)
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            isNegative ? Color.red.opacity(0.3) : Color.green.opacity(0.3)
        )
        .clipShape(Capsule())
        .contextMenu {
            Button(action: {
                // ポジティブに切り替え
                if isNegative {
                    negativeSelectedTags.remove(tag)
                    selectedTags.insert(tag)
                }
            }) {
                Label("このタグを含む", systemImage: "checkmark.circle")
            }
            
            Button(action: {
                // ネガティブに切り替え
                if !isNegative {
                    selectedTags.remove(tag)
                    negativeSelectedTags.insert(tag)
                }
            }) {
                Label("このタグを含まない", systemImage: "xmark.circle")
            }
            
            Divider()
            
            Button(action: onRemove) {
                Label("削除", systemImage: "trash")
            }
        }
    }
}
