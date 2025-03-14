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
    @State private var viewType: ViewType = .grid // Estado para controlar el tipo de vista
    @State private var showSheetCategory: Bool = false // Corregido de @ObservedObject a @State

    var body: some View {
        NavigationView {
            List {
                // Fila del scroll horizontal de categorías
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            DualActionButton(
                                actionOnTap: {
                                    viewModel.selectedCategory = category
                                },
                                actionOnLongPress: {
                                    viewModel.selectedCategory = category
                                    showSheetCategory = true
                                }
                            ) {
                                Text(category)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(viewModel.selectedCategory == category ? Color.blue : Color.clear, lineWidth: 2)
                                    )
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
                
                // Fila para cada item (similares a chats)
                switch viewType {
                case .grid:
                    GridView(viewModel: viewModel)
                        .listRowSeparator(.hidden)
                case .list:
                    ListView(viewModel: viewModel)
                        .listRowSeparator(.hidden)
                case .landscape:
                    LandscapeView(viewModel: viewModel)
                        .listRowSeparator(.hidden)
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
                    }
                }
            )
            .animation(.easeInOut(duration: 0.2), value: isAddCategoryPresented)
            .navigationBarItems(trailing: Button(action: {
                // Rotar entre los tipos de vista
                let allTypes = ViewType.allCases
                guard let currentIndex = allTypes.firstIndex(of: viewType) else { return }
                let nextIndex = (currentIndex + 1) % allTypes.count
                viewType = allTypes[nextIndex]
            }) {
                Image(systemName: viewType == .grid ? "square.grid.2x2" : viewType == .list ? "list.bullet" : "rectangle.split.2x1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24) // Tamaño uniforme para todos los iconos
                    .padding(10)
            })
            .sheet(isPresented: $showSheetCategory) {
                ActionSheetCategoryView(viewModel: viewModel, showSheetCategory: $showSheetCategory) {
                    showSheetCategory = false
                }
            }
        }
    }
}
