/*
 Privacy Information for LifeTunes App
 
 These descriptions should be added to Info.plist for App Store submission:
 
 Location Usage:
 NSLocationWhenInUseUsageDescription: "LifeTunes uses your location to create personalized music playlists based on your surroundings (for example, relaxing music for parks or energetic music for gyms) and to map your mood entries to specific places so you can track patterns and discover which locations make you feel happiest."
 
 Notifications Usage:
 NSUserNotificationsUsageDescription: "LifeTunes sends you daily wellness reminders and motivational challenges to help maintain your mental health routine. For example, you'll receive a gentle reminder at 7 PM to log your mood or a motivational quote to start your day."
 
 These descriptions explain WHY the app needs each permission, HOW it will be used, and provide
 specific examples of the functionality, which is required by Apple's App Store Review Guidelines.
 */

import Foundation

// This file provides privacy policy information for developers
// The actual Info.plist keys should be added through Xcode project settings

struct PrivacyInfo {
    static let locationUsageDescription = "LifeTunes uses your location to create personalized music playlists based on your surroundings (for example, relaxing music for parks or energetic music for gyms) and to map your mood entries to specific places so you can track patterns and discover which locations make you feel happiest."
    
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

