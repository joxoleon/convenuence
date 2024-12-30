import SwiftUI
import CVCore

// MARK: - SearchVenuesView
struct SearchVenuesView: View {
    @StateObject private var viewModel: SearchVenuesViewModel

    init(viewModel: SearchVenuesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            VStack {
                TextField("Search venues", text: $viewModel.searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                if viewModel.isLoading {
                    ProgressView()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage).foregroundColor(.red)
                } else {
                    VenueListView(venues: viewModel.venues)
                }
            }
            .navigationTitle("Search Venues")
        }
    }
}
