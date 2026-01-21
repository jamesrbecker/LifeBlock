import SwiftUI
import SwiftData
import StoreKit

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var systemColorScheme
    @Query private var userSettings: [UserSettings]

    @StateObject private var healthKit = HealthKitManager.shared
    @StateObject private var notifications = NotificationManager.shared
    @StateObject private var purchases = PurchaseManager.shared
    @ObservedObject private var appSettings = AppSettings.shared

    @State private var showingPremium = false
    @State private var showingExportSheet = false
    @State private var reminderTime = Date()
    @State private var reminderEnabled = true
    @State private var showingReferralSheet = false
    @State private var showingFamilySheet = false
    @State private var showingInsights = false

    private var settings: UserSettings {
        userSettings.first ?? UserSettings()
    }

    var body: some View {
        NavigationStack {
            List {
                premiumSection
                streakProtectionSection
                privacySection
                appearanceSection
                analyticsSection
                remindersSection
                healthSection
                premiumFeaturesSection
                notificationsSection
                dataSection
                referralSection
                familySection
                feedbackSection
                aboutSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingPremium) {
                PremiumView()
            }
            .sheet(isPresented: $showingFamilySheet) {
                FamilyPlanView()
            }
            .onAppear {
                loadSettings()
            }
            .preferredColorScheme(colorSchemePreference)
        }
    }

    private var colorSchemePreference: ColorScheme? {
        switch appSettings.colorSchemeOverride {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    private func shareReferralCode() {
        let message = "Join me on LifeBlocks! Use my referral code \(appSettings.referralCode) to get started. Download: https://apps.apple.com/app/lifeblocks"
        let activityVC = UIActivityViewController(activityItems: [message], applicationActivities: nil)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
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

    // MARK: - Section Views

    @ViewBuilder
    private var premiumSection: some View {
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
                                .foregroundStyle(Color.secondaryText)
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
    }

    private var streakProtectionSection: some View {
        Section {
            HStack {
                Label("Freeze Days", systemImage: "snowflake")
                Spacer()
                Text("\(appSettings.freezeDaysRemaining) remaining")
                    .foregroundStyle(Color.secondaryText)
            }
            if appSettings.freezeDaysRemaining > 0 {
                Text("Use a freeze day to protect your streak when you can't check in")
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
            }
            HStack {
                Text("Monthly Limit")
                Spacer()
                Text("\(appSettings.maxFreezeDaysPerMonth) days")
                    .foregroundStyle(Color.secondaryText)
            }
        } header: {
            Text("Streak Protection")
        } footer: {
            Text("Freeze days reset at the start of each month")
        }
    }

    private var privacySection: some View {
        Section {
            NavigationLink {
                PrivacySettingsView()
            } label: {
                HStack {
                    Label("Privacy", systemImage: "lock.shield.fill")
                    Spacer()
                    if appSettings.isPrivateMode {
                        Text("Private Mode")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
            }
        } header: {
            Text("Privacy")
        } footer: {
            Text("Control what friends can see. Your path, goals, and progress are private by default.")
        }
    }

    private var appearanceSection: some View {
        Section("Appearance") {
            Picker("Theme", selection: Binding(
                get: { appSettings.colorSchemeOverride ?? "system" },
                set: { appSettings.colorSchemeOverride = $0 == "system" ? nil : $0 }
            )) {
                Text("System").tag("system")
                Text("Light").tag("light")
                Text("Dark").tag("dark")
            }
            .pickerStyle(.segmented)
        }
    }

    private var analyticsSection: some View {
        Section("Analytics") {
            NavigationLink {
                InsightsView()
            } label: {
                Label("Insights & Trends", systemImage: "chart.line.uptrend.xyaxis")
            }
        }
    }

    private var remindersSection: some View {
        Section("Reminders") {
            Toggle("Daily Reminder", isOn: $reminderEnabled)
                .onChange(of: reminderEnabled) { _, newValue in
                    updateReminderSettings(enabled: newValue)
                }
            if reminderEnabled {
                DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    .onChange(of: reminderTime) { _, newValue in
                        updateReminderSettings(time: newValue)
                    }
            }
            if !notifications.isAuthorized {
                Button {
                    Task { _ = await notifications.requestAuthorization() }
                } label: {
                    Label("Enable Notifications", systemImage: "bell.badge")
                        .foregroundStyle(.orange)
                }
            }
        }
    }

    private var healthSection: some View {
        Section("Health Integration") {
            if healthKit.isHealthKitAvailable {
                if healthKit.isAuthorized {
                    HStack {
                        Label("Apple Health", systemImage: "heart.fill")
                        Spacer()
                        Text("Connected").font(.caption).foregroundStyle(.green)
                    }
                    HStack {
                        Text("Exercise today")
                        Spacer()
                        Text("\(healthKit.todayExerciseMinutes) min").foregroundStyle(Color.secondaryText)
                    }
                    HStack {
                        Text("Sleep last night")
                        Spacer()
                        Text(String(format: "%.1f hrs", healthKit.todaySleepHours)).foregroundStyle(Color.secondaryText)
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
                Text("HealthKit not available").font(.caption).foregroundStyle(Color.secondaryText)
            }
        }
    }

    private var premiumFeaturesSection: some View {
        Section("Premium Features") {
            if purchases.isPremium {
                NavigationLink { MultiplePathsView() } label: {
                    Label("Multiple Paths", systemImage: "arrow.triangle.branch")
                }
                NavigationLink { ThemePickerView() } label: {
                    Label("Color Theme", systemImage: "paintpalette.fill")
                }
            } else {
                HStack {
                    Label("Multiple Paths", systemImage: "arrow.triangle.branch")
                    Spacer()
                    Button("Premium") { showingPremium = true }.font(.caption).buttonStyle(.borderedProminent).tint(.yellow)
                }
                HStack {
                    Label("Color Theme", systemImage: "paintpalette.fill")
                    Spacer()
                    Button("Premium") { showingPremium = true }.font(.caption).buttonStyle(.borderedProminent).tint(.yellow)
                }
            }
        }
    }

    private var notificationsSection: some View {
        Section("Notifications") {
            NavigationLink { NotificationSettingsView() } label: {
                Label("Reminder Settings", systemImage: "bell.fill")
            }
        }
    }

    private var dataSection: some View {
        Section("Data") {
            NavigationLink { HabitListView() } label: {
                Label("Manage Habits", systemImage: "list.bullet")
            }
            if purchases.isPremium {
                Button { exportData() } label: {
                    Label("Export Data", systemImage: "square.and.arrow.up")
                }
            } else {
                HStack {
                    Label("Export Data", systemImage: "square.and.arrow.up")
                    Spacer()
                    Button("Premium") { showingPremium = true }.font(.caption).buttonStyle(.borderedProminent).tint(.yellow)
                }
            }
        }
    }

    private var referralSection: some View {
        Section {
            HStack {
                Label("Your Code", systemImage: "person.2.fill")
                Spacer()
                Text(appSettings.referralCode)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(Color.secondaryText)
                Button {
                    UIPasteboard.general.string = appSettings.referralCode
                    HapticManager.shared.success()
                } label: {
                    Image(systemName: "doc.on.doc").font(.caption)
                }
            }
            HStack {
                Text("Friends Referred")
                Spacer()
                Text("\(appSettings.referralCount)").foregroundStyle(Color.secondaryText)
            }
            if appSettings.earnedPremiumDays > 0 {
                HStack {
                    Text("Bonus Days Earned")
                    Spacer()
                    Text("\(appSettings.earnedPremiumDays) days").foregroundStyle(.green)
                }
            }
            Button { shareReferralCode() } label: {
                Label("Share Referral Code", systemImage: "square.and.arrow.up")
            }
        } header: {
            Text("Refer Friends")
        } footer: {
            Text("Earn 7 days of Premium for each friend who signs up!")
        }
    }

    private var familySection: some View {
        Section {
            if appSettings.familyGroupId != nil {
                HStack {
                    Label("Family Plan", systemImage: "person.3.fill")
                    Spacer()
                    Text(appSettings.isFamilyAdmin ? "Admin" : "Member").foregroundStyle(Color.secondaryText)
                }
                HStack {
                    Text("Family Members")
                    Spacer()
                    Text("\(appSettings.familyMemberCount)").foregroundStyle(Color.secondaryText)
                }
                if appSettings.isFamilyAdmin {
                    Button { showingFamilySheet = true } label: {
                        Label("Manage Family", systemImage: "gearshape")
                    }
                }
            } else {
                Button { showingFamilySheet = true } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Family Plan").foregroundStyle(.primary)
                            Text("Share Premium with up to 6 family members").font(.caption).foregroundStyle(Color.secondaryText)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").foregroundStyle(Color.secondaryText)
                    }
                }
            }
        } header: {
            Text("Family")
        }
    }

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text("2.0").foregroundStyle(Color.secondaryText)
            }
            if purchases.isPremium {
                HStack {
                    Text("Subscription")
                    Spacer()
                    Text("Premium").foregroundStyle(.green)
                }
            }
            Button {
                Task { await purchases.restorePurchases() }
            } label: {
                Text("Restore Purchases")
            }
            if let privacyURL = URL(string: "https://jamesrbecker.github.io/LifeBlock/privacy.html") {
                Link(destination: privacyURL) { Text("Privacy Policy") }
            }
            if let termsURL = URL(string: "https://jamesrbecker.github.io/LifeBlock/terms.html") {
                Link(destination: termsURL) { Text("Terms of Service") }
            }
        }
    }

    private var feedbackSection: some View {
        Section("Feedback & Support") {
            Button {
                sendFeedbackEmail()
            } label: {
                Label("Send Feedback", systemImage: "envelope.fill")
            }

            Button {
                requestAppStoreReview()
            } label: {
                Label("Rate LifeBlocks", systemImage: "star.fill")
            }

            if let twitterURL = URL(string: "https://twitter.com/LifeBlocksApp") {
                Link(destination: twitterURL) {
                    Label("Follow on X", systemImage: "at")
                }
            }
        }
    }

    private func sendFeedbackEmail() {
        let email = "support@lifeblocks.app"
        let subject = "LifeBlocks Feedback - v2.0"
        let body = """

        ---
        App Version: 2.0
        iOS Version: \(UIDevice.current.systemVersion)
        Device: \(UIDevice.current.model)
        """

        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        if let url = URL(string: "mailto:\(email)?subject=\(encodedSubject)&body=\(encodedBody)") {
            UIApplication.shared.open(url)
        }
    }

    private func requestAppStoreReview() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}

struct ThemePickerView: View {
    @AppStorage("selectedTheme") private var selectedTheme: String = "green"
    @StateObject private var themeManager = ThemeManager.shared
    @State private var showingIconChangeAlert = false

    // Theme data: name, displayName, colors, isPremium, hasAlternateIcon
    let themes: [(name: String, displayName: String, colors: [Color], isPremium: Bool, iconName: String?)] = [
        // Free themes with matching app icons
        ("green", "Green", [Color(hex: "#161B22"), Color(hex: "#0D3D1F"), Color(hex: "#1A7A3E"), Color(hex: "#28A745"), Color(hex: "#34C759")], false, "AppIcon-Green"),
        ("skyblue", "Sky Blue", [Color(hex: "#161B22"), Color(hex: "#0C3A5A"), Color(hex: "#1877B8"), Color(hex: "#3DA5E0"), Color(hex: "#5AC8FA")], false, "AppIcon-SkyBlue"),
        ("lavender", "Lavender", [Color(hex: "#161B22"), Color(hex: "#3D2E5C"), Color(hex: "#6B5B95"), Color(hex: "#9B8DC2"), Color(hex: "#BDB5D5")], false, "AppIcon-Lavender"),
        // Premium themes with matching app icons
        ("blue", "Ocean Blue", [Color(hex: "#161B22"), Color(hex: "#0A3069"), Color(hex: "#0550AE"), Color(hex: "#218BFF"), Color(hex: "#58A6FF")], true, nil),
        ("purple", "Violet", [Color(hex: "#161B22"), Color(hex: "#3D1F5C"), Color(hex: "#6E40C9"), Color(hex: "#8B5CF6"), Color(hex: "#A78BFA")], true, "AppIcon-Purple"),
        ("orange", "Fire", [Color(hex: "#161B22"), Color(hex: "#5C2D0E"), Color(hex: "#9A3412"), Color(hex: "#EA580C"), Color(hex: "#FB923C")], true, "AppIcon-Orange"),
        ("pink", "Rose", [Color(hex: "#161B22"), Color(hex: "#5C1A3D"), Color(hex: "#9D174D"), Color(hex: "#DB2777"), Color(hex: "#F472B6")], true, nil),
        ("gold", "Gold", [Color(hex: "#161B22"), Color(hex: "#5C4A0E"), Color(hex: "#8C7016"), Color(hex: "#BD961F"), Color(hex: "#EFBC27")], true, nil),
        ("cyan", "Cyan", [Color(hex: "#161B22"), Color(hex: "#0E4A5C"), Color(hex: "#167A8C"), Color(hex: "#1FAABD"), Color(hex: "#27DAEF")], true, nil),
        ("monochrome", "Monochrome", [Color(hex: "#161B22"), Color(hex: "#333333"), Color(hex: "#666666"), Color(hex: "#999999"), Color(hex: "#CCCCCC")], true, nil),
        ("neon", "Neon", [Color(hex: "#0D0D0D"), Color(hex: "#FF00FF").opacity(0.3), Color(hex: "#FF00FF").opacity(0.5), Color(hex: "#FF00FF").opacity(0.7), Color(hex: "#FF00FF")], true, nil),
    ]

    var body: some View {
        List {
            // App Icon Section (Premium only)
            if PurchaseManager.shared.isPremium {
                Section {
                    HStack {
                        // Current icon preview
                        if let currentIcon = UIApplication.shared.alternateIconName {
                            Image(uiImage: UIImage(named: currentIcon) ?? UIImage())
                                .resizable()
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 13))
                        } else {
                            Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                                .resizable()
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 13))
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("App Icon")
                                .font(.headline)
                            Text("Changes with theme selection")
                                .font(.caption)
                                .foregroundStyle(Color.secondaryText)
                        }
                        .padding(.leading, 8)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("App Icon")
                } footer: {
                    Text("Premium feature: Your app icon will match your selected theme color.")
                }
            }

            Section("Free Themes") {
                ForEach(themes.filter { !$0.isPremium }, id: \.name) { theme in
                    themeRow(theme)
                }
            }

            Section("Premium Themes") {
                ForEach(themes.filter { $0.isPremium }, id: \.name) { theme in
                    themeRow(theme)
                }
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Label("About Themes", systemImage: "info.circle")
                        .font(.headline)

                    Text("Themes change the color of your activity grid and accent colors throughout the app. Premium users can also change the app icon to match their theme.")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondaryText)
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("Color Theme")
    }

    @ViewBuilder
    private func themeRow(_ theme: (name: String, displayName: String, colors: [Color], isPremium: Bool, iconName: String?)) -> some View {
        Button {
            if !theme.isPremium || PurchaseManager.shared.isPremium {
                selectedTheme = theme.name
                // Update ThemeManager
                if let gridTheme = GridColorScheme(rawValue: theme.name) {
                    themeManager.setTheme(gridTheme)
                }
                // Change app icon if premium and icon available
                if PurchaseManager.shared.isPremium, let iconName = theme.iconName {
                    changeAppIcon(to: iconName)
                }
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

                VStack(alignment: .leading, spacing: 2) {
                    Text(theme.displayName)
                    if theme.iconName != nil && PurchaseManager.shared.isPremium {
                        Text("Includes app icon")
                            .font(.caption2)
                            .foregroundStyle(Color.tertiaryText)
                    }
                }
                .padding(.leading, 12)

                if theme.isPremium && !PurchaseManager.shared.isPremium {
                    Image(systemName: "crown.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                }

                Spacer()

                if selectedTheme == theme.name {
                    Image(systemName: "checkmark")
                        .foregroundStyle(theme.colors[4])
                }
            }
            .padding(.vertical, 8)
            .opacity(theme.isPremium && !PurchaseManager.shared.isPremium ? 0.6 : 1)
        }
        .buttonStyle(.plain)
    }

    private func changeAppIcon(to iconName: String) {
        guard UIApplication.shared.supportsAlternateIcons else { return }

        UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error = error {
                print("Failed to change app icon: \(error.localizedDescription)")
            }
        }
    }
}

