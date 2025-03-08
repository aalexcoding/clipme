//
//  ContentView.swift
//  reelKeeper
//
//  Created by AlexDelgado on 6/3/25.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewViewModel
    @State private var selectedCategory: String = "Todas"
    @State private var isAddCategoryPresented: Bool = false

    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    // Barra de búsqueda
                    SearchBar(text: $viewModel.searchQuery)
                        .padding(.horizontal)

                    // Scroll de Categorías
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.categories, id: \.self) { category in
                                Button(category) {
                                    viewModel.selectedCategory = category
                                }
                                .padding()
                                .background(viewModel.selectedCategory == category ? Color.blue.opacity(0.2) : Color.clear)
                                .cornerRadius(8)
                            }
                            
                            Button(action: {
                                isAddCategoryPresented = true
                            }) {
                                Image(systemName: "plus")
                                    .padding()
                                    .background(Color.blue.opacity(0.2))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(.horizontal)

                List {
                    ForEach(viewModel.filteredItems(), id: \.id) { item in
                        Button {
                            viewModel.openURL(item.url.absoluteString)
                        } label: {
                            HStack {
                                if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 40, height: 40)
                                        .cornerRadius(5)
                                        .clipped()
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title.isEmpty ? item.url.absoluteString : item.title)
                                        .font(.body)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                    Text(item.date, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .animation(.default, value: viewModel.filteredItems()) // Para actualizar visualmente la lista con animación
                    .navigationTitle("URLs por Categoría")
                    .refreshable {
                        viewModel.fetchSharedURLs()
                    }
                }
            }
            
            if isAddCategoryPresented {
                AddCategoryPopupView(isPresented: $isAddCategoryPresented) { newCategory in
                    viewModel.addNewCategory(newCategory)
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: MainViewViewModel())
    }
}
