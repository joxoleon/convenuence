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
        NavigationView {
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
                .zIndex(1) // Ensure it stays above the list

                if viewModel.isLoading {
                    ProgressView()
                        .padding(.top)
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    ScrollView {
                        VenueListView(venues: viewModel.venues, currentLocation: viewModel.currentLocation)
                    }
                    .padding(.top, 8)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Search Venues")
                        .font(.headline)
                        .foregroundColor(.accentBlue)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Ensure proper layout for single-column view
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
