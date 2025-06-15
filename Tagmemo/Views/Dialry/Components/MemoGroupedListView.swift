import SwiftUI

struct MemoGroupedListView: View {
    @ObservedObject var memoStore: MemoStore
    @Binding var selectedTags: Set<String>
    var onEdit: (SavedMemo) -> Void

    @State private var showSecretMemos = false
    @State private var showCompletedTasks = true
    @State private var alertType: AlertType? = nil
    
    // 編集用の状態変数
    @State private var editingMemoId: UUID? = nil
    @State private var editingMemo: SavedMemo = SavedMemo(
        id: UUID(),
        content: "",
        date: Date(),
        tags: []
    )
    @State private var newTag: String = ""
    @FocusState private var isTextFieldFocused: Bool

    enum AlertType: Identifiable {
        case secretConfirmation
        case deleteConfirmation(SavedMemo)
        
        var id: String {
            switch self {
            case .secretConfirmation: return "secret"
            case .deleteConfirmation: return "delete"
            }
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(Array(groupedFilteredMemos.enumerated()), id: \.element.date) { _, group in
                    Section(header: Text(formattedDate(group.date)).font(.headline)) {
                        ForEach(group.entries) { memo in
                            if editingMemoId == memo.id {
                                // インライン編集モード
                                VStack(alignment: .leading, spacing: 12) {
                                    // メモ内容の編集
                                    TextEditor(text: $editingMemo.content)
                                        .frame(minHeight: 100)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                    
                                    // トグル設定
                                    HStack {
                                        Toggle(isOn: $editingMemo.isSecret) {
                                            HStack {
                                                Image(systemName: "lock")
                                                Text("秘密")
                                            }
                                        }
                                        .toggleStyle(SwitchToggleStyle(tint: .orange))
                                        
                                        Toggle(isOn: $editingMemo.isTask) {
                                            HStack {
                                                Image(systemName: "checkmark.square")
                                                Text("タスク")
                                            }
                                        }
                                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                                    }
                                    
                                    if editingMemo.isTask {
                                        Toggle(isOn: $editingMemo.isCompleted) {
                                            HStack {
                                                Image(systemName: "checkmark.circle.fill")
                                                Text("完了済み")
                                            }
                                        }
                                        .toggleStyle(SwitchToggleStyle(tint: .green))
                                    }
                                    
                                    // 現在のタグ表示
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("タグ: \(editingMemo.tags.count)個")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        if !editingMemo.tags.isEmpty {
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: 4) {
                                                    ForEach(editingMemo.tags, id: \.self) { tag in
                                                        Button(action: {
                                                            editingMemo.tags.removeAll { $0 == tag }
                                                        }) {
                                                            HStack(spacing: 2) {
                                                                Text(tag)
                                                                    .font(.caption)
                                                                Image(systemName: "xmark.circle.fill")
                                                                    .font(.caption2)
                                                            }
                                                            .padding(.horizontal, 8)
                                                            .padding(.vertical, 4)
                                                            .background(Color.green.opacity(0.3))
                                                            .clipShape(Capsule())
                                                        }
                                                        .buttonStyle(PlainButtonStyle())
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    // タグ候補表示
                                    if !newTag.isEmpty && !filteredAvailableTagsForEditing.isEmpty {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("💡 タグ候補")
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                            
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: 4) {
                                                    ForEach(filteredAvailableTagsForEditing, id: \.self) { tag in
                                                        Button(action: {
                                                            addExistingTag(tag)
                                                        }) {
                                                            Text(tag)
                                                                .font(.caption)
                                                                .padding(.horizontal, 8)
                                                                .padding(.vertical, 4)
                                                                .background(Color.blue.opacity(0.2))
                                                                .clipShape(Capsule())
                                                        }
                                                        .buttonStyle(PlainButtonStyle())
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    // 新しいタグ追加
                                    HStack {
                                        TextField("新しいタグ", text: $newTag)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .focused($isTextFieldFocused)
                                            .font(.caption)
                                        
                                        Button("追加") {
                                            addNewTag()
                                        }
                                        .font(.caption)
                                        .disabled(newTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                    }
                                    
                                    // 保存・キャンセルボタン
                                    HStack {
                                        Button(action: {
                                            cancelMemoEdit()
                                        }) {
                                            Text("キャンセル")
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(Color.gray.opacity(0.2))
                                                .foregroundColor(.red)
                                                .cornerRadius(8)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            saveMemoEdit()
                                        }) {
                                            Text("保存")
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(Color.blue)
                                                .foregroundColor(.white)
                                                .cornerRadius(8)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                    .padding(.top, 4)
                                }
                                .padding(.vertical, 8)
                                .contentShape(Rectangle())
                                .onTapGesture { }
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                            } else {
                                // 通常のメモ表示
                                MemoRowView(
                                    memo: memo,
                                    selectedTags: $selectedTags,
                                    onEdit: {
                                        startEditingMemo(memo)
                                    },
                                    onDeleteRequest: {
                                        alertType = .deleteConfirmation(memo)
                                    }
                                )
                            }
                        }
                        .deleteDisabled(editingMemoId != nil)
                    }
                }
            }
            .listStyle(.plain)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        // 完了済みタスク表示切り替え
                        Button(action: {
                            showCompletedTasks.toggle()
                        }) {
                            Image(systemName: showCompletedTasks ? "checkmark.circle.fill" : "checkmark.circle")
                                .foregroundColor(showCompletedTasks ? .green : .gray)
                        }
                        
                        // 秘密メモ表示切り替え
                        Button(action: {
                            if showSecretMemos {
                                showSecretMemos = false
                            } else {
                                alertType = .secretConfirmation
                            }
                        }) {
                            Image(systemName: showSecretMemos ? "lock.open" : "lock")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                ToolbarItem(placement: .keyboard) {
                    if editingMemoId != nil {
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
            .alert(item: $alertType) { type in
                switch type {
                case .secretConfirmation:
                    return Alert(
                        title: Text("秘密メモを表示しますか？"),
                        message: Text("秘密属性のメモも一覧に表示されます。"),
                        primaryButton: .default(Text("はい")) {
                            showSecretMemos = true
                        },
                        secondaryButton: .cancel()
                    )
                case .deleteConfirmation(let memo):
                    return Alert(
                        title: Text("本当に削除しますか？"),
                        message: Text("このメモは復元できません。"),
                        primaryButton: .destructive(Text("削除")) {
                            memoStore.delete(memo: memo)
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
    }

    private var filteredMemos: [SavedMemo] {
        memoStore.memos.filter { memo in
            // タグフィルター
            let matchesTag = selectedTags.isEmpty || selectedTags.isSubset(of: Set(memo.tags))
            
            // 秘密メモフィルター
            let passesSecretFilter = showSecretMemos || !memo.isSecret
            
            // 完了タスクフィルター
            let passesCompletedTaskFilter = !memo.isTask || showCompletedTasks || !memo.isCompleted
            
            return matchesTag && passesSecretFilter && passesCompletedTaskFilter
        }
    }

    private var groupedFilteredMemos: [(date: Date, entries: [SavedMemo])] {
        let grouped = Dictionary(grouping: filteredMemos) {
            Calendar.current.startOfDay(for: $0.date)
        }
        return grouped.map { ($0.key, $0.value) }
            .sorted { $0.date > $1.date }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    // 編集関連のメソッド
    private func startEditingMemo(_ memo: SavedMemo) {
        editingMemoId = memo.id
        editingMemo = memo
        newTag = ""
    }
    
    private func saveMemoEdit() {
        // タスクタグの自動管理を実行
        var memoToSave = editingMemo
        memoToSave.updateTaskStatus()
        
        // 保存時にのみ更新を反映
        memoStore.update(memo: memoToSave)
        
        // UIを更新
        editingMemoId = nil
        editingMemo = SavedMemo(
            id: UUID(),
            content: "",
            date: Date(),
            tags: []
        )
        newTag = ""
    }
    
    private func cancelMemoEdit() {
        // キャンセル時は何も保存せずに編集モードを終了
        editingMemoId = nil
        editingMemo = SavedMemo(
            id: UUID(),
            content: "",
            date: Date(),
            tags: []
        )
        newTag = ""
    }
    
    // タグ関連のメソッド
    private var allTags: [String] {
        Array(Set(memoStore.memos.flatMap { $0.tags })).sorted()
    }
    
    private var availableTagsForEditing: [String] {
        allTags.filter { !editingMemo.tags.contains($0) }
    }
    
    private var filteredAvailableTagsForEditing: [String] {
        let trimmed = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return []
        } else {
            return availableTagsForEditing.filter { $0.localizedCaseInsensitiveContains(trimmed) }
        }
    }
    
    private func addNewTag() {
        let trimmed = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !editingMemo.tags.contains(trimmed) {
            editingMemo.tags.append(trimmed)
        }
        newTag = ""
    }
    
    private func addExistingTag(_ tag: String) {
        if !editingMemo.tags.contains(tag) {
            editingMemo.tags.append(tag)
        }
        newTag = ""
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
