import Foundation
import CoreLocation

struct Playlist: Codable, Identifiable {
    let id: UUID
    var name: String
    var tracks: [Track]
    var location: CLLocationCoordinate2D?
    var mood: String
    var genre: String
    var createdDate: Date
    var isGeoTuned: Bool
    
    init(name: String, tracks: [Track] = [], location: CLLocationCoordinate2D? = nil, mood: String = "", genre: String = "", isGeoTuned: Bool = false) {
        self.id = UUID()
        self.name = name
        self.tracks = tracks
        self.location = location
        self.mood = mood
        self.genre = genre
        self.createdDate = Date()
        self.isGeoTuned = isGeoTuned
    }
}

struct Track: Codable, Identifiable {
    let id: UUID
    var title: String
    var artist: String
    var duration: TimeInterval
    var genre: String
    var mood: String
    var isLocal: Bool
    
    init(title: String, artist: String, duration: TimeInterval, genre: String = "", mood: String = "", isLocal: Bool = false) {
        self.id = UUID()
        self.title = title
        self.artist = artist
        self.duration = duration
        self.genre = genre
        self.mood = mood
        self.isLocal = isLocal
    }
}