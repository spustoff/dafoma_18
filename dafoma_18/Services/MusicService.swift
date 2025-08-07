import Foundation
import CoreLocation
import Combine

class MusicService: ObservableObject {
    @Published var currentPlaylist: Playlist?
    @Published var isPlaying: Bool = false
    @Published var currentTrack: Track?
    
    private var cancellables = Set<AnyCancellable>()
    
    // Sample tracks for demo purposes
    private let sampleTracks: [Track] = [
        Track(title: "Morning Energy", artist: "LifeTunes", duration: 210, genre: "Electronic", mood: "Energetic"),
        Track(title: "City Vibes", artist: "Urban Sounds", duration: 180, genre: "Hip Hop", mood: "Happy"),
        Track(title: "Peaceful Moments", artist: "Calm Collective", duration: 240, genre: "Ambient", mood: "Calm"),
        Track(title: "Workout Beast", artist: "Fitness Beats", duration: 195, genre: "Electronic", mood: "Energetic"),
        Track(title: "Study Focus", artist: "Concentration", duration: 300, genre: "Lo-fi", mood: "Focused"),
        Track(title: "Evening Chill", artist: "Relaxation", duration: 270, genre: "Jazz", mood: "Relaxed"),
        Track(title: "Adventure Time", artist: "Explorer", duration: 220, genre: "Rock", mood: "Adventurous"),
        Track(title: "Creative Flow", artist: "Inspiration", duration: 260, genre: "Instrumental", mood: "Creative")
    ]
    
    func generateGeoTunedPlaylist(for location: CLLocationCoordinate2D, mood: String = "", completion: @escaping (Playlist) -> Void) {
        // Simulate API call delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let filteredTracks = self.getTracksForLocation(location, mood: mood)
            let locationName = self.getLocationBasedName(for: location)
            
            let playlist = Playlist(
                name: "\(locationName) Mix",
                tracks: filteredTracks,
                location: location,
                mood: mood,
                genre: "Mixed",
                isGeoTuned: true
            )
            
            completion(playlist)
        }
    }
    
    func generateMoodBasedPlaylist(mood: Mood, completion: @escaping (Playlist) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let filteredTracks = self.sampleTracks.filter { track in
                track.mood.lowercased() == mood.rawValue.lowercased()
            }
            
            let playlist = Playlist(
                name: "\(mood.rawValue) Playlist",
                tracks: filteredTracks.isEmpty ? Array(self.sampleTracks.prefix(4)) : filteredTracks,
                mood: mood.rawValue,
                genre: "Mixed"
            )
            
            completion(playlist)
        }
    }
    
    func getRecommendedTracks(for challenge: Challenge, completion: @escaping ([Track]) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let categoryTracks = self.sampleTracks.filter { track in
                switch challenge.category {
                case .fitness:
                    return track.mood == "Energetic" || track.genre == "Electronic"
                case .mindfulness:
                    return track.mood == "Calm" || track.mood == "Relaxed"
                case .creativity:
                    return track.mood == "Creative" || track.genre == "Instrumental"
                case .learning:
                    return track.mood == "Focused" || track.genre == "Lo-fi"
                default:
                    return true
                }
            }
            
            completion(Array(categoryTracks.prefix(3)))
        }
    }
    
    func playTrack(_ track: Track) {
        currentTrack = track
        isPlaying = true
    }
    
    func pausePlayback() {
        isPlaying = false
    }
    
    func stopPlayback() {
        isPlaying = false
        currentTrack = nil
    }
    
    private func getTracksForLocation(_ location: CLLocationCoordinate2D, mood: String) -> [Track] {
        // Simulate location-based filtering
        var tracks = sampleTracks
        
        if !mood.isEmpty {
            tracks = tracks.filter { $0.mood.lowercased().contains(mood.lowercased()) }
        }
        
        return Array(tracks.shuffled().prefix(6))
    }
    
    private func getLocationBasedName(for location: CLLocationCoordinate2D) -> String {
        // Simplified location naming
        let names = ["Downtown", "Park", "Beach", "Cafe", "Gym", "Home", "Office", "City"]
        return names.randomElement() ?? "Local"
    }
}