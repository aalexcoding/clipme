//
//  SharedDefaultsManagerTests.swift
//  clipme
//
//  Created by AlexDelgado on 9/3/25.
//

import SharedResources


final class MockSharedDefaultsManager: SharedDefaultsManagerProtocol {
    private var storage: [SharedURLItem] = []
    
    func saveURL(_ url: URL,
                 origin: String,
                 title: String,
                 itemDescription: String,
                 idCategory: String,
                 userNotes: String,
                 date: Date,
                 tags: [String],
                 isFavorite: Bool,
                 imageData: Data?,
                 imageURL: String) {
        let newItem = SharedURLItem(url: url,
                                    origin: origin,
                                    title: title,
                                    itemDescription: itemDescription,
                                    idCategory: idCategory,
                                    userNotes: userNotes,
                                    date: date,
                                    tags: tags,
                                    isFavorite: isFavorite,
                                    imageData: imageData,
                                    imageURL: imageURL)
        storage.append(newItem)
    }

    func retrieveURLItems() -> [SharedURLItem]? {
        return storage
    }

    func clearURLInfo() {
        storage.removeAll()
    }
}
