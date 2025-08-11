import Foundation
import Combine
import CoreLocation

class PlaylistViewModel: ObservableObject {
    @Published var playlists: [Playlist] = []
    @Published var currentPlaylist: Playlist?
    @Published var isGeneratingPlaylist: Bool = false
    @Published var errorMessage: String?
    @Published var currentTrackIndex: Int = 0
    @Published var isPlaying: Bool = false
    
    private let musicService: MusicService
    private let locationService: LocationService
    private var cancellables = Set<AnyCancellable>()
    
    init(musicService: MusicService = MusicService(), locationService: LocationService = LocationService()) {
        self.musicService = musicService
        self.locationService = locationService
        setupBindings()
        loadSavedPlaylists()
    }
    
    private func setupBindings() {
        musicService.$currentPlaylist
            .receive(on: DispatchQueue.main)
            .assign(to: \.currentPlaylist, on: self)
            .store(in: &cancellables)
        
        musicService.$isPlaying
            .receive(on: DispatchQueue.main)
            .assign(to: \.isPlaying, on: self)
            .store(in: &cancellables)
    }
    
    func generateGeoTunedPlaylist(mood: String = "") {
        guard let location = locationService.getCurrentLocation() else {
            errorMessage = "Location not available. Please enable location services."
            return
        }
        
        isGeneratingPlaylist = true
        errorMessage = nil
        
        musicService.generateGeoTunedPlaylist(for: location, mood: mood) { [weak self] playlist in
            DispatchQueue.main.async {
                self?.isGeneratingPlaylist = false
                self?.currentPlaylist = playlist
                self?.addPlaylist(playlist)
            }
        }
    }
    
    func generateMoodBasedPlaylist(for mood: Mood) {
        isGeneratingPlaylist = true
        errorMessage = nil
        
        musicService.generateMoodBasedPlaylist(mood: mood) { [weak self] playlist in
            DispatchQueue.main.async {
                self?.isGeneratingPlaylist = false
                self?.currentPlaylist = playlist
                self?.addPlaylist(playlist)
            }
        }
    }
    
    func addPlaylist(_ playlist: Playlist) {
        // Check if playlist already exists
        if !playlists.contains(where: { $0.id == playlist.id }) {
            playlists.append(playlist)
            savePlaylists()
        }
    }
    
    func deletePlaylist(_ playlist: Playlist) {
        playlists.removeAll { $0.id == playlist.id }
        if currentPlaylist?.id == playlist.id {
            currentPlaylist = nil
        }
        savePlaylists()
    }
    
    func playTrack(_ track: Track) {
        guard let playlist = currentPlaylist else { return }
        if let index = playlist.tracks.firstIndex(where: { $0.id == track.id }) {
            currentTrackIndex = index
        }
        musicService.playTrack(track)
    }
    
    func pausePlayback() {
        musicService.pausePlayback()
    }
    
    func stopPlayback() {
        musicService.stopPlayback()
        currentTrackIndex = 0
    }
    
    func playNextTrack() {
        guard let playlist = currentPlaylist, !playlist.tracks.isEmpty else { return }
        
        currentTrackIndex = (currentTrackIndex + 1) % playlist.tracks.count
        let nextTrack = playlist.tracks[currentTrackIndex]
        musicService.playTrack(nextTrack)
    }
    
    func playPreviousTrack() {
        guard let playlist = currentPlaylist, !playlist.tracks.isEmpty else { return }
        
        currentTrackIndex = currentTrackIndex > 0 ? currentTrackIndex - 1 : playlist.tracks.count - 1
        let previousTrack = playlist.tracks[currentTrackIndex]
        musicService.playTrack(previousTrack)
    }
    
    func getPlaylistsForLocation(_ location: CLLocationCoordinate2D) -> [Playlist] {
        return playlists.filter { playlist in
            guard let playlistLocation = playlist.location else { return false }
            let distance = CLLocation(latitude: location.latitude, longitude: location.longitude)
                .distance(from: CLLocation(latitude: playlistLocation.latitude, longitude: playlistLocation.longitude))
            return distance <= 5000 // Within 5km
        }
    }
    
    func getPlaylistsForMood(_ mood: String) -> [Playlist] {
        return playlists.filter { $0.mood.lowercased() == mood.lowercased() }
    }
    
    private func savePlaylists() {
        do {
            let playlistData = try JSONEncoder().encode(playlists)
            UserDefaults.standard.set(playlistData, forKey: "LifeTunesPlaylists")
        } catch {
            print("Failed to save playlists: \(error)")
        }
    }
    
    private func loadSavedPlaylists() {
        if let playlistData = UserDefaults.standard.data(forKey: "LifeTunesPlaylists"),
           let decodedPlaylists = try? JSONDecoder().decode([Playlist].self, from: playlistData) {
            self.playlists = decodedPlaylists
        }
    }
}