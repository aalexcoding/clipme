//
//  RealmDatabaseProvider.swift
//  reelKeeper
//
//  Created by AlexDelgado on 8/3/25.
//

import Foundation
import ZIPFoundation
internal import RealmSwift

internal class RealmDatabaseProvider: DatabaseProvider {

    
    private let realm: Realm
    private let appGroup = "group.com.add.clipme.shared"

    init() {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("No se pudo obtener el contenedor del grupo \(appGroup)")
        }
        let realmURL = containerURL.appendingPathComponent("default.realm")
        var config = Realm.Configuration()
        config.fileURL = realmURL
        do {
            self.realm = try Realm(configuration: config)
        } catch {
            fatalError("No se pudo inicializar Realm: \(error.localizedDescription)")
        }
    }

    func fetchItems() -> [SharedURLItem] {
        return realm.objects(SharedURLItemRealm.self).map { $0.toSharedURLItem() }
    }

    func deleteItem(by id: String) {
        if let objectToDelete = realm.objects(SharedURLItemRealm.self).filter("id == %@", id).first {
            do {
                try realm.write {
                    realm.delete(objectToDelete)
                    print("🔹 Elemento eliminado correctamente: \(id)")
                }
            } catch {
                print("❌ Error al eliminar elemento: \(error.localizedDescription)")
            }
        } else {
            print("⚠️ No se encontró el elemento a eliminar: \(id)")
        }
    }

    func saveItems(_ items: [SharedURLItem], append: Bool) {
        try? realm.write {
            if !append {
                realm.delete(realm.objects(SharedURLItemRealm.self))
            }
            let realmItems = items.map { SharedURLItemRealm(from: $0) }
            realm.add(realmItems, update: .all)
        }
    }

    func clearAllItems() {
        try? realm.write {
            realm.delete(realm.objects(SharedURLItemRealm.self))
        }
    }

    func getURLItemsByTag(_ tag: String) -> [SharedURLItem] {
        return realm.objects(SharedURLItemRealm.self)
            .filter("ANY tags == %@", tag)
            .map { $0.toSharedURLItem() }
    }

    func getFavoriteURLItems() -> [SharedURLItem] {
        return realm.objects(SharedURLItemRealm.self)
            .filter("isFavorite == true")
            .map { $0.toSharedURLItem() }
    }
    
    
    func toggleFavoriteStatus(for item: SharedURLItem) {
        if let realmItem = realm.objects(SharedURLItemRealm.self).filter("id == %@", item.idString).first {
            try? realm.write {
                realmItem.isFavorite.toggle()
            }
        }
    }

    func getURLItemsByCategory(_ idCategory: String) -> [SharedURLItem] {
        return realm.objects(SharedURLItemRealm.self)
            .filter("idCategory == %@", idCategory)
            .map { $0.toSharedURLItem() }
    }
    
    func updateSharedURLItemCategory(_ item: SharedURLItem, newCategoryID: String) {
        if let realmItem = realm.objects(SharedURLItemRealm.self).filter("id == %@", item.idString).first {
            try? realm.write {
                realmItem.idCategory = newCategoryID
            }
        }
    }
    
    func updateSharedURLItemTitle(_ item: SharedURLItem, newTitle: String) {
        if let realmItem = realm.objects(SharedURLItemRealm.self).filter("id == %@", item.idString).first {
            try? realm.write {
                realmItem.title = newTitle
            }
        }
    }

    func saveCategoryOrder(_ categories: [CategorySettingsItem]) {
        try? realm.write {
            let existingCategories = realm.objects(CategorySettingsItemRealm.self)
            for (index, category) in categories.enumerated() {
                if let categoryItem = existingCategories.filter("id == %@", category.id).first {
                    categoryItem.order = index
                }
            }
        }
    }

    func searchURLItemsByTitle(_ query: String) -> [SharedURLItem] {
        return realm.objects(SharedURLItemRealm.self)
            .filter("title CONTAINS[c] %@", query)
            .map { $0.toSharedURLItem() }
    }

    func getImage(for item: SharedURLItem) -> Data? {
        return realm.objects(SharedURLItemRealm.self)
            .filter("id == %@", item.id)
            .first?.imageData
    }

    // Gestión de categorías

    func fetchCategorySettings() -> [CategorySettingsItem] {
        return realm.objects(CategorySettingsItemRealm.self).map { $0.toCategorySettings() }
    }

    func saveCategorySettings(_ settings: [CategorySettingsItem]) {
        try? realm.write {
            // Obtener el máximo 'order' antes de procesar los nuevos elementos
            var maxOrder = (realm.objects(CategorySettingsItemRealm.self).max(ofProperty: "order") as Int?) ?? -1

            for setting in settings {
                if let existingCategory = realm.objects(CategorySettingsItemRealm.self).filter("id == %@", setting.idString).first {
                    // Si la categoría ya existe, actualizamos su color y orden (si se proporciona)
                    existingCategory.color = setting.color ?? "#FFFFFF"
                    existingCategory.order = setting.order
                } else {
                    // Si no existe, se agrega con el siguiente valor de 'order'
                    maxOrder += 1
                    let newCategory = CategorySettingsItemRealm(
                        name: setting.name,
                        color: setting.color ?? "#FFFFFF",
                        order: maxOrder,
                        isHidden: setting.isHidden
                    )
                    realm.add(newCategory)
                }
            }
        }
    }

    func removeCategory(_ category: CategorySettingsItem) {
        if let categorySetting = realm.objects(CategorySettingsItemRealm.self).filter("id == %@", category.idString).first {
            try? realm.write {
                realm.delete(categorySetting)
            }
        }
    }

    func updateCategoryName(_ category: CategorySettingsItem, newName: String) {
        if let realmCategory = realm.objects(CategorySettingsItemRealm.self).filter("id == %@", category.idString).first {
            try? realm.write {
                let oldName = realmCategory.name
                realmCategory.name = newName

//                // Actualizar la categoría en todos los SharedURLItemRealm que usaban el nombre antiguo
//                let itemsToUpdate = realm.objects(SharedURLItemRealm.self).filter("category == %@", oldName)
//                for item in itemsToUpdate {
//                    item.category = newName
//                }
            }
        }
    }
    
    func toggleHiddenStatusCategory(for category: CategorySettingsItem) {
        if let realmItem = realm.objects(CategorySettingsItemRealm.self).filter("id == %@", category.idString).first {
            try? realm.write {
                realmItem.isHidden.toggle()
            }
        }
    }

    // MARK: - Export/Import de Base de Datos (ZIP)
    /// Exporta una copia consistente de la base de datos en un archivo .zip dentro del contenedor del App Group.
    /// - Returns: URL del archivo .zip generado si tuvo éxito, `nil` en caso de error o si no está disponible en la versión del sistema.
    @discardableResult
    func exportDatabaseZip() -> URL? {
        // Obtener contenedor del App Group
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            print("❌ No se pudo obtener el contenedor del grupo \(appGroup)")
            return nil
        }

        // Directorio de backups
        let backupsDir = containerURL.appendingPathComponent("Backups", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: backupsDir, withIntermediateDirectories: true)
        } catch {
            print("❌ No se pudo crear el directorio de Backups: \(error.localizedDescription)")
            return nil
        }

        // Fecha para el nombre del archivo
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        let stamp = formatter.string(from: Date())

        // Crear copia consistente del Realm
        let tempRealmCopyURL = backupsDir.appendingPathComponent("default-\(stamp).realm")
        do {
            try realm.writeCopy(toFile: tempRealmCopyURL)
        } catch {
            print("❌ Error al crear copia del Realm: \(error.localizedDescription)")
            return nil
        }

        // Comprimir a .zip (ZIPFoundation)
        let zipURL = backupsDir.appendingPathComponent("reelKeeper-\(stamp).zip")
        do {
            if let archive = Archive(url: zipURL, accessMode: .create) {
                let baseURL = tempRealmCopyURL.deletingLastPathComponent()
                let path = tempRealmCopyURL.lastPathComponent
                try archive.addEntry(with: path, relativeTo: baseURL, compressionMethod: .deflate)
                // Limpiar la copia temporal .realm tras comprimir
                try? FileManager.default.removeItem(at: tempRealmCopyURL)
                print("✅ Backup ZIP creado en: \(zipURL.path)")
                return zipURL
            } else {
                print("❌ No se pudo crear el archivo ZIP")
                return nil
            }
        } catch {
            print("❌ Error al comprimir a ZIP: \(error.localizedDescription)")
            // Si falla la compresión, dejamos la copia .realm por si el usuario desea usarla manualmente
            return nil
        }
    }

    /// Importa los datos desde un archivo .zip que contiene un fichero .realm exportado previamente.
    /// No sustituye el fichero del Realm en caliente; en su lugar, lee el .realm importado y reemplaza los datos del Realm actual.
    /// - Parameter zipURL: URL del archivo .zip a importar.
    /// - Returns: `true` si la importación fue exitosa, `false` en caso contrario.
    func importDatabaseZip(from zipURL: URL) -> Bool {
        // Validar que el ZIP existe
        guard FileManager.default.fileExists(atPath: zipURL.path) else {
            print("❌ El archivo ZIP no existe en la ruta proporcionada: \(zipURL.path)")
            return false
        }

        // Crear directorio temporal de importación dentro del App Group
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            print("❌ No se pudo obtener el contenedor del grupo \(appGroup)")
            return false
        }
        let tempImportDir = containerURL.appendingPathComponent("ImportTemp-\(UUID().uuidString)", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: tempImportDir, withIntermediateDirectories: true)
        } catch {
            print("❌ No se pudo crear el directorio temporal de importación: \(error.localizedDescription)")
            return false
        }

        // Descomprimir el ZIP (ZIPFoundation)
        do {
            guard let archive = Archive(url: zipURL, accessMode: .read) else {
                print("❌ No se pudo abrir el archivo ZIP para lectura")
                try? FileManager.default.removeItem(at: tempImportDir)
                return false
            }
            for entry in archive {
                let destinationURL = tempImportDir.appendingPathComponent(entry.path)
                let destinationDir = destinationURL.deletingLastPathComponent()
                try FileManager.default.createDirectory(at: destinationDir, withIntermediateDirectories: true)
                try archive.extract(entry, to: destinationURL)
            }
        } catch {
            print("❌ Error al descomprimir ZIP: \(error.localizedDescription)")
            try? FileManager.default.removeItem(at: tempImportDir)
            return false
        }

        // Buscar el primer fichero .realm dentro del directorio descomprimido
        let realmFileToImport: URL?
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: tempImportDir, includingPropertiesForKeys: nil)
            realmFileToImport = contents.first { $0.pathExtension.lowercased() == "realm" }
        } catch {
            print("❌ No se pudo listar el contenido descomprimido: \(error.localizedDescription)")
            try? FileManager.default.removeItem(at: tempImportDir)
            return false
        }

        guard let importedRealmURL = realmFileToImport else {
            print("❌ No se encontró ningún fichero .realm dentro del ZIP")
            try? FileManager.default.removeItem(at: tempImportDir)
            return false
        }

        // Abrir el Realm importado en modo lectura y migrar si es necesario
        let importedConfig = Realm.Configuration(fileURL: importedRealmURL)
        let importedRealm: Realm
        do {
            importedRealm = try Realm(configuration: importedConfig)
        } catch {
            print("❌ No se pudo abrir el Realm importado: \(error.localizedDescription)")
            try? FileManager.default.removeItem(at: tempImportDir)
            return false
        }

        // Transferir los datos: primero categorías y luego items (o viceversa según tus dependencias)
        let importedCategories = importedRealm.objects(CategorySettingsItemRealm.self)
        let importedItems = importedRealm.objects(SharedURLItemRealm.self)

        do {
            try realm.write {
                // Borrar datos actuales
                realm.delete(realm.objects(SharedURLItemRealm.self))
                realm.delete(realm.objects(CategorySettingsItemRealm.self))

                // Insertar datos importados
                realm.add(importedCategories.map { self.makeDetachedCopy(of: $0) }, update: .all)
                realm.add(importedItems.map { self.makeDetachedCopy(of: $0) }, update: .all)
            }
        } catch {
            print("❌ Error al escribir datos importados en el Realm actual: \(error.localizedDescription)")
            try? FileManager.default.removeItem(at: tempImportDir)
            return false
        }

        // Limpieza
        try? FileManager.default.removeItem(at: tempImportDir)
        print("✅ Importación desde ZIP completada correctamente")
        return true
    }

    // Crea copias desvinculadas para poder insertar objetos de un Realm diferente
    private func makeDetachedCopy(of category: CategorySettingsItemRealm) -> CategorySettingsItemRealm {
        let copy = CategorySettingsItemRealm()
        copy.id = category.id
        copy.name = category.name
        copy.color = category.color
        copy.order = category.order
        copy.isHidden = category.isHidden
        return copy
    }

    private func makeDetachedCopy(of item: SharedURLItemRealm) -> SharedURLItemRealm {
        let copy = SharedURLItemRealm()
        copy.id = item.id
        copy.url = item.url
        copy.origin = item.origin
        copy.title = item.title
        copy.idCategory = item.idCategory
        copy.tags.removeAll()
        copy.tags.append(objectsIn: item.tags)
        copy.isFavorite = item.isFavorite
        copy.imageData = item.imageData
        copy.imageURL = item.imageURL
        return copy
    }
}

