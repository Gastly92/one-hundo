import Base
import SwiftUI

extension View {
  /// Fixes the moment these views treat as
  /// now (`\.now`), for snapshot tests. Set
  /// here, in the app: the test bundle links
  /// its own copy of Base, and its `\.now`
  /// is a key the app's views never read.
  func fixedNow(_ date: Date) -> some View {
    environment(\.now, date)
  }
}
