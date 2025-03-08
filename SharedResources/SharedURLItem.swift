//
//  SharedURLItem.swift
//  reelKeeper
//
//  Created by AlexDelgado on 6/3/25.
//


import SwiftData
import Foundation

@Model
public final class SharedURLItem: Codable, Equatable, Hashable, Identifiable {
    public var id: UUID = UUID()
    public var url: URL
    public var origin: String
    public var title: String
    public var itemDescription: String
    public var category: String
    public var userNotes: String
    public var date: Date
    public var tags: [String]
    public var isFavorite: Bool

    public init(url: URL,
                origin: String,
                title: String = "",
                itemDescription: String = "",
                category: String = "",
                userNotes: String = "",
                date: Date = Date(),
                tags: [String] = [],
                isFavorite: Bool = false) {
        self.url = url
        self.origin = origin
        self.title = title
        self.itemDescription = itemDescription
        self.category = category
        self.userNotes = userNotes
        self.date = date
        self.tags = tags
        self.isFavorite = isFavorite
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case id, url, origin, title, itemDescription, category, userNotes, date, tags, isFavorite
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(url, forKey: .url)
        try container.encode(origin, forKey: .origin)
        try container.encode(title, forKey: .title)
        try container.encode(itemDescription, forKey: .itemDescription)
        try container.encode(category, forKey: .category)
        try container.encode(userNotes, forKey: .userNotes)
        try container.encode(date, forKey: .date)
        try container.encode(tags, forKey: .tags)
        try container.encode(isFavorite, forKey: .isFavorite)
    }

    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let url = try container.decode(URL.self, forKey: .url)
        let origin = try container.decode(String.self, forKey: .origin)
        let title = try container.decode(String.self, forKey: .title)
        let itemDescription = try container.decode(String.self, forKey: .itemDescription)
        let category = try container.decode(String.self, forKey: .category)
        let userNotes = try container.decode(String.self, forKey: .userNotes)
        let date = try container.decode(Date.self, forKey: .date)
        let tags = try container.decode([String].self, forKey: .tags)
        let isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        self.init(url: url, origin: origin, title: title, itemDescription: itemDescription, category: category, userNotes: userNotes, date: date, tags: tags, isFavorite: isFavorite)
        self.id = try container.decode(UUID.self, forKey: .id)
    }
    
    // MARK: - Equatable

    public static func == (lhs: SharedURLItem, rhs: SharedURLItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: - Hashable

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
