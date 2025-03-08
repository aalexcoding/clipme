//
//  CategorySettingsItem.swift
//  clipme
//
//  Created by AlexDelgado on 8/3/25.
//

import SwiftData
import Foundation

@Model
public final class CategorySettingsItem: Codable, Equatable, Hashable, Identifiable {
    public var id: UUID
    public var name: String
    public var color: String?

    public init(id: UUID = UUID(),
                name: String,
                color: String? = nil) {
        self.id = id
        self.name = name
        self.color = color
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case id, name, color
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(color, forKey: .color)
    }

    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let color = try container.decode(String.self, forKey: .color)
        self.init(id: id, name: name, color: color)
    }

    // MARK: - Equatable

    public static func == (lhs: CategorySettingsItem, rhs: CategorySettingsItem) -> Bool {
        return lhs.id == rhs.id
    }

    // MARK: - Hashable

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
