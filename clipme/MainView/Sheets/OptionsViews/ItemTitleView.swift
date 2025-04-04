//
//  ItemTitleView.swift
//  clipme
//
//  Created by AlexDelgado on 20/3/25.
//

import SwiftUI
import SharedResources

struct ItemTitleView: View {
    @ObservedObject var viewModel: MainViewViewModel
    @Binding var selectedItem: SharedURLItem?
    @Binding var isPresented: Bool
    @State private var newTitle: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(String(localized: "edit_element"))) {
                    TextField(String(localized: "new_tittle"), text: $newTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onAppear {
                            newTitle = selectedItem?.title ?? ""
                        }
                }
            }
            .navigationTitle(String(localized: "edit_element"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "_cancel")) {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "_save")) {
                        if let item = selectedItem {
                            viewModel.changeItemTitle(of: item, to: newTitle)
                        }
                        isPresented = false
                    }
                    .bold()
                }
            }
        }
    }
}

