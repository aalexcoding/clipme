//
//  SharedURLsViewModel.swift
//  reelKeeper
//
//  Created by AlexDelgado on 6/3/25.
//

import SwiftUI
import SharedResources

struct MainView: View {
    
    enum ViewType: CaseIterable {
        case grid
        case list
        case landscape
    }
    
    @ObservedObject var viewModel: MainViewViewModel
    @State private var isAddCategoryPresented: Bool = false
    @State private var viewType: ViewType = .grid // Estado para controlar el tipo de vista
    @State private var showSheet: Bool = false // Corregido de @ObservedObject a @State
    @State private var showSheetCategory: Bool = false // Corregido de @ObservedObject a @State
    @State private var selectedItem: SharedURLItem? // Controla qué elemento tiene el menú abierto


    var body: some View {
        NavigationView {
            List {
                // Fila del scroll horizontal de categorías
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.categories, id: \.self) { category in
                        DualActionButton(
                            actionOnTap: {
                                viewModel.selectedCategory = category
                            },
                            actionOnLongPress: {
                                print("Categoría seleccionada con toque largo: \(category)")
                                viewModel.selectedCategory = category
                                showSheetCategory = true

                            }
                        ) {
                            Text(category)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(viewModel.selectedCategory == category ? Color.blue.opacity(0.2) : Color.clear)
                                .cornerRadius(20)
                        }
                        }
                        Button(action: {
                            isAddCategoryPresented = true
                        }) {
                            Image(systemName: "plus")
                                .padding(10)
                                .background(Color.blue.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 0)
                }
                .listRowSeparator(.hidden) // 🔥 Oculta las líneas arriba y abajo

                // Fila para cada item (similares a chats)
                switch viewType {
                    case .grid:
                    GridView(viewModel: viewModel, selectedItem: $selectedItem, showSheet: $showSheet)
                        .listRowSeparator(.hidden)
                    case .list:
                    ListView(viewModel: viewModel, selectedItem: $selectedItem, showSheet: $showSheet)
                        .listRowSeparator(.hidden)
                    case .landscape:
                        LandscapeView(viewModel: viewModel, showSheet: $showSheet, selectedItem: $selectedItem)
                        .listRowSeparator(.hidden)
                }
            }

            .listStyle(PlainListStyle())
            .navigationTitle("ClipMe")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchQuery)
            .overlay(
                Group {
                    if isAddCategoryPresented {
                        AddCategoryPopupView(isPresented: $isAddCategoryPresented) { newCategory in
                            viewModel.addNewCategory(newCategory)
                        }
                    }
                }
            )
            .animation(.easeInOut(duration: 0.2), value: isAddCategoryPresented)
            .navigationBarItems(trailing: Button(action: {
                // Rotar entre los tipos de vista
                let allTypes = ViewType.allCases
                guard let currentIndex = allTypes.firstIndex(of: viewType) else { return }
                let nextIndex = (currentIndex + 1) % allTypes.count
                viewType = allTypes[nextIndex]
            }) {
                Image(systemName: viewType == .grid ? "square.grid.2x2" : viewType == .list ? "list.bullet" : "rectangle.split.2x1")
                    .padding(10)
            })
            .sheet(isPresented: $showSheetCategory) {
                ActionSheetCategoryView(viewModel: viewModel, showSheetCategory: $showSheetCategory) {
                    showSheetCategory = false
                }
            }

        }
    }
}


struct GridView: View {
    @ObservedObject var viewModel: MainViewViewModel
    @Binding var selectedItem: SharedURLItem? // Controla qué elemento tiene el menú abierto
    @Binding var showSheet: Bool // Corregido de @ObservedObject a @State


    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                ForEach(viewModel.filteredItems(), id: \.id) { item in
                    VStack {
                        DualActionButton(
                            actionOnTap: {
                                viewModel.openURL(item.url.absoluteString)
                            },
                            actionOnLongPress: {
                                print("A eliminar \(item.id.uuidString)")
                                selectedItem = item
                                showSheet = true
                            }
                        ) {
                            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 80, height: 80)
                            }
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .padding()
        }
        .sheet(isPresented: $showSheet) {
            ActionSheetView(viewModel: viewModel, selectedItem: $selectedItem, showSheet: $showSheet) {
                showSheet = false
            }
        }
    }
}



struct ListView: View {
    @ObservedObject var viewModel: MainViewViewModel
    @Binding var selectedItem: SharedURLItem? // Controla qué elemento tiene el menú abierto
    @Binding var showSheet: Bool  // Corregido de @ObservedObject a @State

