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
    @Binding var selectedObjetctCategory: CategorySettingsItem?

    @State private var reorderedCategories: [CategorySettingsItem] = []
    @State var showCategorySelection: Bool = false
    @State var showCategoryTitleSelection: Bool = false // Nuevo estado para mostrar la selección de categoría
    @State var showElementsOrderSelection: Bool = false // Nuevo estado para mostrar la selección de categoría

    
    let onDismiss: () -> Void
    
    @StateObject private var lockManager = AppLockManager(autoLockSeconds: 60)


    var body: some View {
        VStack {
            HStack {

                Spacer()
                
//                if let item = selectedObjetctCategory {
                    Text(viewModel.selectedCategory)
                        .font(.headline)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading) // Aligns text to the left
                    //Spacer()

//                }

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
                
                if viewModel.selectedCategory != "Todas" && viewModel.selectedCategory != "Favorites" {
                    
                    Button(action: {
                        print("Cambiar titulo categeoria")
                        showCategoryTitleSelection=true
                        //onDismiss()
                    }) {
                        HStack {
                            Image(systemName: "textformat")
                            Text("Editar Título")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color.secondary)
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                }
                
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
                    print("Ordenar elementos")
                    showElementsOrderSelection=true
                    //onDismiss()
                }) {
                    HStack {
                        Image(systemName: "arrow.up.arrow.down")
                        Text("Ordenar elementos")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color.secondary)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                }
                
                if viewModel.selectedCategory != "Todas" && viewModel.selectedCategory != "Favorites" {
                    if let category = viewModel.selectedObjectCategory {
                        let isHidden = category.isHidden
                        let lockIcon = isHidden ? "lock" : "lock.open"
                        let lockText = isHidden ? "Desbloquear" : "Bloquear"
                        let backgroundColor = Color.red.opacity(UIScreen.main.traitCollection.userInterfaceStyle == .dark ? 0.4 : 0.2)

                        Button(role: .destructive, action: {
                            if lockManager.isUnlocked {
                                viewModel.toggleCategoryHidden(category)
                            }else{
                                
                                Task {
                                    let success = await lockManager.authenticate()
                                    if success {
                                        // ✅ Do something right after unlocking
                                        print("🔓 Authenticated! Now loading secure content...")
                                        viewModel.toggleCategoryHidden(category)
                                    }
                                }
                                                  }
                            // onDismiss() // descomenta si lo necesitas
                        }) {
                            HStack {
                                Image(systemName: lockIcon)
                                Text(lockText)
                                Spacer()
                            }
                            .padding()
                            .background(backgroundColor)
                            .cornerRadius(8)
                        }
                    }
                }
                
                if viewModel.selectedCategory != "Todas" && viewModel.selectedCategory != "Favorites" {
                    Button(role: .destructive, action: {
                        guard let category = viewModel.selectedObjectCategory else { return }
                        viewModel.removeCategory(category)
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
        .sheet(isPresented: $showCategoryTitleSelection) {
            CategoryTitleView(viewModel: viewModel, isPresented: $showCategoryTitleSelection, selectedCategory: $selectedObjetctCategory)
        }
        .sheet(isPresented: $showElementsOrderSelection) {
            ItemOrderSelectorView(viewModel: viewModel, isPresented: $showElementsOrderSelection)
        }
    }

}







