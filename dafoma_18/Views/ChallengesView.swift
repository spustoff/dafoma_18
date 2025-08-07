import SwiftUI

struct ChallengesView: View {
    @ObservedObject var viewModel: ChallengesViewModel
    @State private var selectedCategory: ChallengeCategory?
    @State private var showingChallengeDetail = false
    @State private var selectedChallenge: Challenge?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.11, green: 0.12, blue: 0.19)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header section
                    headerSection
                    
                    // Stats section
                    statsSection
                    
                    // Category filter
                    categoryFilterSection
                    
                    // Challenges list
                    challengesListSection
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(item: $selectedChallenge) { challenge in
                ChallengeDetailSheet(challenge: challenge, viewModel: viewModel)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Challenges")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Streak indicator
                HStack(spacing: 5) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(viewModel.currentStreak)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.2))
                .cornerRadius(20)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private var statsSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Today's Progress")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            
            // Progress ring
            HStack(spacing: 30) {
                CircularProgressView(
                    progress: viewModel.getTodaysProgress(),
                    title: "Daily Goal",
                    subtitle: "\(viewModel.dailyChallenges.filter { $0.isCompleted }.count)/\(viewModel.dailyChallenges.count)"
                )
                
                VStack(spacing: 15) {
                    StatItem(
                        title: "Total Points",
                        value: "\(viewModel.totalPoints)",
                        icon: "star.fill",
                        color: .yellow
                    )
                    
                    StatItem(
                        title: "Completed",
                        value: "\(viewModel.completedChallenges.count)",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
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
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    CategoryChip(
                        category: nil,
                        isSelected: selectedCategory == nil,
                        title: "All"
                    ) {
                        selectedCategory = nil
                    }
                    
                    ForEach(ChallengeCategory.allCases, id: \.self) { category in
                        CategoryChip(
                            category: category,
                            isSelected: selectedCategory == category,
                            title: category.rawValue
                        ) {
                            selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var challengesListSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text(selectedCategory?.rawValue ?? "Daily Challenges")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(filteredChallenges.count) challenges")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            
            if filteredChallenges.isEmpty {
                emptyChallengesView
            } else {
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(filteredChallenges, id: \.id) { challenge in
                            ChallengeRowView(
                                challenge: challenge,
                                viewModel: viewModel
                            ) {
                                selectedChallenge = challenge
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
    }
    
    private var emptyChallengesView: some View {
        VStack(spacing: 20) {
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No challenges found")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Check back later for new challenges!")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxHeight: .infinity)
        .padding(.horizontal, 40)
    }
    
    private var filteredChallenges: [Challenge] {
        if let selectedCategory = selectedCategory {
            return viewModel.dailyChallenges.filter { $0.category == selectedCategory }
        } else {
            return viewModel.dailyChallenges
        }
    }
}

// MARK: - Supporting Views

struct CircularProgressView: View {
    let progress: Double
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.996, green: 0.157, blue: 0.29),
                                Color.orange
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1), value: progress)
                
                Text("\(Int(progress * 100))%")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct CategoryChip: View {
    let category: ChallengeCategory?
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
            .background(
                isSelected ? Color(red: 0.996, green: 0.157, blue: 0.29) : Color.gray.opacity(0.2)
            )
            .foregroundColor(isSelected ? .white : .gray)
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func categoryIcon(_ category: ChallengeCategory) -> String {
        switch category {
        case .fitness: return "figure.run"
        case .mindfulness: return "leaf.fill"
        case .creativity: return "paintbrush.fill"
        case .social: return "person.3.fill"
        case .learning: return "book.fill"
        case .music: return "music.note"
        }
    }
}

struct ChallengeRowView: View {
    let challenge: Challenge
    @ObservedObject var viewModel: ChallengesViewModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 15) {
                HStack(spacing: 15) {
                    // Category icon
                    Image(systemName: categoryIcon(challenge.category))
                        .font(.title2)
                        .foregroundColor(categoryColor(challenge.category))
                        .frame(width: 50, height: 50)
                        .background(categoryColor(challenge.category).opacity(0.2))
                        .cornerRadius(25)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(challenge.title)
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            if challenge.isCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title2)
                            }
                        }
                        
                        Text(challenge.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                        
                        HStack {
                            DifficultyBadge(difficulty: challenge.difficulty)
                            
                            Spacer()
                            
                            Text("\(Int(challenge.duration / 60)) min")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                if !challenge.isCompleted {
                    // Progress bar
                    ProgressView(value: Double(challenge.currentProgress), total: Double(challenge.requiredSteps))
                        .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 0.996, green: 0.157, blue: 0.29)))
                        .scaleEffect(y: 2)
                    
                    HStack {
                        Text("Progress: \(challenge.currentProgress)/\(challenge.requiredSteps)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Button(challenge.currentProgress > 0 ? "Continue" : "Start") {
                            viewModel.startChallenge(challenge)
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(red: 0.996, green: 0.157, blue: 0.29))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func categoryIcon(_ category: ChallengeCategory) -> String {
        switch category {
        case .fitness: return "figure.run"
        case .mindfulness: return "leaf.fill"
        case .creativity: return "paintbrush.fill"
        case .social: return "person.3.fill"
        case .learning: return "book.fill"
        case .music: return "music.note"
        }
    }
    
    private func categoryColor(_ category: ChallengeCategory) -> Color {
        switch category {
        case .fitness: return .green
        case .mindfulness: return .blue
        case .creativity: return .purple
        case .social: return .orange
        case .learning: return .yellow
        case .music: return Color(red: 0.996, green: 0.157, blue: 0.29)
        }
    }
}

struct DifficultyBadge: View {
    let difficulty: ChallengeDifficulty
    
    var body: some View {
        Text(difficulty.rawValue)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(difficultyColor.opacity(0.2))
            .foregroundColor(difficultyColor)
            .cornerRadius(8)
    }
    
    private var difficultyColor: Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .yellow
        case .hard: return .orange
        case .expert: return .red
        }
    }
}

