//
//  SharedFileManager.swift
//  reelKeeper
//
//  Created by AlexDelgado on 6/3/25.
//

import Foundation

public class SharedFileManager: SharedFileManagerProtocol {
    
    private let database: DatabaseProvider
    
    public static let shared = SharedFileManager(database: RealmDatabaseProvider())
    
    private init(database: DatabaseProvider) {
        self.database = database
    }

    // Gestión de elementos
    public func getURLItems() -> [SharedURLItem] {
        return database.fetchItems()
    }

    public func deleteURL(by id: String) {
        database.deleteItem(by: id)
    }

    public func saveURL(_ items: [SharedURLItem], append: Bool = true) {
        database.saveItems(items, append: append)
    }

    public func clearURLInfo() {
        database.clearAllItems()
    }

    // Búsquedas
    public func getURLItemsByTag(_ tag: String) -> [SharedURLItem] {
        return database.getURLItemsByTag(tag)
    }

    public func getFavoriteURLItems() -> [SharedURLItem] {
        return database.getFavoriteURLItems()
    }

    public func getURLItemsByCategory(_ category: String) -> [SharedURLItem] {
        return database.getURLItemsByCategory(category)
    }

    public func searchURLItemsByTitle(_ query: String) -> [SharedURLItem] {
        return database.searchURLItemsByTitle(query)
    }

    // Obtención de imágenes
    public func getImage(for item: SharedURLItem) -> Data? {
        return database.getImage(for: item)
    }

    // Gestión de categorías
    public func fetchCategorySettings() -> [CategorySettingsItem] {
        return database.fetchCategorySettings()
    }

    public func saveCategorySettings(_ settings: [CategorySettingsItem]) {
        database.saveCategorySettings(settings)
    }

    public func updateCategorySetting(for category: String, color: String?) {
        database.updateCategorySetting(for: category, color: color)
    }

    public func removeCategory(_ category: String) {
        let itemsToRemove = database.getURLItemsByCategory(category)
        for item in itemsToRemove {
            database.deleteItem(by: item.idString)
        }
        database.removeCategory(category)
    }
}
