//
//  ActionSheetCategoryView.swift
//  clipme
//
//  Created by AlexDelgado on 13/3/25.
//

import SwiftUI
import SharedResources

struct ActionSheetCategoryView: View {
    @ObservedObject var viewModel: MainViewViewModel
    @Binding var showSheetCategory: Bool
    @State private var reorderedCategories: [CategorySettingsItem] = []
    @State var showCategorySelection: Bool = false

    let onDismiss: () -> Void

    var body: some View {
        VStack {
            HStack {

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.secondary)
                        .font(.title2)
                }
                .padding(.trailing)
            }
            .padding(.vertical)

            Divider()

            VStack(spacing: 12) {
                
                Button(action: {
                    reorderedCategories = viewModel.fetchedCategories.sorted { $0.order < $1.order }
                    showCategorySelection = true
                }) {
                    HStack {
                        Image(systemName: "list.bullet")
                        Text("Reordenar Categorías")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color.secondary)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                }
                
                Button(action: {
                    print("Opción 1")
                    onDismiss()
                }) {
                    HStack {
                        Image(systemName: "gear")
                        Text("Opción 1")
                        Spacer()
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                }
                
                if viewModel.selectedCategory != "Todas" && viewModel.selectedCategory != "Favorites" {
                    Button(role: .destructive, action: {
                        viewModel.removeCategory(viewModel.selectedCategory)
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
            }
            .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 5)
        .sheet(isPresented: $showCategorySelection) {
            CategorySelectionOrderView(viewModel: viewModel, isPresented: $showCategorySelection, reorderedCategories: $reorderedCategories)
        }
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
                    HStack {
                        Text(category.name)
                            .foregroundColor(Color.primary)
                        Spacer()
                        Image(systemName: "line.horizontal.3")
                            .foregroundColor(Color.secondary)
                    }
                    //.padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                }
                .onMove(perform: moveCategory)
               // .listRowBackground(Color.clear)
            }
            .listRowSeparator(.hidden)

            //.environment(\.editMode, .constant(.active))
            .navigationTitle("Reordena las Categorías")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        isPresented = false
                    }
                }
            }
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
