import Foundation
import Combine
import CoreLocation

class NewsService: ObservableObject {
    @Published var articles: [NewsArticle] = []
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    // Sample articles for demo purposes
    private let sampleArticles: [NewsArticle] = [
        NewsArticle(
            title: "The Science of Music and Productivity",
            summary: "Research shows how different genres can boost focus and creativity.",
            content: "Studies have revealed that instrumental music, particularly classical and ambient genres, can significantly enhance cognitive performance and focus. The key is finding the right tempo and complexity that matches your task.",
            category: .music,
            author: "Dr. Sarah Mitchell",
            sourceURL: "https://example.com/music-productivity"
        ),
        NewsArticle(
            title: "5 Daily Habits That Transform Your Lifestyle",
            summary: "Simple changes that can lead to dramatic improvements in well-being.",
            content: "Small, consistent habits can create powerful transformations. From morning meditation to evening gratitude practices, these five habits can reshape your daily experience and long-term happiness.",
            category: .lifestyle,
            author: "Michael Chen",
            sourceURL: "https://example.com/daily-habits"
        ),
        NewsArticle(
            title: "Mindful Walking: A New Approach to Urban Exploration",
            summary: "How to turn your daily walk into a mindfulness practice.",
            content: "Mindful walking combines physical exercise with mental wellness. By paying attention to your surroundings, breathing, and body sensations, you can transform routine walks into powerful mindfulness sessions.",
            category: .mindfulness,
            author: "Emma Rodriguez",
            sourceURL: "https://example.com/mindful-walking"
        ),
        NewsArticle(
            title: "The Rise of Location-Based Wellness Apps",
            summary: "Technology meets geography in the latest health trend.",
            content: "Location-aware wellness applications are revolutionizing how we approach health and fitness. By leveraging GPS and local data, these apps provide personalized recommendations based on your environment.",
            category: .technology,
            author: "Alex Thompson",
            sourceURL: "https://example.com/location-wellness"
        ),
        NewsArticle(
            title: "Music Therapy in Modern Healthcare",
            summary: "How hospitals are using music to improve patient outcomes.",
            content: "Music therapy has shown remarkable results in reducing anxiety, managing pain, and accelerating recovery. Many healthcare facilities are now integrating music programs into their treatment protocols.",
            category: .health,
            author: "Dr. Jennifer Park",
            sourceURL: "https://example.com/music-therapy"
        ),
        NewsArticle(
            title: "Building Sustainable Fitness Habits",
            summary: "Expert tips for creating workout routines that last.",
            content: "The key to sustainable fitness isn't intensity—it's consistency. Fitness experts share strategies for building exercise habits that fit seamlessly into your lifestyle and provide long-term benefits.",
            category: .fitness,
            author: "Coach Maria Santos",
            sourceURL: "https://example.com/sustainable-fitness"
        )
    ]
    
    func fetchPersonalizedNews(for user: User, location: CLLocationCoordinate2D? = nil) {
        isLoading = true
        
        // Simulate API call delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            var filteredArticles = self.sampleArticles
            
            // Filter by user interests
            if !user.newsInterests.isEmpty {
                filteredArticles = filteredArticles.filter { article in
                    user.newsInterests.contains { interest in
                        article.category.rawValue.lowercased().contains(interest.lowercased()) ||
                        article.title.lowercased().contains(interest.lowercased()) ||
                        article.tags.contains { $0.lowercased().contains(interest.lowercased()) }
                    }
                }
            }
            
            // Add music-related content based on music preferences
            if !user.musicPreferences.isEmpty {
                let musicArticles = self.sampleArticles.filter { $0.category == .music }
                filteredArticles.append(contentsOf: musicArticles)
            }
            
            // Remove duplicates and shuffle
            let uniqueArticles = Array(Set(filteredArticles.map { $0.id }))
                .compactMap { id in filteredArticles.first { $0.id == id } }
            
            var finalArticles = Array(uniqueArticles.shuffled().prefix(10))
            
            // Load bookmark states
            let bookmarkedIds = UserDefaults.standard.stringArray(forKey: "LifeTunesBookmarkedIds") ?? []
            finalArticles = finalArticles.map { article in
                var updatedArticle = article
                updatedArticle.isBookmarked = bookmarkedIds.contains(article.id.uuidString)
                return updatedArticle
            }
            
            self.articles = finalArticles
            self.isLoading = false
        }
    }
    
    func searchArticles(query: String, completion: @escaping ([NewsArticle]) -> Void) {
        let results = sampleArticles.filter { article in
            article.title.lowercased().contains(query.lowercased()) ||
            article.summary.lowercased().contains(query.lowercased()) ||
            article.content.lowercased().contains(query.lowercased()) ||
            article.tags.contains { $0.lowercased().contains(query.lowercased()) }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(results)
        }
    }
    
    func bookmarkArticle(_ article: NewsArticle) {
        // Save bookmark state to UserDefaults first
        var bookmarkedIds = UserDefaults.standard.stringArray(forKey: "LifeTunesBookmarkedIds") ?? []
        let isCurrentlyBookmarked = bookmarkedIds.contains(article.id.uuidString)
        
        if isCurrentlyBookmarked {
            // Remove from bookmarks
            bookmarkedIds.removeAll { $0 == article.id.uuidString }
        } else {
            // Add to bookmarks
            bookmarkedIds.append(article.id.uuidString)
        }
        
        UserDefaults.standard.set(bookmarkedIds, forKey: "LifeTunesBookmarkedIds")
        
        // Update in main articles array
        if let index = articles.firstIndex(where: { $0.id == article.id }) {
            articles[index].isBookmarked = !isCurrentlyBookmarked
        }
    }
    
    func getBookmarkedArticles() -> [NewsArticle] {
        return articles.filter { $0.isBookmarked }
    }
    
    func getArticlesByCategory(_ category: NewsCategory) -> [NewsArticle] {
        return articles.filter { $0.category == category }
    }
}