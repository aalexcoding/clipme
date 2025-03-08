import SwiftUI
import SwiftData
import SharedResources

@main
struct reelKeeperApp: App {

    @StateObject var viewModel: MainViewViewModel
    @Environment(\.scenePhase) private var scenePhase

    
    init() {
        _viewModel = StateObject(wrappedValue: MainViewViewModel())
    }

    var body: some Scene {
        WindowGroup {
            MainView(viewModel: viewModel)
                .onAppear {
                    if let items = SharedDefaultsManager.shared.retrieveURLItems() {
                        SharedFileManager.shared.saveURL(items)
                       // insertURLItems(items, into: container.mainContext)
                        SharedDefaultsManager.shared.clearURLInfo()
                    }
                    viewModel.fetchSharedURLs()
                }
                .onChange(of: scenePhase) {
                    // Usamos la versión sin parámetros y leemos el valor del entorno
                    if scenePhase == .active {
                        if let items = SharedDefaultsManager.shared.retrieveURLItems() {
                            SharedFileManager.shared.saveURL(items)
                            SharedDefaultsManager.shared.clearURLInfo()
                            viewModel.fetchSharedURLs()
                        }
                    }
                }
        }
    }

}
