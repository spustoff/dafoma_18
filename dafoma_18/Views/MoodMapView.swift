import SwiftUI
import MapKit

struct MoodMapView: View {
    @ObservedObject var viewModel: MoodMapViewModel
    @State private var showingMoodEntry = false
    @State private var selectedMood: Mood = .happy
    @State private var moodIntensity: Double = 0.5
    @State private var moodNotes: String = ""
    @State private var selectedActivities: Set<String> = []
    @State private var showingAnalytics = false
    
    private let activities = ["Walking", "Working", "Eating", "Shopping", "Exercise", "Socializing", "Reading", "Music", "Rest"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.11, green: 0.12, blue: 0.19)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerSection
                    
                    // Map view
                    mapSection
                    
                    // Bottom panel
                    bottomPanel
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingMoodEntry) {
                MoodEntrySheet(
                    selectedMood: $selectedMood,
                    moodIntensity: $moodIntensity,
                    moodNotes: $moodNotes,
                    selectedActivities: $selectedActivities,
                    activities: activities,
                    viewModel: viewModel
                )
            }
            .sheet(isPresented: $showingAnalytics) {
                MoodAnalyticsSheet(viewModel: viewModel)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Mood Map")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    showingAnalytics = true
                }) {
                    Image(systemName: "chart.bar.fill")
                        .font(.title2)
                        .foregroundColor(Color(red: 0.996, green: 0.157, blue: 0.29))
                }
            }
            
            // Current mood indicator
            if let currentMood = viewModel.currentMood {
                HStack(spacing: 10) {
                    Text(currentMood.emoji)
                        .font(.title2)
                    Text("Current mood: \(currentMood.rawValue)")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private var mapSection: some View {
        Map(coordinateRegion: $viewModel.mapRegion, annotationItems: viewModel.moodRecords) { record in
            MapAnnotation(coordinate: record.location) {
                MoodAnnotationView(mood: record.mood, intensity: record.intensity) {
                    viewModel.selectMoodRecord(record)
                }
            }
        }
        .frame(height: 300)
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .overlay(
            // Map controls
            VStack {
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Button(action: {
                            // Center on user location
                        }) {
                            Image(systemName: "location.fill")
                                .font(.title3)
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(20)
                        }
                        
                        Button(action: {
                            viewModel.updateMoodHotspots()
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.title3)
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(20)
                        }
                    }
                    .padding(.trailing, 30)
                }
                Spacer()
            }
            .padding(.top, 30)
        )
    }
    
    private var bottomPanel: some View {
        VStack(spacing: 20) {
            // Quick mood selector
            quickMoodSelector
            
            // Mood hotspots
            moodHotspotsSection
            
            // Record mood button
            recordMoodButton
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
    }
    
    private var quickMoodSelector: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Quick Mood Check")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach([Mood.happy, .calm, .energetic, .focused, .stressed], id: \.self) { mood in
                        QuickMoodButton(mood: mood) {
                            selectedMood = mood
                            showingMoodEntry = true
                        }
                    }
                }
                .padding(.horizontal, 5)
            }
        }
    }
    
    private var moodHotspotsSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Mood Hotspots")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(viewModel.moodHotspots.count) locations")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            if viewModel.moodHotspots.isEmpty {
                Text("No mood data yet. Start recording your moods!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(Array(viewModel.moodHotspots.prefix(5).enumerated()), id: \.offset) { index, hotspot in
                            MoodHotspotCard(
                                mood: hotspot.mood,
                                frequency: hotspot.frequency,
                                rank: index + 1
                            ) {
                                viewModel.mapRegion.center = hotspot.location
                            }
                        }
                    }
                    .padding(.horizontal, 5)
                }
            }
        }
    }
    
    private var recordMoodButton: some View {
        Button("Record Current Mood") {
            showingMoodEntry = true
        }
        .buttonStyle(PrimaryButtonStyle())
    }
}

// MARK: - Supporting Views

struct MoodAnnotationView: View {
    let mood: Mood
    let intensity: Double
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            print("MoodAnnotation tapped: \(mood.rawValue)")
            onTap()
        }) {
            ZStack {
                Circle()
                    .fill(Color(hex: mood.color))
                    .frame(width: 30 + (intensity * 20), height: 30 + (intensity * 20))
                    .opacity(0.8)
                
                Text(mood.emoji)
                    .font(.title3)
            }
        }
        .buttonStyle(StartButtonStyle())
    }
}

struct QuickMoodButton: View {
    let mood: Mood
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            print("QuickMoodButton tapped: \(mood.rawValue)")
            action()
        }) {
            VStack(spacing: 8) {
                Text(mood.emoji)
                    .font(.title)
                
                Text(mood.rawValue)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .frame(width: 80, height: 80)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
        }
        .buttonStyle(StartButtonStyle())
    }
}

