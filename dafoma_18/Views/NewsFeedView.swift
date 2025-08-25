import SwiftUI

struct NewsFeedView: View {
    @ObservedObject var viewModel: NewsFeedViewModel
    @ObservedObject var userProfileViewModel: UserProfileViewModel
    @State private var selectedCategory: NewsCategory?
    @State private var showingBookmarks = false
    @State private var selectedArticle: NewsArticle?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.11, green: 0.12, blue: 0.19)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header section
                    headerSection
                    
                    // Search results or main content
                    if !viewModel.searchQuery.isEmpty {
                        searchResultsSection
                    } else {
                        mainContentSection
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .onAppear {
                if viewModel.articles.isEmpty {
                    viewModel.fetchPersonalizedNews(for: userProfileViewModel.user)
                }
            }
            .sheet(item: $selectedArticle) { article in
                ArticleDetailSheet(article: article, viewModel: viewModel)
            }
            .sheet(isPresented: $showingBookmarks) {
                BookmarkedArticlesSheet(viewModel: viewModel)
            }
            .refreshable {
                viewModel.refreshNews(for: userProfileViewModel.user)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("News Feed")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    showingBookmarks = true
                }) {
                    Image(systemName: "bookmark.fill")
                        .font(.title2)
                        .foregroundColor(Color(red: 0.996, green: 0.157, blue: 0.29))
                }
            }
            
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search articles...", text: $viewModel.searchQuery)
                    .foregroundColor(.white)
                
                if !viewModel.searchQuery.isEmpty {
                    Button(action: {
                        viewModel.searchQuery = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private var searchResultsSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Search Results")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(viewModel.searchResults.count) articles")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            
            if viewModel.searchResults.isEmpty {
                emptySearchView
            } else {
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(viewModel.searchResults, id: \.id) { article in
                            ArticleRowView(article: article, viewModel: viewModel) {
                                selectedArticle = article
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
    }
    
    private var mainContentSection: some View {
        VStack(spacing: 0) {
            // Category filter
            categoryFilterSection
            
            // Articles list
            articlesListSection
        }
    }
    
    private var categoryFilterSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Categories")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    CategoryFilterChip(
                        category: nil,
                        isSelected: selectedCategory == nil,
                        title: "All"
                    ) {
                        selectedCategory = nil
                        viewModel.filterByCategory(nil)
                    }
                    
                    ForEach(NewsCategory.allCases, id: \.self) { category in
                        CategoryFilterChip(
                            category: category,
                            isSelected: selectedCategory == category,
                            title: category.rawValue
                        ) {
                            selectedCategory = category
                            viewModel.filterByCategory(category)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 15)
    }
    
    private var articlesListSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text(selectedCategory?.rawValue ?? "Personalized Feed")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Text("\(viewModel.articles.count) articles")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 20)
            
            if viewModel.articles.isEmpty && !viewModel.isLoading {
                emptyArticlesView
            } else {
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(viewModel.articles, id: \.id) { article in
                            ArticleRowView(article: article, viewModel: viewModel) {
                                selectedArticle = article
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
    }
    
    private var emptySearchView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No results found")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Try searching with different keywords")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxHeight: .infinity)
        .padding(.horizontal, 40)
    }
    
    private var emptyArticlesView: some View {
        VStack(spacing: 20) {
            Image(systemName: "newspaper")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No articles available")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Pull down to refresh or check your preferences")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button("Refresh") {
                viewModel.refreshNews(for: userProfileViewModel.user)
            }
            .buttonStyle(PrimaryButtonStyle())
            .frame(maxWidth: 200)
        }
        .frame(maxHeight: .infinity)
        .padding(.horizontal, 40)
    }
}

// MARK: - Supporting Views

struct CategoryFilterChip: View {
    let category: NewsCategory?
    let isSelected: Bool
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let category = category {
                    Image(systemName: categoryIcon(category))
                        .font(.caption)
                }
                
                Text(title)
                    .font(.headline)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(minHeight: 44) // Ensure minimum touch target
            .background(
                isSelected ? Color(red: 0.996, green: 0.157, blue: 0.29) : Color.gray.opacity(0.2)
            )
            .foregroundColor(isSelected ? .white : .gray)
            .cornerRadius(20)
            .contentShape(Capsule()) // Ensure entire area is tappable
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func categoryIcon(_ category: NewsCategory) -> String {
        switch category {
        case .lifestyle: return "heart.fill"
        case .music: return "music.note"
        case .health: return "cross.fill"
        case .technology: return "laptopcomputer"
        case .entertainment: return "tv.fill"
        case .travel: return "airplane"
        case .fitness: return "figure.run"
        case .mindfulness: return "leaf.fill"
        }
    }
}

