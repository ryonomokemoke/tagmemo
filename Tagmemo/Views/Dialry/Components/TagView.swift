import SwiftUI

// MARK: - タグコンポーネント
struct TagView: View {
    let tag: String
    @Binding var selectedTags: Set<String>
    @Binding var negativeSelectedTags: Set<String>
    
    // カスタマイズ可能なプロパティ
    var style: TagStyle = .normal
    var showDeleteButton: Bool = false
    var onDelete: (() -> Void)? = nil
    
    // 計算プロパティ
    private var isSelected: Bool {
        selectedTags.contains(tag)
    }
    
    private var isNegative: Bool {
        negativeSelectedTags.contains(tag)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .normal:
            return isNegative ? Color.red.opacity(0.3) :
                   isSelected ? Color.green.opacity(0.3) :
                   Color.gray.opacity(0.2)
        case .suggestion:
            return Color.blue.opacity(0.2)
        case .newTag:
            return Color.orange.opacity(0.2)
        case .editing:
            return Color.green.opacity(0.3)
        }
    }
    
    var body: some View {
        Menu {
            // ポジティブ選択
            Button(action: {
                if isSelected {
                    selectedTags.remove(tag)
                } else {
                    selectedTags.insert(tag)
                    negativeSelectedTags.remove(tag)
                }
            }) {
                Label(
                    isSelected ? "選択を解除" : "このタグを含む",
                    systemImage: isSelected ? "checkmark.circle.fill" : "checkmark.circle"
                )
            }
            
            // ネガティブ選択
            Button(action: {
                if isNegative {
                    negativeSelectedTags.remove(tag)
                } else {
                    negativeSelectedTags.insert(tag)
                    selectedTags.remove(tag)
                }
            }) {
                Label(
                    isNegative ? "除外を解除" : "このタグを含まない",
                    systemImage: isNegative ? "xmark.circle.fill" : "xmark.circle"
                )
            }
            
            // 削除オプション（編集モードなど）
            if showDeleteButton, let onDelete = onDelete {
                Divider()
                Button(action: onDelete) {
                    Label("削除", systemImage: "trash")
                }
            }
        } label: {
            HStack(spacing: 4) {
                // ネガティブアイコン
                if isNegative {
                    Image(systemName: "minus.circle.fill")
                        .font(.caption2)
                }
                
                // 新規作成アイコン（新規タグの場合）
                if style == .newTag {
                    Image(systemName: "plus.circle.fill")
                        .font(.caption2)
                }
                
                // タグテキスト
                Text(style == .newTag ? "\"\(tag)\" を新規作成" : "#\(tag)")
                    .font(.caption)
                
                // 削除ボタン（インライン表示の場合）
                if showDeleteButton && style == .editing {
                    Button(action: { onDelete?() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption2)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, style == .normal ? 6 : 8)
            .padding(.vertical, style == .normal ? 6 : 4)
            .background(backgroundColor)
            .clipShape(Capsule())
        }
        .menuStyle(BorderlessButtonMenuStyle())
    }
    
    // タグのスタイル
    enum TagStyle {
        case normal      // 通常のタグ（メモ内）
        case suggestion  // 検索候補
        case newTag      // 新規作成
        case editing     // 編集モード用
    }
}
