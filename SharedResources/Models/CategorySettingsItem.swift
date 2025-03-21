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
    public var id: UUID = UUID()
    public var idString: String // id del elemento en la base de datos. 
    public var name: String
    public var color: String?
    public var order: Int
    public var isHidden: Bool

    public init(
                idString: String = "",
                name: String,
                color: String? = nil,
                order: Int,
                isHidden: Bool) {
                    self.idString = idString
                    self.name = name
                    self.color = color
                    self.order = order
                    self.isHidden = isHidden

    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case id, name, color, order, idString, isHidden
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(color, forKey: .color)
        try container.encode(order, forKey: .order)
        try container.encode(idString, forKey: .idString)
        try container.encode(isHidden, forKey: .isHidden)

    }

    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let color = try container.decode(String.self, forKey: .color)
        let order = try container.decode(Int.self, forKey: .order)
        let idString = try container.decode(String.self, forKey: .idString)
        let isHidden = try container.decode(Bool.self, forKey: .isHidden)

        self.init(idString: idString, name: name, color: color, order: order, isHidden: isHidden)
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
