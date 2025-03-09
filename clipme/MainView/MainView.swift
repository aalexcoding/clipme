//
//  SharedURLsViewModel.swift
//  reelKeeper
//
//  Created by AlexDelgado on 6/3/25.
//

import SwiftUI
import SharedResources

struct MainView: View {
    @ObservedObject var viewModel: MainViewViewModel
    @State private var isAddCategoryPresented: Bool = false

    var body: some View {
        NavigationView {
            List {
                // Fila del scroll horizontal de categorías
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            Button(action: {
                                viewModel.selectedCategory = category
                            }) {
                                Text(category)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(viewModel.selectedCategory == category ? Color.blue.opacity(0.2) : Color.clear)
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
//                .listRowInsets(EdgeInsets())
                
                // Fila para cada item (similares a chats)
                ForEach(viewModel.filteredItems(), id: \.id) { item in
                    Button(action: {
                        viewModel.openURL(item.url.absoluteString)
                    }) {
                        HStack(spacing: 12) {
                            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 50, height: 50)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title.isEmpty ? item.url.absoluteString : item.title)
                                    .font(.headline)
                                  //  .lineLimit(1)
                                Text(item.date, style: .date)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("ClipMe")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchQuery)
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
        }
    }
}
