/*
 Privacy Information for LifeTunes App
 
 These descriptions should be added to Info.plist for App Store submission:
 
 Location Usage:
 NSLocationWhenInUseUsageDescription: "LifeTunes requires your location to automatically generate location-specific playlists that match your environment (for example, calming music when you're in a park, or energetic tracks when you're at the gym) and to create a personalized mood map by recording where you log your emotions, helping you identify which places positively or negatively affect your wellbeing."
 
 Notifications Usage:
 NSUserNotificationsUsageDescription: "LifeTunes sends you daily wellness reminders and motivational challenges to help maintain your mental health routine. For example, you'll receive a gentle reminder at 7 PM to log your mood or a motivational quote to start your day."
 
 These descriptions explain WHY the app needs each permission, HOW it will be used, and provide
 specific examples of the functionality, which is required by Apple's App Store Review Guidelines.
 */

import Foundation

// This file provides privacy policy information for developers
// The actual Info.plist keys should be added through Xcode project settings

struct PrivacyInfo {
    static let locationUsageDescription = "LifeTunes requires your location to automatically generate location-specific playlists that match your environment (for example, calming music when you're in a park, or energetic tracks when you're at the gym) and to create a personalized mood map by recording where you log your emotions, helping you identify which places positively or negatively affect your wellbeing."
    
    static let notificationUsageDescription = "LifeTunes sends you daily wellness reminders and motivational challenges to help maintain your mental health routine. For example, you'll receive a gentle reminder at 7 PM to log your mood or a motivational quote to start your day."
    
    // Instructions for adding to Info.plist:
    // 1. Open your Xcode project
    // 2. Select your app target
    // 3. Go to Info tab
    // 4. Add these keys:
    //    - NSLocationWhenInUseUsageDescription
    //    - NSUserNotificationsUsageDescription
    // 5. Use the descriptions above as values
    // 
    // Note: Apple requires purpose strings to clearly explain HOW the data will be used
    // and provide specific examples of the functionality.
}

