//
//  SharedDefaultsManagerProtocol.swift
//  clipme
//
//  Created by AlexDelgado on 9/3/25.
//


public protocol SharedDefaultsManagerProtocol {
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
                 imageURL: String)

    func retrieveURLItems() -> [SharedURLItem]?
    func clearURLInfo()
}
