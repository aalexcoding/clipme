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
                Image("background")
                    .resizable(resizingMode: .tile)
                    .ignoresSafeArea()
                    .opacity(0.08)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 10) {
                        categoryScrollView
                            .padding(.bottom, 30)
                            //.frame(height: 30)
                            
                            Spacer()
                        

                        let isVisible = {
                            if let category = viewModel.selectedObjectCategory {
                                return !category.isHidden
                            }
                            return false
                        }()

                        if lockManager.isUnlocked || isVisible || viewModel.selectedCategory == String(localized: "horizontal_scroll_all") || viewModel.selectedCategory == String(localized: "horizontal_scroll_fav") {
                            currentView
                                //.padding(.top, 10)
                        } else {
                            VStack(spacing: 8) {
                                Button(String(localized: "auth_with \(lockManager.biometricType.rawValue)")) {
                                    Task {
                                        _ = await lockManager.authenticate()
                                    }
                                }

                                if let error = lockManager.errorMessage {
                                    Text(error)
                                        .foregroundColor(.red)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.clear)
                }

            }
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
                ActionSheetCategoryView(
                    viewModel: viewModel,
                    showSheetCategory: $showSheetCategory,
                    selectedObjetctCategory: $selectedObjetctCategory
                ) {
                    showSheetCategory = false
                }
            }
            .onOpenURL { url in
                print("🔗 App abierta con URL: \(url)")
                manejarURL(url)
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
                        .id("lastItem")
                    }
                    ChevronIndicators(viewModel: viewModel)
                        .ignoresSafeArea()
                }
                .frame(height: 40)

            }
            .task {
                await storeScrollProxy(scrollProxy)
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
        .background(Color.clear)
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
                    .padding(.horizontal, 12)
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
        
        try? await Task.sleep(nanoseconds: 200_000_000)
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
