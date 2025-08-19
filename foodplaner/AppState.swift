import SwiftUI

final class AppState: ObservableObject {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @AppStorage("languageCode") var languageCode: String = "en" // "en" or "it"
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = false
    
    @Published var resetTrigger: Bool = false
    
    func hardReset() {
        DataStore.shared.wipeAll()
        hasSeenOnboarding = false
        // Оставим язык и тему как были, сбросим только контент/прогресс:
        resetTrigger.toggle()
    }
}
