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
    @State private var showSheetCategory: Bool = false // Corregido de @ObservedObject a @State
    @State private var selectedObjetctCategory: CategorySettingsItem? = nil
    @State private var scrollProxy: ScrollViewProxy?
    @State private var elementosRecibido: [SharedURLItem]?

    @State private var lastScrollCheck: Date = .now

    
    @StateObject private var lockManager = AppLockManager(autoLockSeconds: 10)

    
    var body: some View {
        NavigationView {
            
            ZStack {
                Image("background") // replace with your asset name
                    .resizable(resizingMode: .tile)
                    .ignoresSafeArea()
                    .opacity(0.08) // optional: make it subtle
                List {
                    categoryScrollView
                        .listRowSeparator(.hidden)
                    
                    let isVisible = {
                        if let category = viewModel.selectedObjectCategory {
                            return !category.isHidden
                        }
                        return false
                    }()
                    
                    if lockManager.isUnlocked || isVisible == true || viewModel.selectedCategory == "Todas" || viewModel.selectedCategory == "Favorites" {
                        currentView
                            .listRowSeparator(.hidden)
                            .padding(.top, 10)
                            .background(Color.clear)

                      } else {
                          Button("Autenticarse con \(lockManager.biometricType.rawValue)") {
                              Task {
                                  _ = await lockManager.authenticate()
                              }
                          }
                          .listRowSeparator(.hidden)


                          if let error = lockManager.errorMessage {
                              Text(error)
                                  .foregroundColor(.red)
                                  .multilineTextAlignment(.center)
                                  .padding(.horizontal)
                          }
                      }

                }
               // .listStyle(PlainListStyle())
               // .background(Color.clear)

                .scrollContentBackground(.hidden)
                .navigationTitle("ClipMe")
                .navigationBarTitleDisplayMode(.inline)
                .searchable(text: $viewModel.searchQuery)
                .overlay(
                    Group {
                        if isAddCategoryPresented {
                            AddCategoryPopupView(isPresented: $isAddCategoryPresented) { newCategory in
                                viewModel.addNewCategory(newCategory)
                                viewModel.selectedCategory = newCategory
                                Task {
                                    await scrollToEnd()
                                }
                            }
                        }
                    }
                )
                .animation(.easeInOut(duration: 0.2), value: isAddCategoryPresented)
                .navigationBarItems(trailing: navigationElementViewSwitcher)
                .sheet(isPresented: $showSheetCategory) {
                    ActionSheetCategoryView(viewModel: viewModel, showSheetCategory: $showSheetCategory, selectedObjetctCategory: $selectedObjetctCategory) {
                        showSheetCategory = false
                    }
                }
                .onOpenURL { url in
                    print("🔗 App abierta con URL: \(url)")
                    manejarURL(url)
                }
            }
            }
            
    }
    

    func manejarURL(_ url: URL) {
        guard url.scheme == "clipmeapp",
              url.host == "elementos",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let urlString = components.queryItems?.first(where: { $0.name == "data" })?.value,
              let decoded = urlString.removingPercentEncoding else {
            return
        }

        let urlStrings = decoded.components(separatedBy: ",")
        let urls = urlStrings.compactMap { URL(string: $0) }

        print("✅ URLs recibidas:")
        urls.forEach { print($0.absoluteString) }

        // Si querés reconstruir SharedURLItem solo con las URLs:
        //let sharedItems = urls.map { SharedURLItem(id: UUID(), nombre: "Desconocido", url: $0) }
        // Hacé lo que necesites con los items reconstruidos
    }
    
    private var categoryScrollView: some View {
        
        
        ScrollViewReader { scrollProxy in
            GeometryReader { geometry in
                ZStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 0) {
                            categoryButtons
                            Button(action: {
                                isAddCategoryPresented = true
                            }) {
                                Image(systemName: "plus")
                                    .padding(10)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                            }
                        }
                        .background(GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    updateChevronVisibility(proxy: proxy)
                                }

                                .onChange(of: proxy.frame(in: .global).minX) { newValue, _ in
                                    let now = Date()
                                    lastScrollCheck = now
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        if now == lastScrollCheck {
                                            updateChevronVisibility(proxy: proxy)
                                        }
                                    }
                                }
                        })
                        .id("lastItem") // Assign an ID to the last item

                    }
                    ChevronIndicators(viewModel: viewModel)
                        .ignoresSafeArea()
                }
            }
            .task {
                await storeScrollProxy(scrollProxy) // Store proxy properly
            }
        }
    }
    
    private var currentView: some View {
        Group {
            switch viewModel.viewType {
            case .grid:
                GridView(viewModel: viewModel)
            case .list:
                ListView(viewModel: viewModel)
            case .landscape:
                LandscapeView(viewModel: viewModel)
            }
        }
    }
    

    
    private var categoryButtons: some View {
        ForEach(viewModel.categories, id: \.self) { category in
            DualActionButton(
                actionOnTap: {
                    viewModel.selectedCategory = category
                },
                actionOnLongPress: {
                    viewModel.selectedCategory = category
                    selectedObjetctCategory = viewModel.selectedObjectCategory
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
    }
    
    private var navigationElementViewSwitcher: some View {
        Button(action: {
            let allTypes = ViewType.allCases
            guard let currentIndex = allTypes.firstIndex(of: viewModel.viewType) else { return }
            let nextIndex = (currentIndex + 1) % allTypes.count
            viewModel.viewType = allTypes[nextIndex]
            
            viewModel.storeElementView()
            
        }) {
            Image(systemName: viewModel.viewType == .grid ? "square.grid.2x2" : viewModel.viewType == .list ? "list.bullet" : "rectangle.split.2x1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .padding(10)
        }
    }
    
    private func updateChevronVisibility(proxy: GeometryProxy) {
        let offset = proxy.frame(in: .global).minX
        let contentWidth = proxy.size.width
        let scrollViewWidth = UIScreen.main.bounds.width
        viewModel.showLeftChevron = offset < 0
        viewModel.showRightChevron = contentWidth + offset > scrollViewWidth
    }
    
    @MainActor
    private func storeScrollProxy(_ proxy: ScrollViewProxy) async {
        self.scrollProxy = proxy
    }
    
    @MainActor
    private func scrollToEnd() async {
        guard let scrollProxy = scrollProxy else { return }
        
        try? await Task.sleep(nanoseconds: 200_000_000) // Delay to ensure SwiftUI loads
        withAnimation {
            scrollProxy.scrollTo("lastItem", anchor: .trailing)
        }
    }
}



struct ChevronIndicators: View {
    @ObservedObject var viewModel: MainViewViewModel
    
    var body: some View {
        HStack {
            if viewModel.showLeftChevron {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
                    .opacity(0.7)
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .transition(.opacity)
            }
            Spacer()
            if viewModel.showRightChevron {
                Image(systemName: "chevron.right")
                    .foregroundColor(.blue)
                    .opacity(0.7)
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .transition(.opacity)
            }
        }
    }
}
