//
//  UNPNudgeJourneyView.swift
//

import SwiftUI

struct UNPNudgeJourneyView: View {
    @EnvironmentObject private var store: UNPDataStore
    var highlightId: UUID?
    
    @State private var pollSelection: String?
    
    private var hero: UNPNudge {
        if let h = highlightId, let m = store.nudges.first(where: { $0.id == h }) {
            return m
        }
        return store.nudges[0]
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                heroCard(hero)
                
                ForEach(store.nudges) { n in
                    if n.id != hero.id {
                        nudgeCard(n)
                    }
                }
            }
            .padding(20)
        }
        .background(UNPColors.background.ignoresSafeArea())
        .navigationTitle("Nudge")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private func heroCard(_ n: UNPNudge) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tonight's Nudge")
                .font(.caption.weight(.bold))
                .foregroundStyle(UNPColors.accent)
            Text(n.title)
                .font(.title2.bold())
                .foregroundStyle(UNPColors.cream)
            Text(n.heroSubtitle)
                .font(.subheadline)
                .foregroundStyle(UNPColors.creamMuted())
            Divider().background(UNPColors.creamMuted(0.2))
            Text(n.basicText)
                .foregroundStyle(UNPColors.cream)
            
            Text("Tonight's vibe")
                .font(.headline)
                .foregroundStyle(UNPColors.cream)
            ForEach(n.pollOptions, id: \.self) { opt in
                Button {
                    pollSelection = opt
                    store.addPoints(10, action: .socialInteraction, label: "Poll vote")
                } label: {
                    HStack {
                        Text(opt)
                            .foregroundStyle(UNPColors.cream)
                        Spacer()
                        if pollSelection == opt {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(UNPColors.accent)
                        }
                    }
                    .padding(12)
                    .background(UNPColors.cardSurface)
                    .clipShape(RoundedRectangle(cornerRadius: UNPRadius.small, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            
            if store.user.accessTier != .paid {
                Text("Subscribe for Tonight's Plan — 3 curated stops with links to events & pours.")
                    .font(.subheadline)
                    .foregroundStyle(UNPColors.creamMuted())
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(UNPColors.accent.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: UNPRadius.small, style: .continuous))
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Tonight's Plan")
                        .font(.headline)
                        .foregroundStyle(UNPColors.accent)
                    ForEach(Array(n.paidPlanSteps.enumerated()), id: \.offset) { _, step in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "circle.fill")
                                .font(.caption2)
                                .foregroundStyle(UNPColors.accent)
                            Text(step)
                                .foregroundStyle(UNPColors.cream)
                        }
                    }
                    crossLinks(n)
                }
                .padding()
                .background(UNPColors.cardSurface)
                .clipShape(RoundedRectangle(cornerRadius: UNPRadius.card, style: .continuous))
            }
        }
        .padding(16)
        .unpCard()
    }
    
    private func crossLinks(_ n: UNPNudge) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Linked")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(UNPColors.creamMuted())
            let evs = store.events.filter { n.linkedEventIds.contains($0.id) }
            let bevs = store.beverages.filter { n.linkedBeverageIds.contains($0.id) }
            ForEach(evs) { e in
                NavigationLink {
                    UNPExploreJourneyView(highlightId: e.id)
                } label: {
                    Text("Event · \(e.name)")
                        .foregroundStyle(UNPColors.accent)
                }
            }
            ForEach(bevs) { b in
                NavigationLink {
                    UNPPourJourneyView(highlightId: b.id)
                } label: {
                    Text("Pour · \(b.name)")
                        .foregroundStyle(UNPColors.accent)
                }
            }
        }
    }
    
    private func nudgeCard(_ n: UNPNudge) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(n.title)
                .font(.headline)
                .foregroundStyle(UNPColors.cream)
            Text(n.basicText)
                .font(.subheadline)
                .foregroundStyle(UNPColors.creamMuted())
                .lineLimit(3)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .unpCard()
    }
}

#Preview("UNP Nudge") {
    NavigationStack {
        UNPNudgeJourneyView()
    }
    .environmentObject(UNPDataStore.shared)
}
