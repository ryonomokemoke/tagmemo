import SwiftUI

struct MemoRowView: View {
    let memo: SavedMemo
    @Binding var selectedTags: Set<String>
    @Binding var negativeSelectedTags: Set<String>
    var onEdit: () -> Void
    var onDeleteRequest: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 8) {
                // タスク完了チェックマーク
                if memo.isTask {
                    Image(systemName: memo.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundColor(memo.isCompleted ? .green : .gray)
                        .padding(.top, 2)
                }
                
                Text(memo.content)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                    .strikethrough(memo.isCompleted, color: .gray)
                    .foregroundColor(memo.isCompleted ? .gray : .primary)
            }

            HStack {
                if memo.isSecret {
                    Image(systemName: "lock")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                ForEach(memo.tags, id: \.self) { tag in
                    TagButton(
                        tag: tag,
                        isSelected: selectedTags.contains(tag),
                        isNegative: negativeSelectedTags.contains(tag),
                        selectedTags: $selectedTags,
                        negativeSelectedTags: $negativeSelectedTags
                    )
                }

                Spacer()

                Image(systemName: "pencil")
                    .onTapGesture {
                        onEdit()
                    }
            }
        }
        .padding()
        .background(Color.white.opacity(0.3))
        .cornerRadius(16)
        .swipeActions(edge: .trailing) {
            Button {
                onDeleteRequest()
            } label: {
                Label("削除", systemImage: "trash")
            }
            .tint(.red)
        }
    }
}

struct TagButton: View {
    let tag: String
    let isSelected: Bool
    let isNegative: Bool
    @Binding var selectedTags: Set<String>
    @Binding var negativeSelectedTags: Set<String>
    
    @State private var showMenu = false
    
    var body: some View {
        Menu {
            Button(action: {
                // ポジティブ選択
                if selectedTags.contains(tag) {
                    selectedTags.remove(tag)
                } else {
                    selectedTags.insert(tag)
                    negativeSelectedTags.remove(tag)
                }
            }) {
                Label(
                    selectedTags.contains(tag) ? "選択を解除" : "このタグを含む",
                    systemImage: selectedTags.contains(tag) ? "checkmark.circle.fill" : "checkmark.circle"
                )
            }
            
            Button(action: {
                // ネガティブ選択
                if negativeSelectedTags.contains(tag) {
                    negativeSelectedTags.remove(tag)
                } else {
                    negativeSelectedTags.insert(tag)
                    selectedTags.remove(tag)
                }
            }) {
                Label(
                    negativeSelectedTags.contains(tag) ? "除外を解除" : "このタグを含まない",
                    systemImage: negativeSelectedTags.contains(tag) ? "xmark.circle.fill" : "xmark.circle"
                )
            }
        } label: {
            HStack(spacing: 2) {
                if isNegative {
                    Image(systemName: "minus.circle.fill")
                        .font(.caption2)
                }
                Text("#\(tag)")
                    .font(.caption)
            }
            .padding(6)
            .background(
                isNegative ? Color.red.opacity(0.3) :
                isSelected ? Color.green.opacity(0.3) :
                Color.gray.opacity(0.2)
            )
            .clipShape(Capsule())
        }
        .menuStyle(BorderlessButtonMenuStyle())
    }
}
