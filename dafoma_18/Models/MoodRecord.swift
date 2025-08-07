import Foundation
import CoreLocation

struct MoodRecord: Codable, Identifiable {
    let id: UUID
    var mood: Mood
    var intensity: Double // 0.0 to 1.0
    var location: CLLocationCoordinate2D
    var timestamp: Date
    var notes: String
    var activities: [String]
    var weather: String?
    var musicGenre: String?
    
    init(mood: Mood, intensity: Double, location: CLLocationCoordinate2D, notes: String = "", activities: [String] = []) {
        self.id = UUID()
        self.mood = mood
        self.intensity = max(0.0, min(1.0, intensity))
        self.location = location
        self.timestamp = Date()
        self.notes = notes
        self.activities = activities
        self.weather = nil
        self.musicGenre = nil
    }
}

enum Mood: String, CaseIterable, Codable {
    case happy = "Happy"
    case excited = "Excited"
    case calm = "Calm"
    case focused = "Focused"
    case energetic = "Energetic"
    case relaxed = "Relaxed"
    case melancholic = "Melancholic"
    case stressed = "Stressed"
    case creative = "Creative"
    case social = "Social"
    case contemplative = "Contemplative"
    case adventurous = "Adventurous"
    
    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .excited: return "🤩"
        case .calm: return "😌"
        case .focused: return "🎯"
        case .energetic: return "⚡"
        case .relaxed: return "😴"
        case .melancholic: return "😔"
        case .stressed: return "😰"
        case .creative: return "🎨"
        case .social: return "👥"
        case .contemplative: return "🤔"
        case .adventurous: return "🌟"
        }
    }
    
    var color: String {
        switch self {
        case .happy: return "#FFD700"
        case .excited: return "#FF6B6B"
        case .calm: return "#74C0FC"
        case .focused: return "#8884FF"
        case .energetic: return "#FF8C42"
        case .relaxed: return "#95E1D3"
        case .melancholic: return "#A8DADC"
        case .stressed: return "#F72585"
        case .creative: return "#B794F6"
        case .social: return "#48CAE4"
        case .contemplative: return "#457B9D"
        case .adventurous: return "#F77F00"
        }
    }
}