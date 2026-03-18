//
//  UserManager.swift
//  SIP SYNC
//
//  User data management for onboarding and profile
//

import SwiftUI
import Combine

class UserManager: ObservableObject {
    static let shared = UserManager()
    
    @Published var currentUser: User? {
        didSet {
            // Save user name to UserDefaults when updated
            if let user = currentUser {
                UserDefaults.standard.set(user.name, forKey: "userName")
            }
        }
    }
    
    private init() {
        // Load user name from UserDefaults on init
        if let savedName = UserDefaults.standard.string(forKey: "userName"), !savedName.isEmpty {
            currentUser = User(
                name: savedName,
                email: "",
                profileImage: nil,
                location: "Detroit, Michigan",
                userType: .consumer,
                bio: nil,
                profession: nil,
                languages: [],
                interests: [],
                headerImage: nil,
                instagramHandle: nil,
                twitterHandle: nil
            )
        }
    }
    
    func createUser(from onboardingData: OnboardingData) -> User {
        // Convert UIImage to String (in a real app, you'd upload to server and get URL)
        let profileImageName: String? = onboardingData.profileImage != nil ? "user_\(UUID().uuidString)" : nil
        
        return User(
            name: onboardingData.name,
            email: onboardingData.email,
            profileImage: profileImageName,
            location: onboardingData.location,
            userType: onboardingData.userType,
            bio: onboardingData.bio.isEmpty ? nil : onboardingData.bio,
            profession: onboardingData.profession.isEmpty ? nil : onboardingData.profession,
            languages: onboardingData.languages,
            interests: onboardingData.interests,
            headerImage: nil,
            instagramHandle: onboardingData.instagramHandle.isEmpty ? nil : onboardingData.instagramHandle,
            twitterHandle: onboardingData.twitterHandle.isEmpty ? nil : onboardingData.twitterHandle
        )
    }
    
    func updateUser(_ user: User) {
        currentUser = user
        // Name is automatically saved via didSet
    }
}




