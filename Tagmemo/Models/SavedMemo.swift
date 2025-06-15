//
//  SavedMemo.swift
//  Tagmemo
//
//  Created by りょう on 2025/06/09.
//

import Foundation

struct SavedMemo: Identifiable, Codable, Equatable {
    var id: UUID
    var content: String
    var date: Date
    var tags: [String]
    var isSecret: Bool
    var isTask: Bool
    var isCompleted: Bool  // 新規追加

    // MARK: - カスタムDecoder
    enum CodingKeys: String, CodingKey {
        case id, content, date, tags, isSecret, isTask, isCompleted
    }
    
    init(
        id: UUID,
        content: String,
        date: Date,
        tags: [String],
        isSecret: Bool = false,
        isTask: Bool = false,
        isCompleted: Bool = false  // 新規追加
    ) {
        self.id = id
        self.content = content
        self.date = date
        self.tags = tags
        self.isSecret = isSecret
        self.isTask = isTask
        self.isCompleted = isCompleted
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(UUID.self, forKey: .id)
        self.content = try container.decode(String.self, forKey: .content)
        self.date = try container.decode(Date.self, forKey: .date)
        self.tags = try container.decode([String].self, forKey: .tags)

        // 🔽 新フィールドは存在しなければ false にする（後方互換）
        self.isSecret = try container.decodeIfPresent(Bool.self, forKey: .isSecret) ?? false
        self.isTask = try container.decodeIfPresent(Bool.self, forKey: .isTask) ?? false
        self.isCompleted = try container.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false  // 新規追加
    }

    // MARK: - Encoder（省略可だが書いておくと明示的）
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(content, forKey: .content)
        try container.encode(date, forKey: .date)
        try container.encode(tags, forKey: .tags)
        try container.encode(isSecret, forKey: .isSecret)
        try container.encode(isTask, forKey: .isTask)
        try container.encode(isCompleted, forKey: .isCompleted)  // 新規追加
    }
    
    // タスクタグの自動管理
    mutating func updateTaskStatus() {
        if isTask && !tags.contains("タスク") {
            tags.append("タスク")
        } else if !isTask {
            tags.removeAll { $0 == "タスク" }
            isCompleted = false // タスク属性を外すと完了状態もリセット
        }
    }
}	
