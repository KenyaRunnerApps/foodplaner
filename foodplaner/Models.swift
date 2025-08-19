import Foundation

struct Ingredient: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var quantity: String
    var isChecked: Bool
    
    init(id: UUID = UUID(), name: String, quantity: String = "", isChecked: Bool = false) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.isChecked = isChecked
    }
}

struct Recipe: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var notes: String
    var ingredients: [Ingredient]
    var isFavorite: Bool
    
    init(id: UUID = UUID(), title: String, notes: String = "", ingredients: [Ingredient] = [], isFavorite: Bool = false) {
        self.id = id
        self.title = title
        self.notes = notes
        self.ingredients = ingredients
        self.isFavorite = isFavorite
    }
}

struct PlannerDay: Identifiable, Codable, Hashable {
    let id: UUID
    var date: Date
    var recipeIDs: [UUID]
    
    init(id: UUID = UUID(), date: Date = Date(), recipeIDs: [UUID] = []) {
        self.id = id
        self.date = date
        self.recipeIDs = recipeIDs
    }
}
