//
//  ContentView.swift
//  reelKeeper
//
//  Created by AlexDelgado on 6/3/25.
//

import SwiftUI


struct MainView: View {
    @ObservedObject var viewModel: MainViewViewModel
//    @Environment(\.scenePhase) private var scenePhase

    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.sharedURLs) { item in
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
//            .onChange(of: scenePhase) {
//                if scenePhase == .active {
//                    viewModel.insertFromSharedFileManager()
//                }
//            }
            
            .navigationTitle("URLs Recibidos")
            // Permite refrescar la lista manualmente
            .refreshable {
                viewModel.fetchSharedURLs()
            }

            
        }

    }
    
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        // Para previsualización usamos un ViewModel de ejemplo
        MainView(viewModel: MainViewViewModel())
    }
}
