//
//  UNPModels.swift
//  Until The Next Pour — domain models
//

import Foundation

// MARK: - Access & Role

enum UNPAccessTier: String, Codable, CaseIterable, Identifiable {
    case guest
    case free
    case paid
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .guest: return "Guest"
        case .free: return "Free"
        case .paid: return "Paid"
        }
    }
}

struct UNPUserProfile: Equatable, Codable {
    var displayName: String
    var accessTier: UNPAccessTier
    var isBeverageAmbassador: Bool
    var notificationsEnabled: Bool
    var rewardPoints: Int
    var rewardTier: UNPRewardTierName
    var pointsEarnedThisMonth: Int
    var lastPointsResetMonth: Int // 1...12
    var lastPointsResetYear: Int
}

enum UNPRewardTierName: String, Codable, CaseIterable, Identifiable {
    case bronze
    case silver
    case gold
    
    var id: String { rawValue }
    
    var displayName: String { rawValue.capitalized }
    
    var minPoints: Int {
        switch self {
        case .bronze: return 0
        case .silver: return 500
        case .gold: return 1500
        }
    }
}

// MARK: - Beverages

struct UNPBeverage: Identifiable, Equatable, Codable {
    let id: UUID
    var name: String
    var shortDescription: String
    var imageSymbolName: String // SF Symbol placeholder
    var ingredients: [String]
    var pairingNotes: String
    var fullRecipe: String
    var relatedIds: [UUID]
}

// MARK: - Nudges

struct UNPNudge: Identifiable, Equatable, Codable {
    let id: UUID
    var title: String
    var heroSubtitle: String
    var basicText: String
    var pollOptions: [String]
    var paidPlanSteps: [String]
    var linkedEventIds: [UUID]
    var linkedBeverageIds: [UUID]
}

// MARK: - Events

enum UNPTimeOfDay: String, CaseIterable, Identifiable, Codable {
    case day
    case night
    case lateNight
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .day: return "Day"
        case .night: return "Night"
        case .lateNight: return "Late Night"
        }
    }
}

struct UNPEvent: Identifiable, Equatable, Codable {
    let id: UUID
    var name: String
    var venueName: String
    var startTime: Date
    var endTime: Date
    var description: String
    var latitude: Double
    var longitude: Double
    var timeCategory: UNPTimeOfDay
    var howToAttend: String
    var relatedBeverageIds: [UUID]
    var relatedNudgeIds: [UUID]
}

struct UNPCommunityMessage: Identifiable, Equatable, Codable {
    let id: UUID
    let eventId: UUID
    var authorName: String
    var text: String
    var timestamp: Date
}

// MARK: - Pour Circle

struct UNPPourCircleGroup: Identifiable, Equatable, Codable {
    let id: UUID
    var name: String
    var memberCount: Int
    var lastActivitySummary: String
    var chatPreview: [String]
    var sharedPlanSummary: String
    var perks: [String]
}

struct UNPCircleActivity: Identifiable, Equatable, Codable {
    let id: UUID
    var userName: String
    var action: String
    var timestamp: Date
}

// MARK: - Rewards tracking

enum UNPRewardAction: String, Codable {
    case save
    case share
    case eventAttendance
    case recipeUpload
    case planCompletion
    case socialInteraction
}

struct UNPRewardLedgerEntry: Identifiable, Equatable, Codable {
    let id: UUID
    var action: UNPRewardAction
    var points: Int
    var label: String
    var date: Date
}

// MARK: - Demo screenshot catalog

struct UNPDemoScreenshotItem: Identifiable, Hashable {
    let id: String
    var title: String
    var journey: UNPDemoJourney
    var roles: Set<UNPDemoRoleFilter>
}

enum UNPDemoJourney: String, CaseIterable, Identifiable {
    case home
    case pour
    case nudge
    case explore
    case circles
    case profile
    
    var id: String { rawValue }
    var label: String {
        switch self {
        case .home: return "Home"
        case .pour: return "Pour"
        case .nudge: return "Nudge"
        case .explore: return "Explore"
        case .circles: return "Circles"
        case .profile: return "Profile"
        }
    }
}

enum UNPDemoRoleFilter: String, CaseIterable, Identifiable {
    case free
    case paid
    case ambassador
    
    var id: String { rawValue }
    var label: String {
        switch self {
        case .free: return "Free"
        case .paid: return "Paid"
        case .ambassador: return "Ambassador"
        }
    }
}
