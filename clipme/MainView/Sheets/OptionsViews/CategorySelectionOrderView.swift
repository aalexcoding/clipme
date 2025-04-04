//
//  CategorySelectionOrderView.swift
//  clipme
//
//  Created by AlexDelgado on 21/3/25.
//
import SwiftUI
import SharedResources

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
            .navigationTitle(String(localized: "scroll_options_reorder_cat"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "_close")) {
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
