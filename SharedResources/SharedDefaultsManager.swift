//
//  SharedDefaultsManager.swift
//  reelKeeper
//
//  Created by AlexDelgado on 6/3/25.
//


import Foundation

public final class SharedDefaultsManager {
    public static let shared = SharedDefaultsManager()
    
    // Nombre del App Group. Debe coincidir en ambos targets.
    private let suiteName = "group.com.add.testing.reelKeeper.2"
    
    // Clave donde se almacenará la información (ahora un array de diccionarios)
    private let sharedURLItemListKey = "sharedURLItemList"

    private var userDefaults: UserDefaults? {
        return UserDefaults(suiteName: suiteName)
    }
    

    public func saveURL(_ url: URL,
                        origin: String,
                        itemDescription: String = "",
                        category: String = "",
                        userNotes: String = "") {
        var currentItems = retrieveURLItems() ?? []
        let newItem = SharedURLItem(url: url,
                                    origin: origin,
                                    itemDescription: itemDescription,
                                    category: category,
                                    userNotes: userNotes,
                                    date: Date())
        currentItems.append(newItem)
        
        do {
            let data = try JSONEncoder().encode(currentItems)
            userDefaults?.set(data, forKey: sharedURLItemListKey)
        } catch {
            print("Error al codificar los SharedURLItem: \(error)")
        }
    }
    
    public func retrieveURLItems() -> [SharedURLItem]? {
        guard let data = userDefaults?.data(forKey: sharedURLItemListKey) else {
            return nil
        }
        do {
            let items = try JSONDecoder().decode([SharedURLItem].self, from: data)
            return items
        } catch {
            print("Error al decodificar los SharedURLItem: \(error)")
            return nil
        }
    }
    
    /// Limpia la información almacenada.
    public func clearURLInfo() {
        userDefaults?.removeObject(forKey: sharedURLItemListKey)
        userDefaults?.synchronize()
    }
}
