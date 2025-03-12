//
//  YouTubeVideoMetadata.swift
//  clipme
//
//  Created by AlexDelgado on 10/3/25.
//


import Foundation

public class YouTubeVideoMetadata {
    
    // Estructura para representar los metadatos del video
    struct VideoMetadata {
        let id: String
        let title: String
        let description: String
        let publishedAt: String
        let channelTitle: String
        let thumbnailURL: URL?
        let viewCount: String?
        let likeCount: String?
        let duration: String?
    }
    
    // Tu API Key de YouTube
    private let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    // Extraer el ID del video desde un enlace de YouTube
    private func extractVideoID(from urlString: String) -> String? {
        guard let url = URL(string: urlString) else { return nil }
        
        // Manejar enlaces de YouTube Shorts
        if urlString.contains("youtube.com/shorts/") {
            let components = urlString.components(separatedBy: "/shorts/")
            if components.count > 1 {
                return components[1].components(separatedBy: "?")[0]
            }
        }
        
        // Manejar enlaces de YouTube normales
        if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems {
            for item in queryItems where item.name == "v" {
                return item.value
            }
        }
        
        return nil
    }
    
    // Realizar la llamada a la API de YouTube
    func fetchVideoMetadata(from urlString: String, completion: @escaping (Result<VideoMetadata, Error>) -> Void) {
        guard let videoID = extractVideoID(from: urlString) else {
            completion(.failure(NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid YouTube URL"])))
            return
        }
        
        let apiURLString = "https://www.googleapis.com/youtube/v3/videos?part=snippet,contentDetails,statistics&id=\(videoID)&key=\(apiKey)"
        
        guard let apiURL = URL(string: apiURLString) else {
            completion(.failure(NSError(domain: "InvalidAPIURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid API URL"])))
            return
        }
        
        let task = URLSession.shared.dataTask(with: apiURL) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                guard let items = json?["items"] as? [[String: Any]], let firstItem = items.first else {
                    completion(.failure(NSError(domain: "NoItems", code: -1, userInfo: [NSLocalizedDescriptionKey: "No video data found"])))
                    return
                }
                
                // Parsear los metadatos del video
                let snippet = firstItem["snippet"] as? [String: Any]
                let contentDetails = firstItem["contentDetails"] as? [String: Any]
                let statistics = firstItem["statistics"] as? [String: Any]
                
                guard let snippet = snippet else {
                    completion(.failure(NSError(domain: "InvalidSnippet", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid snippet data"])))
                    return
                }
                
                let title = snippet["title"] as? String ?? "No Title"
                let description = snippet["description"] as? String ?? "No Description"
                let publishedAt = snippet["publishedAt"] as? String ?? "No Date"
                let channelTitle = snippet["channelTitle"] as? String ?? "No Channel"
                let thumbnailURLString = (snippet["thumbnails"] as? [String: Any])?["medium"] as? [String: Any]? ?? ["url": nil ?? ""]
                let thumbnailURL = URL(string: thumbnailURLString?["url"] as? String ?? "")
                
                let viewCount = statistics?["viewCount"] as? String
                let likeCount = statistics?["likeCount"] as? String
                let duration = contentDetails?["duration"] as? String
                
                let metadata = VideoMetadata(
                    id: videoID,
                    title: title,
                    description: description,
                    publishedAt: publishedAt,
                    channelTitle: channelTitle,
                    thumbnailURL: thumbnailURL,
                    viewCount: viewCount,
                    likeCount: likeCount,
                    duration: duration
                )
                
                completion(.success(metadata))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
