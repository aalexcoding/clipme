//
//  SharedURLItemRealm.swift
//  reelKeeper
//
//  Created by AlexDelgado on 8/3/25.
//

internal import RealmSwift

class SharedURLItemRealm: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var title: String = ""
    @Persisted var url: String = ""
    @Persisted var tags: List<String>
    @Persisted var isFavorite: Bool = false
    @Persisted var category: String = ""
    @Persisted var userNotes: String = ""
    @Persisted var date: Date = Date()
    @Persisted var origin: String = ""
    @Persisted var imageData: Data?

    convenience init(from item: SharedURLItem) {
        self.init()
        self.title = item.title
        self.url = item.url.absoluteString
        self.tags.append(objectsIn: item.tags)
        self.isFavorite = item.isFavorite
        self.category = item.category
        self.userNotes = item.userNotes
        self.date = item.date
        self.origin = item.origin
        self.imageData = item.imageData
    }

    func toSharedURLItem() -> SharedURLItem {
        return SharedURLItem(
            url: URL(string: self.url)!,
            origin: self.origin,
            title: self.title,
            category: self.category,
            userNotes: self.userNotes,
            date: self.date,
            tags: Array(self.tags),
            isFavorite: self.isFavorite,
            imageData: self.imageData
        )
    }
}
