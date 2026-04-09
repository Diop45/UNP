//
//  UNPDataStore.swift
//  Until The Next Pour — global state + seeding
//

import Foundation
import SwiftUI

@MainActor
final class UNPDataStore: ObservableObject {
    static let shared = UNPDataStore()
    
    private let seededKey = "unp_data_seeded_v1"
    private let profileKey = "unp_user_profile_v1"
    private let tourKey = "unp_first_run_complete_v1"
    
    @Published var user: UNPUserProfile
    @Published var beverages: [UNPBeverage] = []
    @Published var nudges: [UNPNudge] = []
    @Published var events: [UNPEvent] = []
    @Published var circleGroups: [UNPPourCircleGroup] = []
    @Published var circleActivities: [UNPCircleActivity] = []
    @Published var rewardLedger: [UNPRewardLedgerEntry] = []
    @Published var eventCommunityMessages: [UUID: [UNPCommunityMessage]] = [:]
    
    /// Ambassador-managed recipes (demo)
    @Published var ambassadorUploads: [UNPBeverage] = []
    
    @Published var firstRunCompleted: Bool
    @Published var guidedTourStepIndex: Int = 0
    @Published var showGuidedTourOverlay: Bool = false
    
    private init() {
        if let data = UserDefaults.standard.data(forKey: profileKey),
           let decoded = try? JSONDecoder().decode(UNPUserProfile.self, from: data) {
            user = decoded
        } else {
            user = UNPUserProfile(
                displayName: "Alex Morgan",
                accessTier: .paid,
                isBeverageAmbassador: true,
                notificationsEnabled: true,
                rewardPoints: 420,
                rewardTier: .silver,
                pointsEarnedThisMonth: 420,
                lastPointsResetMonth: Calendar.current.component(.month, from: Date()),
                lastPointsResetYear: Calendar.current.component(.year, from: Date())
            )
        }
        firstRunCompleted = UserDefaults.standard.bool(forKey: tourKey)
        seedIfNeeded()
        refreshRewardTier()
        applyMonthlyResetIfNeeded()
    }
    
