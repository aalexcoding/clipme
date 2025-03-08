import SwiftUI
import Foundation
import SharedResources
import MobileCoreServices

// MARK: - ShareExtensionViewModel

class ShareExtensionViewModel: ObservableObject {
    // Propiedades observadas para actualizar la UI
    @Published var title: String?
    @Published var imageURL: String = ""
    @Published var category: String = ""
    @Published var categories: [String] = []
    @Published var errorMessage: String?
    
    // Esta propiedad puede usarse para almacenar datos adicionales (por ejemplo, imagen compartida)
    var sharedMetadata: SharedMetadata? // Asegúrate de que SharedMetadata esté definido o elimínalo si no se usa.
    
    // Instancia del proveedor de base de datos
    var databaseProvider: DatabaseProvider
    
    // Inicializador inyectando el proveedor de base de datos
    init(databaseProvider: DatabaseProvider) {
        self.databaseProvider = databaseProvider
        loadCategories()
    }
    
    // Inicializador de conveniencia (necesitas tener una implementación por defecto del DatabaseProvider)
    convenience init() {
        self.init(databaseProvider: DefaultDatabaseProvider())
    }
    
    // MARK: - Gestión de Categorías
    
    /// Carga las categorías utilizando el método fetchCategorySettings del proveedor
    func loadCategories() {
        let categoryItems = databaseProvider.fetchCategorySettings()
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
    
    /// Agrega una nueva categoría y la guarda usando el proveedor de base de datos
    func addNewCategory(_ categoryName: String) {
        guard !categoryName.isEmpty, !categories.contains(categoryName) else { return }
        
        let newCategory = CategorySettingsItem(name: categoryName, color: "#FFFFFF")
        var currentSettings = databaseProvider.fetchCategorySettings()
        currentSettings.append(newCategory)
        databaseProvider.saveCategorySettings(currentSettings)
        loadCategories()
    }
    
    // MARK: - Gestión del URL Compartido
    
    /// Extrae el URL (y opcionalmente otros datos) del extension context
    func loadURL(_ extensionContext: NSExtensionContext?) {
        guard let context = extensionContext else {
            self.errorMessage = "No se proporcionó un contexto."
            return
        }
        
        // Se asume que el contexto tiene inputItems con attachments
        if let inputItem = context.inputItems.first as? NSExtensionItem,
           let attachments = inputItem.attachments,
           let itemProvider = attachments.first {
            
            let urlType = "public.url"
            if itemProvider.hasItemConformingToTypeIdentifier(urlType) {
                itemProvider.loadItem(forTypeIdentifier: urlType, options: nil) { (item, error) in
                    DispatchQueue.main.async {
                        if let url = item as? URL {
                            // Usamos la URL como título por ejemplo. Puedes extenderlo según tus necesidades.
                            self.title = url.absoluteString
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
    
    /// Crea un SharedURLItem a partir de la información obtenida y lo guarda usando el proveedor
    func saveSharedURL() {
        guard let title = title, let url = URL(string: title) else {
            self.errorMessage = "URL inválido."
            return
        }
        // Se asume que SharedURLItem tiene un inicializador con (id, title, url, category)
        let newItem = SharedURLItem(id: UUID(), title: title, url: url, category: category)
        databaseProvider.saveItems([newItem], append: true)
    }
}
