import SwiftUI

struct SearchVenuesView: View {
    var body: some View {
        VStack {
            Text("Search Venues Screen")
                .font(.largeTitle)
                .padding()
            NavigationLink("Go to Details", destination: Text("Search Details Screen"))
        }
        .navigationTitle("Search")
    }
}
