//
//  UNPPourJourneyView.swift
//  Pour — beverages & recipes
//

import SwiftUI

struct UNPPourJourneyView: View {
    @EnvironmentObject private var store: UNPDataStore
    var highlightId: UUID?
    
    @State private var searchText = ""
    @State private var selectedBeverage: UNPBeverage?
    @State private var showAmbassadorUpload = false
    @State private var showManageUploads = false
    
    private var allBeverages: [UNPBeverage] {
        store.beverages + store.ambassadorUploads
    }
    
    private var filtered: [UNPBeverage] {
        let base = allBeverages
        guard !searchText.isEmpty else { return base }
        let q = searchText.lowercased()
        return base.filter {
            $0.name.lowercased().contains(q)
                || $0.shortDescription.lowercased().contains(q)
                || $0.ingredients.joined(separator: " ").lowercased().contains(q)
                || $0.pairingNotes.lowercased().contains(q)
                || $0.fullRecipe.lowercased().contains(q)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                searchField
                
                if store.user.isBeverageAmbassador {
                    ambassadorBar
                }
                
                LazyVStack(spacing: 14) {
                    ForEach(filtered) { bev in
                        Button {
                            selectedBeverage = bev
                        } label: {
                            UNPBeverageRowCard(beverage: bev, tier: store.user.accessTier)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                similarRow
            }
            .padding(20)
        }
        .background(UNPColors.background.ignoresSafeArea())
        .navigationTitle("Pour")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            if let hid = highlightId,
               let match = allBeverages.first(where: { $0.id == hid }) {
                selectedBeverage = match
            }
        }
        .sheet(item: $selectedBeverage) { bev in
            UNPBeverageDetailSheet(beverage: bev, tier: store.user.accessTier, isAmbassadorOwned: store.ambassadorUploads.contains(where: { $0.id == bev.id }))
        }
        .sheet(isPresented: $showAmbassadorUpload) {
            UNPAmbassadorUploadSheet()
        }
        .sheet(isPresented: $showManageUploads) {
            NavigationStack {
                UNPAmbassadorManageList()
            }
        }
    }
    
    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(UNPColors.creamMuted())
            TextField("Search beverages", text: $searchText)
                .foregroundStyle(UNPColors.cream)
                .textInputAutocapitalization(.never)
        }
        .padding(12)
        .background(UNPColors.cardSurface)
        .clipShape(RoundedRectangle(cornerRadius: UNPRadius.small, style: .continuous))
    }
    
    private var ambassadorBar: some View {
        HStack(spacing: 12) {
            Button {
                showAmbassadorUpload = true
            } label: {
                Label("Upload recipe", systemImage: "square.and.arrow.up.fill")
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(.borderedProminent)
            .tint(UNPColors.accent)
            
            Button {
                showManageUploads = true
            } label: {
                Label("Manage", systemImage: "slider.horizontal.3")
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(.bordered)
            .tint(UNPColors.cream)
        }
    }
    
    private var similarRow: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Similar beverages")
                .font(.unpDisplay(18, weight: .semibold))
                .foregroundStyle(UNPColors.cream)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(store.beverages.prefix(6)) { bev in
                        Button {
                            selectedBeverage = bev
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Image(systemName: bev.imageSymbolName)
                                    .font(.title2)
                                    .foregroundStyle(UNPColors.accent)
                                Text(bev.name)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(UNPColors.cream)
                                    .lineLimit(2)
                            }
                            .frame(width: 120, height: 88)
                            .padding(8)
                            .background(UNPColors.cardSurface)
                            .clipShape(RoundedRectangle(cornerRadius: UNPRadius.small, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

struct UNPBeverageRowCard: View {
    let beverage: UNPBeverage
    let tier: UNPAccessTier
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: beverage.imageSymbolName)
                .font(.title2)
                .foregroundStyle(UNPColors.accent)
                .frame(width: 48, height: 48)
                .background(UNPColors.accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: UNPRadius.small, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(beverage.name)
                    .font(.headline)
                    .foregroundStyle(UNPColors.cream)
                Text(beverage.shortDescription)
                    .font(.subheadline)
                    .foregroundStyle(UNPColors.creamMuted())
                    .lineLimit(2)
                if tier != .paid {
                    Text("Full recipe · Paid")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(UNPColors.accent)
                }
            }
            Spacer()
        }
        .padding(14)
        .unpCard()
    }
}

struct UNPBeverageDetailSheet: View {
    @EnvironmentObject private var store: UNPDataStore
    @Environment(\.dismiss) private var dismiss
    let beverage: UNPBeverage
    let tier: UNPAccessTier
    var isAmbassadorOwned: Bool
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Image(systemName: beverage.imageSymbolName)
                        .font(.system(size: 56))
                        .foregroundStyle(UNPColors.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    
                    Text(beverage.name)
                        .font(.title.bold())
                        .foregroundStyle(UNPColors.cream)
                    Text(beverage.shortDescription)
                        .foregroundStyle(UNPColors.creamMuted())
                    
                    if tier == .paid {
                        section("Full recipe", beverage.fullRecipe)
                        section("Ingredients", beverage.ingredients.joined(separator: "\n"))
                        section("Pairing", beverage.pairingNotes)
                        relatedList
                    } else {
                        lockedBlock
                    }
                }
                .padding(20)
            }
            .background(UNPColors.background)
            .navigationTitle("Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(UNPColors.accent)
                }
            }
        }
        .presentationDetents([.large])
    }
    
    private var lockedBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preview")
                .font(.headline)
                .foregroundStyle(UNPColors.cream)
            Text(String(beverage.fullRecipe.prefix(120)) + "…")
                .foregroundStyle(UNPColors.creamMuted())
            Button {
                // Subscribe flow would hook StoreKit here
            } label: {
                Text("Subscribe to unlock full recipe")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(UNPColors.accent)
                    .foregroundStyle(UNPColors.background)
                    .clipShape(RoundedRectangle(cornerRadius: UNPRadius.small, style: .continuous))
            }
        }
        .padding()
        .background(UNPColors.cardSurface)
        .clipShape(RoundedRectangle(cornerRadius: UNPRadius.card, style: .continuous))
    }
    
    private func section(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(UNPColors.accent)
            Text(body)
                .foregroundStyle(UNPColors.cream)
        }
    }
    
    private var relatedList: some View {
        let related = store.beverages.filter { beverage.relatedIds.contains($0.id) }
        return Group {
            if !related.isEmpty {
                Text("Related beverages")
                    .font(.headline)
                    .foregroundStyle(UNPColors.cream)
                ForEach(related) { r in
                    Text("· \(r.name)")
                        .foregroundStyle(UNPColors.creamMuted())
                }
            }
        }
    }
}

