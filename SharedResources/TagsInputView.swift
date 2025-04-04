//
//  TagsInputView.swift
//  clipme
//
//  Created by AlexDelgado on 8/3/25.
//


import SwiftUI

public struct TagsInputView: View {
    @Binding public var tags: [String]
    @State private var newTag: String = ""

    public init(tags: Binding<[String]>) {
        self._tags = tags
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Text("Tags")
                .font(.headline)
            HStack {
                TextField(String(localized: "add_tag"), text: $newTag)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: .infinity)

                Button(action: {
                    if !newTag.isEmpty {
                        tags.append(newTag.trimmingCharacters(in: .whitespacesAndNewlines))
                        newTag = ""
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                            .overlay(
                                Button(action: {
                                    tags.removeAll { $0 == tag }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                }
                                .offset(x: 10, y: -10),
                                alignment: .topTrailing
                            )
                    }
                }
            }
        }
        .padding()
    }
}
