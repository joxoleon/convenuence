import SwiftUI
import CoreLocation
import Combine
import CVCore

struct SearchVenuesView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel: SearchVenuesViewModel

    // MARK: - Initializers
    
    init(viewModel: SearchVenuesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.accentBlue)
                TextField("Search venues", text: $viewModel.searchQuery)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.cardBackground))
            .padding([.horizontal, .top])

            ZStack {
                if viewModel.isLoading {
                    CenteredProgressView()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .multilineTextAlignment(.center)
                } else {
                    VenueListView(
                        venues: viewModel.venues,
                        currentLocation: viewModel.currentLocation,
                        favoriteRepositoryDelegate: viewModel
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .background(Color.primaryBackground)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
