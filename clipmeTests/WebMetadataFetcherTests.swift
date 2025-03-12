//
//  WebMetadataFetcherTests.swift
//  clipme
//
//  Created by AlexDelgado on 11/3/25.
//

import XCTest
import LinkPresentation
import SharedResources

@testable import ClipMe

class WebMetadataFetcherTests: XCTestCase {
    
    var webMetadataFetcher: WebMetadataFetcher!
    var sharedMetadata: WebMetadata?
    var title: String?
    var imageURL: String?
    
    override func setUp() {
        super.setUp()
        self.webMetadataFetcher = WebMetadataFetcher(apiKey: "")

    }

    override func tearDown() {
        webMetadataFetcher = nil
        super.tearDown()
    }

    // MARK: - Default Metadata Tests

    func testFetchDefaultMetadataWithYouTubeSuccess() async throws {
        let url = URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")!
        
        let metadata = try await webMetadataFetcher.fetch(url: url)

        XCTAssertEqual(metadata.title, "Rick Astley - Never Gonna Give You Up (Official Music Video)")
        XCTAssertEqual(metadata.description, "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
        XCTAssertNotNil(metadata.image)
    }
    
//    func testFetchDefaultMetadataWithInstagramSuccess() async throws {
//        let url = URL(string: "https://www.instagram.com/reel/DFeI0LEiEJL/?igsh=MXFpdjEwemI3MWU3dg==")!
//        
//        let metadata = try await webMetadataFetcher.fetch(url: url)
//
//        XCTAssertEqual(metadata.title, "Techno Forever en Instagram: \"Un temazo 😍🔊\n\n#dj #reels #rave #parati #techhouse #foryou #raver #explore #techno #housemusic #technomusic #ravers #deejay #festival #fiesta #edm\"")
//        XCTAssertEqual(metadata.description, "https://www.instagram.com/reel/DFeI0LEiEJL/")
//        XCTAssertNotNil(metadata.image)
//    }

//    func testFetchDefaultMetadataWithXSuccess() async throws {
//        let url = URL(string: "https://twitter.com/username/status/1234567890")!
//        
//        let metadata = try await webMetadataFetcher.fetch(url: url)
//
//        XCTAssertEqual(metadata.title, "Expected Title from X")
//        XCTAssertEqual(metadata.description, "Expected Description from X")
//        XCTAssertNotNil(metadata.image)
//    }
//
//    func testFetchDefaultMetadataWithLinkedInSuccess() async throws {
//        let url = URL(string: "https://www.linkedin.com/posts/username_post-title-1234567890")!
//        
//        let metadata = try await webMetadataFetcher.fetch(url: url)
//
//        XCTAssertEqual(metadata.title, "Expected Title from LinkedIn")
//        XCTAssertEqual(metadata.description, "Expected Description from LinkedIn")
//        XCTAssertNotNil(metadata.image)
//    }
//
//    func testFetchDefaultMetadataWithTikTokSuccess() async throws {
//        let url = URL(string: "https://www.tiktok.com/@username/video/1234567890")!
//        
//        let metadata = try await webMetadataFetcher.fetch(url: url)
//
//        XCTAssertEqual(metadata.title, "Expected Title from TikTok")
//        XCTAssertEqual(metadata.description, "Expected Description from TikTok")
//        XCTAssertNotNil(metadata.image)
//    }
    
//    func testFetchDefaultMetadataError() async throws {
//        let url = URL(string: "https://example.com")!
//
//        let metadata = try await webMetadataFetcher.fetch(url: url)
//        XCTAssertEqual(metadata.title, "Unknown Title")
//        XCTAssertEqual(metadata.description, "No description available")
//        XCTAssertEqual(metadata.imageURL, "https://example.com/default-image.jpg")
//        XCTAssertNil(metadata.image)
//    }

    // MARK: - YouTube Metadata Tests

//    func testFetchYouTubeMetadataSuccess() async throws {
//        let url = URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")!
//
//        let metadata = try await webMetadataFetcher.fetch(url: url)
//
//        XCTAssertEqual(metadata.title, "Test Video Title")
//        XCTAssertEqual(metadata.description, "Test Video Description")
//        XCTAssertEqual(metadata.imageURL, "https://example.com/thumbnail.jpg")
//        XCTAssertNil(metadata.image)
//    }

//    func testFetchYouTubeMetadataError() async throws {
//        let url = URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")!
//
//        let metadata = try await webMetadataFetcher.fetch(url: url)
//        XCTAssertEqual(metadata.title, "Unknown Title")
//        XCTAssertEqual(metadata.description, "No description available")
//        XCTAssertEqual(metadata.imageURL, "")
//        XCTAssertNil(metadata.image)
//    }
}
