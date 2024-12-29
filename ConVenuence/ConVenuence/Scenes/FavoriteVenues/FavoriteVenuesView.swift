import SwiftUI

struct FavoriteVenuesView: View {
    var body: some View {
        VStack {
            Text("Favorites Screen")
                .font(.largeTitle)
                .padding()
            NavigationLink("Go to Details", destination: Text("Favorite Details Screen"))
        }
        .navigationTitle("Favorites")
    }
}
