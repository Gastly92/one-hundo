import SwiftData
import SwiftUI
import UIKit

@main
struct OneHundoApp: App {
  private let launch: AppLaunch

  init() {
    let info = ProcessInfo.processInfo
    launch = AppLaunch(
      arguments: info.arguments
    )
    if launch.isUITesting {
      // No UIKit animations (screen pushes,
      // sheets, menus): a long-press that
      // lands while a screen is still
      // sliding in turns into a tap.
      UIView.setAnimationsEnabled(false)
    }
  }

  var body: some Scene {
    WindowGroup {
      content
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
