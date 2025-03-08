import SwiftUI
import Foundation
import SharedResources
import MobileCoreServices
import LinkPresentation
import UIKit

class ShareExtensionViewModel: ObservableObject {
    // Propiedades para la interfaz
    @Published var title: String?            // Título a mostrar (del metadata)
    @Published var imageURL: String = ""       // URL de la imagen (si la hay)
    @Published var category: String = ""       // Categoría seleccionada
    @Published var categories: [String] = []   // Lista de categorías disponibles
    @Published var errorMessage: String?       // Mensaje de error en caso de fallo
    @Published var sharedMetadata: WebMetadata? // Metadatos obtenidos desde la URL
    
    // Almacenamos el URL original extraído del NSExtensionContext
    var sharedURL: URL?
    
    init() {
        loadCategories()
    }
    
    // MARK: - Gestión de Categorías
    
    /// Carga las categorías usando SharedFileManager
    func loadCategories() {
        let categoryItems = SharedFileManager.shared.fetchCategorySettings()
        let fetchedCategories = categoryItems.map { $0.name }
        
        DispatchQueue.main.async {
            if fetchedCategories.isEmpty {
                self.categories = ["Sin Categoría"]
            } else {
                self.categories = fetchedCategories
            }
            
            if !self.categories.contains(self.category) || self.category.isEmpty {
                self.category = self.categories.first ?? "Sin Categoría"
            }
        }
    }
    
    /// Agrega una nueva categoría y actualiza la lista
    func addNewCategory(_ categoryName: String) {
        guard !categoryName.isEmpty, !categories.contains(categoryName) else { return }
        
        let newCategory = CategorySettingsItem(name: categoryName, color: "#FFFFFF")
        var currentSettings = SharedFileManager.shared.fetchCategorySettings()
        currentSettings.append(newCategory)
        SharedFileManager.shared.saveCategorySettings(currentSettings)
        loadCategories()
    }
    
    // MARK: - Gestión del URL Compartido y Metadatos
    
    /// Extrae el URL del NSExtensionContext y obtiene los metadatos web
    func loadURL(_ extensionContext: NSExtensionContext?) {
        guard let context = extensionContext else {
            self.errorMessage = "No se proporcionó un contexto."
            return
        }
        
        if let inputItem = context.inputItems.first as? NSExtensionItem,
           let attachments = inputItem.attachments,
           let itemProvider = attachments.first {
            
            let urlType = "public.url"
            if itemProvider.hasItemConformingToTypeIdentifier(urlType) {
                itemProvider.loadItem(forTypeIdentifier: urlType, options: nil) { (item, error) in
                    DispatchQueue.main.async {
                        if let url = item as? URL {
                            self.sharedURL = url
                            // Inicialmente usamos la URL como título
                            self.title = url.absoluteString
                            
                            // Obtenemos metadatos web para mostrar un título más amigable y otros datos
                            WebMetadataFetcher.fetch(url: url) { metadata in
                                DispatchQueue.main.async {
                                    self.sharedMetadata = metadata
                                    self.title = metadata.title
                                    self.imageURL = metadata.imageURL
                                }
                            }
                        } else if let error = error {
                            self.errorMessage = error.localizedDescription
                        } else {
                            self.errorMessage = "No se encontró una URL válida."
                        }
                    }
                }
            } else {
                self.errorMessage = "No se encontró un URL válido en los attachments."
            }
        } else {
            self.errorMessage = "No se encontraron input items."
        }
    }
    
    // MARK: - Guardado del URL Compartido
    
    /// Crea y guarda un SharedURLItem usando SharedFileManager y SharedDefaultsManager
    func saveSharedURL() {
        guard let url = self.sharedURL,
              let displayTitle = self.title, let imageData = self.sharedMetadata?.image else {
            self.errorMessage = "URL inválido."
            return
        }
        
        // Extraer el dominio de la URL para usarlo como origin
        let origin = url.host ?? "Desconocido"
        
        // Guarda el item en SharedDefaultsManager incluyendo la imageURL
        SharedDefaultsManager.shared.saveURL(url,
                                            origin: origin,
                                            title: displayTitle,
                                            category: category,
                                            imageData: imageData,
                                            imageURL: self.imageURL )
    }
}
