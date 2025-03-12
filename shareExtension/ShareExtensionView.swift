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
    
    @ObservedObject var viewModel = ShareExtensionViewModel(apiKey: "AIzaSyAERVpetNGIkIMz36W7_scy8OzU8y2Kch0")
    @State private var isAddCategoryPresented: Bool = false
    @State private var isLoading: Bool = true

    
    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                ProgressView() // Loader cuando isLoading es true
            } else {
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
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.categories, id: \.self) { category in
                                Button(action: {
                                    viewModel.category = category
                                }) {
                                    Text(category)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 16)
                                        .background(viewModel.category == category ? Color.blue.opacity(0.2) : Color.clear)
                                        .cornerRadius(20)
                                }
                            }
                            Button(action: {
                                isAddCategoryPresented = true
                            }) {
                                Image(systemName: "plus")
                                    .padding(10)
                                    .background(Color.blue.opacity(0.2))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 0)
                    }
                    .listRowSeparator(.hidden) // 🔥 Oculta las líneas arriba y abajo
                    
                    
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
        }
        .overlay(
            Group {
                if isAddCategoryPresented {
                    AddCategoryPopupView(isPresented: $isAddCategoryPresented) { newCategory in
                        viewModel.addNewCategory(newCategory)
                    }
//                        .transition(.move(edge: .leading).combined(with: .opacity))
                }
            }
        )
        .animation(.easeInOut(duration: 0.2), value: isAddCategoryPresented)
        .padding()
        .onAppear {
            print("ShareExtensionView aparece en pantalla")
            
            // Extraer la información del extensionContext en el hilo principal
            guard let extensionContext = extensionContext else { return }
            
            // Extraer los datos necesarios del extensionContext
            let inputItems = extensionContext.inputItems
            
            // Pasar los datos extraídos a la función asíncrona
            Task {
                isLoading = true // Actualiza isLoading antes de la carga
                await viewModel.loadURL(inputItems)
                isLoading = false // Actualiza isLoading después de la carga
            }
            viewModel.loadCategories()
        }
    }
}