    let columns = [GridItem(.flexible())] // Single column grid

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(viewModel.filteredItems(), id: \.id) { item in
                    DualActionButton(
                        actionOnTap: {
                            viewModel.openURL(item.url.absoluteString)
                        },
                        actionOnLongPress: {
                            selectedItem = item
                            showSheet = true
                        }
                    ) {
                        HStack(spacing: 8) {
                            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                                GeometryReader { geometry in
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: geometry.size.width * 1, height: geometry.size.width * 1) // Ensure a reasonable height
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .frame(maxWidth: .infinity, alignment: .center) // Center the image

                                }
                                .frame(minHeight: 80) // Prevents the GeometryReader from collapsing
                                .frame(maxWidth: 80)
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 50, height: 50)
                            }
                            Text(item.title.isEmpty ? item.url.absoluteString : item.title)
                                .font(.headline)
                                .lineLimit(2)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading) // Aligns text to the left

                            Spacer()
                        }
                        .padding(.horizontal)
                        .background(Color(UIColor.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 2)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Full screen usage
        .sheet(isPresented: $showSheet) {
            ActionSheetView(viewModel: viewModel, selectedItem: $selectedItem, showSheet: $showSheet) {
                showSheet = false
            }
        }
    }
}

// Vista de landscape
struct LandscapeView: View {
    @ObservedObject var viewModel: MainViewViewModel
    @Binding var showSheet: Bool // Corregido de @ObservedObject a @State
    @Binding var selectedItem: SharedURLItem? // Controla qué elemento tiene el menú abierto


    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 50), count: 2), spacing: 50) {
                ForEach(viewModel.filteredItems(), id: \.id) { item in
                    DualActionButton(
                        actionOnTap: {
                            viewModel.openURL(item.url.absoluteString)
                        },
                        actionOnLongPress: {
                            selectedItem = item
                            showSheet = true
                        }
                    ) {
                        VStack {
                            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                                GeometryReader { geometry in
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: geometry.size.width * 0.9, height: max(geometry.size.height * 0.5, 200)) // Ensure a reasonable height
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .frame(maxWidth: .infinity, alignment: .center) // Center the image

                                }
                                .frame(minHeight: 200) // Prevents the GeometryReader from collapsing
                                .frame(maxWidth: 150)
                            } else {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 120)
                            }
                            Text(item.title.isEmpty ? item.url.absoluteString : item.title)
                                .font(.headline)
                                .lineLimit(2)
                                .padding(.top, 4)
                                .foregroundColor(.primary)

                        }
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $showSheet) {
            ActionSheetView(viewModel: viewModel, selectedItem: $selectedItem, showSheet: $showSheet) {
                showSheet = false
            }
        }
    }
}

// Nueva vista reutilizable para el sheet
struct ActionSheetView: View {
    @ObservedObject var viewModel: MainViewViewModel
    @Binding var selectedItem: SharedURLItem?
    @Binding var showSheet: Bool // Corregido de @ObservedObject a @State

    let onDismiss: () -> Void

    var body: some View {
        VStack {
//            Button("Opción 1") {
//                if let item = selectedItem {
//                   // viewModel.performAction1(for: item.id)
//                }
//                onDismiss()
//            }
//            Button("Opción 2") {
//                if let item = selectedItem {
//                   // viewModel.performAction2(for: item.id)
//                }
//                onDismiss()
//            }
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
    }
}

// Nueva vista reutilizable para el sheet
struct ActionSheetCategoryView: View {
    @ObservedObject var viewModel: MainViewViewModel
    @Binding var showSheetCategory: Bool // Corregido de @ObservedObject a @State

    let onDismiss: () -> Void

    var body: some View {
        VStack {
            Button("Opción 1") {
                print("Opcion 1")
                onDismiss()
            }
//            Button("Opción 2") {
//                if let item = selectedItem {
//                   // viewModel.performAction2(for: item.id)
//                }
//                onDismiss()
//            }
            Button("Eliminar", role: .destructive) {
                viewModel.removeCategory(viewModel.selectedCategory)
                onDismiss()
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

struct DualActionButton<Content: View>: View {
    var actionOnTap: () -> Void
    var actionOnLongPress: () -> Void
    @ViewBuilder var content: () -> Content // Usamos @ViewBuilder para permitir múltiples vistas

    var body: some View {
        ZStack {
            content()
        }
        .contentShape(Rectangle()) // Asegura que todo el área sea táctil
        .onTapGesture {
            print("Toque corto detectado")
            actionOnTap() // Acción para toque corto
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            print("Toque largo detectado")
            actionOnLongPress() // Acción para toque largo
        }
    }
}
