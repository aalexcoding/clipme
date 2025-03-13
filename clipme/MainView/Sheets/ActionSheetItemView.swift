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
    @Binding var showSheet: Bool
    @State private var showCategorySelection: Bool = false // Nuevo estado para mostrar la selección de categoría
    @State private var showItemTitleSelection: Bool = false // Nuevo estado para mostrar la selección de categoría
    @State private var isFavorite: Bool = false // Nuevo estado para manejar favoritos

    let onDismiss: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    if let item = selectedItem {
                        isFavorite.toggle()
                        //item.isFavorite.toggle()
                        viewModel.toggleFavoriteStatus(of: item) // Método en el ViewModel
                    }
                }) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundColor(isFavorite ? .yellow : .gray)
                        .font(.title)
                }
                .padding()
                
                Spacer()
            }
            
            Button("Cambiar Categoría") {
                showCategorySelection = true
            }
            Button("Cambiar title") {
                showItemTitleSelection = true
            }
            
            Button("Eliminar", role: .destructive) {
                if let item = selectedItem {
                    print("Eliminar \(item.id.uuidString)")
                    viewModel.removeElement(item)
                }
                onDismiss()
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .onAppear {
            if let item = selectedItem {
                isFavorite = item.isFavorite
            }
        }
        .sheet(isPresented: $showCategorySelection) {
            CategorySelectionView(viewModel: viewModel, selectedItem: $selectedItem, isPresented: $showCategorySelection)
        }
        .sheet(isPresented: $showItemTitleSelection) {
            ItemTitleView(viewModel: viewModel, selectedItem: $selectedItem, isPresented: $showCategorySelection)
        }
    }
}

/** Selector de categoria para el item **/
struct CategorySelectionView: View {
    @ObservedObject var viewModel: MainViewViewModel
    @Binding var selectedItem: SharedURLItem?
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            List(viewModel.categoriesWithOutTodasFavorites, id: \.self) { category in
                Button(action: {
                    if let item = selectedItem {
                        viewModel.changeItemCategory(of: item, to: category) // Método en el ViewModel
                    }
                    //isPresented = false
                }) {
                    HStack {
                        Text(category)
                        Spacer()
                        if viewModel.getCategory(of: selectedItem) == category {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            .navigationTitle("Seleccionar Categoría")
            .navigationBarItems(trailing: Button("Cerrar") {
                isPresented = false
            })
        }
    }
}

struct ItemTitleView: View {
    @ObservedObject var viewModel: MainViewViewModel
    @Binding var selectedItem: SharedURLItem?
    @Binding var isPresented: Bool
    @State private var newTitle: String = ""

    var body: some View {
        NavigationView {
            VStack {
                // TextField to edit the title
                TextField("Nuevo título", text: $newTitle, onCommit: {
                    if let item = selectedItem {
                        viewModel.changeItemTitle(of: item, to: newTitle) // Update title in ViewModel
                    }
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onAppear {
                    newTitle = selectedItem?.title ?? ""
                }
            }
            .navigationTitle("Editar Item")
            .navigationBarItems(trailing: Button("Cerrar") {
                isPresented = false
            })
        }
    }
}
