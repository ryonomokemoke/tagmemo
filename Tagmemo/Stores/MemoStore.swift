import Foundation

class MemoStore: ObservableObject {
    @Published var memos: [SavedMemo] = []

    private let key = "saved_memos"

    init() {
        load()
    }

    func add(memoContent: String) {
        let newMemo = SavedMemo(
            id: UUID(),
            content: memoContent,
            date: Date(),
            tags: [],
            isSecret: false,
            isTask: false,
            isCompleted: false  // 新規追加
        )
        memos.insert(newMemo, at: 0)
        save()
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(memos) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func update(memo: SavedMemo) {
        print("MemoStore.update が呼ばれました: \(memo.id)")
        if let index = memos.firstIndex(where: { $0.id == memo.id }) {
            print("インデックス \(index) のメモを更新します")
            memos[index] = memo
            save()
        } else {
            print("⚠️ 更新対象のメモが見つかりません")
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([SavedMemo].self, from: data) {
            memos = decoded
        }
    }
    
    func delete(memo: SavedMemo) {
        if let index = memos.firstIndex(where: { $0.id == memo.id }) {
            memos.remove(at: index)
            save()
        }
    }

}
