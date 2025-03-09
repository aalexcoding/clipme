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
            // Fondo semitransparente
            if isPresented {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        isPresented = false
                    }
            }

            // Popup centrado
            if isPresented {
                VStack(spacing: 15) {
                    Text("Nueva Categoría")
                        .font(.headline)
                        .foregroundColor(.primary)

                    TextField("Nombre de la categoría", text: $categoryName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    HStack {
                        Button("Cancelar") {
                            isPresented = false
                        }
                        .padding()
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(8)

                        Button("Aceptar") {
                            if !categoryName.isEmpty {
                                onAddCategory(categoryName)
                                isPresented = false
                            }
                        }
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
                .padding()
                .frame(width: UIScreen.main.bounds.width * 0.85)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .shadow(radius: 10)
                .transition(.scale.combined(with: .opacity)) // Animación de escala y opacidad
                .zIndex(1) // Asegura que el popup esté encima del fondo
            }
        }
        .animation(.easeInOut, value: isPresented)
    }
}
