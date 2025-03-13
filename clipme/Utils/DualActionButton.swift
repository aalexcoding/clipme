//
//  DualActionButton.swift
//  clipme
//
//  Created by AlexDelgado on 13/3/25.
//

import SwiftUI

struct DualActionButton<Content: View>: View {
    var actionOnTap: () -> Void
    var actionOnLongPress: () -> Void
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        ZStack {
            content()
        }
        .contentShape(Rectangle()) // Asegura que todo el área sea táctil
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.4)
                .onEnded { _ in
                    print("Toque largo detectado")
                    actionOnLongPress()
                }
        )
        .highPriorityGesture(
            TapGesture()
                .onEnded {
                    print("Toque corto detectado")
                    actionOnTap()
                }
        )
    }
}
