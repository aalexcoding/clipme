//
//  elementOrderBy.swift
//  clipme
//
//  Created by AlexDelgado on 20/3/25.
//


enum ElementOrderBy: String, CaseIterable {
    case dateLatestFirst = "date_new_first"
    case dateLatestLast = "date_old_first"
    case titleAscending = "title_ascending"
    case titleDescending = "title_descending"
    
    var localizedName: String {
        return String(localized: String.LocalizationValue(self.rawValue))
    }
}
