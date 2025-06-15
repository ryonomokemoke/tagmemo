import SwiftUI

struct DiaryView: View {
    @ObservedObject var memoStore: MemoStore
    @State private var selectedTags: Set<String> = []
    @State private var tagSearchText: String = ""
    
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
                onEdit: { memo in editingMemo = memo }
            )

            // === 2. 選択中タグの表示 ===
            SelectedTagListView(selectedTags: $selectedTags)
                .padding(.top)

            // === 3. タグ検索・追加エリア ===
            TagSearchInputView(
                tagSearchText: $tagSearchText,
                allTags: allTags,
                selectedTags: $selectedTags
            )
        }
        .sheet(item: $editingMemo) { memo in
            MemoEditView(
                memo: memo,
                onSave: { updatedMemo in
                    memoStore.update(memo: updatedMemo)
                    editingMemo = nil
                },
                allTags: allTags // 追加: 全タグを編集画面に渡す
            )
        }
        .onChange(of: pendingDelete) {
            if let memo = pendingDelete {
                memoStore.delete(memo: memo)
                pendingDelete = nil
            }
        }
    }

    var allTags: [String] {
        Set(memoStore.memos.flatMap { $0.tags }).sorted()
    }

    var matchingTags: [String] {
        guard !tagSearchText.isEmpty else { return [] }
        return allTags.filter { $0.localizedCaseInsensitiveContains(tagSearchText) }
    }
}
