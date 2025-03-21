//
//  elementOrderBy.swift
//  clipme
//
//  Created by AlexDelgado on 20/3/25.
//


enum ElementOrderBy: String, CaseIterable {
    case dateLatestFirst = "date-new-first"
    case dateLatestLast = "date-old-first"
    case titleAscending = "title-ascending"
    case titleDescending = "title-descending"
}