struct ArticleRowView: View {
    let article: NewsArticle
    @ObservedObject var viewModel: NewsFeedViewModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                HStack(spacing: 15) {
                    // Article placeholder image
                    RoundedRectangle(cornerRadius: 8)
                        .fill(categoryColor(article.category))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: categoryIcon(article.category))
                                .font(.title2)
                                .foregroundColor(.white)
                        )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(article.title)
                            .font(.headline)
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        Text(article.summary)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                        
                        HStack {
                            CategoryBadge(category: article.category)
                            
                            Spacer()
                            
                            Text("\(article.readingTime) min read")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                }
                
                // Article metadata
                HStack {
                    Text("By \(article.author)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text(DateFormatter.timeAgo.string(from: article.publishedDate))
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        print("Bookmark button tapped for article: \(article.title)")
                        viewModel.bookmarkArticle(article)
                    }) {
                        Image(systemName: article.isBookmarked ? "bookmark.fill" : "bookmark")
                            .foregroundColor(article.isBookmarked ? Color(red: 0.996, green: 0.157, blue: 0.29) : .gray)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(StartButtonStyle())
                    
                    if viewModel.isArticleRead(article) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func categoryIcon(_ category: NewsCategory) -> String {
        switch category {
        case .lifestyle: return "heart.fill"
        case .music: return "music.note"
        case .health: return "cross.fill"
        case .technology: return "laptopcomputer"
        case .entertainment: return "tv.fill"
        case .travel: return "airplane"
        case .fitness: return "figure.run"
        case .mindfulness: return "leaf.fill"
        }
    }
    
    private func categoryColor(_ category: NewsCategory) -> Color {
        switch category {
        case .lifestyle: return Color(red: 0.996, green: 0.157, blue: 0.29)
        case .music: return .purple
        case .health: return .green
        case .technology: return .blue
        case .entertainment: return .orange
        case .travel: return .cyan
        case .fitness: return .red
        case .mindfulness: return .mint
        }
    }
}

struct CategoryBadge: View {
    let category: NewsCategory
    
    var body: some View {
        Text(category.rawValue)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(categoryColor.opacity(0.2))
            .foregroundColor(categoryColor)
            .cornerRadius(8)
    }
    
    private var categoryColor: Color {
        switch category {
        case .lifestyle: return Color(red: 0.996, green: 0.157, blue: 0.29)
        case .music: return .purple
        case .health: return .green
        case .technology: return .blue
        case .entertainment: return .orange
        case .travel: return .cyan
        case .fitness: return .red
        case .mindfulness: return .mint
        }
    }
}

// MARK: - Article Detail Sheet

struct ArticleDetailSheet: View {
    let article: NewsArticle
    @ObservedObject var viewModel: NewsFeedViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.11, green: 0.12, blue: 0.19)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header image placeholder
                        RoundedRectangle(cornerRadius: 12)
                            .fill(categoryColor(article.category))
                            .frame(height: 200)
                            .overlay(
                                Image(systemName: categoryIcon(article.category))
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                            )
                        
                        VStack(alignment: .leading, spacing: 15) {
                            // Category and reading time
                            HStack {
                                CategoryBadge(category: article.category)
                                
                                Spacer()
                                
                                Text("\(article.readingTime) min read")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            // Title
                            Text(article.title)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            // Author and date
                            HStack {
                                Text("By \(article.author)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                Text(DateFormatter.longDate.string(from: article.publishedDate))
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            // Summary
                            Text(article.summary)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                            
                            // Content
                            Text(article.content)
                                .font(.body)
                                .foregroundColor(.white)
                                .lineSpacing(6)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color(red: 0.996, green: 0.157, blue: 0.29)),
                trailing: Button(action: {
                    viewModel.bookmarkArticle(article)
                }) {
                    Image(systemName: article.isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundColor(Color(red: 0.996, green: 0.157, blue: 0.29))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
            )
            .onAppear {
                viewModel.markArticleAsRead(article)
            }
        }
    }
    
    private func categoryIcon(_ category: NewsCategory) -> String {
        switch category {
        case .lifestyle: return "heart.fill"
        case .music: return "music.note"
        case .health: return "cross.fill"
        case .technology: return "laptopcomputer"
        case .entertainment: return "tv.fill"
        case .travel: return "airplane"
        case .fitness: return "figure.run"
        case .mindfulness: return "leaf.fill"
        }
    }
    
    private func categoryColor(_ category: NewsCategory) -> Color {
        switch category {
        case .lifestyle: return Color(red: 0.996, green: 0.157, blue: 0.29)
        case .music: return .purple
        case .health: return .green
        case .technology: return .blue
        case .entertainment: return .orange
        case .travel: return .cyan
        case .fitness: return .red
        case .mindfulness: return .mint
        }
    }
}

// MARK: - Bookmarked Articles Sheet

struct BookmarkedArticlesSheet: View {
    @ObservedObject var viewModel: NewsFeedViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedArticle: NewsArticle?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.11, green: 0.12, blue: 0.19)
                    .ignoresSafeArea()
                
                VStack {
                    if viewModel.bookmarkedArticles.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "bookmark")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("No bookmarked articles")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("Bookmark articles you want to read later")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 15) {
                                ForEach(viewModel.bookmarkedArticles, id: \.id) { article in
                                    ArticleRowView(article: article, viewModel: viewModel) {
                                        selectedArticle = article
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        }
                    }
                }
            }
            .navigationTitle("Bookmarks")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color(red: 0.996, green: 0.157, blue: 0.29))
            )
            .sheet(item: $selectedArticle) { article in
                ArticleDetailSheet(article: article, viewModel: viewModel)
            }
        }
    }
}

// MARK: - Extensions

extension DateFormatter {
    static let timeAgo: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        return formatter
    }()
    
    static let longDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
}

// NewsArticle is already Identifiable in the model

#Preview {
    NewsFeedView(viewModel: NewsFeedViewModel(), userProfileViewModel: UserProfileViewModel())
}