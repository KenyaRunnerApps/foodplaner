import SwiftUI

struct RecipesView: View {
    @StateObject private var store = DataStore.shared
    @State private var showingAdd = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.recipes) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(recipe.title).font(.headline)
                                if !recipe.notes.isEmpty {
                                    Text(recipe.notes).font(.subheadline).foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            Button {
                                toggleFavorite(recipe)
                            } label: {
                                Image(systemName: recipe.isFavorite ? "star.fill" : "star")
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle(Text("tab_recipes"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddRecipeSheet { newRecipe in
                    store.recipes.append(newRecipe)
                    store.trackRecipeCreated()
                }
            }
        }
    }
    
    private func toggleFavorite(_ recipe: Recipe) {
        guard let idx = store.recipes.firstIndex(of: recipe) else { return }
        store.recipes[idx].isFavorite.toggle()
        store.saveAll()
    }
    
    private func delete(at offsets: IndexSet) {
        store.recipes.remove(atOffsets: offsets)
        store.saveAll()
    }
}

struct AddRecipeSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var ingredientName: String = ""
    @State private var ingredientQty: String = ""
    @State private var ingredients: [Ingredient] = []
    let onSave: (Recipe) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("recipe_title")) {
                    TextField("recipe_title_ph", text: $title)
                }
                Section(header: Text("recipe_notes")) {
                    TextField("recipe_notes_ph", text: $notes)
                }
                Section(header: Text("recipe_ingredients")) {
                    HStack {
                        TextField("ingredient_name_ph", text: $ingredientName)
                        TextField("ingredient_qty_ph", text: $ingredientQty)
                        Button {
                            let ing = Ingredient(name: ingredientName, quantity: ingredientQty)
                            ingredients.append(ing)
                            ingredientName = ""
                            ingredientQty = ""
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }.disabled(ingredientName.isEmpty)
                    }
                    ForEach(ingredients) { ing in
                        HStack {
                            Text(ing.name)
                            Spacer()
                            Text(ing.quantity).foregroundColor(.secondary)
                        }
                    }
                    .onDelete { idx in
                        ingredients.remove(atOffsets: idx)
                    }
                }
            }
            .navigationTitle(Text("recipe_add"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common_cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("common_save") {
                        let r = Recipe(title: title, notes: notes, ingredients: ingredients)
                        onSave(r)
                        dismiss()
                    }.disabled(title.isEmpty)
                }
            }
        }
    }
}
