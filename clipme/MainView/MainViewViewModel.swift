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
    @Published var selectedCategory: String = "Todas"
    @Published var searchQuery: String = ""
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
    /// Carga los URLs guardados, ordenándolos por fecha descendente y actualizando categorías.
    func fetchSharedURLs() {
        let items = fileManager.getURLItems()
        let sortedItems = items.sorted { $0.date > $1.date }
        self.sharedURLs = sortedItems
    }

    /// Devuelve la lista de categorías únicas extraídas de los elementos guardados.
    var categories: [String] {
        fetchedCategories = fileManager.fetchCategorySettings()
        for each in fetchedCategories {
            print("\(each.name)")
            print("\(each.order)")
        }
        let storedCategories = fetchedCategories.map { $0.name }
        let uniqueCategories = Set(sharedURLs.map { $0.category.isEmpty ? "Sin Categoría" : $0.category }).union(storedCategories)
        return ["Todas"] + uniqueCategories.sorted()
    }

    /// Filtra los elementos según la categoría seleccionada y el término de búsqueda.
    func filteredItems() -> [SharedURLItem] {
        var filtered = sharedURLs

        if selectedCategory != "Todas" {
            filtered = filtered.filter { $0.category == selectedCategory }
        }

        if !searchQuery.isEmpty {
            filtered = filtered.filter { item in
                item.category.lowercased().contains(searchQuery.lowercased()) ||
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
        var storedCategories = fileManager.fetchCategorySettings().map { $0.name }
        self.sharedURLs.forEach { item in
            if !storedCategories.contains(item.category) {
                storedCategories.append(item.category)
            }
        }
        self.selectedCategory = "Todas"
    }
    
    func removeCategory(_ categoryName: String) {
        guard categoryName != "Todas" else { return }
        
        fileManager.removeCategory(categoryName)
        
        // Filtrar los elementos eliminados de la lista local
        sharedURLs.removeAll { $0.category == categoryName }
        
        // Recargar categorías
        fetchCategories()
    }
    
    func removeElement(_ item: SharedURLItem) {
        fileManager.deleteURL(by: item.idString)
        sharedURLs.removeAll { $0.id == item.id }
//        fetchCategories()
        
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
    
    func getCategory(of item: SharedURLItem?) -> String? {
        return item?.category
    }
}
