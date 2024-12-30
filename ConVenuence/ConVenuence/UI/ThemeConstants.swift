import SwiftUI

struct ThemeConstants {
    static let venueCellBackground = LinearGradient(
        gradient: Gradient(colors: [Color.accentBlue.opacity(0.3), Color.accentPurple.opacity(0.3)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
