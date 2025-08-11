import SwiftUI

struct OnboardingView: View {
    @StateObject private var userProfileViewModel = UserProfileViewModel()
    @State private var currentStep = 0
    @State private var name = ""
    @State private var selectedMusicPreferences: Set<String> = []
    @State private var selectedLifestyleGoals: Set<String> = []
    @State private var selectedNewsInterests: Set<String> = []
    
    private let musicPreferences = ["Pop", "Rock", "Hip Hop", "Electronic", "Classical", "Jazz", "R&B", "Country", "Indie", "Ambient", "Lo-fi", "Instrumental"]
    private let lifestyleGoals = ["Fitness", "Mindfulness", "Creativity", "Social Connection", "Learning", "Adventure", "Relaxation", "Productivity", "Health", "Travel"]
    private let newsInterests = ["Lifestyle", "Music", "Health", "Technology", "Entertainment", "Travel", "Fitness", "Mindfulness"]
    
    var body: some View {
        ZStack {
            // Dark background
            Color(red: 0.11, green: 0.12, blue: 0.19)
                .ignoresSafeArea()
            
            if userProfileViewModel.isOnboardingCompleted {
                HomeView()
            } else {
                VStack {
                    switch currentStep {
                    case 0:
                        welcomeStep
                    case 1:
                        nameStep
                    case 2:
                        musicPreferencesStep
                    case 3:
                        lifestyleGoalsStep
                    case 4:
                        newsInterestsStep
                    case 5:
                        permissionsStep
                    default:
                        completionStep
                    }
                }
                .animation(.easeInOut(duration: 0.5), value: currentStep)
            }
        }
    }
    
    // MARK: - Welcome Step
    private var welcomeStep: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // App Logo/Icon with animation
            VStack(spacing: 20) {
                Image(systemName: "music.note.list")
                    .font(.system(size: 80))
                    .foregroundColor(Color(red: 0.996, green: 0.157, blue: 0.29))
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: currentStep)
                
                Text("LifeTunes Vada")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Enhance your everyday life through music-integrated experiences")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
            
            Spacer()
            
