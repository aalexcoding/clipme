//
//  RealmDatabaseProvider.swift
//  reelKeeper
//
//  Created by AlexDelgado on 8/3/25.
//


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

    func getURLItemsByCategory(_ category: String) -> [SharedURLItem] {
        return realm.objects(SharedURLItemRealm.self)
            .filter("category == %@", category)
            .map { $0.toSharedURLItem() }
    }
    
    func updateSharedURLItemCategory(_ item: SharedURLItem, newCategory: String) {
        if let realmItem = realm.objects(SharedURLItemRealm.self).filter("id == %@", item.idString).first {
            try? realm.write {
                realmItem.category = newCategory
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
                        order: maxOrder
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

                // Actualizar la categoría en todos los SharedURLItemRealm que usaban el nombre antiguo
                let itemsToUpdate = realm.objects(SharedURLItemRealm.self).filter("category == %@", oldName)
                for item in itemsToUpdate {
                    item.category = newName
                }
            }
        }
    }
}
