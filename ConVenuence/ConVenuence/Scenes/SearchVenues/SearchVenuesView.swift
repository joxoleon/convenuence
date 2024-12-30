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
            .zIndex(1)

            ZStack(alignment: .top) {
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
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top) // Fix alignment to prevent movement
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top) // Ensure everything remains at the top
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