// Color(hex:) extension is defined in Utilities/ColorScheme.swift

// MARK: - Family Plan View
struct FamilyPlanView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var appSettings = AppSettings.shared
    @StateObject private var purchases = PurchaseManager.shared

    @State private var inviteEmail = ""
    @State private var showingInviteSent = false

    var body: some View {
        NavigationStack {
            List {
                // Plan Info
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "person.3.fill")
                                .font(.largeTitle)
                                .foregroundStyle(.blue)

                            VStack(alignment: .leading) {
                                Text("Family Plan")
                                    .font(.title2)
                                    .fontWeight(.bold)

                                Text("From $4.99/month")
                                    .font(.headline)
                                    .foregroundStyle(Color.secondaryText)
                            }
                        }

                        Text("Share Premium with up to 5 family members. Each member gets their own account with full Premium features.")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondaryText)
                    }
                    .padding(.vertical, 8)
                }

                if appSettings.familyGroupId != nil {
                    // Current Members
                    Section("Family Members") {
                        ForEach(0..<appSettings.familyMemberCount, id: \.self) { index in
                            HStack {
                                Image(systemName: index == 0 ? "crown.fill" : "person.circle.fill")
                                    .foregroundStyle(index == 0 ? .yellow : .secondary)

                                Text(index == 0 ? "You (Admin)" : "Family Member \(index)")

                                Spacer()

                                if index == 0 {
                                    Text("Admin")
                                        .font(.caption)
                                        .foregroundStyle(Color.secondaryText)
                                }
                            }
                        }
                    }

                    // Invite Section
                    if appSettings.isFamilyAdmin && appSettings.familyMemberCount < 6 {
                        Section("Invite Members") {
                            HStack {
                                TextField("Email address", text: $inviteEmail)
                                    .foregroundStyle(Color.inputText)
                                    .keyboardType(.emailAddress)
                                    .textContentType(.emailAddress)
                                    .autocapitalization(.none)

                                Button("Invite") {
                                    sendInvite()
                                }
                                .disabled(inviteEmail.isEmpty)
                            }

                            Text("\(6 - appSettings.familyMemberCount) spots remaining")
                                .font(.caption)
                                .foregroundStyle(Color.secondaryText)
                        }
                    }
                } else {
                    // Not subscribed
                    Section {
                        VStack(spacing: 16) {
                            FamilyFeatureRow(icon: "person.3.fill", title: "Up to 6 members", description: "Share with family")
                            FamilyFeatureRow(icon: "crown.fill", title: "Full Premium", description: "All features included")
                            FamilyFeatureRow(icon: "dollarsign.circle.fill", title: "Save 50%", description: "vs individual plans")
                        }
                        .padding(.vertical, 8)
                    }

                    Section {
                        Button {
                            // Subscribe to family plan
                            Task {
                                // await purchases.purchaseFamilyPlan()
                            }
                        } label: {
                            HStack {
                                Spacer()
                                Text("Start Family Plan")
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.borderedProminent)
                        .listRowBackground(Color.clear)
                    }

                    Section {
                        TextField("Have an invite code?", text: $inviteEmail)
                            .foregroundStyle(Color.inputText)
                            .textContentType(.oneTimeCode)

                        Button("Join Family") {
                            // Join existing family
                        }
                        .disabled(inviteEmail.isEmpty)
                    }
                }
            }
            .navigationTitle("Family Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Invite Sent", isPresented: $showingInviteSent) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("An invitation has been sent to \(inviteEmail)")
            }
        }
    }

    private func sendInvite() {
        // In production, this would send an invite via CloudKit or email
        showingInviteSent = true
        inviteEmail = ""
    }
}

