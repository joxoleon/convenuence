import SwiftUI
import CoreLocation
import Combine
import CVCore

// MARK: - SearchVenuesView
struct SearchVenuesView: View {
    @StateObject private var viewModel: SearchVenuesViewModel

    init(viewModel: SearchVenuesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.accentBlue)
                TextField("Search venues", text: $viewModel.searchQuery)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray6)))
            .padding([.horizontal, .top])
            .frame(maxWidth: .infinity) // Ensure it spans the entire width

            ZStack {
                if viewModel.isLoading {
                    CenteredProgressView()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    VenueListView(
                        venues: viewModel.venues,
                        currentLocation: viewModel.currentLocation,
                        favoriteRepositoryDelegate: viewModel
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Fill available space
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top) // Prevent content shifting
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top) // Keep everything pinned to the top
    }
}

// MARK: - Custom Progress View
struct CenteredProgressView: View {
    var body: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.5) // Make it slightly larger
                .tint(.accentBlue) // Set color to accentBlue
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure centering
    }
}

// MARK: - Preview
struct SearchVenuesView_Previews: PreviewProvider {
    static var previews: some View {
        SearchVenuesView(
            viewModel: SearchVenuesViewModel(
                venueRepositoryService: ServiceLocator.shared.venueRepositoryService,
                userLocationService: ServiceLocator.shared.userLocationService
            )
        )
    }
}
