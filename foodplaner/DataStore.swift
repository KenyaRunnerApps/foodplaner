import Foundation

// MARK: - Progress & Achievements

struct ProgressState: Codable {
    var recipesCreated: Int = 0
    var groceriesChecked: Int = 0
    var daysPlanned: Int = 0
}

struct Achievement: Identifiable, Codable, Hashable {
    let id: String                 // стабильный ID
    let titleKey: String           // локализационный ключ заголовка
    let descriptionKey: String     // локализационный ключ описания
    let goal: Int
    var progress: Int
    var isUnlocked: Bool
}

final class DataStore: ObservableObject {
    static let shared = DataStore()
    private init() { loadAll() }

    // Контент
    @Published var recipes: [Recipe] = []
    @Published var groceries: [Ingredient] = []
    @Published var planner: [PlannerDay] = []

    // Прогресс и ачивки
    @Published var progress = ProgressState()
    @Published var achievements: [Achievement] = []

    // Версионирование семплов, чтобы подлить новые рецепты поверх старых данных
    private let seedVersionCurrent = 2

    // Keys
    private let recipesKey = "ds_recipes_v1"
    private let groceriesKey = "ds_groceries_v1"
    private let plannerKey = "ds_planner_v1"
    private let progressKey = "ds_progress_v1"
    private let achievementsKey = "ds_achievements_v1"
    private let seedVersionKey = "ds_seed_version"

    // MARK: Load/Save

    func loadAll() {
        recipes = load(forKey: recipesKey) ?? seedRecipes()
        groceries = load(forKey: groceriesKey) ?? []
        planner = load(forKey: plannerKey) ?? []
        progress = load(forKey: progressKey) ?? ProgressState()
        achievements = load(forKey: achievementsKey) ?? defaultAchievements()

        // Мердж семплов, если раньше было всего 1–2 рецепта
        mergeSeedRecipesIfNeeded()

        // Пересчитаем daysPlanned на старте (на случай, если были данные)
        recalcDaysPlannedFromPlanner()

        saveAll()
    }

    func saveAll() {
        save(recipes, forKey: recipesKey)
        save(groceries, forKey: groceriesKey)
        save(planner, forKey: plannerKey)
        save(progress, forKey: progressKey)
        save(achievements, forKey: achievementsKey)
    }

    func wipeAll() {
        UserDefaults.standard.removeObject(forKey: recipesKey)
        UserDefaults.standard.removeObject(forKey: groceriesKey)
        UserDefaults.standard.removeObject(forKey: plannerKey)
        UserDefaults.standard.removeObject(forKey: progressKey)
        UserDefaults.standard.removeObject(forKey: achievementsKey)
        UserDefaults.standard.removeObject(forKey: seedVersionKey)
        loadAll()
    }

