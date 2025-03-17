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
    @State private var viewType: ViewType = ViewType(rawValue: UserDefaults.standard.string(forKey: "preferredViewType") ?? "grid") ?? .landscape
    @State private var showSheetCategory: Bool = false // Corregido de @ObservedObject a @State
    
    
    private func updateChevronVisibility(proxy: GeometryProxy) {
        let offset = proxy.frame(in: .global).minX
        let contentWidth = proxy.size.width
        let scrollViewWidth = UIScreen.main.bounds.width

        // Show left chevron if the content is scrolled to the right
        viewModel.showLeftChevron = offset < 0

        // Show right chevron if there is more content to the right
        viewModel.showRightChevron = contentWidth + offset > scrollViewWidth
    }
    
    struct BlurView: UIViewRepresentable {
        var style: UIBlurEffect.Style

        func makeUIView(context: Context) -> UIVisualEffectView {
            let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
            return view
        }

        func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
    }

    var body: some View {
        NavigationView {
            List {
                // Fila del scroll horizontal de categorías
                ScrollViewReader { scrollProxy in
                    GeometryReader { geometry in
                        ZStack {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 0) {
                                    ForEach(viewModel.categories, id: \.self) { category in
                                        DualActionButton(
                                            actionOnTap: {
                                                viewModel.selectedCategory = category
                                            },
                                            actionOnLongPress: {
                                                viewModel.selectedCategory = category
                                                showSheetCategory = true
                                            }
                                        ) {
                                            Text(category)
                                                .padding(.vertical, 8)
                                                .padding(.horizontal, 16)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .stroke(viewModel.selectedCategory == category ? Color.blue : Color.clear, lineWidth: 2)
                                                )
                                                .cornerRadius(20)
                                        }
                                    }

                                    // Botón para agregar categoría
                                    Button(action: {
                                        isAddCategoryPresented = true
                                    }) {
                                        Image(systemName: "plus")
                                            .padding(10)
                                            .background(
                                                BlurView(style: .systemThinMaterial) // Aplica un desenfoque moderno
                                                    .clipShape(Circle())
                                            )
                                            .clipShape(Circle())
                                    }
                                }
                                //.padding(.horizontal)
                                //.padding(.vertical, 0)
                                .background(GeometryReader { proxy in
                                    Color.clear
                                        .onAppear {
                                            updateChevronVisibility(proxy: proxy)
                                        }
                                        .onChange(of: proxy.frame(in: .global).minX) { _, _ in
                                            updateChevronVisibility(proxy: proxy)
                                        }
                                })
                            }

                            // Indicadores dinámicos
                            HStack {
                                if viewModel.showLeftChevron {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(.blue) // Set the icon color to blue
                                        .opacity(0.7)
                                        .padding(10)
                                        .background(
                                            BlurView(style: .systemThinMaterial) // Aplica un desenfoque moderno
                                                .clipShape(Circle())
                                        )
                                        .clipShape(Circle())
                                        .transition(.opacity)
                                    
                                }
                                Spacer()
                                if viewModel.showRightChevron {
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.blue) // Set the icon color to blue
                                        .opacity(0.7)
                                        .padding(10)
                                        .background(
                                            BlurView(style: .systemThinMaterial) // Aplica un desenfoque moderno
                                                .clipShape(Circle())
                                        )
                                        .clipShape(Circle())
                                        .transition(.opacity)
                                }
                            }
                            .ignoresSafeArea()
                        }
                    }
                    //.padding(.horizontal)
                    //.padding(.vertical, 0)
                }
                .listRowSeparator(.hidden)
                
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
                
                UserDefaults.standard.setValue(viewType.rawValue, forKey: "preferredViewType")

            }) {
                Image(systemName: viewType == .grid ? "square.grid.2x2" : viewType == .list ? "list.bullet" : "rectangle.split.2x1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24) // Tamaño uniforme para todos los iconos
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
