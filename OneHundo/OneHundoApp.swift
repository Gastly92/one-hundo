import SwiftData
import SwiftUI

@main
struct OneHundoApp: App {
    private let launch: AppLaunch

    init() {
        launch = AppLaunch(arguments: ProcessInfo.processInfo.arguments)
    }

    var body: some Scene {
        WindowGroup {
            switch launch.store {
            case .success(let container):
                RootView()
                    .modelContainer(container)
            case .failure(let error):
                StoreErrorView(details: error.localizedDescription)
            }
        }
    }
}
