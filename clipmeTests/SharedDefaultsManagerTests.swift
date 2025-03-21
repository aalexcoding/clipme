//
//  MockSharedDefaultsManager.swift
//  clipme
//
//  Created by AlexDelgado on 9/3/25.
//


import XCTest
import SharedResources

@testable import ClipMe



final class SharedDefaultsManagerTests: XCTestCase {
    var sharedDefaultsManager: SharedDefaultsManagerProtocol!

    override func setUp() {
        super.setUp()
        sharedDefaultsManager = MockSharedDefaultsManager()
    }

    override func tearDown() {
        sharedDefaultsManager.clearURLInfo()
        sharedDefaultsManager = nil
        super.tearDown()
    }

    func testSaveAndRetrieveURL() {
        let testItem = SharedURLItem(
            url: URL(string:"https://www.instagram.com/reel/DFpg5WJoqHY/?igsh=MWl2bmlrN3BibnNsNQ==")!,
            origin: "instagram.com",
            title: "Instagram Reel",
            itemDescription: "Short video on Instagram",
            idCategory: "Social",
            userNotes: "",
            date: Date(),
            tags: ["shorts", "video"],
            isFavorite: false,
            imageData: nil,
            imageURL: "https://instagram.com/reel_image.jpg"
        )

        sharedDefaultsManager.saveURL(testItem.url,
                                      origin: testItem.origin,
                                      title: testItem.title,
                                      itemDescription: testItem.itemDescription,
                                      idCategory: testItem.idCategory,
                                      userNotes: testItem.userNotes,
                                      date: testItem.date,
                                      tags: testItem.tags,
                                      isFavorite: testItem.isFavorite,
                                      imageData: testItem.imageData,
                                      imageURL: testItem.imageURL)

        let retrievedItems = sharedDefaultsManager.retrieveURLItems()
        XCTAssertNotNil(retrievedItems)
        XCTAssertEqual(retrievedItems?.count, 1)
        XCTAssertEqual(retrievedItems?.first?.url, testItem.url)
        XCTAssertEqual(retrievedItems?.first?.title, testItem.title)
    }

    func testClearURLInfo() {

        sharedDefaultsManager.saveURL(URL(string:"https://www.instagram.com/reel/DFpg5WJoqHY/?igsh=MWl2bmlrN3BibnNsNQ==")!,
                                      origin: "instagram.com",
                                      title: "Instagram Reel",
                                      itemDescription: "Short video on Instagram",
                                      idCategory: "Social",
                                      userNotes: "",
                                      date: Date(),
                                      tags: ["shorts", "video"],
                                      isFavorite: false,
                                      imageData: nil,
                                      imageURL: "https://instagram.com/reel_image.jpg")
        
        XCTAssertNotNil(sharedDefaultsManager.retrieveURLItems())

        sharedDefaultsManager.clearURLInfo()
        
        XCTAssertEqual(sharedDefaultsManager.retrieveURLItems(), [])
    }
}
