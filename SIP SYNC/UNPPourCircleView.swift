//
//  UNPPourCircleView.swift
//

import SwiftUI

struct UNPPourCircleView: View {
    @EnvironmentObject private var store: UNPDataStore
    private var group: UNPPourCircleGroup {
        store.circleGroups.first ?? UNPPourCircleGroup(
            id: UUID(),
            name: "Pour Circle",
            memberCount: 1,
            lastActivitySummary: "Welcome",
            chatPreview: ["Start the night"],
            sharedPlanSummary: "Plan your pour",
            perks: ["Join Paid for full Circle"]
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if store.user.accessTier != .paid {
                    freeTeaser
                } else {
                    paidContent
                }
            }
            .padding(20)
        }
        .background(UNPColors.background.ignoresSafeArea())
        .navigationTitle("Pour Circle")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var freeTeaser: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Pour Circle")
                .font(.title.bold())
                .foregroundStyle(UNPColors.cream)
            Text("Group chat, shared Tonight's Plan, rewards, and live activity — unlock with Paid.")
                .foregroundStyle(UNPColors.creamMuted())
            lockedRow(icon: "bubble.left.and.bubble.right.fill", title: "Group chat", subtitle: "Sync your crew in real time")
            lockedRow(icon: "calendar.badge.clock", title: "Shared planning", subtitle: "Linked to Tonight's Plan")
            lockedRow(icon: "gift.fill", title: "Perks & promos", subtitle: "Tier drops and venue hooks")
            Button {
                // Subscription
            } label: {
                Text("Upgrade to Paid")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(UNPColors.accent)
                    .foregroundStyle(UNPColors.background)
                    .clipShape(RoundedRectangle(cornerRadius: UNPRadius.small))
            }
        }
    }
    
    private func lockedRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(UNPColors.creamMuted(0.35))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(UNPColors.cream)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(UNPColors.creamMuted())
            }
            Spacer()
            Image(systemName: "lock.fill")
                .foregroundStyle(UNPColors.accent)
        }
        .padding()
        .unpCard()
    }
    
    private var paidContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(group.name)
                    .font(.title2.bold())
                    .foregroundStyle(UNPColors.cream)
                Spacer()
                tierBadge
            }
            Text(group.lastActivitySummary)
                .font(.subheadline)
                .foregroundStyle(UNPColors.creamMuted())
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Group chat")
                    .font(.headline)
                    .foregroundStyle(UNPColors.accent)
                ForEach(group.chatPreview, id: \.self) { line in
                    Text(line)
                        .foregroundStyle(UNPColors.cream)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(UNPColors.cardSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Shared Tonight's Plan")
                    .font(.headline)
                    .foregroundStyle(UNPColors.accent)
                Text(group.sharedPlanSummary)
                    .foregroundStyle(UNPColors.cream)
            }
            .padding()
            .unpCard()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Rewards")
                    .font(.headline)
                    .foregroundStyle(UNPColors.accent)
                Text("\(store.user.rewardTier.displayName) · \(store.user.rewardPoints) pts")
                    .foregroundStyle(UNPColors.cream)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Activity")
                    .font(.headline)
                    .foregroundStyle(UNPColors.accent)
                ForEach(store.circleActivities) { a in
                    HStack {
                        Text(a.userName)
                            .fontWeight(.semibold)
                            .foregroundStyle(UNPColors.cream)
                        Text(a.action)
                            .foregroundStyle(UNPColors.creamMuted())
                        Spacer()
                    }
                    .font(.subheadline)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Perks & promos")
                    .font(.headline)
                    .foregroundStyle(UNPColors.accent)
                ForEach(group.perks, id: \.self) { p in
                    Text("· \(p)")
                        .foregroundStyle(UNPColors.cream)
                }
            }
        }
    }
    
    private var tierBadge: some View {
        Text(store.user.rewardTier.displayName)
            .font(.caption.weight(.bold))
            .foregroundStyle(UNPColors.background)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(UNPColors.accent)
            .clipShape(Capsule())
    }
}

#Preview("UNP Circles") {
    NavigationStack {
        UNPPourCircleView()
    }
    .environmentObject(UNPDataStore.shared)
}
