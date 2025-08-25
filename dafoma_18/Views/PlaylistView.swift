import SwiftUI
import MapKit

struct PlaylistView: View {
    @ObservedObject var viewModel: PlaylistViewModel
    @State private var showingCreatePlaylist = false
    @State private var selectedMood = ""
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.11, green: 0.12, blue: 0.19)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with create button
                    headerSection
                    
                    // Current playing section
                    if let currentPlaylist = viewModel.currentPlaylist {
                        currentPlayingSection(playlist: currentPlaylist)
                    }
                    
                    // Playlists list
                    playlistsSection
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingCreatePlaylist) {
                CreatePlaylistSheet(viewModel: viewModel, selectedMood: $selectedMood)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Playlists")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    showingCreatePlaylist = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color(red: 0.996, green: 0.157, blue: 0.29))
                }
            }
            
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search playlists...", text: $searchText)
                    .foregroundColor(.white)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
            
            // Quick actions
            quickActionsSection
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private var quickActionsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                QuickCreateButton(
                    icon: "location.circle.fill",
                    title: "Geo-Tuned",
                    color: .blue,
                    isLoading: viewModel.isGeneratingPlaylist
                ) {
                    viewModel.generateGeoTunedPlaylist()
                }
                
                QuickCreateButton(
                    icon: "face.smiling.fill",
                    title: "Happy",
                    color: .yellow,
                    isLoading: false
                ) {
                    viewModel.generateMoodBasedPlaylist(for: .happy)
                }
                
                QuickCreateButton(
                    icon: "leaf.fill",
                    title: "Calm",
                    color: .green,
                    isLoading: false
                ) {
                    viewModel.generateMoodBasedPlaylist(for: .calm)
                }
                
                QuickCreateButton(
                    icon: "bolt.fill",
                    title: "Energetic",
                    color: .orange,
                    isLoading: false
                ) {
                    viewModel.generateMoodBasedPlaylist(for: .energetic)
                }
                
                QuickCreateButton(
                    icon: "paintbrush.fill",
                    title: "Creative",
                    color: .purple,
                    isLoading: false
                ) {
                    viewModel.generateMoodBasedPlaylist(for: .creative)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func currentPlayingSection(playlist: Playlist) -> some View {
        VStack(spacing: 15) {
            HStack {
                Text("Now Playing")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            
            CurrentPlaylistCard(playlist: playlist, viewModel: viewModel)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
    }
    
    private var playlistsSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Your Playlists")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(filteredPlaylists.count) playlists")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            
            if filteredPlaylists.isEmpty {
                emptyPlaylistsView
            } else {
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(filteredPlaylists, id: \.id) { playlist in
                            PlaylistRowCard(playlist: playlist, viewModel: viewModel)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
    }
    
    private var emptyPlaylistsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "music.note.list")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No playlists yet")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Create your first playlist using the buttons above")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button("Create Geo-Tuned Playlist") {
                viewModel.generateGeoTunedPlaylist()
            }
            .buttonStyle(PrimaryButtonStyle())
            .frame(maxWidth: 200)
        }
        .frame(maxHeight: .infinity)
        .padding(.horizontal, 40)
    }
    
    private var filteredPlaylists: [Playlist] {
        if searchText.isEmpty {
            return viewModel.playlists
        } else {
            return viewModel.playlists.filter { playlist in
                playlist.name.localizedCaseInsensitiveContains(searchText) ||
                playlist.mood.localizedCaseInsensitiveContains(searchText) ||
                playlist.genre.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

// MARK: - Supporting Views

struct QuickCreateButton: View {
    let icon: String
    let title: String
    let color: Color
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            print("QuickCreateButton tapped: \(title)")
            action()
        }) {
            VStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .frame(width: 80, height: 70)
            .frame(minWidth: 80, minHeight: 70) // Ensure minimum touch target
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
        }
        .disabled(isLoading)
        .buttonStyle(StartButtonStyle())
    }
}

