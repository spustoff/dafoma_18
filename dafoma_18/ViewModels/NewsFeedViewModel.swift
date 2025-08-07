import Foundation
import Combine
import CoreLocation

class NewsFeedViewModel: ObservableObject {
    @Published var articles: [NewsArticle] = []
    @Published var bookmarkedArticles: [NewsArticle] = []
    @Published var isLoading: Bool = false
    @Published var selectedCategory: NewsCategory?
    @Published var searchQuery: String = ""
    @Published var searchResults: [NewsArticle] = []
    
    private let newsService: NewsService
    private let locationService: LocationService
    private var cancellables = Set<AnyCancellable>()
    
    init(newsService: NewsService = NewsService(), locationService: LocationService = LocationService()) {
        self.newsService = newsService
        self.locationService = locationService
        setupBindings()
        loadBookmarkedArticles()
    }
    
    private func setupBindings() {
        newsService.$articles
            .receive(on: DispatchQueue.main)
            .assign(to: \.articles, on: self)
            .store(in: &cancellables)
        
        newsService.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
        
        // Debounce search query
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }
    
    func fetchPersonalizedNews(for user: User) {
        let location = locationService.getCurrentLocation()
        newsService.fetchPersonalizedNews(for: user, location: location)
    }
    
    func refreshNews(for user: User) {
        fetchPersonalizedNews(for: user)
    }
    
    func filterByCategory(_ category: NewsCategory?) {
        selectedCategory = category
        
        if let category = category {
            articles = newsService.getArticlesByCategory(category)
        } else {
            // Show all articles
            articles = newsService.articles
        }
    }
    
    private func performSearch(query: String) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            return
        }
        
        newsService.searchArticles(query: query) { [weak self] results in
            DispatchQueue.main.async {
                self?.searchResults = results
            }
        }
    }
    
    func bookmarkArticle(_ article: NewsArticle) {
        newsService.bookmarkArticle(article)
        
        if article.isBookmarked {
            if !bookmarkedArticles.contains(where: { $0.id == article.id }) {
                bookmarkedArticles.append(article)
            }
        } else {
            bookmarkedArticles.removeAll { $0.id == article.id }
        }
        
        saveBookmarkedArticles()
    }
    
    func getBookmarkedArticles() -> [NewsArticle] {
        return newsService.getBookmarkedArticles()
    }
    
    func getArticlesByCategory(_ category: NewsCategory) -> [NewsArticle] {
        return articles.filter { $0.category == category }
    }
    
    func getTrendingTopics() -> [String] {
        let allWords = articles.flatMap { article in
            (article.title + " " + article.summary).components(separatedBy: .whitespacesAndNewlines)
        }
        
        let filteredWords = allWords
            .filter { $0.count > 4 } // Only words longer than 4 characters
            .map { $0.lowercased().trimmingCharacters(in: .punctuationCharacters) }
        
        let wordCounts = Dictionary(grouping: filteredWords, by: { $0 })
            .mapValues { $0.count }
            .filter { $0.value > 1 }
        
        return Array(wordCounts.sorted { $0.value > $1.value }.prefix(10).map { $0.key })
    }
    
    func getRecommendedArticles(based on: [String]) -> [NewsArticle] {
        return articles.filter { article in
            on.contains { interest in
                article.title.lowercased().contains(interest.lowercased()) ||
                article.summary.lowercased().contains(interest.lowercased()) ||
                article.tags.contains { $0.lowercased().contains(interest.lowercased()) }
            }
        }
    }
    
    func markArticleAsRead(_ article: NewsArticle) {
        // In a real app, this would update the backend
        // For now, we'll just track it locally
        var readArticles = UserDefaults.standard.stringArray(forKey: "LifeTunesReadArticles") ?? []
        if !readArticles.contains(article.id.uuidString) {
            readArticles.append(article.id.uuidString)
            UserDefaults.standard.set(readArticles, forKey: "LifeTunesReadArticles")
        }
    }
    
    func isArticleRead(_ article: NewsArticle) -> Bool {
        let readArticles = UserDefaults.standard.stringArray(forKey: "LifeTunesReadArticles") ?? []
        return readArticles.contains(article.id.uuidString)
    }
    
    private func saveBookmarkedArticles() {
        do {
            let bookmarkData = try JSONEncoder().encode(bookmarkedArticles)
            UserDefaults.standard.set(bookmarkData, forKey: "LifeTunesBookmarkedArticles")
        } catch {
            print("Failed to save bookmarked articles: \(error)")
        }
    }
    
    private func loadBookmarkedArticles() {
        if let bookmarkData = UserDefaults.standard.data(forKey: "LifeTunesBookmarkedArticles"),
           let decodedBookmarks = try? JSONDecoder().decode([NewsArticle].self, from: bookmarkData) {
            self.bookmarkedArticles = decodedBookmarks
        }
    }
}