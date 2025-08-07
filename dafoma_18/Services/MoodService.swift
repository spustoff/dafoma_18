import Foundation
import CoreLocation
import Combine

class MoodService: ObservableObject {
    @Published var moodRecords: [MoodRecord] = []
    @Published var currentMood: Mood?
    @Published var moodHistory: [MoodRecord] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    func recordMood(_ mood: Mood, intensity: Double, at location: CLLocationCoordinate2D, notes: String = "", activities: [String] = []) {
        let record = MoodRecord(
            mood: mood,
            intensity: intensity,
            location: location,
            notes: notes,
            activities: activities
        )
        
        moodRecords.append(record)
        moodHistory.append(record)
        currentMood = mood
        
        // Keep only last 100 records for performance
        if moodRecords.count > 100 {
            moodRecords.removeFirst(moodRecords.count - 100)
        }
    }
    
    func getMoodRecordsNear(location: CLLocationCoordinate2D, radius: Double = 1000) -> [MoodRecord] {
        return moodRecords.filter { record in
            let distance = CLLocation(latitude: location.latitude, longitude: location.longitude)
                .distance(from: CLLocation(latitude: record.location.latitude, longitude: record.location.longitude))
            return distance <= radius
        }
    }
    
    func getMoodTrends(for period: TimeInterval = 7 * 24 * 60 * 60) -> [Mood: Int] {
        let cutoffDate = Date().addingTimeInterval(-period)
        let recentRecords = moodRecords.filter { $0.timestamp >= cutoffDate }
        
        var moodCounts: [Mood: Int] = [:]
        for record in recentRecords {
            moodCounts[record.mood, default: 0] += 1
        }
        
        return moodCounts
    }
    
    func getAverageMoodIntensity(for mood: Mood, in period: TimeInterval = 7 * 24 * 60 * 60) -> Double {
        let cutoffDate = Date().addingTimeInterval(-period)
        let moodRecords = self.moodRecords.filter { 
            $0.mood == mood && $0.timestamp >= cutoffDate 
        }
        
        guard !moodRecords.isEmpty else { return 0.0 }
        
        let totalIntensity = moodRecords.reduce(0.0) { $0 + $1.intensity }
        return totalIntensity / Double(moodRecords.count)
    }
    
    func getMoodHotspots() -> [(location: CLLocationCoordinate2D, mood: Mood, frequency: Int)] {
        var locationMoodCounts: [String: (location: CLLocationCoordinate2D, mood: Mood, count: Int)] = [:]
        
        for record in moodRecords {
            let key = "\(Int(record.location.latitude * 1000))_\(Int(record.location.longitude * 1000))_\(record.mood.rawValue)"
            
            if let existing = locationMoodCounts[key] {
                locationMoodCounts[key] = (existing.location, existing.mood, existing.count + 1)
            } else {
                locationMoodCounts[key] = (record.location, record.mood, 1)
            }
        }
        
        return locationMoodCounts.values
            .sorted { $0.count > $1.count }
            .prefix(20)
            .map { (location: $0.location, mood: $0.mood, frequency: $0.count) }
    }
    
    func suggestActivitiesForMood(_ mood: Mood, at location: CLLocationCoordinate2D) -> [String] {
        switch mood {
        case .happy, .excited:
            return ["Share with friends", "Dance to music", "Take photos", "Explore the area"]
        case .calm, .relaxed:
            return ["Meditation", "Read a book", "Listen to ambient music", "Gentle stretching"]
        case .focused:
            return ["Study session", "Creative work", "Goal planning", "Skill practice"]
        case .energetic:
            return ["Workout", "Running", "Sports", "Active exploration"]
        case .stressed:
            return ["Deep breathing", "Calming music", "Walk in nature", "Call a friend"]
        case .creative:
            return ["Art creation", "Writing", "Music composition", "Photography"]
        case .social:
            return ["Meet friends", "Join group activities", "Community events", "Collaborative projects"]
        case .adventurous:
            return ["Explore new places", "Try new activities", "Adventure sports", "Discovery walks"]
        case .contemplative:
            return ["Journaling", "Philosophy reading", "Nature observation", "Quiet reflection"]
        case .melancholic:
            return ["Gentle music", "Comfort activities", "Support group", "Self-care routine"]
        }
    }
    
    func getRecommendedMusicGenre(for mood: Mood) -> String {
        switch mood {
        case .happy, .excited:
            return "Pop, Upbeat"
        case .calm, .relaxed:
            return "Ambient, Classical"
        case .focused:
            return "Lo-fi, Instrumental"
        case .energetic:
            return "Electronic, Rock"
        case .stressed:
            return "Meditation, Nature sounds"
        case .creative:
            return "Jazz, Experimental"
        case .social:
            return "Dance, Party"
        case .adventurous:
            return "World, Folk"
        case .contemplative:
            return "Classical, Post-rock"
        case .melancholic:
            return "Blues, Indie"
        }
    }
}