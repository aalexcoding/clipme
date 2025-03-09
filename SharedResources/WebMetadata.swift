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

public class WebMetadataFetcher {
    public static func fetch(url: URL, completion: @escaping (WebMetadata) -> Void) {
        let metadataProvider = LPMetadataProvider()
        
        metadataProvider.startFetchingMetadata(for: url) { metadata, error in
            guard let metadata = metadata, error == nil else {
                print("Error fetching metadata: \(error?.localizedDescription ?? "Unknown error")")
                completion(WebMetadata(title: "Unknown Title", description: "No description available", imageURL: "https://example.com/default-image.jpg", image: nil))
                return
            }
            
            let title = metadata.title ?? "Unknown Title"
            let description = metadata.url?.absoluteString ?? "No description available"
            let imageURL = "https://example.com/default-image.jpg" // Default if no image

            if let imageProvider = metadata.imageProvider {
                imageProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    DispatchQueue.main.async {
                        let imageData = (image as? UIImage)?.jpegData(compressionQuality: 0.6)
                        completion(WebMetadata(title: title, description: description, imageURL: imageURL, image: imageData))
                    }
                }
            } else {
                completion(WebMetadata(title: title, description: description, imageURL: imageURL, image: nil))
            }
        }
    }
}