struct UNPAmbassadorUploadSheet: View {
    @EnvironmentObject private var store: UNPDataStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var desc = ""
    @State private var ingredients = ""
    @State private var pairing = ""
    @State private var recipe = ""
    @State private var symbol = "wineglass.fill"
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Recipe") {
                    TextField("Name", text: $name)
                    TextField("Description", text: $desc, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("SF Symbol name", text: $symbol)
                    TextField("Ingredients (comma-separated)", text: $ingredients, axis: .vertical)
                    TextField("Pairing notes", text: $pairing, axis: .vertical)
                    TextField("Full recipe", text: $recipe, axis: .vertical)
                        .lineLimit(4...10)
                }
            }
            .scrollContentBackground(.hidden)
            .background(UNPColors.background)
            .navigationTitle("New recipe")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Publish") {
                        let ing = ingredients.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                        let bev = UNPBeverage(
                            id: UUID(),
                            name: name.isEmpty ? "Untitled pour" : name,
                            shortDescription: desc.isEmpty ? "Ambassador upload" : desc,
                            imageSymbolName: symbol,
                            ingredients: ing.isEmpty ? ["See recipe"] : ing,
                            pairingNotes: pairing.isEmpty ? "Chef's choice" : pairing,
                            fullRecipe: recipe.isEmpty ? desc : recipe,
                            relatedIds: Array(store.beverages.prefix(2).map(\.id))
                        )
                        store.ambassadorUploads.append(bev)
                        store.addPoints(75, action: .recipeUpload, label: "Recipe published")
                        store.persistLists()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

struct UNPAmbassadorManageList: View {
    @EnvironmentObject private var store: UNPDataStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            ForEach(store.ambassadorUploads) { b in
                VStack(alignment: .leading, spacing: 6) {
                    Text(b.name)
                        .font(.headline)
                    Text("Engagement · demo +128 saves")
                        .font(.caption)
                        .foregroundStyle(UNPColors.creamMuted())
                }
                .listRowBackground(UNPColors.cardSurface)
            }
            .onDelete { offsets in
                for i in offsets {
                    store.deleteAmbassadorBeverage(id: store.ambassadorUploads[i].id)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(UNPColors.background)
        .navigationTitle("Your uploads")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") { dismiss() }
            }
        }
    }
}

#Preview("UNP Pour") {
    NavigationStack {
        UNPPourJourneyView()
    }
    .environmentObject(UNPDataStore.shared)
}

#Preview("UNP Ambassador uploads") {
    NavigationStack {
        UNPAmbassadorManageList()
    }
    .environmentObject(UNPDataStore.shared)
}

#Preview("UNP Beverage detail") {
    UNPBeverageDetailSheet(
        beverage: UNPDataStore.shared.beverages[0],
        tier: .paid,
        isAmbassadorOwned: false
    )
    .environmentObject(UNPDataStore.shared)
}

#Preview("UNP Ambassador upload") {
    UNPAmbassadorUploadSheet()
        .environmentObject(UNPDataStore.shared)
}