            VStack(spacing: 20) {
                FeatureRow(icon: "location.circle.fill", title: "Geo-Tuned Playlists", description: "Music that matches your location")
                FeatureRow(icon: "target", title: "Daily Challenges", description: "Lifestyle goals with motivational music")
                FeatureRow(icon: "newspaper.fill", title: "Personalized News", description: "Curated content for your interests")
                FeatureRow(icon: "face.smiling.fill", title: "Mood Mapping", description: "Track emotions across your city")
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            Button("Get Started") {
                currentStep += 1
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
    }
    
    // MARK: - Name Step
    private var nameStep: some View {
        VStack(spacing: 40) {
            ProgressBar(current: 1, total: 6)
            
            Spacer()
            
            VStack(spacing: 20) {
                Text("What's your name?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("We'll use this to personalize your experience")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
            
            Spacer()
            
            TextField("Enter your name", text: $name)
                .font(.title2)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
            
            Spacer()
            
            HStack(spacing: 20) {
                Button("Back") {
                    currentStep -= 1
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button("Next") {
                    currentStep += 1
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
    }
    
    // MARK: - Music Preferences Step
    private var musicPreferencesStep: some View {
        VStack(spacing: 30) {
            ProgressBar(current: 2, total: 6)
            
            VStack(spacing: 15) {
                Text("Music Preferences")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Select genres you enjoy")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 15) {
                    ForEach(musicPreferences, id: \.self) { preference in
                        SelectableChip(
                            text: preference,
                            isSelected: selectedMusicPreferences.contains(preference)
                        ) {
                            if selectedMusicPreferences.contains(preference) {
                                selectedMusicPreferences.remove(preference)
                            } else {
                                selectedMusicPreferences.insert(preference)
                            }
                        }
                    }
                }
                .padding(.horizontal, 30)
            }
            
            HStack(spacing: 20) {
                Button("Back") {
                    currentStep -= 1
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button("Next") {
                    currentStep += 1
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(selectedMusicPreferences.isEmpty)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
    }
    
    // MARK: - Lifestyle Goals Step
    private var lifestyleGoalsStep: some View {
        VStack(spacing: 30) {
            ProgressBar(current: 3, total: 6)
            
            VStack(spacing: 15) {
                Text("Lifestyle Goals")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("What areas would you like to focus on?")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 15) {
                    ForEach(lifestyleGoals, id: \.self) { goal in
                        SelectableChip(
                            text: goal,
                            isSelected: selectedLifestyleGoals.contains(goal)
                        ) {
                            if selectedLifestyleGoals.contains(goal) {
                                selectedLifestyleGoals.remove(goal)
                            } else {
                                selectedLifestyleGoals.insert(goal)
                            }
                        }
                    }
                }
                .padding(.horizontal, 30)
            }
            
            HStack(spacing: 20) {
                Button("Back") {
                    currentStep -= 1
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button("Next") {
                    currentStep += 1
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(selectedLifestyleGoals.isEmpty)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
    }
    
    // MARK: - News Interests Step
    private var newsInterestsStep: some View {
        VStack(spacing: 30) {
            ProgressBar(current: 4, total: 6)
            
            VStack(spacing: 15) {
                Text("News Interests")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Choose topics for your personalized feed")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 15) {
                    ForEach(newsInterests, id: \.self) { interest in
                        SelectableChip(
                            text: interest,
                            isSelected: selectedNewsInterests.contains(interest)
                        ) {
                            if selectedNewsInterests.contains(interest) {
                                selectedNewsInterests.remove(interest)
                            } else {
                                selectedNewsInterests.insert(interest)
                            }
                        }
                    }
                }
                .padding(.horizontal, 30)
            }
            
            HStack(spacing: 20) {
                Button("Back") {
                    currentStep -= 1
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button("Next") {
                    currentStep += 1
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(selectedNewsInterests.isEmpty)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
    }
    
    // MARK: - Permissions Step
    private var permissionsStep: some View {
        VStack(spacing: 40) {
            ProgressBar(current: 5, total: 6)
            
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(red: 0.996, green: 0.157, blue: 0.29))
                
                Text("Enable Permissions")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("We need location access to provide geo-tuned playlists and mood mapping")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
            
            Spacer()
            
            VStack(spacing: 20) {
                PermissionRow(
                    icon: "location.fill",
                    title: "Location Access",
                    description: "For geo-tuned playlists and mood mapping",
                    isGranted: userProfileViewModel.hasLocationPermission
                ) {
                    userProfileViewModel.requestLocationPermission()
                }
                
                PermissionRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    description: "For daily challenge reminders",
                    isGranted: userProfileViewModel.hasNotificationPermission
                ) {
                    userProfileViewModel.requestNotificationPermission()
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            HStack(spacing: 20) {
                Button("Back") {
                    currentStep -= 1
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button("Continue") {
                    currentStep += 1
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
    }
    
    // MARK: - Completion Step
    private var completionStep: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                Text("Welcome to LifeTunes!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("You're all set to start your musical lifestyle journey")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
            
            Spacer()
            
            Button("Start Exploring") {
                userProfileViewModel.updateUser(
                    name: name,
                    musicPreferences: Array(selectedMusicPreferences),
                    lifestyleGoals: Array(selectedLifestyleGoals),
                    newsInterests: Array(selectedNewsInterests)
                )
                userProfileViewModel.completeOnboarding()
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
    }
}

// MARK: - Supporting Views

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color(red: 0.996, green: 0.157, blue: 0.29))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
}

struct ProgressBar: View {
    let current: Int
    let total: Int
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Step \(current) of \(total)")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(Color(red: 0.996, green: 0.157, blue: 0.29))
                        .frame(width: geometry.size.width * CGFloat(current) / CGFloat(total), height: 4)
                        .cornerRadius(2)
                        .animation(.easeInOut, value: current)
                }
            }
            .frame(height: 4)
        }
        .padding(.horizontal, 30)
    }
}

struct SelectableChip: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.headline)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .frame(minHeight: 44) // Ensure minimum touch target
                .background(
                    isSelected ? Color(red: 0.996, green: 0.157, blue: 0.29) : Color.gray.opacity(0.2)
                )
                .foregroundColor(isSelected ? .white : .gray)
                .cornerRadius(20)
                .contentShape(Rectangle()) // Ensure entire area is tappable
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    let isGranted: Bool
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isGranted ? .green : Color(red: 0.996, green: 0.157, blue: 0.29))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if !isGranted {
                Button("Continue") {
                    action()
                }
                .buttonStyle(SecondaryButtonStyle())
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// Button styles are now in SharedButtonStyles.swift

#Preview {
    OnboardingView()
}