import SwiftUI

struct SettingsView: View {
    @ObservedObject var userProfileViewModel: UserProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingDeleteAlert = false
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.11, green: 0.12, blue: 0.19)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Profile section
                        profileSection
                        
                        // Preferences sections
                        musicPreferencesSection
                        lifestyleGoalsSection
                        newsInterestsSection
                        
                        // App settings
                        appSettingsSection
                        
                        // Data management
                        dataManagementSection
                        
                        // About section
                        aboutSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color(red: 0.996, green: 0.157, blue: 0.29))
            )
            .alert("Reset Data", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetAppData()
                }
            } message: {
                Text("This will reset all your data including playlists, challenges, and mood records. This action cannot be undone.")
            }
            .alert("Delete Account", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteAccount()
                }
            } message: {
                Text("This will permanently delete your account and all associated data. This action cannot be undone.")
            }
        }
    }
    
    private var profileSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Profile")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(spacing: 15) {
                // Profile info
                HStack(spacing: 15) {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.996, green: 0.157, blue: 0.29),
                                Color(red: 0.8, green: 0.1, blue: 0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Text(String(userProfileViewModel.user.name.prefix(1)).uppercased())
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        )
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(userProfileViewModel.user.name.isEmpty ? "Music Lover" : userProfileViewModel.user.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("Member since \(DateFormatter.shortDate.string(from: userProfileViewModel.user.joinedDate))")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        HStack {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                            Text("\(userProfileViewModel.user.currentStreak) day streak")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Daily goal
                HStack {
                    Text("Daily Challenge Goal")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Stepper(value: Binding(
                        get: { userProfileViewModel.user.dailyGoal },
                        set: { userProfileViewModel.updateDailyGoal($0) }
                    ), in: 1...10) {
                        Text("\(userProfileViewModel.user.dailyGoal) challenges")
                            .font(.subheadline)
                            .foregroundColor(Color(red: 0.996, green: 0.157, blue: 0.29))
                    }
                    .accentColor(Color(red: 0.996, green: 0.157, blue: 0.29))
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
    
    private var musicPreferencesSection: some View {
        PreferenceSection(
            title: "Music Preferences",
            items: userProfileViewModel.user.musicPreferences,
            placeholder: "No music preferences set"
        )
    }
    
    private var lifestyleGoalsSection: some View {
        PreferenceSection(
            title: "Lifestyle Goals",
            items: userProfileViewModel.user.lifestyleGoals,
            placeholder: "No lifestyle goals set"
        )
    }
    
    private var newsInterestsSection: some View {
        PreferenceSection(
            title: "News Interests",
            items: userProfileViewModel.user.newsInterests,
            placeholder: "No news interests set"
        )
    }
    
    private var appSettingsSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("App Settings")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "location.fill",
                    title: "Location Services",
                    subtitle: userProfileViewModel.hasLocationPermission ? "Enabled" : "Disabled",
                    showChevron: true
                ) {
                    if !userProfileViewModel.hasLocationPermission {
                        userProfileViewModel.requestLocationPermission()
                    }
                }
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                SettingsRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    subtitle: userProfileViewModel.hasNotificationPermission ? "Enabled" : "Disabled",
                    showChevron: true
                ) {
                    if !userProfileViewModel.hasNotificationPermission {
                        userProfileViewModel.requestNotificationPermission()
                    }
                }
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    private var dataManagementSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Data Management")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "arrow.clockwise",
                    title: "Reset App Data",
                    subtitle: "Clear all data and start fresh",
                    showChevron: true
                ) {
                    showingResetAlert = true
                }
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                SettingsRow(
                    icon: "trash.fill",
                    title: "Delete Account",
                    subtitle: "Permanently delete your account",
                    showChevron: true,
                    isDestructive: true
                ) {
                    showingDeleteAlert = true
                }
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    private var aboutSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("About")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "info.circle.fill",
                    title: "Version",
                    subtitle: "1.0.0",
                    showChevron: false
                ) { }
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                SettingsRow(
                    icon: "heart.fill",
                    title: "Made with ❤️",
                    subtitle: "LifeTunes Vada",
                    showChevron: false
                ) { }
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    private func resetAppData() {
        // Clear UserDefaults
        let defaults = UserDefaults.standard
        let keys = [
            "LifeTunesUser",
            "LifeTunesOnboardingCompleted",
            "LifeTunesPlaylists",
            "LifeTunesDailyChallenges",
            "LifeTunesCompletedChallenges",
            "LifeTunesTotalPoints",
            "LifeTunesCurrentStreak",
            "LifeTunesBookmarkedArticles",
            "LifeTunesReadArticles",
            "LastChallengeGeneration"
        ]
        
        for key in keys {
            defaults.removeObject(forKey: key)
        }
        
        // Reset user profile
        userProfileViewModel.user = User()
        userProfileViewModel.isOnboardingCompleted = false
        
        presentationMode.wrappedValue.dismiss()
    }
    
    private func deleteAccount() {
        resetAppData()
        // In a real app, this would also delete data from the backend
    }
}

// MARK: - Supporting Views

struct PreferenceSection: View {
    let title: String
    let items: [String]
    let placeholder: String
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            
            if items.isEmpty {
                Text(placeholder)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 10) {
                    ForEach(items, id: \.self) { item in
                        Text(item)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(red: 0.996, green: 0.157, blue: 0.29).opacity(0.2))
                            .foregroundColor(Color(red: 0.996, green: 0.157, blue: 0.29))
                            .cornerRadius(20)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let showChevron: Bool
    let isDestructive: Bool
    let action: () -> Void
    
    init(icon: String, title: String, subtitle: String, showChevron: Bool, isDestructive: Bool = false, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.showChevron = showChevron
        self.isDestructive = isDestructive
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isDestructive ? .red : Color(red: 0.996, green: 0.157, blue: 0.29))
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(isDestructive ? .red : .white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsView(userProfileViewModel: UserProfileViewModel())
}