//
//  AddCategoryPopupView.swift
//  clipme
//
//  Created by AlexDelgado on 8/3/25.
//


import SwiftUI

struct AddCategoryPopupView: View {
    @Binding var isPresented: Bool
    @State private var categoryName: String = ""
    var onAddCategory: (String) -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4) // Fondo semitransparente
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isPresented = false
                }

            VStack(spacing: 20) {
                Text("Nueva Categoría")
                    .font(.headline)

                TextField("Nombre de la categoría", text: $categoryName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                HStack {
                    Button("Cancelar") {
                        isPresented = false
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)

                    Button("Aceptar") {
                        if !categoryName.isEmpty {
                            onAddCategory(categoryName)
                            isPresented = false
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            .padding()
            .frame(width: 300)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 10)
        }
        .transition(.opacity)
        .animation(.easeInOut, value: isPresented)
    }
}