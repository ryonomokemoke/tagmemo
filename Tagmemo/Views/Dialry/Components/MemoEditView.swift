import SwiftUI

struct MemoEditView: View {
    @State var memo: SavedMemo
    var onSave: (SavedMemo) -> Void
    let allTags: [String] // 追加: 全ての登録済みタグ

    @State private var newTag: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("メモ編集")
                        .font(.title)

                    TextEditor(text: $memo.content)
                        .frame(minHeight: 200)
                        .border(Color.gray)

                    Toggle(isOn: $memo.isSecret) {
                        HStack {
                            Image(systemName: "lock")
                            Text("秘密メモにする")
                        }
                    }
                    .padding(.top)
                    Toggle(isOn: $memo.isTask) {
                        HStack {
                            Image(systemName: "checkmark.square")
                            Text("タスクにする")
                        }
                    }

                    if memo.isTask {
                        Toggle(isOn: $memo.isCompleted) {
                        }
                    }

                    // 現在のタグ表示
                    VStack(alignment: .leading, spacing: 8) {
                        Text("現在のタグ: \(memo.tags.count)個")
                            .font(.headline)
                        
                        if memo.tags.isEmpty {
                            Text("タグが設定されていません")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.vertical, 8)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(memo.tags, id: \.self) { tag in
                                        Button(action: {
                                            memo.tags.removeAll { $0 == tag }
                                        }) {
                                            HStack(spacing: 4) {
                                                Text(tag)
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.caption)
                                            }
                                            .padding(6)
                                            .background(Color.green.opacity(0.3))
                                            .clipShape(Capsule())
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                            .frame(height: 40)
                        }
                    }

                    // タグ候補表示（入力時のみ）
                    if !newTag.isEmpty && !filteredAvailableTags.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("💡 タグ候補")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(filteredAvailableTags, id: \.self) { tag in
                                        Button(action: {
                                            addExistingTag(tag)
                                        }) {
                                            Text(tag)
                                                .padding(6)
                                                .background(Color.blue.opacity(0.2))
                                                .clipShape(Capsule())
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                            .frame(height: 40)
                        }
                    }

                    // 新しいタグ追加
                    VStack(alignment: .leading, spacing: 8) {
                        Text("新しいタグを追加:")
                            .font(.headline)
                        
                        HStack {
                            TextField("タグ名を入力", text: $newTag)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .focused($isTextFieldFocused)
                                .onChange(of: newTag) { oldValue, newValue in
                                    // リアルタイム検索のため、変更を監視
                                }
                            Button("追加") {
                                addNewTag()
                            }
                            .disabled(newTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }

                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        onSave(memo)
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button(action: {
                            isTextFieldFocused = false
                            hideKeyboard()
                        }) {
                            Image(systemName: "chevron.down")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
    }

    // 現在のメモに含まれていない登録済みタグ
    private var availableTags: [String] {
        allTags.filter { !memo.tags.contains($0) }
    }

    // 入力テキストでフィルタリングされたタグ候補
    private var filteredAvailableTags: [String] {
        let trimmed = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return []
        } else {
            return availableTags.filter { $0.localizedCaseInsensitiveContains(trimmed) }
        }
    }

    private func addNewTag() {
        let trimmed = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !memo.tags.contains(trimmed) {
            memo.tags.append(trimmed)
        }
        newTag = "" // 入力文字列をクリア
    }

    private func addExistingTag(_ tag: String) {
        if !memo.tags.contains(tag) {
            memo.tags.append(tag)
        }
        newTag = "" // 入力文字列をクリア
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
