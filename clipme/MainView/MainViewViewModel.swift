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
    
    
    /// Carga los URLs guardados, ordenándolos por fecha descendente.
    func fetchSharedURLs() {
            let items = SharedFileManager.shared.getURLItems()
            // Utilizamos un descriptor de fetch para ordenar los elementos
            let sortedItems = items.sorted { $0.date > $1.date }
            self.sharedURLs = sortedItems
    }
    
    /// Abre el URL utilizando el sistema (si el enlace es un universal link, se lanzará la app de origen).
    func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}

extension MainViewViewModel {
    func groupedItems(for query: String) -> [(key: String, value: [SharedURLItem])] {
        let items = searchItems(query)
        let grouped = Dictionary(grouping: items, by: { $0.category.isEmpty ? "Sin Categoría" : $0.category })
        return grouped.sorted { $0.key < $1.key }
    }
    
    func searchItems(_ query: String) -> [SharedURLItem] {
        if query.isEmpty {
            return sharedURLs
        } else {
            return sharedURLs.filter { item in
                item.category.lowercased().contains(query.lowercased()) ||
                item.tags.contains(where: { $0.lowercased().contains(query.lowercased()) }) ||
                item.title.lowercased().contains(query.lowercased())
            }
        }
    }
}
