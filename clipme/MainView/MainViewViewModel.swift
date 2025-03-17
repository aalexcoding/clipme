//
//  SharedURLsViewModel.swift
//  reelKeeper
//
//  Created by AlexDelgado on 6/3/25.
//

import SwiftUI
import SwiftData
import SharedResources



final class MainViewViewModel: ObservableObject {
    @Published var sharedURLs: [SharedURLItem] = []
    @Published var selectedCategory: String = "Todas" {
        didSet {
            selectedObjectCategory = fetchedCategories.first(where: { $0.name == selectedCategory })
        }
    }
    @Published var selectedObjectCategory: CategorySettingsItem?
    @Published var searchQuery: String = ""
    
    @Published var hasHiddenLeftCategories: Bool = false
    @Published var hasHiddenRightCategories: Bool = false
    
    @Published var showLeftChevron : Bool = false
    @Published var showRightChevron : Bool = false
    
    var fetchedCategories: [CategorySettingsItem] = []
    
    var fileManager: SharedFileManager

    init(fileManager: SharedFileManager = SharedFileManager.shared) {
        self.fileManager = fileManager
    }
    func getTouchPosition() -> CGPoint {
        var position = CGPoint.zero
        DispatchQueue.main.async {
            if let keyWindow = UIApplication.shared.connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
                .first {
                position = keyWindow.rootViewController?.view.bounds.origin ?? CGPoint.zero
            }
        }
        return position
    }
    


    func updateScrollIndicators(proxy: GeometryProxy) {
        let contentWidth = proxy.size.width
        let visibleWidth = UIScreen.main.bounds.width - 40 // Ajusta según diseño
        
        hasHiddenLeftCategories = contentWidth > visibleWidth
        hasHiddenRightCategories = contentWidth > visibleWidth
    }
    
    
    
    /// Carga los URLs guardados, ordenándolos por fecha descendente y actualizando categorías.
    func fetchSharedURLs() {
        let items = fileManager.getURLItems()
        let sortedItems = items.sorted { $0.date > $1.date }
        self.sharedURLs = sortedItems
    }

    /// Devuelve la lista de categorías únicas extraídas de los elementos guardados.
    var categories: [String] {
        // Obtener categorías desde la configuración
        fetchedCategories = fileManager.fetchCategorySettings()
        
        // Ordenar las categorías por el campo 'order'
        let orderedCategories = fetchedCategories.sorted { $0.order < $1.order }
        
        // Obtener los nombres de las categorías ordenadas
        let storedCategories = orderedCategories.map { $0.name }
        
        // Extraer categorías únicas de los elementos compartidos
        let dynamicCategories = Set(sharedURLs.map { $0.category.isEmpty ? "Sin Categoría" : $0.category })
        
        // Mantener el orden de storedCategories y añadir los dinámicos que no están en storedCategories
        let finalCategories = storedCategories + dynamicCategories.subtracting(storedCategories).sorted()
        
        // Incluir "Todas" y "Favorites" como categorías adicionales
        return ["Todas", "Favorites"] + finalCategories
    }
    
    var categoriesWithOutTodasFavorites: [String] {
        // Obtener categorías desde la configuración
        fetchedCategories = fileManager.fetchCategorySettings()
        
        // Ordenar las categorías por el campo 'order'
        let orderedCategories = fetchedCategories.sorted { $0.order < $1.order }
        
        // Obtener los nombres de las categorías ordenadas
        let storedCategories = orderedCategories.map { $0.name }
        
        // Incluir "Todas" y "Favorites" como categorías adicionales
        return storedCategories
    }

    /// Filtra los elementos según la categoría seleccionada y el término de búsqueda.
    func filteredItems() -> [SharedURLItem] {
        var filtered = sharedURLs

        if selectedCategory != "Todas" && selectedCategory != "Favorites" {
            filtered = filtered.filter { $0.category == selectedCategory }
        }
        
        if selectedCategory == "Favorites" {
            filtered = filtered.filter { $0.isFavorite == true }
        }

        if !searchQuery.isEmpty {
            filtered = filtered.filter { item in
                //item.category.lowercased().contains(searchQuery.lowercased()) ||
                item.tags.contains(where: { $0.lowercased().contains(searchQuery.lowercased()) }) ||
                item.title.lowercased().contains(searchQuery.lowercased())
            }
        }

        return filtered
    }
    
    

