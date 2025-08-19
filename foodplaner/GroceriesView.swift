import SwiftUI

struct GroceriesView: View {
    @StateObject private var store = DataStore.shared
    @State private var name: String = ""
    @State private var qty: String = ""
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("groceries_add_item")) {
                    HStack {
                        TextField("ingredient_name_ph", text: $name)
                        TextField("ingredient_qty_ph", text: $qty)
                        Button {
                            let ing = Ingredient(name: name, quantity: qty)
                            store.groceries.append(ing)
                            store.saveAll()
                            name = ""
                            qty = ""
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }.disabled(name.isEmpty)
                    }
                }
                Section(header: Text("groceries_list")) {
                    ForEach(store.groceries) { ing in
                        HStack {
                            Button {
                                toggle(ing)
                            } label: {
                                Image(systemName: ing.isChecked ? "checkmark.circle.fill" : "circle")
                            }.buttonStyle(.plain)
                            Text(ing.name)
                            Spacer()
                            Text(ing.quantity).foregroundColor(.secondary)
                        }
                    }
                    .onDelete { idx in
                        store.groceries.remove(atOffsets: idx)
                        store.saveAll()
                    }
                }
            }
            .navigationTitle(Text("tab_groceries"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("common_clear") {
                        store.groceries.removeAll()
                        store.saveAll()
                    }
                }
            }
        }
    }
    
    private func toggle(_ ing: Ingredient) {
        if let i = store.groceries.firstIndex(of: ing) {
            let willBeChecked = !store.groceries[i].isChecked
            store.groceries[i].isChecked = willBeChecked
            store.saveAll()
            store.trackGroceryChecked(willBeChecked)
        }
    }
}
