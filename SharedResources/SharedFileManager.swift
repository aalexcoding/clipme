//
//  SharedFileManager.swift
//  reelKeeper
//
//  Created by AlexDelgado on 6/3/25.
//

import Foundation

public protocol DatabaseProvider {
    func fetchItems() -> [SharedURLItem]
    func deleteItem(by id: UUID)
    func saveItems(_ items: [SharedURLItem], append: Bool)
    func clearAllItems()
    
    
    // Funciones de búsqueda
    func getURLItemsByTag(_ tag: String) -> [SharedURLItem]
    func getFavoriteURLItems() -> [SharedURLItem]
    func getURLItemsByCategory(_ category: String) -> [SharedURLItem]
    func searchURLItemsByTitle(_ query: String) -> [SharedURLItem]
}

public class SharedFileManager {
    private let database: DatabaseProvider
    
    public static let shared = SharedFileManager(database: RealmDatabaseProvider())
    
    private init(database: DatabaseProvider) {
        self.database = database
    }

    public func getURLItems() -> [SharedURLItem] {
        return database.fetchItems()
    }

    public func deleteURL(by id: UUID) {
        database.deleteItem(by: id)
    }

    public func saveURL(_ items: [SharedURLItem], append: Bool = true) {
        database.saveItems(items, append: append)
    }

    public func clearURLInfo() {
        database.clearAllItems()
    }
}

extension SharedFileManager {
    public func getURLItemsByTag(_ tag: String) -> [SharedURLItem] {
        return getURLItems().filter { $0.tags.contains(tag) }
    }

    public func getFavoriteURLItems() -> [SharedURLItem] {
        return getURLItems().filter { $0.isFavorite }
    }

    public func getURLItemsByCategory(_ category: String) -> [SharedURLItem] {
        return getURLItems().filter { $0.category.lowercased() == category.lowercased() }
    }

    public func searchURLItemsByTitle(_ query: String) -> [SharedURLItem] {
        return getURLItems().filter { $0.title.lowercased().contains(query.lowercased()) }
    }
}
