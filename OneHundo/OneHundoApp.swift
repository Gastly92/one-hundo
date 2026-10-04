import SwiftData
import SwiftUI

@main
struct OneHundoApp: App {
    let container: ModelContainer

    init() {
        let arguments = ProcessInfo.processInfo.arguments
        // UI tests launch with -uiTesting: an in-memory store, so every run starts clean.
        let isUITesting = arguments.contains("-uiTesting")
        container = AppStore.makeContainer(inMemory: isUITesting)
        if isUITesting && arguments.contains("-seedSampleData") {
            SampleData.insert(into: container.mainContext)
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}
