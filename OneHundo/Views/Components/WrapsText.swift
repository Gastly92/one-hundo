import SwiftUI

extension View {
    /// Lets text grow to as many lines as it needs instead
    /// of truncating, e.g. at large text sizes.
    func wrapsText() -> some View {
        fixedSize(horizontal: false, vertical: true)
    }
}
