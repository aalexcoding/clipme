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
    
    @Published var showLeftChevron : Bool = false
    @Published var showRightChevron : Bool = false
    
    // Almacenamos el URL original extraído del NSExtensionContext
    var sharedURL: URL?
    
    private var webMetadataFetcher: WebMetadataFetcher
    
    init(apiKey: String) {
        self.webMetadataFetcher = WebMetadataFetcher(apiKey: apiKey)
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
        
        let newCategory = CategorySettingsItem(name: categoryName, color: "#FFFFFF", order: 99)
        var currentSettings = SharedFileManager.shared.fetchCategorySettings()
        currentSettings.append(newCategory)
        SharedFileManager.shared.saveCategorySettings(currentSettings)
        loadCategories()
    }
    
    // MARK: - Gestión del URL Compartido y Metadatos
    
    func loadURL(_ inputItems: [Any]) async {
        guard let inputItem = inputItems.first as? NSExtensionItem,
              let attachments = inputItem.attachments,
              let itemProvider = attachments.first else {
            await MainActor.run {
                self.errorMessage = "No se encontraron input items."
            }
            return
        }

        var item: Any?

        if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
            do {
                item = try await itemProvider.loadItem(forTypeIdentifier: "public.url")
            } catch {
                await MainActor.run {
                    self.errorMessage = "Error al cargar la URL: \(error.localizedDescription)"
                }
                return
            }
        } else if itemProvider.hasItemConformingToTypeIdentifier("public.plain-text") {
            do {
                item = try await itemProvider.loadItem(forTypeIdentifier: "public.plain-text")
            } catch {
                await MainActor.run {
                    self.errorMessage = "Error al cargar el texto plano: \(error.localizedDescription)"
                }
                return
            }
        }

        guard let urlItem = item else {
            await MainActor.run {
                self.errorMessage = "No se encontró una URL válida."
            }
            return
        }

        let url: URL?
        if let validURL = urlItem as? URL {
            url = validURL
        } else if let text = urlItem as? String, let extractedURL = URL(string: text) {
            url = extractedURL
        } else {
            url = nil
        }

        guard let finalURL = url else {
            await MainActor.run {
                self.errorMessage = "No se encontró una URL válida."
            }
            return
        }

        await MainActor.run {
            self.sharedURL = finalURL
            self.title = finalURL.absoluteString
        }

        do {
            guard let validURL = url else {
                await MainActor.run {
                    self.errorMessage = "No se encontró una URL válida."
                }
                return
            }
            let metadata = try await self.webMetadataFetcher.fetch(url: validURL)
            await MainActor.run {
                self.sharedMetadata = metadata
                self.title = metadata.title
                self.imageURL = metadata.imageURL
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Guardado del URL Compartido
    
    /// Crea y guarda un SharedURLItem usando SharedFileManager y SharedDefaultsManager
    func saveSharedURL() {
        guard let url = self.sharedURL,
              let displayTitle = self.title,
                let imageData = self.sharedMetadata?.image else {
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
