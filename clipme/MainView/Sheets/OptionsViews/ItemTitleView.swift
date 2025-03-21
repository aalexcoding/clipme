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
                Section(header: Text("Editar título")) {
                    TextField("Nuevo título", text: $newTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onAppear {
                            newTitle = selectedItem?.title ?? ""
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