// MARK: - Challenge Detail Sheet

struct ChallengeDetailSheet: View {
    let challenge: Challenge
    @ObservedObject var viewModel: ChallengesViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var currentStep = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.11, green: 0.12, blue: 0.19)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 15) {
                            Image(systemName: categoryIcon(challenge.category))
                                .font(.system(size: 60))
                                .foregroundColor(categoryColor(challenge.category))
                            
                            Text(challenge.title)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Text(challenge.description)
                                .font(.headline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Challenge info
                        VStack(spacing: 15) {
                            InfoRow(icon: "target", title: "Category", value: challenge.category.rawValue)
                            InfoRow(icon: "clock", title: "Duration", value: "\(Int(challenge.duration / 60)) minutes")
                            InfoRow(icon: "chart.bar", title: "Difficulty", value: challenge.difficulty.rawValue)
                            InfoRow(icon: "checkmark.circle", title: "Steps", value: "\(challenge.requiredSteps)")
                        }
                        
                        // Progress section
                        if !challenge.isCompleted {
                            VStack(spacing: 15) {
                                Text("Progress")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                ProgressView(value: Double(challenge.currentProgress), total: Double(challenge.requiredSteps))
                                    .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 0.996, green: 0.157, blue: 0.29)))
                                    .scaleEffect(y: 3)
                                
                                Text("\(challenge.currentProgress) of \(challenge.requiredSteps) steps completed")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        // Action buttons
                        VStack(spacing: 15) {
                            if challenge.isCompleted {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("Challenge Completed!")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                }
                                .padding()
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(12)
                            } else {
                                Button(challenge.currentProgress > 0 ? "Continue Challenge" : "Start Challenge") {
                                    viewModel.startChallenge(challenge)
                                    presentationMode.wrappedValue.dismiss()
                                }
                                .buttonStyle(PrimaryButtonStyle())
                                
                                if challenge.currentProgress > 0 {
                                    Button("Mark Step Complete") {
                                        viewModel.updateChallengeProgress(challenge, progress: challenge.currentProgress + 1)
                                    }
                                    .buttonStyle(SecondaryButtonStyle())
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color(red: 0.996, green: 0.157, blue: 0.29))
            )
        }
    }
    
    private func categoryIcon(_ category: ChallengeCategory) -> String {
        switch category {
        case .fitness: return "figure.run"
        case .mindfulness: return "leaf.fill"
        case .creativity: return "paintbrush.fill"
        case .social: return "person.3.fill"
        case .learning: return "book.fill"
        case .music: return "music.note"
        }
    }
    
    private func categoryColor(_ category: ChallengeCategory) -> Color {
        switch category {
        case .fitness: return .green
        case .mindfulness: return .blue
        case .creativity: return .purple
        case .social: return .orange
        case .learning: return .yellow
        case .music: return Color(red: 0.996, green: 0.157, blue: 0.29)
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Color(red: 0.996, green: 0.157, blue: 0.29))
                .frame(width: 30)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(.headline)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// Challenge is already Identifiable in the model

#Preview {
    ChallengesView(viewModel: ChallengesViewModel())
}