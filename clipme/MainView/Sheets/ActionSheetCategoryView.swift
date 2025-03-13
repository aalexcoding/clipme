//
//  ActionSheetCategoryView.swift
//  clipme
//
//  Created by AlexDelgado on 13/3/25.
//

import SwiftUI
import SharedResources

struct ActionSheetCategoryView: View {
    @ObservedObject var viewModel: MainViewViewModel // Usamos @Bindable en lugar de @ObservedObject
    @Binding var showSheetCategory: Bool
    @State private var reorderedCategories: [CategorySettingsItem] = []
    @State var showCategorySelection: Bool = false // Nuevo estado para mostrar la selección de categoría

    let onDismiss: () -> Void

    var body: some View {
        VStack {
            Button("Reordenar Categorías") {
                reorderedCategories = viewModel.fetchedCategories.sorted { $0.order < $1.order }
                showCategorySelection = true
            }

            Button("Opción 1") {
                print("Opción 1")
                onDismiss()
            }

            Button("Eliminar", role: .destructive) {
                viewModel.removeCategory(viewModel.selectedCategory)
                onDismiss()
            }
        }
        .sheet(isPresented: $showCategorySelection) {
            CategorySelectionOrderView(viewModel: viewModel, isPresented: $showCategorySelection, reorderedCategories: $reorderedCategories)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }

}

struct CategorySelectionOrderView: View {
    @ObservedObject var viewModel: MainViewViewModel
    @Binding var isPresented: Bool
    @Binding var reorderedCategories: [CategorySettingsItem]

    var body: some View {
        NavigationView {
            List {
                ForEach(reorderedCategories, id: \.self) { category in
                    Text(category.name) // Assuming CategorySettingsItem has a `name` property
                        .padding()
                }
                .onMove(perform: moveCategory) // Move categories correctly
            }
            .navigationTitle("Reordena las Categorías")
            .navigationBarItems(
                leading: EditButton(), // Enables moving functionality
                trailing: Button("Cerrar") {
                    isPresented = false
                }
            )
        }
    }

    private func moveCategory(from source: IndexSet, to destination: Int) {
        reorderedCategories.move(fromOffsets: source, toOffset: destination)
        saveNewOrder()
    }

    private func saveNewOrder() {
        for (index, category) in reorderedCategories.enumerated() {
            category.order = index
        }
        viewModel.reorderCategories(newOrder: reorderedCategories.map { $0.name })
    }
}
