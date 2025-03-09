//
//  CategorySettings.swift
//  clipme
//
//  Created by AlexDelgado on 8/3/25.
//

internal import RealmSwift

class CategorySettingsItemRealm: Object {
    @Persisted(primaryKey: true) var name: String
    @Persisted var color: String
    
    convenience init(name: String, color: String = "#FFFFFF") {
        self.init()
        self.name = name
        self.color = color
    }
    
    func toCategorySettings() -> CategorySettingsItem {
        return CategorySettingsItem(
            name: self.name,
            color: self.color
        )
    }
}

