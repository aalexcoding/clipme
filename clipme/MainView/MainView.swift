//
//  ContentView.swift
//  reelKeeper
//
//  Created by AlexDelgado on 6/3/25.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewViewModel
    @State private var searchQuery: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Barra de búsqueda
                SearchBar(text: $searchQuery)
                    .padding(.horizontal)

                List {
                    // Agrupar elementos por categoría
                    ForEach(viewModel.groupedItems(for: searchQuery), id: \.key) { category, items in
                        Section(header: Text(category).font(.headline)) {
                            ForEach(items) { item in
                                Button {
                                    viewModel.openURL(item.url.absoluteString)
                                } label: {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.url.absoluteString)
                                            .font(.body)
                                            .lineLimit(1)
                                            .truncationMode(.middle)
                                        Text(item.date, style: .date)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("URLs Recibidos")
                .refreshable {
                    viewModel.fetchSharedURLs()
                }
            }
        }
    }
}

// Vista para la barra de búsqueda
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Buscar por categoría, tag o título...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: MainViewViewModel())
    }
}
