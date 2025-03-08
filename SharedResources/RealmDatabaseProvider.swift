//
//  RealmDatabaseProvider.swift
//  reelKeeper
//
//  Created by AlexDelgado on 8/3/25.
//


internal import RealmSwift

class RealmDatabaseProvider: DatabaseProvider {
    private let realm: Realm

    init() {
        do {
            let config = Realm.Configuration(schemaVersion: 1)
            Realm.Configuration.defaultConfiguration = config
            self.realm = try Realm()
        } catch {
            fatalError("Error al inicializar Realm: \(error)")
        }
    }

    func fetchItems() -> [SharedURLItem] {
        let results = realm.objects(SharedURLItemRealm.self)
        return results.map { $0.toSharedURLItem() }
    }

    func deleteItem(by id: UUID) {
        guard let item = realm.object(ofType: SharedURLItemRealm.self, forPrimaryKey: id.uuidString) else { return }
        try? realm.write {
            realm.delete(item)
        }
    }

    func saveItems(_ items: [SharedURLItem], append: Bool = true) {
        do {
            try realm.write {
                if !append {
                    realm.deleteAll()
                }
                let realmItems = items.map { SharedURLItemRealm(from: $0) }
                realm.add(realmItems, update: .modified)
            }
        } catch {
            print("Error guardando datos en Realm: \(error)")
        }
    }

    func clearAllItems() {
        try? realm.write {
            realm.deleteAll()
        }
    }

    func getURLItemsByTag(_ tag: String) -> [SharedURLItem] {
        return fetchItems().filter { $0.tags.contains(tag) }
    }

    func getFavoriteURLItems() -> [SharedURLItem] {
        return fetchItems().filter { $0.isFavorite }
    }

    func getURLItemsByCategory(_ category: String) -> [SharedURLItem] {
        return fetchItems().filter { $0.category.lowercased() == category.lowercased() }
    }

    func searchURLItemsByTitle(_ query: String) -> [SharedURLItem] {
        return fetchItems().filter { $0.title.lowercased().contains(query.lowercased()) }
    }
}