struct CurrentPlaylistCard: View {
    let playlist: Playlist
    @ObservedObject var viewModel: PlaylistViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            HStack(spacing: 15) {
                // Playlist artwork placeholder
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.996, green: 0.157, blue: 0.29),
                            Color(red: 0.8, green: 0.1, blue: 0.2)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "music.note")
                            .font(.title)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(playlist.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("\(playlist.tracks.count) tracks")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 8) {
                        if playlist.isGeoTuned {
                            Label("Geo-Tuned", systemImage: "location.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        
                        if !playlist.mood.isEmpty {
                            Text(playlist.mood)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.2))
                                .foregroundColor(.orange)
                                .cornerRadius(8)
                        }
                    }
                }
                
                Spacer()
            }
            
            // Playback controls
            HStack(spacing: 30) {
                Button(action: {
                    print("Previous track button tapped")
                    viewModel.playPreviousTrack()
                }) {
                    Image(systemName: "backward.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(StartButtonStyle())
                
                Button(action: {
                    print("Play/Pause button tapped - isPlaying: \(viewModel.isPlaying)")
                    if viewModel.isPlaying {
                        viewModel.pausePlayback()
                    } else if let track = playlist.tracks.first {
                        viewModel.playTrack(track)
                    }
                }) {
                    Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Color(red: 0.996, green: 0.157, blue: 0.29))
                        .frame(width: 60, height: 60)
                        .contentShape(Circle())
                }
                .buttonStyle(StartButtonStyle())
                
                Button(action: {
                    print("Next track button tapped")
                    viewModel.playNextTrack()
                }) {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(StartButtonStyle())
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}

struct PlaylistRowCard: View {
    let playlist: Playlist
    @ObservedObject var viewModel: PlaylistViewModel
    @State private var showingDeleteAlert = false
    
    var body: some View {
        HStack(spacing: 15) {
            // Playlist artwork
            RoundedRectangle(cornerRadius: 8)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.996, green: 0.157, blue: 0.29).opacity(0.8),
                        Color(red: 0.8, green: 0.1, blue: 0.2).opacity(0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "music.note.list")
                        .font(.title3)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 5) {
                Text(playlist.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text("\(playlist.tracks.count) tracks • \(playlist.genre)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack(spacing: 8) {
                    if playlist.isGeoTuned {
                        Image(systemName: "location.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    if !playlist.mood.isEmpty {
                        Text(playlist.mood)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(4)
                    }
                    
                    Spacer()
                    
                    Text(DateFormatter.shortDate.string(from: playlist.createdDate))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 10) {
                Button(action: {
                    print("Playlist play button tapped: \(playlist.name)")
                    viewModel.currentPlaylist = playlist
                    if let firstTrack = playlist.tracks.first {
                        viewModel.playTrack(firstTrack)
                    }
                }) {
                    Image(systemName: "play.circle")
                        .font(.title2)
                        .foregroundColor(Color(red: 0.996, green: 0.157, blue: 0.29))
                        .frame(width: 44, height: 44)
                        .contentShape(Circle())
                }
                .buttonStyle(StartButtonStyle())
                
                Menu {
                    Button("Delete", role: .destructive) {
                        showingDeleteAlert = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .frame(width: 44, height: 44)
                        .contentShape(Circle())
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .alert("Delete Playlist", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deletePlaylist(playlist)
            }
        } message: {
            Text("Are you sure you want to delete '\(playlist.name)'? This action cannot be undone.")
        }
    }
}

// MARK: - Create Playlist Sheet

struct CreatePlaylistSheet: View {
    @ObservedObject var viewModel: PlaylistViewModel
    @Binding var selectedMood: String
    @Environment(\.presentationMode) var presentationMode
    
    private let moods = ["Happy", "Calm", "Energetic", "Focused", "Relaxed", "Creative", "Excited", "Contemplative"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.11, green: 0.12, blue: 0.19)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Text("Create New Playlist")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 20) {
                        // Geo-tuned option
                        CreatePlaylistOption(
                            icon: "location.circle.fill",
                            title: "Geo-Tuned Playlist",
                            description: "Based on your current location",
                            color: .blue
                        ) {
                            viewModel.generateGeoTunedPlaylist(mood: selectedMood)
                            presentationMode.wrappedValue.dismiss()
                        }
                        
                        // Mood-based options
                        VStack(spacing: 15) {
                            Text("Select a Mood")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 15) {
                                ForEach(Mood.allCases, id: \.self) { mood in
                                    Button(action: {
                                        viewModel.generateMoodBasedPlaylist(for: mood)
                                        presentationMode.wrappedValue.dismiss()
                                    }) {
                                        VStack(spacing: 8) {
                                            Text(mood.emoji)
                                                .font(.title)
                                            Text(mood.rawValue)
                                                .font(.caption)
                                                .foregroundColor(.white)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(12)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color(red: 0.996, green: 0.157, blue: 0.29))
            )
        }
    }
}

struct CreatePlaylistOption: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 50, height: 50)
                    .background(color.opacity(0.2))
                    .cornerRadius(25)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Extensions

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}

#Preview {
    PlaylistView(viewModel: PlaylistViewModel())
}