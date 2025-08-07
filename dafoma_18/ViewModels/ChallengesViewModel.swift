import Foundation
import Combine

class ChallengesViewModel: ObservableObject {
    @Published var dailyChallenges: [Challenge] = []
    @Published var completedChallenges: [Challenge] = []
    @Published var currentChallenge: Challenge?
    @Published var totalPoints: Int = 0
    @Published var currentStreak: Int = 0
    
    private let musicService: MusicService
    private var cancellables = Set<AnyCancellable>()
    
    init(musicService: MusicService = MusicService()) {
        self.musicService = musicService
        loadChallenges()
        generateDailyChallenges()
    }
    
    func generateDailyChallenges() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastGenerationDate = UserDefaults.standard.object(forKey: "LastChallengeGeneration") as? Date
        
        // Only generate new challenges if it's a new day
        if lastGenerationDate == nil || !Calendar.current.isDate(lastGenerationDate!, inSameDayAs: today) {
            dailyChallenges = createDailyChallenges()
            UserDefaults.standard.set(today, forKey: "LastChallengeGeneration")
            saveChallenges()
        }
    }
    
    private func createDailyChallenges() -> [Challenge] {
        let sampleChallenges = [
            Challenge(title: "Morning Energy Boost", description: "Start your day with 10 minutes of energetic music and stretching", category: .fitness, difficulty: .easy, duration: 600, requiredSteps: 1),
            Challenge(title: "Mindful Listening", description: "Listen to a calming playlist for 15 minutes while focusing on your breath", category: .mindfulness, difficulty: .easy, duration: 900, requiredSteps: 1),
            Challenge(title: "Creative Expression", description: "Create something inspired by your current mood and location", category: .creativity, difficulty: .medium, duration: 1800, requiredSteps: 3),
            Challenge(title: "Social Harmony", description: "Share a meaningful song with a friend and discuss its impact", category: .social, difficulty: .medium, duration: 1200, requiredSteps: 2),
            Challenge(title: "Learn Something New", description: "Explore a new music genre and learn about its cultural background", category: .learning, difficulty: .hard, duration: 2700, requiredSteps: 4),
            Challenge(title: "Workout Rhythm", description: "Complete a 20-minute workout with your favorite high-energy playlist", category: .fitness, difficulty: .medium, duration: 1200, requiredSteps: 2),
            Challenge(title: "Musical Discovery", description: "Discover and save 5 new songs that match your current mood", category: .music, difficulty: .easy, duration: 900, requiredSteps: 5),
            Challenge(title: "Meditation Journey", description: "Complete a 25-minute meditation session with ambient background music", category: .mindfulness, difficulty: .hard, duration: 1500, requiredSteps: 1),
            Challenge(title: "Location Soundtrack", description: "Create a playlist that captures the essence of your current location", category: .creativity, difficulty: .medium, duration: 1800, requiredSteps: 6),
            Challenge(title: "Skill Practice", description: "Practice a musical instrument or singing for 30 minutes", category: .learning, difficulty: .hard, duration: 1800, requiredSteps: 1)
        ]
        
        return Array(sampleChallenges.shuffled().prefix(3))
    }
    
    func startChallenge(_ challenge: Challenge) {
        var updatedChallenge = challenge
        updatedChallenge.currentProgress = 0
        currentChallenge = updatedChallenge
        
        // Get recommended music for the challenge
        musicService.getRecommendedTracks(for: challenge) { tracks in
            if let track = tracks.first {
                updatedChallenge.motivationalTrack = track
            }
        }
        
        if let index = dailyChallenges.firstIndex(where: { $0.id == challenge.id }) {
            dailyChallenges[index] = updatedChallenge
        }
    }
    
    func updateChallengeProgress(_ challenge: Challenge, progress: Int) {
        var updatedChallenge = challenge
        updatedChallenge.currentProgress = min(progress, challenge.requiredSteps)
        
        if updatedChallenge.currentProgress >= challenge.requiredSteps {
            completeChallenge(updatedChallenge)
        }
        
        if let index = dailyChallenges.firstIndex(where: { $0.id == challenge.id }) {
            dailyChallenges[index] = updatedChallenge
        }
        
        if currentChallenge?.id == challenge.id {
            currentChallenge = updatedChallenge
        }
        
        saveChallenges()
    }
    
    func completeChallenge(_ challenge: Challenge) {
        var completedChallenge = challenge
        completedChallenge.isCompleted = true
        completedChallenge.completedDate = Date()
        completedChallenge.currentProgress = challenge.requiredSteps
        
        // Add to completed challenges
        completedChallenges.append(completedChallenge)
        
        // Update points based on difficulty
        let points = pointsForDifficulty(challenge.difficulty)
        totalPoints += points
        
        // Update current challenge if it matches
        if currentChallenge?.id == challenge.id {
            currentChallenge = nil
        }
        
        // Update daily challenges
        if let index = dailyChallenges.firstIndex(where: { $0.id == challenge.id }) {
            dailyChallenges[index] = completedChallenge
        }
        
        // Check if all daily challenges are completed
        let allCompleted = dailyChallenges.allSatisfy { $0.isCompleted }
        if allCompleted {
            currentStreak += 1
        }
        
        saveChallenges()
    }
    
    private func pointsForDifficulty(_ difficulty: ChallengeDifficulty) -> Int {
        switch difficulty {
        case .easy: return 10
        case .medium: return 25
        case .hard: return 50
        case .expert: return 100
        }
    }
    
    func getTodaysProgress() -> Double {
        let completedToday = dailyChallenges.filter { $0.isCompleted }.count
        return dailyChallenges.isEmpty ? 0.0 : Double(completedToday) / Double(dailyChallenges.count)
    }
    
    func getCompletedChallengesThisWeek() -> [Challenge] {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return completedChallenges.filter { challenge in
            guard let completedDate = challenge.completedDate else { return false }
            return completedDate >= weekAgo
        }
    }
    
    private func saveChallenges() {
        do {
            let dailyData = try JSONEncoder().encode(dailyChallenges)
            let completedData = try JSONEncoder().encode(completedChallenges)
            
            UserDefaults.standard.set(dailyData, forKey: "LifeTunesDailyChallenges")
            UserDefaults.standard.set(completedData, forKey: "LifeTunesCompletedChallenges")
            UserDefaults.standard.set(totalPoints, forKey: "LifeTunesTotalPoints")
            UserDefaults.standard.set(currentStreak, forKey: "LifeTunesCurrentStreak")
        } catch {
            print("Failed to save challenges: \(error)")
        }
    }
    
    private func loadChallenges() {
        if let dailyData = UserDefaults.standard.data(forKey: "LifeTunesDailyChallenges"),
           let decodedDaily = try? JSONDecoder().decode([Challenge].self, from: dailyData) {
            self.dailyChallenges = decodedDaily
        }
        
        if let completedData = UserDefaults.standard.data(forKey: "LifeTunesCompletedChallenges"),
           let decodedCompleted = try? JSONDecoder().decode([Challenge].self, from: completedData) {
            self.completedChallenges = decodedCompleted
        }
        
        self.totalPoints = UserDefaults.standard.integer(forKey: "LifeTunesTotalPoints")
        self.currentStreak = UserDefaults.standard.integer(forKey: "LifeTunesCurrentStreak")
    }
}