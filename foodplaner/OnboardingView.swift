import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var app: AppState
    @State private var page: Int = 0
    
    var body: some View {
        VStack {
            TabView(selection: $page) {
                onboardCard(
                    title: "onb_title_1",
                    text: "onb_text_1",
                    systemName: "fork.knife.circle",
                    showFlame: true // 🔥 огонёк на первом экране
                ).tag(0)
                
                onboardCard(
                    title: "onb_title_2",
                    text: "onb_text_2",
                    systemName: "shippingbox"
                ).tag(1)
                
                onboardCard(
                    title: "onb_title_3",
                    text: "onb_text_3",
                    systemName: "bell.badge"
                ).tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            
            Button {
                app.hasSeenOnboarding = true
            } label: {
                Text("onb_get_started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding()
            }
            .accessibilityIdentifier("OnboardingGetStarted")
        }
    }
    
    @ViewBuilder
    private func onboardCard(
        title: LocalizedStringKey,
        text: LocalizedStringKey,
        systemName: String,
        showFlame: Bool = false
    ) -> some View {
        VStack(spacing: 16) {
            Spacer()
            ZStack(alignment: .topTrailing) {
                Image(systemName: systemName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding(.bottom, 8)
                if showFlame {
                    Image(systemName: "flame.fill") // SF Symbols (не эмодзи)
                        .imageScale(.large)
                        .padding(6)
                }
            }
            Text(title)
                .font(.title.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Text(text)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            Spacer()
        }
        .padding()
    }
}
