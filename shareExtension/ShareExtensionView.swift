//
//  ShareExtensionView.swift
//  reelKeeper
//
//  Created by AlexDelgado on 6/3/25.
//

import SwiftUI
import SharedResources


struct ShareExtensionView: View {
    var extensionContext: NSExtensionContext?
    
    @ObservedObject var viewModel = ShareExtensionViewModel(apiKey: "AIzaSyAERVpetNGIkIMz36W7_scy8OzU8y2Kch0")
    @State private var isAddCategoryPresented: Bool = false
    @State private var isLoading: Bool = true
    @State private var scrollProxy: ScrollViewProxy?

    private var contentHeight: CGFloat {
        500 // Adjust as needed to reflect approximate total height of content when not loading
    }
    
    var body: some View {
        ZStack {
            Image("background") // replace with your asset name
                .resizable(resizingMode: .tile)
                .ignoresSafeArea()
                .opacity(0.08) // optional: make it subtle
            
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 16) {
                        Spacer(minLength: max((geometry.size.height - contentHeight) / 2, 20))
                        
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            if let title = viewModel.title {
                                
                                if let imageData = viewModel.sharedMetadata?.image, let uiImage = UIImage(data: imageData) {
                                    HStack {
                                        Spacer()
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 200)
                                            .cornerRadius(10)
                                            .shadow(radius: 5)
                                            .padding()
                                        Spacer()
                                    }
                                } else if !viewModel.imageURL.isEmpty {
                                    AsyncImage(url: URL(string: viewModel.imageURL)) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                        case .success(let image):
                                            image.resizable()
                                                .scaledToFit()
                                                .frame(height: 200)
                                                .cornerRadius(10)
                                                .shadow(radius: 5)
                                        case .failure:
                                            Image(systemName: "photo")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 200)
                                                .foregroundColor(.gray)
                                        @unknown default:
                                            ProgressView()
                                        }
                                    }
                                    .padding()
                                }
                                
                                Text(title)
                                    .font(.body)
                                    .lineLimit(3)
                                    .truncationMode(.tail)
                                    .padding()
                                
                                categoryScrollView
                                
                                Button(String(localized: "_save")) {
                                    viewModel.saveSharedURL()
                                    extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 20)
                            } else if let error = viewModel.errorMessage {
                                Text("Error:")
                                    .font(.headline)
                                
                                Text(error)
                                    .multilineTextAlignment(.center)
                                    .padding()
                            } else {
                                Text(String(localized: "loading"))
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: geometry.size.height)
                    .overlay(
                        Group {
                            if isAddCategoryPresented {
                                AddCategoryPopupView(isPresented: $isAddCategoryPresented) { newCategory in
                                    viewModel.addNewCategory(newCategory)
                                    viewModel.category = newCategory
                                    Task {
                                        await scrollToEnd()
                                    }
                                }
                            }
                        }
                    )
                    .animation(.easeInOut(duration: 0.2), value: isAddCategoryPresented)
                    .onAppear {
                        print("ShareExtensionView aparece en pantalla")
                        
                        guard let extensionContext = extensionContext else { return }
                        let inputItems = extensionContext.inputItems
                        
                        Task {
                            isLoading = true
                            await viewModel.loadURL(inputItems)
                            isLoading = false
                        }
                        viewModel.loadCategories()
                    }
                }
            }
        }

    }
    
    private var categoryScrollView: some View {
        ScrollViewReader { proxy in
            GeometryReader { geometry in
                ZStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            categoryButtons
                                .listRowSeparator(.hidden)

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
                await storeScrollProxy(proxy) // Store proxy properly
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
    
    private func scrollToCategory(_ category: String) {
        guard let scrollProxy = scrollProxy else { return }
        withAnimation {
            scrollProxy.scrollTo(category, anchor: .center)
        }
    }
    
    private var categoryButtons: some View {
        ForEach(viewModel.categories, id: \.self) { category in
            Button(action: {
                viewModel.category = category
            }) {
                Text(category)
                    .foregroundColor(viewModel.category == category ? .white : .white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(viewModel.category == category ? Color.blue : Color.clear, lineWidth: 2)
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
}

struct ChevronIndicators: View {
    @ObservedObject var viewModel: ShareExtensionViewModel
    
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
