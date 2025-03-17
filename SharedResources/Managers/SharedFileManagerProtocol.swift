//
//  SharedFileManagerProtocol.swift
//  clipme
//
//  Created by AlexDelgado on 9/3/25.
//

public protocol SharedFileManagerProtocol {
    func getURLItems() -> [SharedURLItem]
    func deleteURL(by id: String)
    func saveURL(_ items: [SharedURLItem], append: Bool)
    func clearURLInfo()
    func updateSharedURLItemCategory(_ item: SharedURLItem, newCategory: String)
    func updateSharedURLItemTitle(_ item: SharedURLItem, newTitle: String)
    
    func getURLItemsByTag(_ tag: String) -> [SharedURLItem]
    func getFavoriteURLItems() -> [SharedURLItem]
    func toggleFavoriteStatus(for item: SharedURLItem)
    func getURLItemsByCategory(_ category: String) -> [SharedURLItem]
    func searchURLItemsByTitle(_ query: String) -> [SharedURLItem]
    
    func getImage(for item: SharedURLItem) -> Data?
    
    func fetchCategorySettings() -> [CategorySettingsItem]
    func saveCategorySettings(_ settings: [CategorySettingsItem])
   // func updateCategorySetting(for category: String, color: String?, order: Int)
    func removeCategory(_ category: CategorySettingsItem)
    func saveCategoryOrder(_ categories: [CategorySettingsItem])
    func updateCategoryName(_ category: CategorySettingsItem, newName: String)
}
