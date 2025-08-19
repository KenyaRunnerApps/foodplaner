import SwiftUI

struct StatsView: View {
    @StateObject private var store = DataStore.shared
    
    var body: some View {
        let totalRecipes = store.recipes.count
        let favorites = store.recipes.filter { $0.isFavorite }.count
        let totalGroceries = store.groceries.count
        let checkedGroceries = store.groceries.filter { $0.isChecked }.count
        
        return NavigationView {
            List {
                Section(header: Text("stats_progress")) {
                    statRow("stats_prog_recipes_created", value: store.progress.recipesCreated)
                    statRow("stats_prog_groceries_checked", value: store.progress.groceriesChecked)
                    statRow("stats_prog_days_planned", value: store.progress.daysPlanned)
                }
                
                Section(header: Text("stats_achievements")) {
                    if store.achievements.isEmpty {
                        Text("stats_no_achievements")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(store.achievements) { ach in
                            HStack(spacing: 12) {
                                Image(systemName: ach.isUnlocked ? "rosette" : "lock")
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(LocalizedStringKey(ach.titleKey)).font(.headline)
                                    Text(LocalizedStringKey(ach.descriptionKey))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text("\(ach.progress)/\(ach.goal)")
                                    .font(.headline)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                Section(header: Text("stats_recipes")) {
                    statRow("stats_total_recipes", value: totalRecipes)
                    statRow("stats_favorites", value: favorites)
                }
                Section(header: Text("stats_groceries")) {
                    statRow("stats_total_items", value: totalGroceries)
                    statRow("stats_checked", value: checkedGroceries)
                }
                Section(header: Text("stats_planner")) {
                    statRow("stats_days_planned", value: store.progress.daysPlanned)
                }
            }
            .navigationTitle(Text("tab_stats"))
        }
    }
    
    @ViewBuilder
    private func statRow(_ key: LocalizedStringKey, value: Int) -> some View {
        HStack {
            Text(key)
            Spacer()
            Text("\(value)")
                .font(.headline)
        }
    }
}
