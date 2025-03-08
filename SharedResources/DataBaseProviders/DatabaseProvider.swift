//
//  DatabaseProvider.swift
//  clipme
//
//  Created by AlexDelgado on 8/3/25.
//


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