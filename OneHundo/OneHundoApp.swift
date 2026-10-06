import SwiftData
import SwiftUI

@main
struct OneHundoApp: App {
  private let launch: AppLaunch

  init() {
    let info = ProcessInfo.processInfo
    launch = AppLaunch(
      arguments: info.arguments
    )
  }

  var body: some Scene {
    WindowGroup {
      content.preferredColorScheme(
        launch.isDark ? .dark : nil
      )
    }
  }

  @ViewBuilder
  private var content: some View {
    switch launch.store {
    case .success(let container):
      Group {
        if let screen = launch.screen {
          ScreenHost(screen: screen)
        } else {
          RootView()
        }
      }
      .modelContainer(container)
    case .failure(let error):
      StoreErrorView(
        details: error.localizedDescription
      )
    }
  }
}
