/*
 Privacy Information for LifeTunes App
 
 These descriptions should be added to Info.plist for App Store submission:
 
 Location Usage:
 NSLocationWhenInUseUsageDescription: "LifeTunes uses your location to create personalized playlists based on your surroundings and to provide location-specific mood mapping features."
 
 Notifications Usage:
 NSUserNotificationsUsageDescription: "LifeTunes sends notifications to remind you about daily challenges and motivational content to help maintain your wellness routine."
 
 These descriptions explain WHY the app needs each permission and how it benefits the user,
 which is required by Apple's App Store Review Guidelines.
 */

import Foundation

// This file provides privacy policy information for developers
// The actual Info.plist keys should be added through Xcode project settings

struct PrivacyInfo {
    static let locationUsageDescription = "LifeTunes uses your location to create personalized playlists based on your surroundings and to provide location-specific mood mapping features."
    
    static let notificationUsageDescription = "LifeTunes sends notifications to remind you about daily challenges and motivational content to help maintain your wellness routine."
    
    // Instructions for adding to Info.plist:
    // 1. Open your Xcode project
    // 2. Select your app target
    // 3. Go to Info tab
    // 4. Add these keys:
    //    - NSLocationWhenInUseUsageDescription
    //    - NSUserNotificationsUsageDescription
    // 5. Use the descriptions above as values
}
