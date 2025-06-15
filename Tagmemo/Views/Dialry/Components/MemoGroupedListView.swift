import SwiftUI

struct MemoGroupedListView: View {
    @ObservedObject var memoStore: MemoStore
    @Binding var selectedTags: Set<String>
    var onEdit: (SavedMemo) -> Void

    @State private var showSecretMemos = false
    @State private var showCompletedTasks = true // 新規: 完了済みタスク表示設定
    @State private var alertType: AlertType? = nil

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
        NavigationStack {
            List {
                ForEach(Array(groupedFilteredMemos.enumerated()), id: \.element.date) { _, group in
                    Section(header: Text(formattedDate(group.date)).font(.headline)) {
                        ForEach(group.entries) { memo in
                            MemoRowView(
                                memo: memo,
                                selectedTags: $selectedTags,
                                onEdit: { onEdit(memo) },
                                onDeleteRequest: { alertType = .deleteConfirmation(memo) }
                            )
                        }
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
            let matchesTag = selectedTags.isEmpty || selectedTags.isSubset(of: Set(memo.tags))
            let showThisMemo = showSecretMemos || !memo.isSecret
            let showThisTask = showCompletedTasks || !memo.isCompleted
            return matchesTag && showThisMemo && showThisTask
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
}