    /// Abre el URL utilizando el sistema (si el enlace es un universal link, se lanzará la app de origen).
    func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
    
    func addNewCategory(_ categoryName: String) {
        guard !categoryName.isEmpty, !categories.contains(categoryName) else { return }
        
        let newCategory = CategorySettingsItem(name: categoryName, order: 9)
        fileManager.saveCategorySettings([newCategory])
        
        fetchCategories() // Recargar categorías después de agregar una nueva
    }
    
    func fetchCategories() {
        fetchedCategories = fileManager.fetchCategorySettings()
        self.selectedCategory = "Todas"
    }
    
    func removeCategory(_ setCategory: CategorySettingsItem) {
        guard setCategory.name != "Todas" && setCategory.name != "Favorites" else { return }
        
        fileManager.removeCategory(setCategory)
        
        // Filtrar los elementos eliminados de la lista local
        sharedURLs.removeAll { $0.category == setCategory.name }
        
        // Recargar categorías
        fetchCategories()
    }
    
    func removeElement(_ item: SharedURLItem) {
        fileManager.deleteURL(by: item.idString)
        sharedURLs.removeAll { $0.id == item.id }
//        fetchCategories()
    }
    
    func changeCategoryName(_ oldName: String, _ newName: String) {
        guard oldName != newName else { return }
        guard let category = selectedObjectCategory else { return }
        
        fileManager.updateCategoryName(category, newName: newName)
        category.name = newName
        selectedCategory = newName
        
        sharedURLs.forEach {
            if $0.category == oldName {
                $0.category = newName
            }
        }
    }

    func reorderCategories(newOrder: [String]) {
        // Crear un diccionario para acceder rápidamente a las categorías existentes
        let categoryMap = Dictionary(uniqueKeysWithValues: fetchedCategories.map { ($0.name, $0) })

        // Reasignar los valores de `order` según el nuevo orden proporcionado
        for (index, categoryName) in newOrder.enumerated() {
            if let category = categoryMap[categoryName] {
                category.order = index // Asignamos un nuevo order según la posición en newOrder
            }
        }

        // Actualizar `fetchedCategories` con los nuevos valores de `order`
        fetchedCategories = newOrder.compactMap { categoryMap[$0] }

        // Guardar los cambios en el almacenamiento persistente
        fileManager.saveCategorySettings(fetchedCategories)
    }
}

extension MainViewViewModel {
    func groupedItems(for query: String) -> [(key: String, value: [SharedURLItem])] {
        let items = filteredItems()
        let grouped = Dictionary(grouping: items, by: { $0.category.isEmpty ? "Sin Categoría" : $0.category })
        return grouped.sorted { $0.key < $1.key }
    }
    
    func searchItems(_ query: String) -> [SharedURLItem] {
        if query.isEmpty {
            return filteredItems()
        } else {
            return filteredItems().filter { item in
                item.category.lowercased().contains(query.lowercased()) ||
                item.tags.contains(where: { $0.lowercased().contains(query.lowercased()) }) ||
                item.title.lowercased().contains(query.lowercased())
            }
        }
    }
}

extension MainViewViewModel {
    func changeItemCategory(of item: SharedURLItem, to newCategory: String) {
        if let index = sharedURLs.firstIndex(where: { $0.id == item.id }) {
            sharedURLs[index].category = newCategory
            fileManager.updateSharedURLItemCategory(item, newCategory: newCategory)
            objectWillChange.send()
        }
    }
    func changeItemTitle(of item: SharedURLItem, to title: String) {
        if let index = sharedURLs.firstIndex(where: { $0.id == item.id }) {
            sharedURLs[index].title = title
            fileManager.updateSharedURLItemTitle(item, newTitle: title)
            objectWillChange.send()
        }
    }
    
    func isFavorite(_ item: SharedURLItem) -> Bool {
        return fileManager.getFavoriteURLItems().contains { $0.id == item.id }
    }

    func getFavoriteURLItems() -> [SharedURLItem] {
        return fileManager.getFavoriteURLItems()
    }


    func toggleFavoriteStatus(of item: SharedURLItem) {
        if let index = sharedURLs.firstIndex(where: { $0.id == item.id }) {
            sharedURLs[index].isFavorite.toggle()
            fileManager.toggleFavoriteStatus(for: item)
            objectWillChange.send()
        }

    }
    
    func getCategory(of item: SharedURLItem?) -> String? {
        return item?.category
    }
}
