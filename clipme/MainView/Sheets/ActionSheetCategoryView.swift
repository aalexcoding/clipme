//
//  ActionSheetCategoryView.swift
//  clipme
//
//  Created by AlexDelgado on 13/3/25.
//

import SwiftUI
import SharedResources
import UIKit
import UniformTypeIdentifiers

struct ActionSheetCategoryView: View {
    @ObservedObject var viewModel: MainViewViewModel
    @Binding var showSheetCategory: Bool
    @Binding var selectedObjetctCategory: CategorySettingsItem?

    @State private var reorderedCategories: [CategorySettingsItem] = []
    @State var showCategorySelection: Bool = false
    @State var showCategoryTitleSelection: Bool = false // Nuevo estado para mostrar la selección de categoría
    @State var showElementsOrderSelection: Bool = false // Nuevo estado para mostrar la selección de categoría
    @State var showExportOption: Bool = false // Nuevo estado para mostrar la selección de categoría
    @State var showImportOption: Bool = false // Nuevo estado para mostrar la selección de categoría
    
    @State private var exportFileURL: URL? = nil
    @State private var showImportAlert: Bool = false
    @State private var importSuccess: Bool = false

    let onDismiss: () -> Void
    
    @StateObject private var lockManager = AppLockManager(autoLockSeconds: 60)


    var body: some View {
        VStack {
            HStack {

                Spacer()
                
//                if let item = selectedObjetctCategory {
                    Text(viewModel.selectedCategory)
                        .font(.headline)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading) // Aligns text to the left
                    //Spacer()

//                }

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.secondary)
                        .font(.title2)
                }
                .padding(.trailing)
            }
            .padding(.vertical)

            Divider()

            VStack(spacing: 12) {
                
                if viewModel.selectedCategory == String(localized: "horizontal_scroll_all") {
                    
                    Button(action: {
                        print("Exportar base de datos")
                        if let url = SharedFileManager.shared.exportDatabaseZip() {
                            self.exportFileURL = url
                            self.showExportOption = true
                        } else {
                            self.exportFileURL = nil
                            self.showExportOption = false
                        }
                    }) {
                        HStack {
                            Image(systemName: "textformat")
                            Text(String(localized: "Exportar"))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color.secondary)
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                }
                
                if viewModel.selectedCategory == String(localized: "horizontal_scroll_all") {
                    
                    Button(action: {
                        print("Importar base de datos")
                        showImportOption=true
                        //onDismiss()
                    }) {
                        HStack {
                            Image(systemName: "textformat")
                            Text(String(localized: "Importar"))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color.secondary)
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                }
                
                
                
                if viewModel.selectedCategory != String(localized: "horizontal_scroll_all") && viewModel.selectedCategory != String(localized: "horizontal_scroll_fav") {
                    
                    Button(action: {
                        print("Cambiar titulo categeoria")
                        showCategoryTitleSelection=true
                        //onDismiss()
                    }) {
                        HStack {
                            Image(systemName: "textformat")
                            Text(String(localized: "edit_title"))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color.secondary)
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                }
                
                    

                
                Button(action: {
                    reorderedCategories = viewModel.fetchedCategories.sorted { $0.order < $1.order }
                    showCategorySelection = true
                }) {
                    HStack {
                        Image(systemName: "list.bullet")
                        Text(String(localized: "scroll_options_reorder_cat"))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color.secondary)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                }

                
                Button(action: {
                    print(String(localized: "scroll_options_reorder_elem"))
                    showElementsOrderSelection=true
                    //onDismiss()
                }) {
                    HStack {
                        Image(systemName: "arrow.up.arrow.down")
                        Text(String(localized: "scroll_options_reorder_elem"))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color.secondary)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                }
                
                
                if viewModel.selectedCategory != String(localized: "horizontal_scroll_all") && viewModel.selectedCategory != String(localized: "horizontal_scroll_fav") {
                    if let category = viewModel.selectedObjectCategory {
                        let isHidden = category.isHidden
                        let lockIcon = isHidden ? "lock" : "lock.open"
                        let lockText = isHidden ? String(localized: "unblock") : String(localized: "block")
                        let backgroundColor = Color.red.opacity(UIScreen.main.traitCollection.userInterfaceStyle == .dark ? 0.4 : 0.2)

                        Button(role: .destructive, action: {
                            if lockManager.isUnlocked {
                                viewModel.toggleCategoryHidden(category)
                            }else{
                                
                                Task {
                                    let success = await lockManager.authenticate()
                                    if success {
                                        // ✅ Do something right after unlocking
                                        print("🔓 Authenticated! Now loading secure content...")
                                        viewModel.toggleCategoryHidden(category)
                                    }
                                }
                                                  }
                            // onDismiss() // descomenta si lo necesitas
                        }) {
                            HStack {
                                Image(systemName: lockIcon)
                                Text(lockText)
                                Spacer()
                            }
                            .padding()
                            .background(backgroundColor)
                            .cornerRadius(8)
                        }
                    }
                }
                
                if viewModel.selectedCategory != String(localized: "horizontal_scroll_all") && viewModel.selectedCategory != String(localized: "horizontal_scroll_fav") {
                    Button(role: .destructive, action: {
                        guard let category = viewModel.selectedObjectCategory else { return }
                        viewModel.removeCategory(category)
                        onDismiss()
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text(String(localized: "scroll_options_delete"))
                            Spacer()
                        }
                        .padding()
                        .background(Color.red.opacity(UIScreen.main.traitCollection.userInterfaceStyle == .dark ? 0.4 : 0.2))
                        .cornerRadius(8)
                    }
                }
            }
            .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 5)
        .sheet(isPresented: $showCategorySelection) {
            CategorySelectionOrderView(viewModel: viewModel, isPresented: $showCategorySelection, reorderedCategories: $reorderedCategories)
        }
        .sheet(isPresented: $showCategoryTitleSelection) {
            CategoryTitleView(viewModel: viewModel, isPresented: $showCategoryTitleSelection, selectedCategory: $selectedObjetctCategory)
        }
        .sheet(isPresented: $showElementsOrderSelection) {
            ItemOrderSelectorView(viewModel: viewModel, isPresented: $showElementsOrderSelection)
        }
        .sheet(isPresented: $showExportOption) {
            if let url = exportFileURL {
                ActivityView(activityItems: [url])
            } else {
                Text("No hay backup disponible")
                    .padding()
            }
        }
        .sheet(isPresented: $showImportOption) {
            DocumentPicker(supportedTypes: [UTType.zip]) { pickedURL in
                if let url = pickedURL {
                    let success = SharedFileManager.shared.importDatabaseZip(from: url)
                    self.importSuccess = success
                    self.showImportAlert = true
                }
                // Cerrar el sheet del picker
                self.showImportOption = false
            }	
        }
        .alert(importSuccess ? "Importación completada" : "Error de importación", isPresented: $showImportAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(importSuccess ? "Se importaron los datos correctamente." : "No se pudo importar el backup.")
        }
    }

}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        controller.excludedActivityTypes = [.assignToContact, .addToReadingList, .markupAsPDF]
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No-op
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    let supportedTypes: [UTType]
    let onPick: (URL?) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
        controller.allowsMultipleSelection = false
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // No-op
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (URL?) -> Void
        init(onPick: @escaping (URL?) -> Void) {
            self.onPick = onPick
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            onPick(urls.first)
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            onPick(nil)
        }
    }
}