    private func save<T: Codable>(_ value: T, forKey key: String) {
        let enc = JSONEncoder()
        if let data = try? enc.encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load<T: Codable>(forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        let dec = JSONDecoder()
        return try? dec.decode(T.self, from: data)
    }

    // MARK: Seed

    @discardableResult
    private func seedRecipes() -> [Recipe] {
        // 10 готовых семплов
        let r1 = Recipe(title: "Turkey Sandwich", notes: "Wrap in foil", ingredients: [
            Ingredient(name: "Bread", quantity: "2 slices"),
            Ingredient(name: "Turkey", quantity: "80 g"),
            Ingredient(name: "Lettuce", quantity: "2 leaves")
        ])
        let r2 = Recipe(title: "Overnight Oats", notes: "Keep cool", ingredients: [
            Ingredient(name: "Oats", quantity: "60 g"),
            Ingredient(name: "Milk", quantity: "150 ml"),
            Ingredient(name: "Berries", quantity: "1 handful")
        ])
        let r3 = Recipe(title: "Pasta Salad Box", notes: "Olive oil keeps it fresh", ingredients: [
            Ingredient(name: "Pasta (short)", quantity: "120 g"),
            Ingredient(name: "Cherry tomatoes", quantity: "6–8"),
            Ingredient(name: "Olives", quantity: "8"),
            Ingredient(name: "Feta", quantity: "60 g"),
            Ingredient(name: "Olive oil", quantity: "1 tbsp")
        ])
        let r4 = Recipe(title: "Hummus Veggie Wrap", notes: "Great for 6–8h trip", ingredients: [
            Ingredient(name: "Tortilla", quantity: "1"),
            Ingredient(name: "Hummus", quantity: "2 tbsp"),
            Ingredient(name: "Cucumber", quantity: "4–5 slices"),
            Ingredient(name: "Carrot (shredded)", quantity: "30 g"),
            Ingredient(name: "Spinach", quantity: "1 handful")
        ])
        let r5 = Recipe(title: "Trail Mix Cups", notes: "Portion into silicone cups", ingredients: [
            Ingredient(name: "Nuts mix", quantity: "50 g"),
            Ingredient(name: "Raisins", quantity: "20 g"),
            Ingredient(name: "Dark chocolate chips", quantity: "15 g")
        ])
        let r6 = Recipe(title: "Cheese & Crackers Box", notes: "No fridge for 4–5h OK", ingredients: [
            Ingredient(name: "Crackers", quantity: "8–10"),
            Ingredient(name: "Hard cheese", quantity: "80 g"),
            Ingredient(name: "Apple", quantity: "1")
        ])
        let r7 = Recipe(title: "Banana PB Roll-Up", notes: "Fast energy", ingredients: [
            Ingredient(name: "Tortilla", quantity: "1"),
            Ingredient(name: "Peanut butter", quantity: "1–2 tbsp"),
            Ingredient(name: "Banana", quantity: "1")
        ])
        let r8 = Recipe(title: "No-Bake Energy Balls", notes: "Make 8–10 balls", ingredients: [
            Ingredient(name: "Oats", quantity: "80 g"),
            Ingredient(name: "Peanut butter", quantity: "2 tbsp"),
            Ingredient(name: "Honey", quantity: "1 tbsp"),
            Ingredient(name: "Chia seeds", quantity: "1 tsp")
        ])
        let r9 = Recipe(title: "Cold Chicken Pasta", notes: "Good for lunch stop", ingredients: [
            Ingredient(name: "Pasta", quantity: "120 g"),
            Ingredient(name: "Cooked chicken", quantity: "100 g"),
            Ingredient(name: "Corn", quantity: "50 g"),
            Ingredient(name: "Mayo or yogurt", quantity: "1 tbsp")
        ])
        let r10 = Recipe(title: "Yogurt Parfait (Travel Jar)", notes: "Assemble in a jar", ingredients: [
            Ingredient(name: "Yogurt", quantity: "150 g"),
            Ingredient(name: "Granola", quantity: "40 g"),
            Ingredient(name: "Berries", quantity: "1 handful")
        ])
        UserDefaults.standard.set(seedVersionCurrent, forKey: seedVersionKey)
        return [r1, r2, r3, r4, r5, r6, r7, r8, r9, r10]
    }

    /// Если данные старые (seedVersion < current) или рецептов мало — подливаем недостающие семплы по заголовкам
    private func mergeSeedRecipesIfNeeded() {
        let savedVersion = UserDefaults.standard.integer(forKey: seedVersionKey)
        if savedVersion >= seedVersionCurrent, recipes.count >= 5 { return }

        let fresh = seedRecipes()
        let existingTitles = Set(recipes.map { $0.title.lowercased() })
        var merged = recipes

        for r in fresh where !existingTitles.contains(r.title.lowercased()) {
            merged.append(r)
        }

        recipes = merged
        UserDefaults.standard.set(seedVersionCurrent, forKey: seedVersionKey)
    }

    // MARK: Default Achievements

    private func defaultAchievements() -> [Achievement] {
        return [
            Achievement(id: "first_recipe", titleKey: "ach_first_recipe_title", descriptionKey: "ach_first_recipe_desc", goal: 1,  progress: 0, isUnlocked: false),
            Achievement(id: "prep_rookie",  titleKey: "ach_prep_rookie_title", descriptionKey: "ach_prep_rookie_desc", goal: 5,  progress: 0, isUnlocked: false),
            Achievement(id: "shop_champion",titleKey: "ach_shop_champ_title", descriptionKey: "ach_shop_champ_desc", goal: 20, progress: 0, isUnlocked: false),
            Achievement(id: "planner_3days",titleKey: "ach_planner3_title", descriptionKey: "ach_planner3_desc", goal: 3,  progress: 0, isUnlocked: false)
        ]
    }

    // MARK: Progress tracking helpers

    func trackRecipeCreated() {
        progress.recipesCreated += 1
        bumpAchievement(id: "first_recipe", value: 1)
        bumpAchievement(id: "prep_rookie", value: 1)
        saveAll()
    }

    func trackGroceryChecked(_ becameChecked: Bool) {
        if becameChecked {
            progress.groceriesChecked += 1
            bumpAchievement(id: "shop_champion", value: 1)
            saveAll()
        }
    }

    func recalcDaysPlannedFromPlanner() {
        let count = planner.filter { !$0.recipeIDs.isEmpty }.count
        let delta = max(0, count - progress.daysPlanned)
        progress.daysPlanned = count
        if delta > 0 {
            bumpAchievement(id: "planner_3days", value: delta)
        }
        saveAll()
    }

    private func bumpAchievement(id: String, value: Int) {
        guard let idx = achievements.firstIndex(where: { $0.id == id }) else { return }
        achievements[idx].progress = min(achievements[idx].goal, achievements[idx].progress + value)
        if achievements[idx].progress >= achievements[idx].goal {
            achievements[idx].isUnlocked = true
        }
    }
}
