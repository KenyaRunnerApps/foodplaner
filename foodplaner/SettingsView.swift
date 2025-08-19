import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject var app: AppState
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("settings_appearance")) {
                    Toggle(isOn: $app.isDarkMode) {
                        Text("settings_dark_mode")
                    }
                }
                
                Section(header: Text("settings_language")) {
                    Picker("settings_language", selection: $app.languageCode) {
                        Text("English").tag("en")
                        Text("Italiano").tag("it")
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("settings_notifications")) {
                    Toggle(isOn: $app.notificationsEnabled) {
                        Text("settings_pushes")
                    }
                    .onChange(of: app.notificationsEnabled) { enabled in
                        if enabled {
                            NotificationManager.shared.requestPermission { granted in
                                DispatchQueue.main.async {
                                    app.notificationsEnabled = granted
                                    if granted {
                                        NotificationManager.shared.scheduleNoonTomorrowReminder()
                                    }
                                }
                            }
                        } else {
                            NotificationManager.shared.cancelAll()
                        }
                    }
                    
                    Text("settings_pushes_note") // локализуемая подпись
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Section {
                    Button("settings_privacy") {
                        if let url = URL(string: "https://www.termsfeed.com/live/bcbc2f12-4c8b-486a-95a9-c7111b69526d") {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        app.hardReset()
                    } label: {
                        Text("settings_delete_all")
                    }
                } footer: {
                    Text("settings_delete_all_hint")
                }
            }
            .navigationTitle(Text("tab_settings"))
        }
    }
}
