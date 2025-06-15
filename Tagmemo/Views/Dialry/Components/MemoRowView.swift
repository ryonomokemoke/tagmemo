import SwiftUI

struct MemoRowView: View {
    let memo: SavedMemo
    @Binding var selectedTags: Set<String>
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
                    Button(action: {
                        if selectedTags.contains(tag) {
                            selectedTags.remove(tag)
                        } else {
                            selectedTags.insert(tag)
                        }
                    }) {
                        Text("#\(tag)")
                            .font(.caption)
                            .padding(6)
                            .background(
                                selectedTags.contains(tag) ? Color.green.opacity(0.3) : Color.gray.opacity(0.2)
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(PlainButtonStyle())
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
