//
//  SharedFileManagerProtocol.swift
//  clipme
//
//  Created by AlexDelgado on 9/3/25.
//

public protocol SharedFileManagerProtocol {
    func getURLItems() -> [SharedURLItem]
    func deleteURL(by id: UUID)
    func saveURL(_ items: [SharedURLItem], append: Bool)
    func clearURLInfo()
    
    func getURLItemsByTag(_ tag: String) -> [SharedURLItem]
    func getFavoriteURLItems() -> [SharedURLItem]
    func getURLItemsByCategory(_ category: String) -> [SharedURLItem]
    func searchURLItemsByTitle(_ query: String) -> [SharedURLItem]
    
    func getImage(for item: SharedURLItem) -> Data?
    
    func fetchCategorySettings() -> [CategorySettingsItem]
    func saveCategorySettings(_ settings: [CategorySettingsItem])
    func updateCategorySetting(for category: String, color: String?)
    func removeCategory(_ category: String)
}
