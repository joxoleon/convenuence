import SwiftUI

struct SeparatorView: View {
    var body: some View {
        Rectangle()
            .fill(Color.cardBackground)
            .frame(height: 1)
            .padding(.horizontal)
    }
}
