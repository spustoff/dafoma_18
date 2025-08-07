import Foundation
import Combine
import CoreLocation
import MapKit

class MoodMapViewModel: ObservableObject {
    @Published var moodRecords: [MoodRecord] = []
    @Published var currentMood: Mood?
    @Published var selectedMoodRecord: MoodRecord?
    @Published var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var moodHotspots: [(location: CLLocationCoordinate2D, mood: Mood, frequency: Int)] = []
    @Published var isRecordingMood: Bool = false
    @Published var showingMoodEntry: Bool = false
    
    private let moodService: MoodService
    private let locationService: LocationService
    private var cancellables = Set<AnyCancellable>()
    
    init(moodService: MoodService = MoodService(), locationService: LocationService = LocationService()) {
        self.moodService = moodService
        self.locationService = locationService
        setupBindings()
        updateMapToCurrentLocation()
    }
    
    private func setupBindings() {
        moodService.$moodRecords
            .receive(on: DispatchQueue.main)
            .assign(to: \.moodRecords, on: self)
            .store(in: &cancellables)
        
        moodService.$currentMood
            .receive(on: DispatchQueue.main)
            .assign(to: \.currentMood, on: self)
            .store(in: &cancellables)
        
        locationService.$location
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                self?.updateMapRegion(to: location.coordinate)
            }
            .store(in: &cancellables)
    }
    
    func recordMood(_ mood: Mood, intensity: Double, notes: String = "", activities: [String] = []) {
        guard let location = locationService.getCurrentLocation() else {
            print("Location not available")
            return
        }
        
        isRecordingMood = true
        
        moodService.recordMood(mood, intensity: intensity, at: location, notes: notes, activities: activities)
        updateMoodHotspots()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isRecordingMood = false
            self.showingMoodEntry = false
        }
    }
    
    func getMoodRecordsNearLocation(_ location: CLLocationCoordinate2D, radius: Double = 1000) -> [MoodRecord] {
        return moodService.getMoodRecordsNear(location: location, radius: radius)
    }
    
    func getMoodTrends(for period: TimeInterval = 7 * 24 * 60 * 60) -> [Mood: Int] {
        return moodService.getMoodTrends(for: period)
    }
    
    func updateMoodHotspots() {
        moodHotspots = moodService.getMoodHotspots()
    }
    
    func selectMoodRecord(_ record: MoodRecord) {
        selectedMoodRecord = record
        updateMapRegion(to: record.location)
    }
    
    func getSuggestedActivities(for mood: Mood) -> [String] {
        guard let location = locationService.getCurrentLocation() else {
            return moodService.suggestActivitiesForMood(mood, at: CLLocationCoordinate2D(latitude: 0, longitude: 0))
        }
        return moodService.suggestActivitiesForMood(mood, at: location)
    }
    
    func getRecommendedMusicGenre(for mood: Mood) -> String {
        return moodService.getRecommendedMusicGenre(for: mood)
    }
    
    func getMoodIntensityAverage(for mood: Mood, in period: TimeInterval = 7 * 24 * 60 * 60) -> Double {
        return moodService.getAverageMoodIntensity(for: mood, in: period)
    }
    
    func showMoodEntryDialog() {
        showingMoodEntry = true
    }
    
    func hideMoodEntryDialog() {
        showingMoodEntry = false
    }
    
    private func updateMapToCurrentLocation() {
        if let location = locationService.location {
            updateMapRegion(to: location.coordinate)
        }
    }
    
    private func updateMapRegion(to coordinate: CLLocationCoordinate2D) {
        mapRegion = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }
    
    // MARK: - Analytics
    
    func getMostFrequentMood() -> Mood? {
        let moodCounts = getMoodTrends()
        return moodCounts.max(by: { $0.value < $1.value })?.key
    }
    
    func getMoodDiversity() -> Double {
        let uniqueMoods = Set(moodRecords.map { $0.mood }).count
        let totalPossibleMoods = Mood.allCases.count
        return Double(uniqueMoods) / Double(totalPossibleMoods)
    }
    
    func getMoodConsistency() -> Double {
        // Calculate how consistent mood intensities are over time
        guard moodRecords.count > 1 else { return 0.0 }
        
        let intensities = moodRecords.map { $0.intensity }
        let average = intensities.reduce(0, +) / Double(intensities.count)
        let variance = intensities.map { pow($0 - average, 2) }.reduce(0, +) / Double(intensities.count)
        let standardDeviation = sqrt(variance)
        
        // Return consistency as inverse of standard deviation (normalized)
        return max(0, 1 - (standardDeviation / 0.5))
    }
    
    func getLocationMoodMap() -> [String: [Mood: Int]] {
        var locationMoods: [String: [Mood: Int]] = [:]
        
        for record in moodRecords {
            let locationKey = "\(Int(record.location.latitude * 1000))_\(Int(record.location.longitude * 1000))"
            
            if locationMoods[locationKey] == nil {
                locationMoods[locationKey] = [:]
            }
            
            locationMoods[locationKey]![record.mood, default: 0] += 1
        }
        
        return locationMoods
    }
}