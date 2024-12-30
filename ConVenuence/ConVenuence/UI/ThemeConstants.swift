import SwiftUI

struct ThemeConstants {
    static let venueCellBackground = LinearGradient(
        gradient: Gradient(colors: [Color.accentBlue.opacity(0.2), Color.accentPurple.opacity(0.2)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
