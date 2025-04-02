//
//  LandscapeView.swift
//  clipme
//
//  Created by AlexDelgado on 13/3/25.
//

import SwiftUI
import SharedResources

struct LandscapeView: View {
    @ObservedObject var viewModel: MainViewViewModel
    @State private var showSheet: Bool = false // Corregido de @ObservedObject a @State
    @State private var selectedItem: SharedURLItem? // Controla qué elemento tiene el menú abierto

    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 50), count: 2), spacing: 50) {
                ForEach(viewModel.filteredItems(), id: \.id) { item in
                    DualActionButton(
                        actionOnTap: {
                            viewModel.openURL(item.url.absoluteString)
                        },
                        actionOnLongPress: {
                            selectedItem = item
                            showSheet = true
                        }
                    ) {
                        VStack {
                            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                                GeometryReader { geometry in
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: geometry.size.width * 0.9, height: max(geometry.size.height * 0.5, 200)) // Ensure a reasonable height
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .frame(maxWidth: .infinity, alignment: .center) // Center the image
                                    
                                }
                                .frame(minHeight: 200) // Prevents the GeometryReader from collapsing
                                .frame(maxWidth: 150)
                            } else {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 120)
                            }
                            Text(item.title.isEmpty ? item.url.absoluteString : item.title)
                                .font(.headline)
                                .lineLimit(2)
                                .padding(.top, 4)
                                .foregroundColor(.primary)
                            
                        }
                    }
                }
            }
            .background(Color.clear)
            .scrollContentBackground(.hidden)
            .padding()
        }
        .background(Color.clear)
        .scrollContentBackground(.hidden) 
        .sheet(isPresented: $showSheet) {
            ActionSheetItemView(viewModel: viewModel, selectedItem: $selectedItem) {
                showSheet = false
            }
        }
    }
}
