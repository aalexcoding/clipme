//
//  SharedFileManagerTests.swift
//  clipme
//
//  Created by AlexDelgado on 9/3/25.
//

import XCTest
import SharedResources

@testable import ClipMe

final class SharedFileManagerTests: XCTestCase {
    var mockManager: MockSharedFileManager!

    override func setUp() {
        super.setUp()
        mockManager = MockSharedFileManager()
    }

    override func tearDown() {
        mockManager = nil
        super.tearDown()
    }

    func testGetURLItems() {
        let item1 = SharedURLItem(
            url: URL(string:"https://www.instagram.com/reel/DFpg5WJoqHY/?igsh=MWl2bmlrN3BibnNsNQ==")!,
            origin: "instagram.com",
            title: "Instagram Reel",
            itemDescription: "Short video on Instagram",
            category: "Social",
            userNotes: "",
            date: Date(),
            tags: ["shorts", "video"],
            isFavorite: false,
            imageData: nil,
            imageURL: "https://instagram.com/reel_image.jpg"
        )

        let item2 = SharedURLItem(
            url: URL(string:"https://youtube.com/shorts/zoeKKV2VHyw?si=E-Stn6ALWSormLhy")!,
            origin: "youtube.com",
            title: "YouTube Shorts",
            itemDescription: "Short video on YouTube",
            category: "Entertainment",
            userNotes: "",
            date: Date(),
            tags: ["shorts", "video"],
            isFavorite: false,
            imageData: nil,
            imageURL: "https://youtube.com/shorts_image.jpg"
        )

        mockManager.mockURLs = [item1, item2]

        let fetchedItems = mockManager.getURLItems()
        XCTAssertEqual(fetchedItems.count, 2)
        XCTAssertEqual(fetchedItems[0].origin, "instagram.com")
        XCTAssertEqual(fetchedItems[1].origin, "youtube.com")
    }

    func testDeleteURL() {
        let item = SharedURLItem(
            url: URL(string:"https://google.com")!,
            origin: "google.com",
            title: "Google",
            itemDescription: "Search Engine",
            category: "Search",
            userNotes: "",
            date: Date(),
            tags: ["web"],
            isFavorite: false,
            imageData: nil,
            imageURL: ""
        )

        mockManager.mockURLs = [item]
        
        mockManager.deleteURL(by: item.idString)
        XCTAssertEqual(mockManager.mockURLs.count, 0)
    }

    func testSaveURL() {
        let item1 = SharedURLItem(
            url: URL(string:"https://www.instagram.com/reel/DFpg5WJoqHY/?igsh=MWl2bmlrN3BibnNsNQ==")!,
            origin: "instagram.com",
            title: "Instagram Reel",
            itemDescription: "Short video on Instagram",
            category: "Social",
            userNotes: "",
            date: Date(),
            tags: ["shorts", "video"],
            isFavorite: false,
            imageData: nil,
            imageURL: "https://instagram.com/reel_image.jpg"
        )

        mockManager.saveURL([item1], append: true)

        XCTAssertEqual(mockManager.mockURLs.count, 1)
        XCTAssertEqual(mockManager.mockURLs.first?.title, "Instagram Reel")
    }

    func testClearURLInfo() {
        let item2 = SharedURLItem(
            url: URL(string:"https://youtube.com/shorts/zoeKKV2VHyw?si=E-Stn6ALWSormLhy")!,
            origin: "youtube.com",
            title: "YouTube Shorts",
            itemDescription: "Short video on YouTube",
            category: "Entertainment",
            userNotes: "",
            date: Date(),
            tags: ["shorts", "video"],
            isFavorite: false,
            imageData: nil,
            imageURL: "https://youtube.com/shorts_image.jpg"
        )

        mockManager.mockURLs = [item2]
        
        mockManager.clearURLInfo()
        XCTAssertEqual(mockManager.mockURLs.count, 0)
    }

    func testGetURLItemsByTag() {
        
        let item1 = SharedURLItem(
            url: URL(string:"https://www.instagram.com/reel/DFpg5WJoqHY/?igsh=MWl2bmlrN3BibnNsNQ==")!,
            origin: "instagram.com",
            title: "Instagram Reel",
            itemDescription: "Short video on Instagram",
            category: "Social",
            userNotes: "",
            date: Date(),
            tags: ["shorts", "video"],
            isFavorite: false,
            imageData: nil,
            imageURL: "https://instagram.com/reel_image.jpg"
        )

        let item2 = SharedURLItem(
            url: URL(string:"https://youtube.com/shorts/zoeKKV2VHyw?si=E-Stn6ALWSormLhy")!,
            origin: "youtube.com",
            title: "YouTube Shorts",
            itemDescription: "Short video on YouTube",
            category: "Entertainment",
            userNotes: "",
            date: Date(),
            tags: ["shorts", "video"],
            isFavorite: false,
            imageData: nil,
            imageURL: "https://youtube.com/shorts_image.jpg"
        )
        
        mockManager.mockURLs = [item1, item2]

        let filteredItems = mockManager.getURLItemsByTag("shorts")
        XCTAssertEqual(filteredItems.count, 2)
    }

    func testFetchCategorySettings() {
        mockManager.mockCategories = [CategorySettingsItem(name: "Tech"), CategorySettingsItem(name: "Search")]
        XCTAssertEqual(mockManager.fetchCategorySettings().count, 2)
    }

    func testUpdateCategorySetting() {
        let category = CategorySettingsItem(name: "Tech", color: "Blue")
        mockManager.mockCategories = [category]
        
        mockManager.updateCategorySetting(for: "Tech", color: "Red")
        XCTAssertEqual(mockManager.mockCategories.first?.color, "Red")
        XCTAssertEqual(mockManager.mockCategories.first?.name, "Tech")

    }

    func testRemoveCategory() {
        mockManager.mockCategories = [CategorySettingsItem(name: "Tech")]
        mockManager.removeCategory("Tech")
        
        XCTAssertEqual(mockManager.mockCategories.count, 0)
    }
}