    func seedIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: seededKey) else {
            loadPersistedLists()
            return
        }
        seedAll()
        UserDefaults.standard.set(true, forKey: seededKey)
        persistProfile()
        persistLists()
    }
    
    private func loadPersistedLists() {
        let d = UserDefaults.standard
        if let data = d.data(forKey: "unp_beverages"), let v = try? JSONDecoder().decode([UNPBeverage].self, from: data) { beverages = v }
        if let data = d.data(forKey: "unp_nudges"), let v = try? JSONDecoder().decode([UNPNudge].self, from: data) { nudges = v }
        if let data = d.data(forKey: "unp_events"), let v = try? JSONDecoder().decode([UNPEvent].self, from: data) { events = v }
        if let data = d.data(forKey: "unp_circles"), let v = try? JSONDecoder().decode([UNPPourCircleGroup].self, from: data) { circleGroups = v }
        if let data = d.data(forKey: "unp_circle_act"), let v = try? JSONDecoder().decode([UNPCircleActivity].self, from: data) { circleActivities = v }
        if let data = d.data(forKey: "unp_ledger"), let v = try? JSONDecoder().decode([UNPRewardLedgerEntry].self, from: data) { rewardLedger = v }
        if let data = d.data(forKey: "unp_amb_uploads"), let v = try? JSONDecoder().decode([UNPBeverage].self, from: data) { ambassadorUploads = v }
    }
    
    func persistLists() {
        let d = UserDefaults.standard
        if let data = try? JSONEncoder().encode(beverages) { d.set(data, forKey: "unp_beverages") }
        if let data = try? JSONEncoder().encode(nudges) { d.set(data, forKey: "unp_nudges") }
        if let data = try? JSONEncoder().encode(events) { d.set(data, forKey: "unp_events") }
        if let data = try? JSONEncoder().encode(circleGroups) { d.set(data, forKey: "unp_circles") }
        if let data = try? JSONEncoder().encode(circleActivities) { d.set(data, forKey: "unp_circle_act") }
        if let data = try? JSONEncoder().encode(rewardLedger) { d.set(data, forKey: "unp_ledger") }
        if let data = try? JSONEncoder().encode(ambassadorUploads) { d.set(data, forKey: "unp_amb_uploads") }
    }
    
    func persistProfile() {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: profileKey)
        }
    }
    
    func markFirstRunComplete() {
        firstRunCompleted = true
        UserDefaults.standard.set(true, forKey: tourKey)
    }
    
    func restartTour() {
        guidedTourStepIndex = 0
        showGuidedTourOverlay = true
    }
    
    func dismissTour() {
        showGuidedTourOverlay = false
    }
    
    func applyMonthlyResetIfNeeded() {
        let cal = Calendar.current
        let now = Date()
        let m = cal.component(.month, from: now)
        let y = cal.component(.year, from: now)
        if user.lastPointsResetMonth != m || user.lastPointsResetYear != y {
            user.pointsEarnedThisMonth = 0
            user.lastPointsResetMonth = m
            user.lastPointsResetYear = y
            persistProfile()
        }
    }
    
    func addPoints(_ pts: Int, action: UNPRewardAction, label: String) {
        user.rewardPoints += pts
        user.pointsEarnedThisMonth += pts
        rewardLedger.insert(
            UNPRewardLedgerEntry(id: UUID(), action: action, points: pts, label: label, date: Date()),
            at: 0
        )
        refreshRewardTier()
        persistProfile()
        persistLists()
    }
    
    private func refreshRewardTier() {
        let p = user.rewardPoints
        if p >= UNPRewardTierName.gold.minPoints {
            user.rewardTier = .gold
        } else if p >= UNPRewardTierName.silver.minPoints {
            user.rewardTier = .silver
        } else {
            user.rewardTier = .bronze
        }
    }
    
    func upsertAmbassadorBeverage(_ b: UNPBeverage) {
        if let i = ambassadorUploads.firstIndex(where: { $0.id == b.id }) {
            ambassadorUploads[i] = b
        } else {
            ambassadorUploads.append(b)
        }
        persistLists()
    }
    
    func deleteAmbassadorBeverage(id: UUID) {
        ambassadorUploads.removeAll { $0.id == id }
        persistLists()
    }
    
    func messages(for eventId: UUID) -> [UNPCommunityMessage] {
        (eventCommunityMessages[eventId] ?? []).sorted { $0.timestamp < $1.timestamp }
    }
    
    func postCommunityMessage(eventId: UUID, authorName: String, text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var existing = eventCommunityMessages[eventId] ?? []
        existing.append(
            UNPCommunityMessage(
                id: UUID(),
                eventId: eventId,
                authorName: authorName,
                text: trimmed,
                timestamp: Date()
            )
        )
        eventCommunityMessages[eventId] = existing
    }
    
    // MARK: - Seed
    
    private func seedAll() {
        let ids = (0..<8).map { _ in UUID() }
        
        beverages = [
            UNPBeverage(
                id: ids[0],
                name: "Midnight Old Fashioned",
                shortDescription: "Smoked bourbon, demerara, aromatic bitters — Detroit slow pour.",
                imageSymbolName: "wineglass.fill",
                ingredients: ["2 oz bourbon", "0.25 oz demerara", "2 dashes aromatic bitters", "Orange peel"],
                pairingNotes: "Sharp cheddar, dark chocolate, live jazz.",
                fullRecipe: "Stir over ice for 30s. Strain over large cube. Express orange oils.",
                relatedIds: [ids[1], ids[2]]
            ),
            UNPBeverage(
                id: ids[1],
                name: "Copper Sour",
                shortDescription: "Citrus lift with amaro depth and a frothy cap.",
                imageSymbolName: "cup.and.saucer.fill",
                ingredients: ["1.5 oz rye", "0.75 oz lemon", "0.5 oz amaro", "Egg white"],
                pairingNotes: "Fried oysters, pickled veg.",
                fullRecipe: "Dry shake, wet shake, double strain into coupe.",
                relatedIds: [ids[0], ids[3]]
            ),
            UNPBeverage(
                id: ids[2],
                name: "Riverfront Spritz",
                shortDescription: "Aperitivo sparkle with local sparkling and bitter citrus.",
                imageSymbolName: "bubbles.and.sparkles.fill",
                ingredients: ["2 oz bitter aperitif", "3 oz sparkling", "Grapefruit wheel"],
                pairingNotes: "Charcuterie, patio sunsets.",
                fullRecipe: "Build in wine glass over ice, top with sparkling.",
                relatedIds: [ids[1]]
            ),
            UNPBeverage(
                id: ids[3],
                name: "Ambassador's Negroni",
                shortDescription: "Barrel-rested gin, vermouth, Campari — stirred, never rushed.",
                imageSymbolName: "flame.fill",
                ingredients: ["1 oz gin", "1 oz sweet vermouth", "1 oz bitter aperitif"],
                pairingNotes: "Salami, olives, loud laughter.",
                fullRecipe: "Stir all ingredients with ice. Strain over rock.",
                relatedIds: [ids[0]]
            ),
            UNPBeverage(
                id: ids[4],
                name: "Late Night Espresso Martini",
                shortDescription: "Velvet coffee kick for the after-hours crowd.",
                imageSymbolName: "moon.stars.fill",
                ingredients: ["1.5 oz vodka", "1 oz espresso", "0.5 oz coffee liqueur"],
                pairingNotes: "Tiramisu, vinyl sets.",
                fullRecipe: "Shake hard, fine strain into chilled coupe.",
                relatedIds: [ids[5]]
            ),
            UNPBeverage(
                id: ids[5],
                name: "Honey & Smoke Highball",
                shortDescription: "Peated whisky lengthened with honey tonic.",
                imageSymbolName: "leaf.fill",
                ingredients: ["1.5 oz peated whisky", "Honey tonic top", "Lemon"],
                pairingNotes: "BBQ skewers, rooftop breeze.",
                fullRecipe: "Build in collins glass, express lemon.",
                relatedIds: [ids[4]]
            )
        ]
        
        nudges = [
            UNPNudge(
                id: UUID(),
                title: "Tonight's Nudge",
                heroSubtitle: "Curated for Detroit — March rhythm",
                basicText: "Start with a bitter spritz, slide into a stirred cocktail, end with a highball.",
                pollOptions: ["Spritz first", "Stirred first", "Surprise me"],
                paidPlanSteps: [
                    "7:30 PM — Spritz at the riverfront patio",
                    "9:00 PM — Stirred classic at the lounge",
                    "11:30 PM — Highball at the late room"
                ],
                linkedEventIds: [],
                linkedBeverageIds: [ids[2], ids[0]]
            ),
            UNPNudge(
                id: UUID(),
                title: "Adventure: Vinyl & Vermouth",
                heroSubtitle: "Low lights, high fidelity",
                basicText: "Pair a negroni flight with a soul set — vote your opener.",
                pollOptions: ["Negroni", "Boulevardier", "Americano"],
                paidPlanSteps: ["Arrive for opening set", "Order flight", "Toast the encore"],
                linkedEventIds: [],
                linkedBeverageIds: [ids[3]]
            ),
            UNPNudge(
                id: UUID(),
                title: "Waterfront Wander",
                heroSubtitle: "Golden hour to moonrise",
                basicText: "Walk the river, pause for one perfect pour.",
                pollOptions: ["Sunset start", "Moonrise start"],
                paidPlanSteps: ["Walk", "Pause", "Pour"],
                linkedEventIds: [],
                linkedBeverageIds: [ids[2]]
            )
        ]
        
        let cal = Calendar.current
        let today = Date()
        func ev(_ dayOffset: Int, hour: Int, t: UNPTimeOfDay, name: String, venue: String, desc: String, lat: Double, lon: Double) -> UNPEvent {
            let start = cal.date(byAdding: .day, value: dayOffset, to: today)
                .flatMap { cal.date(bySettingHour: hour, minute: 0, second: 0, of: $0) } ?? today
            return UNPEvent(
                id: UUID(),
                name: name,
                venueName: venue,
                startTime: start,
                endTime: start.addingTimeInterval(3 * 3600),
                description: desc,
                latitude: lat,
                longitude: lon,
                timeCategory: t,
                howToAttend: "RSVP in app, arrive 15 min early, ID at door.",
                relatedBeverageIds: [ids[0], ids[2]],
                relatedNudgeIds: []
            )
        }
        
        events = [
            ev(0, hour: 18, t: .day, name: "Riverfront Jazz & Spritz", venue: "Atwater Deck", desc: "Daytime jazz trio and spritz specials.", lat: 42.3314, lon: -83.0458),
            ev(1, hour: 20, t: .night, name: "Midnight Vinyl Sessions", venue: "Corktown Listening Room", desc: "Soul, funk, and stirred classics.", lat: 42.3310, lon: -83.0650),
            ev(2, hour: 22, t: .lateNight, name: "Late Room: Highball Hour", venue: "Downtown Social", desc: "DJ + extended highball menu.", lat: 42.3350, lon: -83.0500),
            ev(3, hour: 19, t: .night, name: "Ambassador Takeover", venue: "Nelson Cocktail Lounge", desc: "Guest shifts and signature pours.", lat: 42.3400, lon: -83.0550)
        ]
        
        circleGroups = [
            UNPPourCircleGroup(
                id: UUID(),
                name: "Detroit Pour Collective",
                memberCount: 128,
                lastActivitySummary: "12 saves · 4 RSVPs in the last hour",
                chatPreview: [
                    "Maya: Who's doing the riverfront spritz first?",
                    "Jordan: Stirred room at 9 — meet at the mural.",
                    "UNP: Tonight's plan link dropped in Paid tier."
                ],
                sharedPlanSummary: "Tonight: Spritz → Stirred → Highball (synced)",
                perks: ["+50 pts this week for group RSVP", "Ambassador shout-out on the feed"]
            )
        ]
        
        circleActivities = [
            UNPCircleActivity(id: UUID(), userName: "Maya K.", action: "saved Midnight Old Fashioned", timestamp: Date().addingTimeInterval(-300)),
            UNPCircleActivity(id: UUID(), userName: "Chris L.", action: "RSVP'd Riverfront Jazz", timestamp: Date().addingTimeInterval(-900)),
            UNPCircleActivity(id: UUID(), userName: "Sam R.", action: "completed Tonight's Plan", timestamp: Date().addingTimeInterval(-1200))
        ]
        
        rewardLedger = [
            UNPRewardLedgerEntry(id: UUID(), action: .save, points: 25, label: "Saved recipe", date: Date().addingTimeInterval(-4000)),
            UNPRewardLedgerEntry(id: UUID(), action: .share, points: 15, label: "Shared event", date: Date().addingTimeInterval(-8000)),
            UNPRewardLedgerEntry(id: UUID(), action: .planCompletion, points: 50, label: "Finished plan", date: Date().addingTimeInterval(-12000))
        ]
        
        if !nudges.isEmpty, !events.isEmpty {
            var n0 = nudges[0]
            n0.linkedEventIds = [events[0].id]
            nudges[0] = n0
        }
        
        seedCommunityMessages()
    }
    
    private func seedCommunityMessages() {
        guard !events.isEmpty else { return }
        let names = ["Saad", "Rosalie", "Caroline", "Andrew", "Maya"]
        let lines = [
            "This spot was amazing last time, who's arriving early?",
            "Loved the cocktail flight here - definitely worth trying.",
            "Sharing my experience after tonight's event!",
            "Any recommendations before we order?",
            "Let's meet near the entrance at 8:15."
        ]
        
        var seeded: [UUID: [UNPCommunityMessage]] = [:]
        for (eventIndex, event) in events.enumerated() {
            var eventMsgs: [UNPCommunityMessage] = []
            for i in 0..<3 {
                eventMsgs.append(
                    UNPCommunityMessage(
                        id: UUID(),
                        eventId: event.id,
                        authorName: names[(eventIndex + i) % names.count],
                        text: lines[(eventIndex + i) % lines.count],
                        timestamp: Date().addingTimeInterval(Double(-3600 * (i + 1)))
                    )
                )
            }
            seeded[event.id] = eventMsgs.sorted { $0.timestamp < $1.timestamp }
        }
        eventCommunityMessages = seeded
    }
    
    func demoScreenshotCatalog() -> [UNPDemoScreenshotItem] {
        let j = UNPDemoJourney.self
        return [
            UNPDemoScreenshotItem(id: "h1", title: "Home — Hero cards", journey: .home, roles: [.free, .paid, .ambassador]),
            UNPDemoScreenshotItem(id: "p1", title: "Pour — Recipe detail", journey: .pour, roles: [.free, .paid, .ambassador]),
            UNPDemoScreenshotItem(id: "p2", title: "Pour — Ambassador tools", journey: .pour, roles: [.ambassador]),
            UNPDemoScreenshotItem(id: "n1", title: "Nudge — Tonight's plan", journey: .nudge, roles: [.paid, .ambassador]),
            UNPDemoScreenshotItem(id: "n2", title: "Nudge — Poll (Free)", journey: .nudge, roles: [.free]),
            UNPDemoScreenshotItem(id: "e1", title: "Explore — Map", journey: .explore, roles: [.free, .paid, .ambassador]),
            UNPDemoScreenshotItem(id: "e2", title: "Explore — Event detail", journey: .explore, roles: [.paid, .ambassador]),
            UNPDemoScreenshotItem(id: "c1", title: "Circles — Chat", journey: .circles, roles: [.paid, .ambassador]),
            UNPDemoScreenshotItem(id: "c2", title: "Circles — Teaser (Free)", journey: .circles, roles: [.free]),
            UNPDemoScreenshotItem(id: "pr1", title: "Profile — Rewards", journey: .profile, roles: [.free, .paid, .ambassador])
        ]
    }
}
