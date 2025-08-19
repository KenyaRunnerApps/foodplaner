import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            PlannerView()
                .tabItem {
                    Label("tab_planner", systemImage: "calendar")
                }
            
            RecipesView()
                .tabItem {
                    Label("tab_recipes", systemImage: "book")
                }
            
            GroceriesView()
                .tabItem {
                    Label("tab_groceries", systemImage: "cart")
                }
            
            StatsView()
                .tabItem {
                    Label("tab_stats", systemImage: "chart.bar")
                }
            
            SettingsView()
                .tabItem {
                    Label("tab_settings", systemImage: "gearshape")
                }
        }
    }
}
