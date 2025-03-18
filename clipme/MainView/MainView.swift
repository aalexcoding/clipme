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
    @State private var selectedObjetctCategory: CategorySettingsItem? = nil
    @State private var scrollProxy: ScrollViewProxy?


    var body: some View {
        NavigationView {
            List {
                categoryScrollView
                    .listRowSeparator(.hidden)
                
                currentView
                    .listRowSeparator(.hidden)
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
                            viewModel.selectedCategory = newCategory
                            Task {
                                await scrollToEnd()
                            }
                        }
                    }
                }
            )
            .animation(.easeInOut(duration: 0.2), value: isAddCategoryPresented)
            .navigationBarItems(trailing: navigationButton)
            .sheet(isPresented: $showSheetCategory) {
                ActionSheetCategoryView(viewModel: viewModel, showSheetCategory: $showSheetCategory, selectedObjetctCategory: $selectedObjetctCategory) {
                    showSheetCategory = false
                }
            }
        }
    }
    
    private var categoryScrollView: some View {
        ScrollViewReader { scrollProxy in
            GeometryReader { geometry in
                ZStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
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
                                .onChange(of: proxy.frame(in: .global).minX) { _, _ in
                                    updateChevronVisibility(proxy: proxy)
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
    
    private func updateChevronVisibility(proxy: GeometryProxy) {
        let offset = proxy.frame(in: .global).minX
        let contentWidth = proxy.size.width
        let scrollViewWidth = UIScreen.main.bounds.width

        // Show left chevron if the content is scrolled to the right
        viewModel.showLeftChevron = offset < 0

        // Show right chevron if there is more content to the right
        viewModel.showRightChevron = contentWidth + offset > scrollViewWidth
    }


    private var currentView: some View {
        Group {
            switch viewType {
            case .grid:
                GridView(viewModel: viewModel)
            case .list:
                ListView(viewModel: viewModel)
            case .landscape:
                LandscapeView(viewModel: viewModel)
            }
        }
    }

    private var navigationButton: some View {
        Button(action: {
            let allTypes = ViewType.allCases
            guard let currentIndex = allTypes.firstIndex(of: viewType) else { return }
            let nextIndex = (currentIndex + 1) % allTypes.count
            viewType = allTypes[nextIndex]
            
            UserDefaults.standard.setValue(viewType.rawValue, forKey: "preferredViewType")
        }) {
            Image(systemName: viewType == .grid ? "square.grid.2x2" : viewType == .list ? "list.bullet" : "rectangle.split.2x1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .padding(10)
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
