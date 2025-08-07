import Foundation
import CoreLocation

struct User: Codable, Identifiable {
    let id: UUID
    var name: String
    var musicPreferences: [String]
    var lifestyleGoals: [String]
    var newsInterests: [String]
    var location: CLLocationCoordinate2D?
    var dailyGoal: Int
    var currentStreak: Int
    var joinedDate: Date
    
    init(name: String = "", musicPreferences: [String] = [], lifestyleGoals: [String] = [], newsInterests: [String] = []) {
        self.id = UUID()
        self.name = name
        self.musicPreferences = musicPreferences
        self.lifestyleGoals = lifestyleGoals
        self.newsInterests = newsInterests
        self.location = nil
        self.dailyGoal = 3
        self.currentStreak = 0
        self.joinedDate = Date()
    }
}

extension CLLocationCoordinate2D: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
    
    private enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
}