struct FamilyFeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 32)

            VStack(alignment: .leading) {
                Text(title)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
            }

            Spacer()
        }
    }
}

// Note: NotificationSettingsView is defined in NotificationManager.swift

// MARK: - Privacy Settings View

struct PrivacySettingsView: View {
    @ObservedObject private var appSettings = AppSettings.shared

    var body: some View {
        List {
            // Privacy Philosophy Header
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .font(.title)
                            .foregroundStyle(.green)
                        Text("Build in Private")
                            .font(.title2)
                            .fontWeight(.bold)
                    }

                    Text("Your path, goals, and achievements are yours alone. Share only what you choose. Let your success speak for itself.")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondaryText)
                }
                .padding(.vertical, 8)
            }

            // Master Privacy Toggle
            Section {
                Toggle(isOn: Binding(
                    get: { appSettings.isPrivateMode },
                    set: { appSettings.isPrivateMode = $0 }
                )) {
                    Label {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Private Mode")
                                .font(.headline)
                            Text("Completely hide your activity from friends")
                                .font(.caption)
                                .foregroundStyle(Color.secondaryText)
                        }
                    } icon: {
                        Image(systemName: "eye.slash.fill")
                            .foregroundStyle(.green)
                    }
                }
                .tint(.green)
            } footer: {
                Text("When enabled, friends only see your name and that you're using LifeBlocks. No stats, no streaks, no details.")
            }

            // Granular Privacy Controls
            if !appSettings.isPrivateMode {
                Section("What Friends Can See") {
                    PrivacyToggle(
                        title: "Activity Status",
                        description: "Show that you checked in today (no details)",
                        icon: "circle.fill",
                        isOn: Binding(
                            get: { appSettings.shareActivityStatus },
                            set: { appSettings.shareActivityStatus = $0 }
                        )
                    )

                    PrivacyToggle(
                        title: "Current Streak",
                        description: "Your consecutive days",
                        icon: "flame.fill",
                        isOn: Binding(
                            get: { appSettings.shareStreak },
                            set: { appSettings.shareStreak = $0 }
                        )
                    )

                    PrivacyToggle(
                        title: "Longest Streak",
                        description: "Your personal best",
                        icon: "trophy.fill",
                        isOn: Binding(
                            get: { appSettings.shareLongestStreak },
                            set: { appSettings.shareLongestStreak = $0 }
                        )
                    )

                    PrivacyToggle(
                        title: "Weekly Score",
                        description: "Your activity this week",
                        icon: "chart.bar.fill",
                        isOn: Binding(
                            get: { appSettings.shareWeeklyScore },
                            set: { appSettings.shareWeeklyScore = $0 }
                        )
                    )
                }

                Section("Always Private") {
                    HStack {
                        Label {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Your Path & Goals")
                                Text("Never shared with friends")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondaryText)
                            }
                        } icon: {
                            Image(systemName: "arrow.triangle.branch")
                                .foregroundStyle(.green)
                        }
                        Spacer()
                        Image(systemName: "lock.fill")
                            .foregroundStyle(.green)
                    }

                    HStack {
                        Label {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Your Habits")
                                Text("Never shared with friends")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondaryText)
                            }
                        } icon: {
                            Image(systemName: "list.bullet")
                                .foregroundStyle(.green)
                        }
                        Spacer()
                        Image(systemName: "lock.fill")
                            .foregroundStyle(.green)
                    }

                    HStack {
                        Label {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Daily Notes")
                                Text("Never shared with friends")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondaryText)
                            }
                        } icon: {
                            Image(systemName: "note.text")
                                .foregroundStyle(.green)
                        }
                        Spacer()
                        Image(systemName: "lock.fill")
                            .foregroundStyle(.green)
                    }
                }

                Section("Social Features") {
                    PrivacyToggle(
                        title: "Appear on Leaderboards",
                        description: "Opt-in to friendly competition",
                        icon: "list.number",
                        isOn: Binding(
                            get: { appSettings.appearOnLeaderboards },
                            set: { appSettings.appearOnLeaderboards = $0 }
                        )
                    )

                    PrivacyToggle(
                        title: "Receive Cheers",
                        description: "Allow friends to send encouragement",
                        icon: "hand.thumbsup.fill",
                        isOn: Binding(
                            get: { appSettings.allowCheers },
                            set: { appSettings.allowCheers = $0 }
                        )
                    )

                    PrivacyToggle(
                        title: "Anonymous Mode",
                        description: "Hide your name, show as 'Anonymous'",
                        icon: "person.fill.questionmark",
                        isOn: Binding(
                            get: { appSettings.useAnonymousName },
                            set: { appSettings.useAnonymousName = $0 }
                        )
                    )
                }
            }

            // Preview Section
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("What Friends See")
                        .font(.headline)

                    HStack(spacing: 12) {
                        Text(appSettings.isPrivateMode ? "🔒" : appSettings.avatarEmoji)
                            .font(.system(size: 40))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(appSettings.publicDisplayName)
                                .font(.headline)

                            if appSettings.isPrivateMode {
                                Text("Private Mode")
                                    .font(.caption)
                                    .foregroundStyle(.green)
                            } else {
                                HStack(spacing: 12) {
                                    if appSettings.shareStreak {
                                        Label("\(appSettings.currentStreak)", systemImage: "flame.fill")
                                            .font(.caption)
                                            .foregroundStyle(.orange)
                                    }
                                    if appSettings.shareWeeklyScore {
                                        Label("\(appSettings.weeklyScore)", systemImage: "chart.bar.fill")
                                            .font(.caption)
                                            .foregroundStyle(.green)
                                    }
                                    if appSettings.shareActivityStatus {
                                        Image(systemName: "circle.fill")
                                            .font(.system(size: 8))
                                            .foregroundStyle(.green)
                                    }
                                }
                            }
                        }

                        Spacer()
                    }
                    .padding()
                    .background(Color.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.vertical, 8)
            } header: {
                Text("Preview")
            } footer: {
                Text("This is how you appear to friends based on your current privacy settings.")
            }
        }
        .navigationTitle("Privacy")
    }
}

struct PrivacyToggle: View {
    let title: String
    let description: String
    let icon: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Label {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                }
            } icon: {
                Image(systemName: icon)
                    .foregroundStyle(isOn ? .green : Color.secondaryText)
            }
        }
        .tint(.green)
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [UserSettings.self, Habit.self], inMemory: true)
        .preferredColorScheme(.dark)
}
