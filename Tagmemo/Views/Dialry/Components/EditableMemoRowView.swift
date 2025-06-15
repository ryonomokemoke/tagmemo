//
//  EditableMemoRowView.swift
//  Tagmemo
//
//  Created by りょう on 2025/06/15.
//


import SwiftUI

struct EditableMemoRowView: View {
    let memo: SavedMemo
    @Binding var tempContent: String
    let onSave: () -> Void
    let onCancel: () -> Void
    @FocusState private var isTextEditorFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 編集可能なテキストエディタ
            TextEditor(text: $tempContent)
                .focused($isTextEditorFocused)
                .frame(minHeight: 60)
                .padding(8)
                .background(Color.white.opacity(0.8))
                .cornerRadius(8)
                .border(Color.blue, width: 2)
            
            // タグ表示（編集中は表示のみ）
            if !memo.tags.isEmpty {
                HStack {
                    ForEach(memo.tags, id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption)
                            .padding(4)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Capsule())
                    }
                    Spacer()
                }
            }
            
            // 編集ボタン
            HStack {
                if memo.isSecret {
                    Image(systemName: "lock")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                if memo.isTask {
                    Image(systemName: memo.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.caption)
                        .foregroundColor(memo.isCompleted ? .green : .gray)
                }
                
                Spacer()
                
                Button("キャンセル") {
                    onCancel()
                }
                .foregroundColor(.gray)
                
                Button("保存") {
                    onSave()
                }
                .foregroundColor(.blue)
                .disabled(tempContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(16)
        .onAppear {
            // 編集モードに入ったら自動でフォーカス
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isTextEditorFocused = true
            }
        }
    }
}