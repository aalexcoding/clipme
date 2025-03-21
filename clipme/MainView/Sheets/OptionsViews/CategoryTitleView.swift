//
//  CategoryTitleView.swift
//  clipme
//
//  Created by AlexDelgado on 20/3/25.
//
import SwiftUI
import SharedResources

struct CategoryTitleView: View {
    @ObservedObject var viewModel: MainViewViewModel
    @Binding var isPresented: Bool
    @State private var newTitle: String = ""
    @Binding var selectedCategory: CategorySettingsItem?


    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Editar título")) {
                    TextField("Nuevo título", text: $newTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onAppear {
                            guard let selectedCategoryName = selectedCategory?.name else {
                                newTitle = ""
                                return
                            }
                            
                            newTitle = selectedCategoryName

                        }
                }
            }
            .navigationTitle("Editar Item")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        viewModel.changeCategoryName(viewModel.selectedCategory, newTitle)
                        isPresented = false
                    }
                    .bold()
                }
            }
        }
    }
}
