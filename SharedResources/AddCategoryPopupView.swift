//
//  AddCategoryPopupView.swift
//  clipme
//
//  Created by AlexDelgado on 8/3/25.
//

import SwiftUI

public struct AddCategoryPopupView: View {
    @Binding public var isPresented: Bool
    @State public var categoryName: String = ""
    public var onAddCategory: (String) -> Void
    
    public init(isPresented: Binding<Bool>, onAddCategory: @escaping (String) -> Void) {
        self._isPresented = isPresented
        self.onAddCategory = onAddCategory
    }
    
    public var body: some View {
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
                        .onChange(of: categoryName) { _, newValue in
                            categoryName = String(newValue.prefix(18)) // Límite de 20 caracteres
                        }
                    
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
