//
//  CategorySelectionView.swift
//  clipme
//
//  Created by AlexDelgado on 21/3/25.
//

import SwiftUI
import SharedResources

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
                        //let newCategoryID = viewModel.fetchedCategories.filter { $0.name == category }
                        viewModel.changeItemCategory(of: item, to: category.idString)
                    }
                }) {
                    HStack {
                        Text(category.name)
                        Spacer()
                        if viewModel.getCategory(of: selectedItem) == category.idString {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color.primary)
                        }
                    }
                    //.padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                }
              //  .listRowBackground(Color.clear)
            }
            .navigationTitle("Seleccionar Categoría")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        isPresented = false
                    }
                }
            }
        }
        .listRowSeparator(.hidden)

    }
}
