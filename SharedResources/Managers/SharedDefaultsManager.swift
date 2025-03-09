//
//  SharedDefaultsManager.swift
//  reelKeeper
//
//  Created by AlexDelgado on 6/3/25.
//

import Foundation



public final class SharedDefaultsManager: SharedDefaultsManagerProtocol {
    public static let shared = SharedDefaultsManager()
    
    private let suiteName = "group.com.add.clipme.shared"
    private let sharedURLItemListKey = "sharedURLItemList"
    private var userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = UserDefaults(suiteName: "group.com.add.clipme.shared")!) {
        self.userDefaults = userDefaults
    }

    public func saveURL(_ url: URL,
                        origin: String,
                        title: String = "",
                        itemDescription: String = "",
                        category: String = "",
                        userNotes: String = "",
                        date: Date = Date(),
                        tags: [String] = [],
                        isFavorite: Bool = false,
                        imageData: Data? = nil,
                        imageURL: String = "") {
        var currentItems = retrieveURLItems() ?? []
        let newItem = SharedURLItem(url: url,
                                    origin: origin,
                                    title: title,
                                    itemDescription: itemDescription,
                                    category: category,
                                    userNotes: userNotes,
                                    date: date,
                                    tags: tags,
                                    isFavorite: isFavorite,
                                    imageData: imageData,
                                    imageURL: imageURL)
        currentItems.append(newItem)
        
        do {
            let data = try JSONEncoder().encode(currentItems)
            userDefaults.set(data, forKey: sharedURLItemListKey)
        } catch {
            print("Error al codificar los SharedURLItem: \(error)")
        }
    }
    
    public func retrieveURLItems() -> [SharedURLItem]? {
        guard let data = userDefaults.data(forKey: sharedURLItemListKey) else {
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
    
    public func clearURLInfo() {
        userDefaults.removeObject(forKey: sharedURLItemListKey)
        userDefaults.synchronize()
    }
}
