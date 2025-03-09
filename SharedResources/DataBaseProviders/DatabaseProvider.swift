//
//  DatabaseProvider.swift
//  clipme
//
//  Created by AlexDelgado on 8/3/25.
//


internal protocol DatabaseProvider {
    func fetchItems() -> [SharedURLItem]
    func deleteItem(by id: UUID)
    func saveItems(_ items: [SharedURLItem], append: Bool)
    func clearAllItems()
    
    
    // Funciones de búsqueda
    func getURLItemsByTag(_ tag: String) -> [SharedURLItem]
    func getFavoriteURLItems() -> [SharedURLItem]
    func getURLItemsByCategory(_ category: String) -> [SharedURLItem]
    func searchURLItemsByTitle(_ query: String) -> [SharedURLItem]
    
    // Nueva función para obtener la imagen de un SharedURLItem
    func getImage(for item: SharedURLItem) -> Data?
    
    // Funciones para gestionar configuraciones de categorías
    func fetchCategorySettings() -> [CategorySettingsItem]
    func saveCategorySettings(_ settings: [CategorySettingsItem])
    func updateCategorySetting(for category: String, color: String?)
    
    // Nueva función para eliminar una categoría
    func removeCategory(_ category: String)
}
