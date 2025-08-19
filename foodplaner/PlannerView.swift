import SwiftUI

struct PlannerView: View {
    @StateObject private var store = DataStore.shared
    @State private var selectedDate: Date = Date()
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("planner_selected_day")) {
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                }
                
                Section(header: Text("planner_attached_recipes")) {
                    let day = dayFor(date: selectedDate)
                    if day.recipeIDs.isEmpty {
                        Text("planner_no_recipes")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(day.recipeIDs, id: \.self) { id in
                            if let recipe = store.recipes.first(where: { $0.id == id }) {
                                Text(recipe.title)
                            }
                        }
                        .onDelete { idx in
                            var d = day
                            idx.map { d.recipeIDs.remove(at: $0) }
                            upsertDay(d)
                            store.recalcDaysPlannedFromPlanner()
                        }
                    }
                }
            }
            .navigationTitle(Text("tab_planner"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("PlannerAdd")
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                RecipePickerSheet(
                    allRecipes: store.recipes,
                    onPick: { recipe in
                        var d = dayFor(date: selectedDate)
                        if !d.recipeIDs.contains(recipe.id) {
                            d.recipeIDs.append(recipe.id)
                        }
                        upsertDay(d)
                        store.recalcDaysPlannedFromPlanner()
                    })
            }
        }
    }
    
    private func dayFor(date: Date) -> PlannerDay {
        if let existing = store.planner.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            return existing
        }
        let new = PlannerDay(date: date, recipeIDs: [])
        store.planner.append(new)
        store.saveAll()
        return new
    }
    
    private func upsertDay(_ day: PlannerDay) {
        if let idx = store.planner.firstIndex(where: { $0.id == day.id }) {
            store.planner[idx] = day
        }
        store.saveAll()
    }
}

struct RecipePickerSheet: View {
    let allRecipes: [Recipe]
    let onPick: (Recipe) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List(allRecipes) { recipe in
                Button {
                    onPick(recipe)
                    dismiss()
                } label: {
                    HStack {
                        Text(recipe.title)
                        if recipe.isFavorite { Image(systemName: "star.fill") }
                    }
                }
            }
            .navigationTitle(Text("planner_add_recipe"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common_close") { dismiss() }
                }
            }
        }
    }
}
