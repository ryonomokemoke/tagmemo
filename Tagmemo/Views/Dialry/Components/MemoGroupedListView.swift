import SwiftUI

struct MemoGroupedListView: View {
    @ObservedObject var memoStore: MemoStore
    @Binding var selectedTags: Set<String>
    @Binding var negativeSelectedTags: Set<String>
    @Binding var showSecretMemos: Bool
    @Binding var showCompletedTasks: Bool
    var onEdit: (SavedMemo) -> Void

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
        case deleteConfirmation(SavedMemo)
        
        var id: String {
            switch self {
            case .deleteConfirmation: return "delete"
            }
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(groupedFilteredMemos, id: \.date) { group in
                    Section(header: sectionHeader(for: group.date)) {
                        ForEach(group.entries) { memo in
                            memoRow(for: memo)
                        }
                        .deleteDisabled(editingMemoId != nil)
                    }
                }
            }
            .listStyle(.plain)
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    keyboardToolbar
                }
            }
            .alert(item: $alertType) { type in
                alertView(for: type)
            }
        }
    }
    
    @ViewBuilder
    private func sectionHeader(for date: Date) -> some View {
        Text(formattedDate(date))
            .font(.headline)
    }
    
    @ViewBuilder
    private func memoRow(for memo: SavedMemo) -> some View {
        if editingMemoId == memo.id {
            editingView
        } else {
            MemoRowView(
                memo: memo,
                selectedTags: $selectedTags,
                negativeSelectedTags: $negativeSelectedTags,
                onEdit: {
                    startEditingMemo(memo)
                },
                onDeleteRequest: {
                    alertType = .deleteConfirmation(memo)
                }
            )
        }
    }
    
    @ViewBuilder
    private var editingView: some View {
        VStack(alignment: .leading, spacing: 12) {
            editingContent
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)  // 左右の余白を追加
        .contentShape(Rectangle())
        .onTapGesture { }
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))  // リストの行インセットを調整
        .listRowBackground(Color.clear)
    }
    
    @ViewBuilder
    private var editingContent: some View {
        // メモ内容の編集
        TextEditor(text: $editingMemo.content)
            .frame(minHeight: 100)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        
        // トグル設定
        toggleSection
        
        // 現在のタグ表示
        currentTagsSection
        
        // タグ候補表示（入力があれば常に表示）
        if !newTag.isEmpty {
            tagSuggestionsSection
        }
        
        // 新しいタグ追加
        addNewTagSection
        
        // 保存・キャンセルボタン
        actionButtonsSection
    }
    
    @ViewBuilder
    private var toggleSection: some View {
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
    }
    
    @ViewBuilder
    private var currentTagsSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("タグ: \(editingMemo.tags.count)個")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if !editingMemo.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(editingMemo.tags, id: \.self) { tag in
                            tagChip(for: tag)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func tagChip(for tag: String) -> some View {
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
    
    @ViewBuilder
    private var tagSuggestionsSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("💡 タグ候補")
                .font(.caption)
                .foregroundColor(.blue)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(filteredAvailableTagsForEditing, id: \.self) { tag in
                        suggestionTagButton(for: tag)
                    }
                    
                    // 新規タグを作成するボタン（完全一致がない場合）
                    if !newTag.isEmpty && !allTags.contains(newTag) {
                        Button(action: {
                            addNewTag()
                        }) {
                            HStack(spacing: 2) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.caption2)
                                Text("\"\(newTag)\" を新規作成")
                                    .font(.caption)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.2))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func suggestionTagButton(for tag: String) -> some View {
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
    
    @ViewBuilder
    private var addNewTagSection: some View {
        TextField("新しいタグを入力", text: $newTag)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .focused($isTextFieldFocused)
            .font(.caption)
    }
    
    @ViewBuilder
    private var actionButtonsSection: some View {
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
    
    @ViewBuilder
    private var keyboardToolbar: some View {
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
    
    private func alertView(for type: AlertType) -> Alert {
        switch type {
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

    private var filteredMemos: [SavedMemo] {
        memoStore.memos.filter { memo in
            // タグフィルター（ポジティブ）
            let matchesTag = selectedTags.isEmpty || selectedTags.isSubset(of: Set(memo.tags))
            
            // ネガティブタグフィルター
            let passesNegativeTagFilter = negativeSelectedTags.isEmpty ||
                negativeSelectedTags.isDisjoint(with: Set(memo.tags))
            
            // 秘密メモフィルター
            let passesSecretFilter = showSecretMemos || !memo.isSecret
            
            // 完了タスクフィルター
            let passesCompletedTaskFilter = !memo.isTask || showCompletedTasks || !memo.isCompleted
            
            return matchesTag && passesNegativeTagFilter && passesSecretFilter && passesCompletedTaskFilter
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
