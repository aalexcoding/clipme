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
    
    @Published var viewType: ViewType = ViewType(rawValue: UserDefaults.standard.string(forKey: "preferredViewType") ?? "grid") ?? .landscape
    @Published var elementOrder: ElementOrderBy = ElementOrderBy(rawValue: UserDefaults.standard.string(forKey: "preferredElementOrder") ?? "dateLatestFirst") ?? .dateLatestFirst

    @Published var sharedURLs: [SharedURLItem] = []
    @Published var selectedCategory: String = String(localized: "horizontal_scroll_all") {
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
    
    /// Devuelve la lista de categorías únicas extraídas de los elementos guardados.
    var categories: [String] {
        fetchedCategories = fileManager.fetchCategorySettings()
        let orderedCategories = fetchedCategories.sorted { $0.order < $1.order }
        let storedCategories = orderedCategories.map { $0.name }
        //let dynamicCategories = Set(sharedURLs.map { $0.category.isEmpty ? "Sin Categoría" : $0.category })
        //let finalCategories = storedCategories + dynamicCategories.subtracting(storedCategories).sorted()
        return [String(localized: "horizontal_scroll_all"), String(localized: "horizontal_scroll_fav")] + storedCategories
    }
    
    var categoriesWithOutTodasFavorites: [CategorySettingsItem] {
        fetchedCategories = fileManager.fetchCategorySettings()
        let orderedCategories = fetchedCategories.sorted { $0.order < $1.order }
        //let storedCategories = orderedCategories.map { $0.name }
        return orderedCategories
    }

    init(fileManager: SharedFileManager = SharedFileManager.shared) {
        self.fileManager = fileManager
    }
    
    // MARK: - Elementos
        
    /// Carga los URLs guardados, ordenándolos por fecha descendente y actualizando categorías.
    func fetchSharedURLs() {
        self.sharedURLs = fileManager.getURLItems()
        orderSharedURLs(by: elementOrder)
        //self.sharedURLs = sortedItems
    }
    
    func orderSharedURLs(by: ElementOrderBy){
        
        self.sharedURLs = self.sharedURLs.sorted {
            switch by {
            case .dateLatestFirst:
                return $0.date > $1.date
            case .dateLatestLast:
                return $0.date < $1.date
            case .titleAscending:
                return $0.title.localizedStandardCompare($1.title) == .orderedAscending
            case .titleDescending:
                return $0.title.localizedStandardCompare($1.title) == .orderedDescending
            }
        }
        elementOrder = by
        UserDefaults.standard.setValue(elementOrder.rawValue, forKey: "preferredElementOrder")

    }
    
    /// Filtra los elementos según la categoría seleccionada y el término de búsqueda.
    func filteredItems() -> [SharedURLItem] {
        var filtered = sharedURLs
        
        let hiddenCategoryIDs = fetchedCategories
            .filter { $0.isHidden }
            .map { $0.idString }

        if selectedCategory != String(localized: "horizontal_scroll_all") && selectedCategory != String(localized: "horizontal_scroll_fav") {
            filtered = filtered.filter { $0.idCategory == selectedObjectCategory?.idString }
        }
        if selectedCategory == String(localized: "horizontal_scroll_fav") {
            filtered = filtered.filter { $0.isFavorite == true }
            filtered = filtered.filter { !hiddenCategoryIDs.contains($0.idCategory)}
        }
        if selectedCategory == String(localized: "horizontal_scroll_all") {
            filtered = filtered.filter { !hiddenCategoryIDs.contains($0.idCategory)}
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
    
    func removeElement(_ item: SharedURLItem) {
        fileManager.deleteURL(by: item.idString)
        sharedURLs.removeAll { $0.id == item.id }
//        fetchCategories()
    }
    
//    func groupedItems(for query: String) -> [(key: String, value: [SharedURLItem])] {
//        let items = filteredItems()
//        let grouped = Dictionary(grouping: items, by: { $0.category.isEmpty ? "Sin Categoría" : $0.category })
//        return grouped.sorted { $0.key < $1.key }
//    }
    
    func searchItems(_ query: String) -> [SharedURLItem] {
        if query.isEmpty {
            return filteredItems()
        } else {
            return filteredItems().filter { item in
                //item.category.lowercased().contains(query.lowercased()) ||
                item.tags.contains(where: { $0.lowercased().contains(query.lowercased()) }) ||
                item.title.lowercased().contains(query.lowercased())
            }
        }
    }
    
    func changeItemCategory(of item: SharedURLItem, to newCategoryID: String) {
        let filtered = filteredItems()
        if let index = sharedURLs.firstIndex(where: { $0.id == item.id }) {
            sharedURLs[index].idCategory = newCategoryID
            fileManager.updateSharedURLItemCategory(item, newCategoryID: newCategoryID)
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
    
    // MARK: - Categories
    
    func getCategory(of item: SharedURLItem?) -> String? {
        return item?.idCategory
    }
    
    func fetchCategories() {
        fetchedCategories = fileManager.fetchCategorySettings()
        self.selectedCategory = String(localized: "horizontal_scroll_all")
    }

    func addNewCategory(_ categoryName: String) {
        guard !categoryName.isEmpty, !categories.contains(categoryName) else { return }
        let newCategory = CategorySettingsItem(name: categoryName, order: 99999, isHidden: false)
        fileManager.saveCategorySettings([newCategory])
        fetchCategories() // Recargar categorías después de agregar una nueva
    }
        
    func removeCategory(_ setCategory: CategorySettingsItem) {
        guard setCategory.name != String(localized: "horizontal_scroll_all") && setCategory.name != String(localized: "horizontal_scroll_fav") else { return }
        fileManager.removeCategory(setCategory)
        sharedURLs.removeAll { $0.idCategory == setCategory.idString }
        fetchCategories()
    }
        
    func changeCategoryName(_ categoryObjectSelected: CategorySettingsItem,_ oldName: String, _ newName: String) {
        guard oldName != newName else { return }
        
        selectedObjectCategory = fetchedCategories.first(where: { $0.name == oldName })
        selectedObjectCategory?.name = newName
        selectedCategory = newName

        fileManager.updateCategoryName(categoryObjectSelected, newName: newName)
//        categoryObjectSelected.name = newName
//        selectedCategory = newName
        
//        sharedURLs.forEach {
//            if $0.idCategory == oldName {
//                $0.idCategory = newName
//            }
//        }
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
    
    func toggleCategoryHidden(_ setCategory: CategorySettingsItem) {
        guard setCategory.name != String(localized: "horizontal_scroll_all") && setCategory.name != String(localized: "horizontal_scroll_fav") else { return }
        fileManager.toggleHiddenStatusCategory(for: setCategory)
        setCategory.isHidden.toggle()
    }
        
    // MARK: - System

    /// Abre el URL utilizando el sistema (si el enlace es un universal link, se lanzará la app de origen).
    func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
    
    func storeElementView(){
        UserDefaults.standard.setValue(viewType.rawValue, forKey: "preferredViewType")
    }
    
    func generarURLCompartibleUniversal(para elementos: [SharedURLItem]) -> URL? {
        let urls = elementos.map { $0.url.absoluteString }
        let joined = urls.joined(separator: ",")
        guard let encoded = joined.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }

        let urlString = "clipmeapp://elementos?data=\(encoded)"
        return URL(string: urlString)
    }
    
    func compartirElementosUniversal(_ elementos: [SharedURLItem]) {
        if let url = generarURLCompartibleUniversal(para: elementos) {
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            
            // Buscar la escena actual (UIHostingController)
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let root = scene.windows.first?.rootViewController {
                root.present(activityVC, animated: true)
            }
        }
    }
    
    func generateURLForSiengleElementOriginalLink(para elementos: [SharedURLItem]) -> URL? {
        let urls = elementos.map { $0.url.absoluteString }
        let joined = urls.joined(separator: ",")
        guard let encoded = joined.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }

        let urlString = "\(encoded)"
        return URL(string: urlString)
    }
    
    func shareOriginalElement(_ elementos: [SharedURLItem]) {
        if let url = generateURLForSiengleElementOriginalLink(para: elementos) {
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            
            // Buscar la escena actual (UIHostingController)
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let root = scene.windows.first?.rootViewController {
                root.present(activityVC, animated: true)
            }
        }
    }
    
}


