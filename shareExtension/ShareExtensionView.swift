//
//  ShareExtensionView.swift
//  reelKeeper
//
//  Created by AlexDelgado on 6/3/25.
//

import SwiftUI
import SharedResources

struct ShareExtensionView: View {
    var extensionContext: NSExtensionContext?
    
    @State private var sharedURL: URL?
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            if let url = sharedURL {
                Text("Link recibido:")
                    .font(.headline)
                Text(url.absoluteString)
                    .multilineTextAlignment(.center)
                    .padding()
            } else if let error = errorMessage {
                Text("Error:")
                    .font(.headline)
                Text(error)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                Text("Procesando link...")
            }
            
            Button("Finalizar") {
                if let url = sharedURL {
                    // Extraer el origen de la URL
                    let origin = extractOrigin(from: url.absoluteString)
                    
                    // Ejemplo en la extensión al finalizar la acción de compartir:
                    SharedDefaultsManager.shared.saveURL(
                        url,
                        origin: origin, // O el identificador que prefieras
                        itemDescription: "", // Opcional
                        category: "",        // Opcional
                        userNotes: ""        // Opcional
                    )

                }
                extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            }
            .padding(.top, 30)
        }
        .padding()
        .onAppear {
            print("ShareExtensionView aparece en pantalla")
            loadURL()
        }
    }
    
    private func loadURL() {
        guard let inputItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            errorMessage = "No se encontraron elementos compartidos."
            return
        }
        
        for item in inputItems {
            if let attachments = item.attachments {
                for provider in attachments {
                    // Primero intentamos con "public.url"
                    if provider.hasItemConformingToTypeIdentifier("public.url") {
                        provider.loadItem(forTypeIdentifier: "public.url", options: nil) { (item, error) in
                            if let error = error {
                                DispatchQueue.main.async {
                                    self.errorMessage = error.localizedDescription
                                }
                            } else if let url = item as? URL {
                                DispatchQueue.main.async {
                                    if isSupportedURL(url) {
                                        self.sharedURL = url
                                    } else {
                                        self.errorMessage = "URL no soportada. Asegúrate de compartir links de TikTok, Instagram, YouTube o Twitter."
                                    }
                                }
                            }
                        }
                        return  // Solo procesamos el primer item encontrado
                    }
                    
                    // Si no se encuentra, intentamos con "public.plain-text"
                    if provider.hasItemConformingToTypeIdentifier("public.plain-text") {
                        provider.loadItem(forTypeIdentifier: "public.plain-text", options: nil) { (item, error) in
                            if let error = error {
                                DispatchQueue.main.async {
                                    self.errorMessage = error.localizedDescription
                                }
                            } else if let text = item as? String, let url = URL(string: text) {
                                DispatchQueue.main.async {
                                    if isSupportedURL(url) {
                                        self.sharedURL = url
                                    } else {
                                        self.errorMessage = "URL no soportada. Asegúrate de compartir links de TikTok, Instagram, YouTube o Twitter."
                                    }
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self.errorMessage = "No se pudo interpretar el texto compartido como una URL válida."
                                }
                            }
                        }
                        return
                    }
                }
            }
        }
    }
    
    /// Verifica que el URL sea de uno de los dominios soportados.
    private func isSupportedURL(_ url: URL) -> Bool {
        let supportedHosts = ["tiktok.com", "instagram.com", "youtube.com", "twitter.com", "x.com", "linkedin.com"]
        guard let host = url.host?.lowercased() else { return false }
        return supportedHosts.contains { host.contains($0) }
    }
    
    /// Extrae el origen de la URL (por ejemplo, "youtube").
    private func extractOrigin(from urlString: String) -> String {
        guard let url = URL(string: urlString),
              let host = url.host else {
            return "web"
        }
        
        if host.contains("youtube.com") || host.contains("youtu.be") {
            return "youtube"
        } else if host.contains("tiktok.com") {
            return "tiktok"
        } else if host.contains("instagram.com") {
            return "instagram"
        } else if host.contains("linkedin.com") {
            return "linkedin"
        } else if host.contains("twitter.com") || host.contains("x.com") {
            return "twitter"
        } else {
            return "web"
        }
    }
}
