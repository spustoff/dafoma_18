import Foundation
import Combine
import CoreLocation

class UserProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var isOnboardingCompleted: Bool = false
    @Published var hasLocationPermission: Bool = false
    @Published var hasNotificationPermission: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let locationService: LocationService
    
    init(locationService: LocationService = LocationService()) {
        self.user = User()
        self.locationService = locationService
        setupBindings()
        loadUserData()
        checkNotificationPermission()
    }
    
    private func setupBindings() {
        locationService.$isLocationEnabled
            .receive(on: DispatchQueue.main)
            .assign(to: \.hasLocationPermission, on: self)
            .store(in: &cancellables)
        
        locationService.$location
            .compactMap { $0?.coordinate }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] coordinate in
                self?.user.location = coordinate
            }
            .store(in: &cancellables)
    }
    
    func updateUser(name: String, musicPreferences: [String], lifestyleGoals: [String], newsInterests: [String]) {
        user.name = name
        user.musicPreferences = musicPreferences
        user.lifestyleGoals = lifestyleGoals
        user.newsInterests = newsInterests
        saveUserData()
    }
    
    func completeOnboarding() {
        isOnboardingCompleted = true
        saveUserData()
    }
    
    func updateDailyGoal(_ goal: Int) {
        user.dailyGoal = goal
        saveUserData()
    }
    
    func incrementStreak() {
        user.currentStreak += 1
        saveUserData()
    }
    
    func resetStreak() {
        user.currentStreak = 0
        saveUserData()
    }
    
    func requestLocationPermission() {
        locationService.requestLocationPermission()
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.hasNotificationPermission = granted
                if let error = error {
                    print("Notification permission error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.hasNotificationPermission = settings.authorizationStatus == .authorized
            }
        }
    }
    
    private func saveUserData() {
        do {
            let userData = try JSONEncoder().encode(user)
            UserDefaults.standard.set(userData, forKey: "LifeTunesUser")
            UserDefaults.standard.set(isOnboardingCompleted, forKey: "LifeTunesOnboardingCompleted")
        } catch {
            print("Failed to save user data: \(error)")
        }
    }
    
    private func loadUserData() {
        if let userData = UserDefaults.standard.data(forKey: "LifeTunesUser"),
           let decodedUser = try? JSONDecoder().decode(User.self, from: userData) {
            self.user = decodedUser
        }
        
        self.isOnboardingCompleted = UserDefaults.standard.bool(forKey: "LifeTunesOnboardingCompleted")
    }
}

// Import UserNotifications for notification permissions
import UserNotifications