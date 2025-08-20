import SwiftUI

struct RecipeDetailView: View {
    @StateObject private var store = DataStore.shared
    let recipe: Recipe
    @State private var showAddedAlert: Bool = false
    
    var body: some View {
        List {
            if !recipe.notes.isEmpty {
                Section(header: Text("recipe_notes")) {
                    Text(recipe.notes)
                }
            }
            Section(header: Text("recipe_ingredients")) {
                ForEach(recipe.ingredients) { ing in
                    HStack {
                        Text(ing.name)
                        Spacer()
                        Text(ing.quantity).foregroundColor(.secondary)
                    }
                }
            }
            Section(header: Text("recipe_actions")) {
                Button {
                    // Экспорт в закупки
                    var copy = store.groceries
                    for ing in recipe.ingredients {
                        if !copy.contains(ing) {
                            copy.append(Ingredient(name: ing.name, quantity: ing.quantity))
                        }
                    }
                    store.groceries = copy
                    store.saveAll()
                    showAddedAlert = true
                } label: {
                    Label("recipe_to_groceries", systemImage: "cart.badge.plus")
                }
            }
        }
        .navigationTitle(recipe.title)
        .alert(Text(LocalizedStringKey("common_success")), isPresented: $showAddedAlert) {
            Button(LocalizedStringKey("common_ok"), role: .cancel) { }
        } message: {
            Text(LocalizedStringKey("recipe_added_success_message"))
        }
    }
}
