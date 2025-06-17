import SwiftUI

struct DiaryView: View {
    @ObservedObject var memoStore: MemoStore
    @State private var selectedTags: Set<String> = []
    @State private var negativeSelectedTags: Set<String> = []
    @State private var tagSearchText: String = ""
    @State private var showTagSearch = false
    
    // 編集・削除状態
    @State private var editingMemo: SavedMemo? = nil
    @State private var confirmDelete: SavedMemo? = nil
    @State private var pendingDelete: SavedMemo? = nil

    var body: some View {
        VStack(spacing: 0) {
            // === 1. メモリスト ===
            MemoGroupedListView(
                memoStore: memoStore,
                selectedTags: $selectedTags,
                negativeSelectedTags: $negativeSelectedTags,
                showSecretMemos: $showSecretMemos,
                showCompletedTasks: $showCompletedTasks,
                onEdit: { memo in editingMemo = memo }
            )

            // === 2. 選択中タグの表示 ===
            SelectedTagListView(
                selectedTags: $selectedTags,
                negativeSelectedTags: $negativeSelectedTags
            )

            // === 3. タグ検索エリア（表示/非表示）===
            if showTagSearch {
                TagSearchInputView(
                    tagSearchText: $tagSearchText,
                    allTags: allTags,
                    selectedTags: $selectedTags,
                    negativeSelectedTags: $negativeSelectedTags
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // === 4. 下部ツールバー ===
            BottomToolbar(
                showSecretMemos: $showSecretMemos,
                showCompletedTasks: $showCompletedTasks,
                showTagSearch: $showTagSearch
            )
        }
        .sheet(item: $editingMemo) { memo in
            MemoEditView(
                memo: memo,
                onSave: { updatedMemo in
                    memoStore.update(memo: updatedMemo)
                    editingMemo = nil
                },
                allTags: allTags
            )
        }
        .onChange(of: pendingDelete) {
            if let memo = pendingDelete {
                memoStore.delete(memo: memo)
                pendingDelete = nil
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showTagSearch)
    }
    
    // フィルター設定の状態
    @State private var showSecretMemos = false
    @State private var showCompletedTasks = true

    var allTags: [String] {
        Set(memoStore.memos.flatMap { $0.tags }).sorted()
    }

    var matchingTags: [String] {
        guard !tagSearchText.isEmpty else { return [] }
        return allTags.filter { $0.localizedCaseInsensitiveContains(tagSearchText) }
    }
}

// 下部ツールバー
struct BottomToolbar: View {
    @Binding var showSecretMemos: Bool
    @Binding var showCompletedTasks: Bool
    @Binding var showTagSearch: Bool
    @State private var showSecretAlert = false
    
    var body: some View {
        HStack(spacing: 24) {
            // タグ検索ボタン
            Button(action: {
                showTagSearch.toggle()
            }) {
                Image(systemName: showTagSearch ? "magnifyingglass.circle.fill" : "magnifyingglass.circle")
                    .font(.title2)
                    .foregroundColor(showTagSearch ? .blue : .gray)
            }
            
            Spacer()
            
            // 完了済みタスク表示切り替え
            Button(action: {
                showCompletedTasks.toggle()
            }) {
                VStack(spacing: 2) {
                    Image(systemName: showCompletedTasks ? "checkmark.circle.fill" : "checkmark.circle")
                        .font(.title2)
                        .foregroundColor(showCompletedTasks ? .green : .gray)
                    Text("完了済み")
                        .font(.caption2)
                        .foregroundColor(showCompletedTasks ? .green : .gray)
                }
            }
            
            // 秘密メモ表示切り替え
            Button(action: {
                if showSecretMemos {
                    showSecretMemos = false
                } else {
                    showSecretAlert = true
                }
            }) {
                VStack(spacing: 2) {
                    Image(systemName: showSecretMemos ? "lock.open" : "lock")
                        .font(.title2)
                        .foregroundColor(showSecretMemos ? .orange : .gray)
                    Text("秘密メモ")
                        .font(.caption2)
                        .foregroundColor(showSecretMemos ? .orange : .gray)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(Color(UIColor.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color.gray.opacity(0.3)),
            alignment: .top
        )
        .alert("秘密メモを表示しますか？", isPresented: $showSecretAlert) {
            Button("キャンセル", role: .cancel) { }
            Button("表示する") {
                showSecretMemos = true
            }
        } message: {
            Text("秘密属性のメモも一覧に表示されます。")
        }
    }
}
