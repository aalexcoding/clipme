//
//  ListView.swift
//  clipme
//
//  Created by AlexDelgado on 13/3/25.
//

import SwiftUI
import SharedResources

struct ListView: View {
    @ObservedObject var viewModel: MainViewViewModel
    @State private var showSheet: Bool = false // Corregido de @ObservedObject a @State
    @State private var selectedItem: SharedURLItem? // Controla qué elemento tiene el menú abierto


    let columns = [GridItem(.flexible())] // Single column grid
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
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
                        HStack(spacing: 8) {
                            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                                GeometryReader { geometry in
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: geometry.size.width * 1, height: geometry.size.width * 1) // Ensure a reasonable height
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .frame(maxWidth: .infinity, alignment: .center) // Center the image
                                    
                                }
                                .frame(minHeight: 80) // Prevents the GeometryReader from collapsing
                                .frame(maxWidth: 80)
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 50, height: 50)
                            }
                            Text(item.title.isEmpty ? item.url.absoluteString : item.title)
                                .font(.headline)
                                .lineLimit(2)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading) // Aligns text to the left
                            
                            Spacer()
                        }
                        //.padding(.horizontal)
                        .background(Color(UIColor.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 2)
                    }
                }
            }
            .background(Color.clear)
            .scrollContentBackground(.hidden)
        }
        .background(Color.clear)
        .scrollContentBackground(.hidden) 
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Full screen usage
        .sheet(isPresented: $showSheet) {
            ActionSheetItemView(viewModel: viewModel, selectedItem: $selectedItem) {
                showSheet = false
            }
        }
    }
}
