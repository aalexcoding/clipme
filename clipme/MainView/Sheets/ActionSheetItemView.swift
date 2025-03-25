//
//  ActionSheetView.swift
//  clipme
//
//  Created by AlexDelgado on 13/3/25.
//

import SwiftUI
import SharedResources

struct ActionSheetItemView: View {
    @ObservedObject var viewModel: MainViewViewModel
    @Binding var selectedItem: SharedURLItem?
    @State private var showCategorySelection: Bool = false // Nuevo estado para mostrar la selección de categoría
    @State private var showItemTitleSelection: Bool = false // Nuevo estado para mostrar la selección de categoría
    @State private var showElementsOrderSelection: Bool = false // Nuevo estado para mostrar la selección de categoría
    @State private var isFavorite: Bool = false // Nuevo estado para manejar favoritos

    let onDismiss: () -> Void
    
    var urlForSharinng: URL? {
        guard let item = selectedItem else { return nil }
        return viewModel.generateURLForSiengleElementOriginalLink(para: [item])
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    if let item = selectedItem {
                        isFavorite.toggle()
                        viewModel.toggleFavoriteStatus(of: item)
                    }
                }) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundColor(Color.primary)
                        .font(.title2)
                }
                .padding(.leading)

                Spacer()
                
                if let item = selectedItem, let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                    GeometryReader { geometry in
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width * 1, height: geometry.size.width * 1) // Ensure a reasonable height
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .frame(maxWidth: .infinity, alignment: .center) // Center the image
                        
                    }
                    .frame(minHeight: 50) // Prevents the GeometryReader from collapsing
                    .frame(maxWidth: 50)
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 50, height: 50)
                }
                if let item = selectedItem {
                    Text(item.title.isEmpty ? item.url.absoluteString : item.title)
                        .font(.headline)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading) // Aligns text to the left
                }

                Spacer()

                

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.secondary)
                        .font(.title2)
                }
                .padding(.trailing)
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity, maxHeight: 80) // Full screen usage

            Divider()

            VStack(spacing: 12) {
                
                Button(action: {
                    showItemTitleSelection = true
                }) {
                    HStack {
                        Image(systemName: "textformat")
                        Text("Editar Título")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color.secondary)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                }
                
                Button(action: {
                    showCategorySelection = true
                }) {
                    HStack {
                        Image(systemName: "folder")
                        Text("Cambiar Categoría")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color.secondary)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                }
                
                Button(action: {
                    print("Ordenar elementos")
                    showElementsOrderSelection=true
                    //onDismiss()
                }) {
                    HStack {
                        Image(systemName: "arrow.up.arrow.down")
                        Text("Ordenar elementos")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color.secondary)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                }
                
                if let url = urlForSharinng {
                    ShareLink(item: url) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Compartir elemento")
                            Spacer()
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                }

                Button(role: .destructive, action: {
                    if let item = selectedItem {
                        viewModel.removeElement(item)
                    }
                    onDismiss()
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Eliminar")
                        Spacer()
                    }
                    .padding()
                    .background(Color.red.opacity(UIScreen.main.traitCollection.userInterfaceStyle == .dark ? 0.4 : 0.2))
                    .cornerRadius(8)
                }
            }
            .padding()

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 5)
        .onAppear {
            if let item = selectedItem {
                isFavorite = item.isFavorite
            }
        }
        .sheet(isPresented: $showCategorySelection) {
            CategorySelectionView(viewModel: viewModel, selectedItem: $selectedItem, isPresented: $showCategorySelection)
        }
        .sheet(isPresented: $showItemTitleSelection) {
            ItemTitleView(viewModel: viewModel, selectedItem: $selectedItem, isPresented: $showItemTitleSelection)
        }
        .sheet(isPresented: $showElementsOrderSelection) {
            ItemOrderSelectorView(viewModel: viewModel, isPresented: $showElementsOrderSelection)
        }
    }
}




