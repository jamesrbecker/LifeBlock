import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userSettings: [UserSettings]

    @StateObject private var healthKit = HealthKitManager.shared
    @StateObject private var notifications = NotificationManager.shared
    @StateObject private var purchases = PurchaseManager.shared

    @State private var showingPremium = false
    @State private var showingExportSheet = false
    @State private var reminderTime = Date()
    @State private var reminderEnabled = true

    private var settings: UserSettings {
        userSettings.first ?? UserSettings()
    }

    var body: some View {
        NavigationStack {
            List {
                // Premium section
                if !purchases.isPremium {
                    Section {
                        Button {
                            showingPremium = true
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Upgrade to Premium")
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Text("Unlimited habits, all widgets & more")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Image(systemName: "crown.fill")
                                    .font(.title2)
                                    .foregroundStyle(.yellow)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }

                // Notifications section
                Section("Reminders") {
                    Toggle("Daily Reminder", isOn: $reminderEnabled)
                        .onChange(of: reminderEnabled) { _, newValue in
                            updateReminderSettings(enabled: newValue)
                        }

                    if reminderEnabled {
                        DatePicker(
                            "Reminder Time",
                            selection: $reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                        .onChange(of: reminderTime) { _, newValue in
                            updateReminderSettings(time: newValue)
                        }
                    }

                    if !notifications.isAuthorized {
                        Button {
                            Task {
                                _ = await notifications.requestAuthorization()
                            }
                        } label: {
                            Label("Enable Notifications", systemImage: "bell.badge")
                                .foregroundStyle(.orange)
                        }
                    }
                }

                // HealthKit section
                Section("Health Integration") {
                    if healthKit.isHealthKitAvailable {
                        if healthKit.isAuthorized {
                            HStack {
                                Label("Apple Health", systemImage: "heart.fill")
                                Spacer()
                                Text("Connected")
                                    .font(.caption)
                                    .foregroundStyle(.green)
                            }

                            HStack {
                                Text("Exercise today")
                                Spacer()
                                Text("\(healthKit.todayExerciseMinutes) min")
                                    .foregroundStyle(.secondary)
                            }

                            HStack {
                                Text("Sleep last night")
                                Spacer()
                                Text(String(format: "%.1f hrs", healthKit.todaySleepHours))
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            Button {
                                Task {
                                    _ = await healthKit.requestAuthorization()
                                    await healthKit.refreshAll()
                                }
                            } label: {
                                Label("Connect Apple Health", systemImage: "heart.fill")
                            }
                        }
                    } else {
                        Text("HealthKit not available on this device")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // Appearance section (Premium)
                Section("Appearance") {
                    if purchases.isPremium {
                        NavigationLink {
                            ThemePickerView()
                        } label: {
                            HStack {
                                Label("Color Theme", systemImage: "paintpalette.fill")
                                Spacer()
                                Text("Green")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } else {
                        HStack {
                            Label("Color Theme", systemImage: "paintpalette.fill")
                            Spacer()
                            Button("Premium") {
                                showingPremium = true
                            }
                            .font(.caption)
                            .buttonStyle(.borderedProminent)
                            .tint(.yellow)
                        }
                    }
                }

                // Data section
                Section("Data") {
                    NavigationLink {
                        HabitListView()
                    } label: {
                        Label("Manage Habits", systemImage: "list.bullet")
                    }

                    if purchases.isPremium {
                        Button {
                            exportData()
                        } label: {
                            Label("Export Data", systemImage: "square.and.arrow.up")
                        }
                    } else {
                        HStack {
                            Label("Export Data", systemImage: "square.and.arrow.up")
                            Spacer()
                            Button("Premium") {
                                showingPremium = true
                            }
                            .font(.caption)
                            .buttonStyle(.borderedProminent)
                            .tint(.yellow)
                        }
                    }
                }

                // About section
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    if purchases.isPremium {
                        HStack {
                            Text("Subscription")
                            Spacer()
                            Text("Premium")
                                .foregroundStyle(.green)
                        }
                    }

                    Button {
                        Task {
                            await purchases.restorePurchases()
                        }
                    } label: {
                        Text("Restore Purchases")
                    }

                    if let privacyURL = URL(string: "https://lifegrid.app/privacy") {
                        Link(destination: privacyURL) {
                            Text("Privacy Policy")
                        }
                    }

                    if let termsURL = URL(string: "https://lifegrid.app/terms") {
                        Link(destination: termsURL) {
                            Text("Terms of Service")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingPremium) {
                PremiumView()
            }
            .onAppear {
                loadSettings()
            }
        }
    }

    private func loadSettings() {
        reminderTime = settings.reminderTime
        reminderEnabled = settings.reminderEnabled
    }

    private func updateReminderSettings(enabled: Bool? = nil, time: Date? = nil) {
        if let enabled = enabled {
            settings.reminderEnabled = enabled
            if enabled {
                Task {
                    await notifications.scheduleDailyReminder(at: settings.reminderTime)
                }
            } else {
                notifications.cancelDailyReminder()
            }
        }

        if let time = time {
            settings.reminderTime = time
            if settings.reminderEnabled {
                Task {
                    await notifications.scheduleDailyReminder(at: time)
                }
            }
        }

        try? modelContext.save()
    }

    private func exportData() {
        guard let data = DataManager.shared.exportData() else { return }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let filename = "lifegrid-export-\(dateFormatter.string(from: Date())).json"

        // Save to temp file and share
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        do {
            try data.write(to: tempURL)
            showingExportSheet = true
        } catch {
            // Export failed silently - could show alert in future
        }
    }
}

struct ThemePickerView: View {
    @State private var selectedTheme: GridColorScheme = .green

    var body: some View {
        List {
            ForEach(GridColorScheme.allCases, id: \.rawValue) { theme in
                Button {
                    selectedTheme = theme
                } label: {
                    HStack {
                        // Theme preview
                        HStack(spacing: 3) {
                            ForEach(0..<5, id: \.self) { level in
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(theme.color(for: level, isDarkMode: true))
                                    .frame(width: 20, height: 20)
                            }
                        }

                        Text(theme.rawValue.capitalized)
                            .padding(.leading, 12)

                        Spacer()

                        if selectedTheme == theme {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.accentGreen)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Color Theme")
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [UserSettings.self, Habit.self], inMemory: true)
        .preferredColorScheme(.dark)
}
