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

                // Premium Features
                Section("Premium Features") {
                    if purchases.isPremium {
                        NavigationLink {
                            MultiplePathsView()
                        } label: {
                            Label("Multiple Paths", systemImage: "arrow.triangle.branch")
                        }

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

                        NavigationLink {
                            CloudSyncSettingsView()
                        } label: {
                            Label("iCloud Sync", systemImage: "icloud.fill")
                        }
                    } else {
                        HStack {
                            Label("Multiple Paths", systemImage: "arrow.triangle.branch")
                            Spacer()
                            Button("Premium") {
                                showingPremium = true
                            }
                            .font(.caption)
                            .buttonStyle(.borderedProminent)
                            .tint(.yellow)
                        }

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

                        HStack {
                            Label("iCloud Sync", systemImage: "icloud.fill")
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

                // Notifications
                Section("Notifications") {
                    NavigationLink {
                        NotificationSettingsView()
                    } label: {
                        Label("Reminder Settings", systemImage: "bell.fill")
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

                    // Privacy and Terms links - hosted on GitHub Pages
                    if let privacyURL = URL(string: "https://jamesrbecker.github.io/LifeBlock/privacy.html") {
                        Link(destination: privacyURL) {
                            Text("Privacy Policy")
                        }
                    }

                    if let termsURL = URL(string: "https://jamesrbecker.github.io/LifeBlock/terms.html") {
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
        let filename = "lifeblock-export-\(dateFormatter.string(from: Date())).json"

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
    @AppStorage("selectedTheme") private var selectedTheme: String = "green"

    let themes: [(name: String, colors: [Color], isPremium: Bool)] = [
        ("green", [Color(hex: "#161B22"), Color(hex: "#0E4429"), Color(hex: "#006D32"), Color(hex: "#26A641"), Color(hex: "#39D353")], false),
        ("blue", [Color(hex: "#161B22"), Color(hex: "#0D3B66"), Color(hex: "#1E6091"), Color(hex: "#3A8BC2"), Color(hex: "#5AB4F5")], false),
        ("purple", [Color(hex: "#161B22"), Color(hex: "#3D1A5C"), Color(hex: "#6B2D8C"), Color(hex: "#9945BD"), Color(hex: "#C75DEF")], true),
        ("orange", [Color(hex: "#161B22"), Color(hex: "#5C2D0E"), Color(hex: "#8C4516"), Color(hex: "#BD5D1F"), Color(hex: "#EF7627")], true),
        ("pink", [Color(hex: "#161B22"), Color(hex: "#5C1A3D"), Color(hex: "#8C2D5C"), Color(hex: "#BD457B"), Color(hex: "#EF5D9A")], true),
        ("red", [Color(hex: "#161B22"), Color(hex: "#5C1A1A"), Color(hex: "#8C2D2D"), Color(hex: "#BD4545"), Color(hex: "#EF5D5D")], true),
        ("gold", [Color(hex: "#161B22"), Color(hex: "#5C4A0E"), Color(hex: "#8C7016"), Color(hex: "#BD961F"), Color(hex: "#EFBC27")], true),
        ("cyan", [Color(hex: "#161B22"), Color(hex: "#0E4A5C"), Color(hex: "#167A8C"), Color(hex: "#1FAABD"), Color(hex: "#27DAEF")], true),
        ("monochrome", [Color(hex: "#161B22"), Color(hex: "#333333"), Color(hex: "#666666"), Color(hex: "#999999"), Color(hex: "#CCCCCC")], true),
        ("neon", [Color(hex: "#0D0D0D"), Color(hex: "#FF00FF").opacity(0.3), Color(hex: "#FF00FF").opacity(0.5), Color(hex: "#FF00FF").opacity(0.7), Color(hex: "#FF00FF")], true),
    ]

    var body: some View {
        List {
            Section {
                ForEach(themes, id: \.name) { theme in
                    Button {
                        if !theme.isPremium || PurchaseManager.shared.isPremium {
                            selectedTheme = theme.name
                        }
                    } label: {
                        HStack {
                            // Theme preview
                            HStack(spacing: 3) {
                                ForEach(0..<5, id: \.self) { level in
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(theme.colors[level])
                                        .frame(width: 20, height: 20)
                                }
                            }

                            Text(theme.name.capitalized)
                                .padding(.leading, 12)

                            if theme.isPremium && !PurchaseManager.shared.isPremium {
                                Image(systemName: "crown.fill")
                                    .font(.caption)
                                    .foregroundStyle(.yellow)
                            }

                            Spacer()

                            if selectedTheme == theme.name {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.green)
                            }
                        }
                        .padding(.vertical, 8)
                        .opacity(theme.isPremium && !PurchaseManager.shared.isPremium ? 0.6 : 1)
                    }
                    .buttonStyle(.plain)
                }
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Label("About Themes", systemImage: "info.circle")
                        .font(.headline)

                    Text("Themes change the color of your activity grid. Premium themes are marked with a crown icon.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("Color Theme")
    }
}

// Color(hex:) extension is defined in Utilities/ColorScheme.swift

#Preview {
    SettingsView()
        .modelContainer(for: [UserSettings.self, Habit.self], inMemory: true)
        .preferredColorScheme(.dark)
}
