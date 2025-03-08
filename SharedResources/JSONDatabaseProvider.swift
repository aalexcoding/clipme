//
//  JSONDatabaseProvider.swift
//  reelKeeper
//
//  Created by AlexDelgado on 8/3/25.
//

public class JSONDatabaseProvider: DatabaseProvider {
    private let appGroup = "group.com.add.testing.reelKeeper.2"
    private let fileName = "sharedURLs.json"
    private let backupFileName = "sharedURLs.backup.json"

    public func getFileURL() -> URL? {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            print("Error: No se pudo obtener la URL del contenedor compartido.")
            return nil
        }
        return containerURL.appendingPathComponent(fileName)
    }

    public func getBackupFileURL() -> URL? {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            return nil
        }
        return containerURL.appendingPathComponent(backupFileName)
    }

    public func fetchItems() -> [SharedURLItem] {
        guard let fileURL = getFileURL() else { return [] }
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([SharedURLItem].self, from: data)
        } catch {
            print("Error leyendo URLs: \(error)")
            return []
        }
    }

    public func deleteItem(by id: UUID) {
        var existingItems = fetchItems()
        existingItems.removeAll { $0.id == id }
        saveItems(existingItems, append: false)
    }

    public func saveItems(_ items: [SharedURLItem], append: Bool = true) {
        guard let fileURL = getFileURL(), let backupURL = getBackupFileURL() else {
            print("Error: No se pudo obtener la URL del fichero o del backup.")
            return
        }

        var updatedItems = append ? fetchItems() : []
        updatedItems.append(contentsOf: items)

        do {
            let data = try JSONEncoder().encode(updatedItems)

            // Borrar contenido del archivo antes de escribir nuevos datos
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }

            // Intentar escribir los datos en el archivo
            try data.write(to: fileURL, options: .atomic)
            print("Datos guardados correctamente en \(fileURL.path)")

            // Si la escritura fue exitosa, eliminar el backup.
            if FileManager.default.fileExists(atPath: backupURL.path) {
                try FileManager.default.removeItem(at: backupURL)
            }

        } catch {
            print("Error al guardar los datos: \(error). Intentando recuperar desde el backup.")
            // Recuperar desde el backup si existe
            if FileManager.default.fileExists(atPath: backupURL.path) {
                do {
                    try FileManager.default.copyItem(at: backupURL, to: fileURL)
                    print("Recuperado desde el backup en \(backupURL.path)")
                } catch {
                    print("Error al recuperar desde el backup: \(error)")
                }
            }

            // Implementación de reintentos en la escritura
            for attempt in 1...3 {
                do {
                    print("Reintento \(attempt) para guardar los datos...")
                    let data = try JSONEncoder().encode(updatedItems) // Asegurar que 'data' está disponible
                    try data.write(to: fileURL, options: .atomic)
                    print("Datos guardados correctamente en \(fileURL.path) tras el reintento \(attempt)")
                    break
                } catch {
                    print("Reintento fallido al guardar los datos: \(error)")
                }
            }
        }
    }

    public func clearAllItems() {
        if let fileURL = getFileURL() {
            do {
                try FileManager.default.removeItem(at: fileURL)
                print("Archivo eliminado correctamente.")
            } catch {
                print("Error eliminando archivo: \(error)")
            }
        }
    }
    
    // Nuevas funciones de búsqueda
    public func getURLItemsByTag(_ tag: String) -> [SharedURLItem] {
        return fetchItems().filter { $0.tags.contains(tag) }
    }
    
    public func getFavoriteURLItems() -> [SharedURLItem] {
        return fetchItems().filter { $0.isFavorite }
    }
    
    public func getURLItemsByCategory(_ category: String) -> [SharedURLItem] {
        return fetchItems().filter { $0.category == category }
    }
    
    public func searchURLItemsByTitle(_ title: String) -> [SharedURLItem] {
        return fetchItems().filter { $0.title.lowercased().contains(title.lowercased()) }
    }
}
