internal protocol DatabaseProvider {
    func fetchItems() -> [SharedURLItem]
    func deleteItem(by id: String)
    func saveItems(_ items: [SharedURLItem], append: Bool)
    func clearAllItems()
    
    func updateSharedURLItemCategory(_ item: SharedURLItem, newCategoryID: String)
    func updateSharedURLItemTitle(_ item: SharedURLItem, newTitle: String)

    // Funciones de búsqueda
    func getURLItemsByTag(_ tag: String) -> [SharedURLItem]
    func getFavoriteURLItems() -> [SharedURLItem]
    func toggleFavoriteStatus(for item: SharedURLItem)
    func getURLItemsByCategory(_ category: String) -> [SharedURLItem]
    func searchURLItemsByTitle(_ query: String) -> [SharedURLItem]
    
    // Nueva función para obtener la imagen de un SharedURLItem
    func getImage(for item: SharedURLItem) -> Data?
    
    // Funciones para gestionar configuraciones de categorías
    func fetchCategorySettings() -> [CategorySettingsItem]
    func saveCategorySettings(_ settings: [CategorySettingsItem])
    
    // Nueva función para eliminar una categoría usando ID
    func removeCategory(_ category: CategorySettingsItem)
    func saveCategoryOrder(_ categories: [CategorySettingsItem])
    func updateCategoryName(_ category: CategorySettingsItem, newName: String)
    func toggleHiddenStatusCategory(for category: CategorySettingsItem)
    
    //Import - Export
    func exportDatabaseZip() -> URL?
    func importDatabaseZip(from zipURL: URL) -> Bool
}
