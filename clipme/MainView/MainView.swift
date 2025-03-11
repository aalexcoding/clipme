//
//  SharedURLsViewModel.swift
//  reelKeeper
//
//  Created by AlexDelgado on 6/3/25.
//

import SwiftUI
import SharedResources

struct MainView: View {
    @ObservedObject var viewModel: MainViewViewModel
    @State private var isAddCategoryPresented: Bool = false
    @State private var viewType: ViewType = .list // Estado para controlar el tipo de vista

    
    enum ViewType: CaseIterable {
        case grid
        case list
        case landscape
    }

    var body: some View {
        NavigationView {
            List {
                // Fila del scroll horizontal de categorías
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            Button(action: {
                                viewModel.selectedCategory = category
                            }) {
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
//                .listRowInsets(EdgeInsets())
                
                // Fila para cada item (similares a chats)
                switch viewType {
                    case .grid:
                        GridView(viewModel: viewModel)
                        .listRowSeparator(.hidden)
                    case .list:
                        ListView(viewModel: viewModel)
                        .listRowSeparator(.hidden)
                    case .landscape:
                        LandscapeView(viewModel: viewModel)
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
//                        .transition(.move(edge: .leading).combined(with: .opacity))
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
                    
                   //.background(Color.blue.opacity(0.2))
                    //.clipShape(Circle())
            }
            //.padding(.trailing)
            )
        }
    }
}


// Vista de cuadrícula
struct GridView: View {
    @ObservedObject var viewModel: MainViewViewModel

    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                ForEach(viewModel.filteredItems(), id: \.id) { item in
                    Button(action: {
                        viewModel.openURL(item.url.absoluteString)
                    }) {
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
            }
            .padding()
        }
    }
}

struct ListView: View {
    @ObservedObject var viewModel: MainViewViewModel

    let columns = [GridItem(.flexible())] // Single column grid

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(viewModel.filteredItems(), id: \.id) { item in
                    Button(action: {
                        viewModel.openURL(item.url.absoluteString)
                    }) {
                        HStack(spacing: 8) {
                            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
//                                Image(uiImage: uiImage)
//                                    .resizable()
//                                    .scaledToFill()
//                                    .frame(width: 80, height: 80)
//                                    .clipShape(RoundedRectangle(cornerRadius: 10))
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
                               // .background(Color.gray.opacity(0.2))
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
                        //.padding(.vertical, 8)
                        .padding(.horizontal)
                        .background(Color(UIColor.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 2)
                    }
                }
            }
            //.padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Full screen usage
    }
}

// Vista de landscape
struct LandscapeView: View {
    @ObservedObject var viewModel: MainViewViewModel

    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 50), count: 2), spacing: 50) {
                ForEach(viewModel.filteredItems(), id: \.id) { item in
                    Button(action: {
                        viewModel.openURL(item.url.absoluteString)
                    }) {
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
                                //.background(Color.gray.opacity(0.2))
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
    }
}
