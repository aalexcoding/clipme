//
//  MockSharedFileManager.swift
//  clipme
//
//  Created by AlexDelgado on 9/3/25.
//


import Foundation
import SharedResources


class MockSharedFileManager: SharedFileManagerProtocol {
    
    
    var mockURLs: [SharedURLItem] = []
    var mockCategories: [CategorySettingsItem] = []
    
    func getURLItems() -> [SharedURLItem] {
        return mockURLs
    }

    func deleteURL(by id: UUID) {
        mockURLs.removeAll { $0.id == id }
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

    func getURLItemsByCategory(_ category: String) -> [SharedURLItem] {
        return mockURLs.filter { $0.category == category }
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
