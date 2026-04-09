//
//  UNPProfileShellView.swift
//

import SwiftUI

struct UNPProfileShellView: View {
    @EnvironmentObject private var store: UNPDataStore
    @State private var showSettings = false
    @State private var showDemoPage = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(store.user.displayName)
                            .font(.title.bold())
                            .foregroundStyle(UNPColors.cream)
                        roleLine
                    }
                    Spacer()
                }
                
                rewardsCard
                
                if store.user.isBeverageAmbassador {
                    NavigationLink {
                        UNPAmbassadorManageList()
                    } label: {
                        HStack {
                            Image(systemName: "square.stack.3d.up.fill")
                            Text("Ambassador uploads")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .foregroundStyle(UNPColors.cream)
                        .padding()
                        .unpCard()
                    }
                    .buttonStyle(.plain)
                }
                
                Button {
                    showSettings = true
                } label: {
                    Label("Settings", systemImage: "gearshape.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(UNPColors.accent)
                
                Button {
                    showDemoPage = true
                } label: {
                    Label("Demo screenshots", systemImage: "photo.on.rectangle.angled")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(UNPColors.cream)
            }
            .padding(20)
        }
        .background(UNPColors.background.ignoresSafeArea())
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showSettings) {
            UNPSettingsView()
        }
        .sheet(isPresented: $showDemoPage) {
            UNPDemoScreenshotsPage()
        }
    }
    
    private var roleLine: some View {
        HStack(spacing: 8) {
            Text(store.user.accessTier.displayName)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(UNPColors.accent)
            if store.user.isBeverageAmbassador {
                Text("Ambassador")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(UNPColors.background)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(UNPColors.creamMuted(0.6))
                    .clipShape(Capsule())
            }
        }
    }
    
    private var rewardsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Rewards")
                .font(.headline)
                .foregroundStyle(UNPColors.accent)
            Text("Tier: \(store.user.rewardTier.displayName)")
                .foregroundStyle(UNPColors.cream)
            Text("Points: \(store.user.rewardPoints) · This month: \(store.user.pointsEarnedThisMonth)")
                .font(.subheadline)
                .foregroundStyle(UNPColors.creamMuted())
            ChartStrip(entries: store.rewardLedger.prefix(8))
        }
        .padding()
        .unpCard()
    }
}

struct ChartStrip: View {
    let entries: ArraySlice<UNPRewardLedgerEntry>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Recent engagement")
                .font(.caption.weight(.semibold))
                .foregroundStyle(UNPColors.creamMuted())
            ForEach(Array(entries)) { e in
                HStack {
                    Text(e.label)
                        .font(.caption2)
                        .foregroundStyle(UNPColors.cream)
                    Spacer()
                    Text("+\(e.points)")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(UNPColors.accent)
                }
                GeometryReader { geo in
                    let w = max(4, CGFloat(e.points) / 100 * geo.size.width)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(UNPColors.accent.opacity(0.4))
                        .frame(width: w, height: 6)
                }
                .frame(height: 8)
            }
        }
    }
}

struct UNPSettingsView: View {
    @EnvironmentObject private var store: UNPDataStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Preferences") {
                    Toggle("Notifications", isOn: Binding(
                        get: { store.user.notificationsEnabled },
                        set: { store.user.notificationsEnabled = $0; store.persistProfile() }
                    ))
                    Button("Restart guided tour") {
                        store.restartTour()
                        dismiss()
                    }
                    Button("Manage subscription") {
                        // StoreKit integration point
                    }
                }
                Section("About") {
                    Text("Until The Next Pour v1.0")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview("UNP Profile") {
    NavigationStack {
        UNPProfileShellView()
    }
    .environmentObject(UNPDataStore.shared)
}

#Preview("UNP Chart strip") {
    ChartStrip(entries: UNPDataStore.shared.rewardLedger.prefix(8))
        .padding()
        .background(UNPColors.background)
}

#Preview("UNP Settings") {
    UNPSettingsView()
        .environmentObject(UNPDataStore.shared)
}
