import SwiftUI

struct RootView: View {
    @EnvironmentObject var app: AppState
    
    var body: some View {
        Group {
            if app.hasSeenOnboarding {
                ContentView()
            } else {
                OnboardingView()
            }
        }
    }
}
