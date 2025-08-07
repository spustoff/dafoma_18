import Foundation

struct NewsArticle: Codable, Identifiable {
    let id: UUID
    var title: String
    var summary: String
    var content: String
    var category: NewsCategory
    var author: String
    var publishedDate: Date
    var imageURL: String?
    var sourceURL: String
    var isBookmarked: Bool
    var readingTime: Int // in minutes
    var tags: [String]
    
    init(title: String, summary: String, content: String, category: NewsCategory, author: String, sourceURL: String) {
        self.id = UUID()
        self.title = title
        self.summary = summary
        self.content = content
        self.category = category
        self.author = author
        self.publishedDate = Date()
        self.imageURL = nil
        self.sourceURL = sourceURL
        self.isBookmarked = false
        self.readingTime = max(1, content.count / 250) // Approximate reading time
        self.tags = []
    }
}

enum NewsCategory: String, CaseIterable, Codable {
    case lifestyle = "Lifestyle"
    case music = "Music"
    case health = "Health"
    case technology = "Technology"
    case entertainment = "Entertainment"
    case travel = "Travel"
    case fitness = "Fitness"
    case mindfulness = "Mindfulness"
}