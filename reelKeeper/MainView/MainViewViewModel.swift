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
