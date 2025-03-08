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
    
    @ObservedObject var viewModel = ShareExtensionViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            if let title = viewModel.title {
                
                if let imageData = viewModel.sharedMetadata?.image, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding()
                    
                } else if !viewModel.imageURL.isEmpty { // Display downloaded image
                    AsyncImage(url: URL(string: viewModel.imageURL)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView() // Show loading indicator
                        case .success(let image):
                            image.resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        case .failure:
                            Image(systemName: "photo") // Fallback image icon
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .foregroundColor(.gray)
                        @unknown default:
                            ProgressView()
                        }
                    }
                    .padding()
                }
                
                Text(title)
                    .font(.body)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .padding()
                
                Picker("Categoría", selection: $viewModel.category) {
                    ForEach(viewModel.categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                
                //TagsInputView(tags: $viewModel.tags) // Componente para añadir tags
                
                Button("Guardar") {
                    viewModel.saveSharedURL()
                    extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                }
                .padding(.top, 20)
            } else if let error = viewModel.errorMessage {
                Text("Error:")
                    .font(.headline)
                Text(error)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                Text("Procesando link...")
            }
        }
        .padding()
        .onAppear {
            print("ShareExtensionView aparece en pantalla")
            viewModel.loadURL(extensionContext)
        }
    }
}
