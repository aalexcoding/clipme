//
//  CategorySettings.swift
//  clipme
//
//  Created by AlexDelgado on 8/3/25.
//

internal import RealmSwift

class CategorySettingsItemRealm: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var name: String
    @Persisted var color: String
    @Persisted var order: Int // Nuevo campo para almacenar el orden
    @Persisted var isHidden: Bool // Nuevo campo para almacenar el orden

    
    convenience init(name: String, color: String = "#FFFFFF", order: Int, isHidden: Bool) {
        self.init()
        self.name = name
        self.color = color
        self.order = order
        self.isHidden = isHidden

    }
    
    func toCategorySettings() -> CategorySettingsItem {
        return CategorySettingsItem(
            idString: self.id,
            name: self.name,
            color: self.color,
            order: self.order,
            isHidden: self.isHidden

        )
    }
}
