import SwiftUI

struct HomeView: View {
    @State private var selectedTab = 0
    @StateObject private var userProfileViewModel = UserProfileViewModel()
    @StateObject private var playlistViewModel = PlaylistViewModel()
    @StateObject private var challengesViewModel = ChallengesViewModel()
    @StateObject private var newsFeedViewModel = NewsFeedViewModel()
    @StateObject private var moodMapViewModel = MoodMapViewModel()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Dashboard
            DashboardView(
                userProfileViewModel: userProfileViewModel,
                challengesViewModel: challengesViewModel,
                playlistViewModel: playlistViewModel
            )
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(0)
            
            // Playlists
            PlaylistView(viewModel: playlistViewModel)
                .tabItem {
                    Image(systemName: "music.note.list")
                    Text("Playlists")
                }
                .tag(1)
            
            // Challenges
            ChallengesView(viewModel: challengesViewModel)
                .tabItem {
                    Image(systemName: "target")
                    Text("Challenges")
                }
                .tag(2)
            
            // News Feed
            NewsFeedView(
                viewModel: newsFeedViewModel,
                userProfileViewModel: userProfileViewModel
            )
            .tabItem {
                Image(systemName: "newspaper.fill")
                Text("News")
            }
            .tag(3)
            
            // Mood Map
            MoodMapView(viewModel: moodMapViewModel)
                .tabItem {
                    Image(systemName: "face.smiling.fill")
                    Text("Mood")
                }
                .tag(4)
        }
        .accentColor(Color(red: 0.996, green: 0.157, blue: 0.29))
        .onAppear {
            setupTabBarAppearance()
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.11, green: 0.12, blue: 0.19, alpha: 1.0)
        
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.gray]
        
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(red: 0.996, green: 0.157, blue: 0.29, alpha: 1.0)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 0.996, green: 0.157, blue: 0.29, alpha: 1.0)]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Dashboard View

struct DashboardView: View {
    @ObservedObject var userProfileViewModel: UserProfileViewModel
    @ObservedObject var challengesViewModel: ChallengesViewModel
    @ObservedObject var playlistViewModel: PlaylistViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.11, green: 0.12, blue: 0.19)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        headerSection
                        
                        // Quick Stats
                        quickStatsSection
                        
                        // Today's Challenges
                        todaysChallengesSection
                        
                        // Recent Playlists
                        recentPlaylistsSection
                        
                        // Quick Actions
                        quickActionsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Welcome back,")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text(userProfileViewModel.user.name.isEmpty ? "Music Lover" : userProfileViewModel.user.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                NavigationLink(destination: SettingsView(userProfileViewModel: userProfileViewModel)) {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(22)
                        .contentShape(Circle()) // Ensure entire circle is tappable
                }
            }
            
            // Current streak
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("\(userProfileViewModel.user.currentStreak) day streak")
                    .font(.subheadline)
                    .foregroundColor(.white)
                Spacer()
            }
        }
    }
    
    private var quickStatsSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Quick Stats")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            
            HStack(spacing: 15) {
                StatCard(
                    title: "Challenges",
                    value: "\(challengesViewModel.completedChallenges.count)",
                    subtitle: "Completed",
                    icon: "target",
                    color: .blue
                )
                
                StatCard(
                    title: "Points",
                    value: "\(challengesViewModel.totalPoints)",
                    subtitle: "Total",
                    icon: "star.fill",
                    color: .yellow
                )
                
                StatCard(
                    title: "Playlists",
                    value: "\(playlistViewModel.playlists.count)",
                    subtitle: "Created",
                    icon: "music.note.list",
                    color: Color(red: 0.996, green: 0.157, blue: 0.29)
                )
            }
        }
    }
    
    private var todaysChallengesSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Today's Challenges")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
                
                Text("\(challengesViewModel.dailyChallenges.filter { $0.isCompleted }.count)/\(challengesViewModel.dailyChallenges.count) complete")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            if challengesViewModel.dailyChallenges.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "target")
                        .font(.title)
                        .foregroundColor(.gray)
                    Text("No challenges today")
                        .foregroundColor(.gray)
                }
                .frame(height: 100)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            } else {
                ForEach(Array(challengesViewModel.dailyChallenges.prefix(3)), id: \.id) { challenge in
                    ChallengeCard(challenge: challenge) {
                        challengesViewModel.startChallenge(challenge)
                    }
                }
            }
        }
    }
    
    private var recentPlaylistsSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Recent Playlists")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            
            if playlistViewModel.playlists.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "music.note.list")
                        .font(.title)
                        .foregroundColor(.gray)
                    Text("No playlists yet")
                        .foregroundColor(.gray)
                }
                .frame(height: 100)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(Array(playlistViewModel.playlists.prefix(5)), id: \.id) { playlist in
                            PlaylistCard(playlist: playlist) {
                                playlistViewModel.currentPlaylist = playlist
                            }
                        }
                    }
                    .padding(.horizontal, 5)
                }
            }
        }
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Quick Actions")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            
            HStack(spacing: 15) {
                QuickActionButton(
                    icon: "location.circle.fill",
                    title: "Geo Playlist",
                    subtitle: "Based on location"
                ) {
                    playlistViewModel.generateGeoTunedPlaylist()
                }
                
                QuickActionButton(
                    icon: "face.smiling.fill",
                    title: "Mood Map",
                    subtitle: "Record your mood"
                ) {
                    // This should work as a navigation, functionality is in MoodMapViewModel
                }
            }
        }
    }
}

// MARK: - Supporting Components

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ChallengeCard: View {
    let challenge: Challenge
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: categoryIcon(challenge.category))
                .font(.title2)
                .foregroundColor(Color(red: 0.996, green: 0.157, blue: 0.29))
                .frame(width: 40, height: 40)
                .background(Color(red: 0.996, green: 0.157, blue: 0.29).opacity(0.2))
                .cornerRadius(20)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(challenge.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(challenge.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                HStack {
                    Text(challenge.category.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    if challenge.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else {
                        Button("Start") {
                            action()
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .frame(minHeight: 44)
                        .background(Color(red: 0.996, green: 0.157, blue: 0.29))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .contentShape(Rectangle())
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func categoryIcon(_ category: ChallengeCategory) -> String {
        switch category {
        case .fitness: return "figure.run"
        case .mindfulness: return "leaf.fill"
        case .creativity: return "paintbrush.fill"
        case .social: return "person.3.fill"
        case .learning: return "book.fill"
        case .music: return "music.note"
        }
    }
}

struct PlaylistCard: View {
    let playlist: Playlist
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "music.note.list")
                        .font(.title2)
                        .foregroundColor(Color(red: 0.996, green: 0.157, blue: 0.29))
                    Spacer()
                    if playlist.isGeoTuned {
                        Image(systemName: "location.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(playlist.name)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text("\(playlist.tracks.count) tracks")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if !playlist.mood.isEmpty {
                        Text(playlist.mood)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
            }
            .frame(width: 150, height: 120)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(Color(red: 0.996, green: 0.157, blue: 0.29))
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 100) // Ensure minimum touch target
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .contentShape(Rectangle()) // Ensure entire area is tappable
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeView()
}