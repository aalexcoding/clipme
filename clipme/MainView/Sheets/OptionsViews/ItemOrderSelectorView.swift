//
//  ElementOrderSelectorView.swift
//  clipme
//
//  Created by AlexDelgado on 20/3/25.
//

import SwiftUI

struct ItemOrderSelectorView: View {
    @ObservedObject var viewModel: MainViewViewModel
    //@Binding var selectedItem: SharedURLItem?
    @Binding var isPresented: Bool
    //@Binding var selectedOrder: ElementOrderBy
    @State private var newOrder: ElementOrderBy = ElementOrderBy(rawValue: UserDefaults.standard.string(forKey: "preferredElementOrder") ?? "dateLatestFirst") ?? .dateLatestFirst

    
    var body: some View {
        NavigationView {
            List {
                // Sorting Options
                Section(header: Text(String(localized: "order_by"))) {
                    ForEach(ElementOrderBy.allCases, id: \.self) { order in
                        Button(action: {
                            newOrder = order
                            viewModel.orderSharedURLs(by: newOrder)
                        }) {
                            HStack {
                                Text(order.localizedName).tag(order)
                                Spacer()
                                if newOrder == order {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                }

            }
            .navigationTitle(String(localized: "scroll_options_reorder_elem"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "_close")) {
                        isPresented = false
                    }
                }
            }
        }
    }
}