struct MoodHotspotCard: View {
    let mood: Mood
    let frequency: Int
    let rank: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                HStack {
                    Text("#\(rank)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.996, green: 0.157, blue: 0.29))
                    
                    Spacer()
                    
                    Text("\(frequency)x")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(mood.emoji)
                    .font(.title)
                
                Text(mood.rawValue)
                    .font(.caption)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 100, height: 100)
            .padding(10)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Mood Entry Sheet

struct MoodEntrySheet: View {
    @Binding var selectedMood: Mood
    @Binding var moodIntensity: Double
    @Binding var moodNotes: String
    @Binding var selectedActivities: Set<String>
    let activities: [String]
    @ObservedObject var viewModel: MoodMapViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.11, green: 0.12, blue: 0.19)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Mood selection
                        moodSelectionSection
                        
                        // Intensity slider
                        intensitySection
                        
                        // Activities
                        activitiesSection
                        
                        // Notes
                        notesSection
                        
                        // Suggested activities
                        suggestedActivitiesSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Record Mood")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color(red: 0.996, green: 0.157, blue: 0.29)),
                trailing: Button("Save") {
                    viewModel.recordMood(
                        selectedMood,
                        intensity: moodIntensity,
                        notes: moodNotes,
                        activities: Array(selectedActivities)
                    )
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color(red: 0.996, green: 0.157, blue: 0.29))
                .font(.system(size: 16, weight: .bold))
            )
        }
    }
    
    private var moodSelectionSection: some View {
        VStack(spacing: 15) {
            Text("How are you feeling?")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                ForEach(Mood.allCases, id: \.self) { mood in
                    Button(action: {
                        selectedMood = mood
                    }) {
                        VStack(spacing: 5) {
                            Text(mood.emoji)
                                .font(.title)
                            Text(mood.rawValue)
                                .font(.caption2)
                                .foregroundColor(.white)
                        }
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(
                            selectedMood == mood ? Color(red: 0.996, green: 0.157, blue: 0.29) : Color.gray.opacity(0.2)
                        )
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var intensitySection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Intensity")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(Int(moodIntensity * 100))%")
                    .font(.headline)
                    .foregroundColor(Color(red: 0.996, green: 0.157, blue: 0.29))
            }
            
            Slider(value: $moodIntensity, in: 0...1)
                .accentColor(Color(red: 0.996, green: 0.157, blue: 0.29))
            
            HStack {
                Text("Low")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text("High")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var activitiesSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("What are you doing?")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 10) {
                ForEach(activities, id: \.self) { activity in
                    Button(action: {
                        if selectedActivities.contains(activity) {
                            selectedActivities.remove(activity)
                        } else {
                            selectedActivities.insert(activity)
                        }
                    }) {
                        Text(activity)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                selectedActivities.contains(activity) ? Color(red: 0.996, green: 0.157, blue: 0.29) : Color.gray.opacity(0.2)
                            )
                            .foregroundColor(selectedActivities.contains(activity) ? .white : .gray)
                            .cornerRadius(20)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var notesSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Notes (optional)")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            
            TextField("How are you feeling? What's happening?", text: $moodNotes)
                .font(.body)
                .foregroundColor(.white)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
                .lineLimit(6)
        }
    }
    
    private var suggestedActivitiesSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Suggested for \(selectedMood.rawValue) mood")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            
            let suggestions = viewModel.getSuggestedActivities(for: selectedMood)
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 10) {
                ForEach(suggestions.prefix(4), id: \.self) { suggestion in
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        
                        Text(suggestion)
                            .font(.caption)
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
    }
}

// MARK: - Mood Analytics Sheet

struct MoodAnalyticsSheet: View {
    @ObservedObject var viewModel: MoodMapViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.11, green: 0.12, blue: 0.19)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Overview stats
                        overviewSection
                        
                        // Mood trends
                        moodTrendsSection
                        
                        // Analytics
                        analyticsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Mood Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color(red: 0.996, green: 0.157, blue: 0.29))
            )
        }
    }
    
    private var overviewSection: some View {
        VStack(spacing: 15) {
            Text("This Week")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            HStack(spacing: 15) {
                AnalyticsCard(
                    title: "Records",
                    value: "\(viewModel.moodRecords.count)",
                    icon: "doc.text.fill",
                    color: .blue
                )
                
                AnalyticsCard(
                    title: "Diversity",
                    value: String(format: "%.0f%%", viewModel.getMoodDiversity() * 100),
                    icon: "chart.pie.fill",
                    color: .green
                )
                
                AnalyticsCard(
                    title: "Consistency",
                    value: String(format: "%.0f%%", viewModel.getMoodConsistency() * 100),
                    icon: "waveform.path.ecg",
                    color: .orange
                )
            }
        }
    }
    
    private var moodTrendsSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Mood Trends")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            
            let trends = viewModel.getMoodTrends()
            if trends.isEmpty {
                Text("Not enough data yet")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 15) {
                    ForEach(trends.sorted { $0.value > $1.value }.prefix(6), id: \.key) { mood, count in
                        MoodTrendCard(mood: mood, count: count)
                    }
                }
            }
        }
    }
    
    private var analyticsSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Insights")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(spacing: 10) {
                if let mostFrequentMood = viewModel.getMostFrequentMood() {
                    InsightCard(
                        icon: "chart.bar.fill",
                        title: "Most Common Mood",
                        description: "You feel \(mostFrequentMood.rawValue) most often",
                        mood: mostFrequentMood
                    )
                }
                
                InsightCard(
                    icon: "location.fill",
                    title: "Mood Locations",
                    description: "You've recorded moods in \(viewModel.moodHotspots.count) different locations",
                    mood: nil
                )
                
                InsightCard(
                    icon: "music.note",
                    title: "Music Recommendation",
                    description: "Based on your current mood, try \(viewModel.getRecommendedMusicGenre(for: viewModel.currentMood ?? .happy))",
                    mood: nil
                )
            }
        }
    }
}

struct AnalyticsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct MoodTrendCard: View {
    let mood: Mood
    let count: Int
    
    var body: some View {
        HStack(spacing: 10) {
            Text(mood.emoji)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(mood.rawValue)
                    .font(.headline)
                    .foregroundColor(.white)
                Text("\(count) times")
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

struct InsightCard: View {
    let icon: String
    let title: String
    let description: String
    let mood: Mood?
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color(red: 0.996, green: 0.157, blue: 0.29))
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            if let mood = mood {
                Text(mood.emoji)
                    .font(.title)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Extensions

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    MoodMapView(viewModel: MoodMapViewModel())
}