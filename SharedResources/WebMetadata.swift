//
//  WebMetadata.swift
//  clipme
//
//  Created by AlexDelgado on 8/3/25.
//

import Foundation
import LinkPresentation
import UIKit

public struct WebMetadata {
    public let title: String
    public let description: String
    public let imageURL: String
    public let image: Data?
}

public enum PlatformType {
    case youtube
    case `default`
}

public protocol WebMetadataFetcherProtocol {
    func fetch(url: URL) async throws -> WebMetadata
}

public class WebMetadataFetcher: WebMetadataFetcherProtocol {
    private let apiKey: String
    private let urlSession: URLSession
    private let baseAPIURL: String

    public init(apiKey: String, urlSession: URLSession = .shared, baseAPIURL: String = "https://www.googleapis.com/youtube/v3/videos") {
        self.apiKey = apiKey
        self.urlSession = urlSession
        self.baseAPIURL = baseAPIURL
    }

    public func fetch(url: URL) async throws -> WebMetadata {
        let platform = identifyPlatform(for: url)
        
        switch platform {
        case .youtube:
            return try await obtenerMetadatosDelVideo(url: url)
        case .default:
            return try await fetchDefaultMetadata(from: url)
        }
    }
    
    private func identifyPlatform(for url: URL) -> PlatformType {
        if url.host?.contains("youtube.com") == true || url.host?.contains("youtu.be") == true {
            return .default
        } else if url.host?.contains("twitter.com") == true {
            return .default
        } else if url.host?.contains("instagram.com") == true {
            return .default
        } else if url.host?.contains("tiktok.com") == true {
            return .default
        } else if url.host?.contains("linkedin.com") == true {
            return .default
        } else {
            return .default
        }
    }
    
    private func fetchDefaultMetadata(from url: URL) async throws -> WebMetadata {
        let metadataProvider = LPMetadataProvider()
        return try await withCheckedThrowingContinuation { continuation in
            metadataProvider.startFetchingMetadata(for: url) { metadata, error in
                if let metadata = metadata, error == nil {
                    self.processLPMetadata(metadata, continuation: continuation)
                } else {
                    continuation.resume(returning: WebMetadata(title: "Unknown Title", description: "No description available", imageURL: "https://example.com/default-image.jpg", image: nil))
                }
            }
        }
    }
    
    private func processLPMetadata(_ metadata: LPLinkMetadata, continuation: CheckedContinuation<WebMetadata, Error>) {
        let title = metadata.title ?? "Unknown Title"
        let description = metadata.url?.absoluteString ?? "No description available"
        let imageURL = metadata.imageProvider != nil ? "Extracted image URL" : "https://example.com/default-image.jpg"

        if let imageProvider = metadata.imageProvider {
            imageProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                let imageData = (image as? UIImage)?.jpegData(compressionQuality: 0.6)
                continuation.resume(returning: WebMetadata(title: title, description: description, imageURL: imageURL, image: imageData))
            }
        } else {
            continuation.resume(returning: WebMetadata(title: title, description: description, imageURL: imageURL, image: nil))
        }
    }
    
    private func obtenerMetadatosDelVideo(url: URL) async throws -> WebMetadata {
        return try await fetchYouTubeMetadata(from: url)
    }
    
    private func fetchYouTubeMetadata(from url: URL) async throws -> WebMetadata {
        guard let videoID = extractYouTubeVideoID(from: url) else {
            throw NSError(domain: "InvalidURL", code: 0, userInfo: nil)
        }

        let apiURL = "\(baseAPIURL)?id=\(videoID)&part=snippet&key=\(apiKey)"

        let (data, response) = try await urlSession.data(from: URL(string: apiURL)!)
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let items = json["items"] as? [[String: Any]],
              let snippet = items.first?["snippet"] as? [String: Any],
              let title = snippet["title"] as? String,
              let description = snippet["description"] as? String,
              let thumbnails = snippet["thumbnails"] as? [String: Any],
              let highThumbnail = thumbnails["high"] as? [String: Any],
              let thumbnailURL = highThumbnail["url"] as? String else {
            throw NSError(domain: "ParsingError", code: 0, userInfo: nil)
        }

        return WebMetadata(title: title, description: description, imageURL: thumbnailURL, image: nil)
    }
    
    private func extractYouTubeVideoID(from url: URL) -> String? {
        let patterns = [
            "youtube\\.com/watch\\?v=([^&]+)",  // Standard YouTube video
            "youtube\\.com/shorts/([^?]+)",     // YouTube Shorts
            "youtu\\.be/([^?]+)"                // Shortened YouTube link
        ]

        let urlString = url.absoluteString
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: urlString, options: [], range: NSRange(location: 0, length: urlString.count)) {
                if let range = Range(match.range(at: 1), in: urlString) {
                    return String(urlString[range])
                }
            }
        }
        return nil
    }
}
