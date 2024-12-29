import SwiftUI

struct MainTabView: View {
    init() {
        UITabBar.appearance().backgroundColor = UIColor(named: "PrimaryBackground")
        UITabBar.appearance().barTintColor = UIColor(named: "PrimaryBackground")
        UITabBar.appearance().unselectedItemTintColor = UIColor(named: "SecondaryText")
        UITabBar.appearance().tintColor = UIColor(named: "AccentBlue") // For selected items
    }

    var body: some View {
        TabView {
            NavigationView {
                SearchVenuesView()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }

            NavigationView {
                FavoriteVenuesView()
            }
            .tabItem {
                Label("Favorites", systemImage: "star")
            }
        }
        .background(Color.primaryBackground.ignoresSafeArea()) // Set background color for the TabView
        .accentColor(.accentBlue) // Set accent color for the TabView
    }
}
