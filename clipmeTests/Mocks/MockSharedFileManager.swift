//
//  MockSharedFileManager.swift
//  clipme
//
//  Created by AlexDelgado on 9/3/25.
//

import SharedResources


class MockSharedFileManager: SharedFileManagerProtocol {
    func updateSharedURLItemCategory(_ item: SharedResources.SharedURLItem, newCategoryID: String) {
        
    }
    
    func updateSharedURLItemTitle(_ item: SharedResources.SharedURLItem, newTitle: String) {
        
    }
    
    func toggleFavoriteStatus(for item: SharedResources.SharedURLItem) {
        
    }
    
    func removeCategory(_ category: SharedResources.CategorySettingsItem) {
        
    }
    
    func saveCategoryOrder(_ categories: [SharedResources.CategorySettingsItem]) {
        
    }
    
    func updateCategoryName(_ category: SharedResources.CategorySettingsItem, newName: String) {
        
    }
    
    func toggleHiddenStatusCategory(for category: SharedResources.CategorySettingsItem) {
        
    }
    

    
    
    
    var mockURLs: [SharedURLItem] = []
    var mockCategories: [CategorySettingsItem] = []
    
    func getURLItems() -> [SharedURLItem] {
        return mockURLs
    }
    
    
    func deleteURL(by id: String) {
        mockURLs.removeAll { $0.idString == id }

    }


    func saveURL(_ items: [SharedURLItem], append: Bool) {
        if append {
            mockURLs.append(contentsOf: items)
        } else {
            mockURLs = items
        }
    }

    func clearURLInfo() {
        mockURLs.removeAll()
    }

    func getURLItemsByTag(_ tag: String) -> [SharedURLItem] {
        return mockURLs.filter { $0.tags.contains(tag) }
    }

    func getFavoriteURLItems() -> [SharedURLItem] {
        return mockURLs.filter { $0.isFavorite }
    }

    func getURLItemsByCategory(_ idCategory: String) -> [SharedURLItem] {
        return mockURLs.filter { $0.idCategory == idCategory }
    }

    func searchURLItemsByTitle(_ query: String) -> [SharedURLItem] {
        return mockURLs.filter { $0.title.contains(query) }
    }

    func getImage(for item: SharedURLItem) -> Data? {
        return nil
    }

    func fetchCategorySettings() -> [CategorySettingsItem] {
        return mockCategories
    }

    func saveCategorySettings(_ settings: [CategorySettingsItem]) {
        mockCategories.append(contentsOf: settings)
    }

    func updateCategorySetting(for category: String, color: String?) {
        if let index = mockCategories.firstIndex(where: { $0.name == category }) {
            if let color = color {
                mockCategories[index].color = color
            }
        }
    }

    func removeCategory(_ category: String) {
        mockCategories.removeAll { $0.name == category }
    }
}
