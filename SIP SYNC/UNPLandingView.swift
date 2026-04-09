//
//  UNPLandingView.swift
//  Home — "Your Next Pour"
//

import SwiftUI

/// Hero cards + header for “Your Next Pour”, embedded in `HomeView` or standalone `UNPLandingView`.
struct UNPLandingHeroSection: View {
    @EnvironmentObject private var store: UNPDataStore
    
    private var beverageOfDay: UNPBeverage {
        store.beverages.first ?? store.beverages[0]
    }
    private var tonightsNudge: UNPNudge {
        store.nudges.first ?? store.nudges[0]
    }
    private var featuredEvent: UNPEvent {
        store.events.first ?? store.events[0]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header
            
            Text("Your Next Pour")
                .font(.unpDisplay(28, weight: .bold))
                .foregroundStyle(UNPColors.cream)
            
            Text("Three ways into tonight — always curated, never empty.")
                .font(.unpBody(15))
                .foregroundStyle(UNPColors.creamMuted())
            
            VStack(spacing: 16) {
                NavigationLink {
                    UNPPourJourneyView(highlightId: beverageOfDay.id)
                } label: {
                    heroCard(
                        title: "Beverage of the Day",
                        subtitle: beverageOfDay.name,
                        detail: beverageOfDay.shortDescription,
                        icon: "sparkles"
                    )
                }
                .buttonStyle(.plain)
                
                NavigationLink {
                    UNPNudgeJourneyView(highlightId: tonightsNudge.id)
                } label: {
                    heroCard(
                        title: "Tonight's Nudge",
                        subtitle: tonightsNudge.title,
                        detail: tonightsNudge.heroSubtitle,
                        icon: "moon.stars.fill"
                    )
                }
                .buttonStyle(.plain)
                
                NavigationLink {
                    UNPExploreJourneyView(highlightId: featuredEvent.id)
                } label: {
                    heroCard(
                        title: "Events Near You",
                        subtitle: featuredEvent.name,
                        detail: "\(featuredEvent.venueName) · \(UNPLandingView.formatTime(featuredEvent.startTime))",
                        icon: "mappin.and.ellipse"
                    )
                }
                .buttonStyle(.plain)
                
                NavigationLink {
                    UNPPourCircleView()
                } label: {
                    heroCard(
                        title: "Pour Circles",
                        subtitle: "Shared plans & chat",
                        detail: "Circles and activity for your tier.",
                        icon: "person.3.fill"
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .background(UNPColors.background.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: UNPRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: UNPRadius.card, style: .continuous)
                .stroke(UNPColors.accent.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome back,")
                    .font(.unpBody(14))
                    .foregroundStyle(UNPColors.creamMuted())
                Text(store.user.displayName)
                    .font(.unpDisplay(20, weight: .semibold))
                    .foregroundStyle(UNPColors.cream)
            }
            Spacer()
            Text(store.user.rewardTier.displayName)
                .font(.caption.weight(.semibold))
                .foregroundStyle(UNPColors.background)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(UNPColors.accent)
                .clipShape(Capsule())
        }
    }
    
    private func heroCard(title: String, subtitle: String, detail: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(UNPColors.accent)
                .frame(width: 44, height: 44)
                .background(UNPColors.accent.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: UNPRadius.small, style: .continuous))
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title.uppercased())
                    .font(.caption.weight(.bold))
                    .foregroundStyle(UNPColors.creamMuted(0.55))
                Text(subtitle)
                    .font(.unpDisplay(18, weight: .semibold))
                    .foregroundStyle(UNPColors.cream)
                Text(detail)
                    .font(.unpBody(14))
                    .foregroundStyle(UNPColors.creamMuted())
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .foregroundStyle(UNPColors.creamMuted(0.35))
        }
        .padding(16)
        .unpCard()
    }
}

struct UNPLandingView: View {
    @EnvironmentObject private var store: UNPDataStore
    
    var body: some View {
        ScrollView {
            UNPLandingHeroSection()
        }
        .background(UNPColors.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Until The Next Pour")
                    .font(.headline)
                    .foregroundStyle(UNPColors.cream)
            }
        }
    }
    
    static func formatTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .none
        f.timeStyle = .short
        return f.string(from: date)
    }
}

#Preview("UNP Landing") {
    NavigationStack {
        UNPLandingView()
    }
    .environmentObject(UNPDataStore.shared)
}
