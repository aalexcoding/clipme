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
                Section(header: Text(String(localized: "scroll_options_edit_title"))) {
                    TextField(String(localized: "scroll_options_edit_title"), text: $newTitle)
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
            .navigationTitle(String(localized: "scroll_options_edit_title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "_cancel")) {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "_save")) {
                        guard let selectedCategory = selectedCategory else {
                            return
                        }
                        viewModel.changeCategoryName(selectedCategory, selectedCategory.name, newTitle)
                        isPresented = false
                    }
                    .bold()
                }
            }
        }
    }
}


 
