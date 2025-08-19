import SwiftUI
import UserNotifications

@main
struct FoodPlanerRoadApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environment(\.locale, Locale(identifier: appState.languageCode))
                .preferredColorScheme(appState.isDarkMode ? .dark : .light)
                .onAppear {
                    NotificationManager.shared.bootstrap()
                }
        }
    }
}
