//
//  GridView.swift
//  clipme
//
//  Created by AlexDelgado on 13/3/25.
//

import SwiftUI
import SharedResources

struct GridView: View {
    @ObservedObject var viewModel: MainViewViewModel
    @State private var selectedItem: SharedURLItem? // Controla qué elemento tiene el menú abierto
    @State private var showSheet: Bool = false // Corregido de @ObservedObject a @State

    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                ForEach(viewModel.filteredItems(), id: \.id) { item in
                    VStack {
                        DualActionButton(
                            actionOnTap: {
                                viewModel.openURL(item.url.absoluteString)
                            },
                            actionOnLongPress: {
                                print("A eliminar \(item.id.uuidString)")
                                selectedItem = item
                                showSheet = true
                            }
                        ) {
                            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.clear)
                                    .frame(width: 80, height: 80)
                            }
                        }
                    }
                    .background(Color.clear)

                   // .padding(.top, 4)
                }
            }
            .background(Color.clear)

            //.padding()
        }
        .background(Color.clear)

        .sheet(isPresented: $showSheet) {
            ActionSheetItemView(viewModel: viewModel, selectedItem: $selectedItem) {
                showSheet = false
            }
        }
    }
}
