import Foundation

struct Challenge: Codable, Identifiable {
    let id: UUID
    var title: String
    var description: String
    var category: ChallengeCategory
    var difficulty: ChallengeDifficulty
    var duration: TimeInterval
    var requiredSteps: Int
    var currentProgress: Int
    var isCompleted: Bool
    var completedDate: Date?
    var motivationalTrack: Track?
    var rewards: [String]
    
    init(title: String, description: String, category: ChallengeCategory, difficulty: ChallengeDifficulty, duration: TimeInterval, requiredSteps: Int) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.category = category
        self.difficulty = difficulty
        self.duration = duration
        self.requiredSteps = requiredSteps
        self.currentProgress = 0
        self.isCompleted = false
        self.completedDate = nil
        self.motivationalTrack = nil
        self.rewards = []
    }
}

enum ChallengeCategory: String, CaseIterable, Codable {
    case fitness = "Fitness"
    case mindfulness = "Mindfulness"
    case creativity = "Creativity"
    case social = "Social"
    case learning = "Learning"
    case music = "Music"
}

enum ChallengeDifficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case expert = "Expert"
}