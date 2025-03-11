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

    func getURLItemsByCategory(_ category: String) -> [SharedURLItem] {
        return realm.objects(SharedURLItemRealm.self)
            .filter("category == %@", category)
            .map { $0.toSharedURLItem() }
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
            let realmSettings = settings.map { CategorySettingsItemRealm(name: $0.name, color: $0.color ?? "FFFFFFF") }
            realm.add(realmSettings, update: .all)
        }
    }

    func updateCategorySetting(for category: String, color: String?) {
        if let existingSetting = realm.objects(CategorySettingsItemRealm.self).filter("name == %@", category).first {
            try? realm.write {
                if let color = color {
                    existingSetting.color = color
                }
            }
        } else {
            let newSetting = CategorySettingsItemRealm(name: category, color: color ?? "#FFFFFF")
            try? realm.write {
                realm.add(newSetting)
            }
        }
    }

    func removeCategory(_ category: String) {
        if let categorySetting = realm.objects(CategorySettingsItemRealm.self).filter("name == %@", category).first {
            try? realm.write {
                realm.delete(categorySetting)
            }
        }
    }
}
