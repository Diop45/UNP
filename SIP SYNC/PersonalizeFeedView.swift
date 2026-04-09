//
//  PersonalizeFeedView.swift
//  SIP SYNC
//
//  Two-step personalization flow: Mood (feelings) then Drinks by Bartenders
//

import SwiftUI

// MARK: - Mood Enum
enum Mood: String, CaseIterable, Identifiable {
    case happy = "Happy"
    case relaxed = "Relaxed"
    case energetic = "Energetic"
    case romantic = "Romantic"
    case celebratory = "Celebratory"
    case sophisticated = "Sophisticated"
    case adventurous = "Adventurous"
    case cozy = "Cozy"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .happy: return "face.smiling"
        case .relaxed: return "leaf.fill"
        case .energetic: return "bolt.fill"
        case .romantic: return "heart.fill"
        case .celebratory: return "party.popper.fill"
        case .sophisticated: return "crown.fill"
        case .adventurous: return "mountain.2.fill"
        case .cozy: return "house.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .happy: return .yellow
        case .relaxed: return .green
        case .energetic: return UNPColors.creamMuted()
        case .romantic: return .pink
        case .celebratory: return .purple
        case .sophisticated: return .blue
        case .adventurous: return .red
        case .cozy: return .brown
        }
    }
    
    var description: String {
        switch self {
        case .happy: return "Feeling joyful and upbeat"
        case .relaxed: return "Want to unwind and chill"
        case .energetic: return "Ready to party and have fun"
        case .romantic: return "Looking for something intimate"
        case .celebratory: return "Time to celebrate and toast"
        case .sophisticated: return "Seeking refined elegance"
        case .adventurous: return "Ready to try something bold"
        case .cozy: return "Want comfort and warmth"
        }
    }
    
    // Map mood to appropriate drink categories and types
    var associatedCategories: [DrinkCategory] {
        switch self {
        case .happy, .celebratory, .relaxed, .cozy, .energetic, .romantic, .sophisticated, .adventurous:
            return [.drinks]
        }
    }
    
    var associatedDrinkNames: [String] {
        switch self {
        case .happy:
            return ["Spritzer"]
        case .relaxed:
            return ["Scotch & Bourbon", "Spritzer"]
        case .energetic:
            return ["Negroni"]
        case .romantic:
            return ["Martini"]
        case .celebratory:
            return ["Spritzer"]
        case .sophisticated:
            return ["Martini", "Negroni"]
        case .adventurous:
            return ["Negroni"]
        case .cozy:
            return ["Scotch & Bourbon"]
        }
    }
}

struct PersonalizeFeedView: View {
    @Binding var selectedInterests: Set<DrinkInterest>
    var onDone: (() -> Void)?
    
    @State private var currentStep: PersonalizationStep = .mood
    @State private var selectedMoods: Set<Mood> = []
    @State private var selectedDrinkIds: Set<UUID> = []
    
    private let sampleData = SampleData.shared
    
    enum PersonalizationStep {
        case mood
        case drinks
    }
    
    var body: some View {
        ZStack {
            // Dark purple background matching the rest of the app
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.15, green: 0.1, blue: 0.25).opacity(0.95),
                    Color(red: 0.1, green: 0.05, blue: 0.2).opacity(0.95)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    if currentStep == .drinks {
                        Button(action: {
                            withAnimation {
                                currentStep = .mood
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    } else {
                        Button(action: { onDone?() }) {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                    
                    Spacer()
                    
                    // SipSync Logo
                    Image("SIP SYNC LOGO")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 32)
                    
                    Spacer()
                    
                    // Spacer for balance
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        if currentStep == .mood {
                            moodStepView
                        } else {
                            drinksStepView
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
                
                // Bottom bar with continue button
                HStack {
                    if currentStep == .mood {
                        Text("\(selectedMoods.count) Selected")
                            .font(.body)
                            .foregroundColor(.white)
                    } else {
                        Text("\(selectedDrinkIds.count) Selected")
                            .font(.body)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if currentStep == .mood {
                            withAnimation {
                                currentStep = .drinks
                            }
                        } else {
                            // Convert selected drinks to interests and save
                            convertDrinksToInterests()
                            // Small delay to ensure state updates propagate
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                onDone?()
                            }
                        }
                    }) {
                        Text(currentStep == .mood ? "Continue" : "Done")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 48)
                            .background(canContinue ? Color.black : Color.gray)
                            .cornerRadius(24)
                    }
                    .disabled(!canContinue)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 34)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.15, green: 0.1, blue: 0.25).opacity(0.95),
                            Color(red: 0.1, green: 0.05, blue: 0.2).opacity(0.95)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
    }
    
    // MARK: - Mood Step View
    
    private var moodStepView: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Title section
            VStack(alignment: .leading, spacing: 8) {
                Text("How are you feeling?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Select the moods that match how you're feeling right now.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Moods grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(Mood.allCases) { mood in
                    MoodCard(
                        mood: mood,
                        isSelected: selectedMoods.contains(mood),
                        action: {
                            toggleMood(mood)
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Drinks Step View
    
    private var drinksStepView: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Title section
            VStack(alignment: .leading, spacing: 8) {
                Text("Select drinks by bartenders")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Choose from available drinks on Until The Next Pour by our bartenders.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Filter drinks by selected moods
            let filteredDrinks = getDrinksForMoods(selectedMoods)
            
            if filteredDrinks.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "wineglass")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No drinks available")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("Please select at least one category")
                        .font(.subheadline)
                        .foregroundColor(.gray.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            } else {
                // Drinks grid - 2 columns
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(filteredDrinks) { drink in
                        DrinkSelectionCard(
                            drink: drink,
                            isSelected: selectedDrinkIds.contains(drink.id),
                            action: {
                                toggleDrink(drink)
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var canContinue: Bool {
        switch currentStep {
        case .mood:
            return !selectedMoods.isEmpty
        case .drinks:
            return !selectedDrinkIds.isEmpty
        }
    }
    
    // MARK: - Helper Functions
    
    private func toggleMood(_ mood: Mood) {
        if selectedMoods.contains(mood) {
            selectedMoods.remove(mood)
        } else {
            selectedMoods.insert(mood)
        }
    }
    
    private func getDrinksForMoods(_ moods: Set<Mood>) -> [Drink] {
        guard !moods.isEmpty else { return [] }
        
        // Collect all associated drink names from selected moods
        var drinkNames: Set<String> = []
        for mood in moods {
            for drinkName in mood.associatedDrinkNames {
                drinkNames.insert(drinkName)
            }
        }
        
        // Filter drinks that match the mood associations, excluding food and social items (classes)
        return sampleData.sampleDrinks.filter { drink in
            drink.category == .drinks && (
                drinkNames.contains(drink.name) || 
                moods.contains { mood in
                    mood.associatedCategories.contains(drink.category)
                }
            )
        }
    }
    
    private func toggleDrink(_ drink: Drink) {
        if selectedDrinkIds.contains(drink.id) {
            selectedDrinkIds.remove(drink.id)
        } else {
            selectedDrinkIds.insert(drink.id)
        }
    }
    
    private func convertDrinksToInterests() {
        // Convert selected drinks to drink interests
        var interests: Set<DrinkInterest> = []
        
        let selectedDrinks = sampleData.sampleDrinks.filter { selectedDrinkIds.contains($0.id) }
        
        for drink in selectedDrinks {
            // Map drink names to interests
            let drinkName = drink.name.lowercased()
            let drinkContent = (drink.name + " " + drink.bio + " " + drink.tags.joined(separator: " ")).lowercased()
            
            // Check for specific cocktails first (higher priority)
            if drinkContent.contains("negroni") {
                interests.insert(.negroni)
            }
            if drinkContent.contains("martini") {
                interests.insert(.martini)
            }
            if drinkContent.contains("old fashioned") || drinkContent.contains("oldfashioned") {
                interests.insert(.oldFashioned)
            }
            if drinkContent.contains("margarita") {
                interests.insert(.margarita)
            }
            if drinkContent.contains("manhattan") {
                interests.insert(.manhattan)
            }
            if drinkContent.contains("spritz") || drinkContent.contains("spritzer") {
                interests.insert(.spritz)
            }
            
            // Check for spirits
            if drinkContent.contains("scotch") {
                interests.insert(.scotch)
            }
            if drinkContent.contains("bourbon") {
                interests.insert(.bourbon)
            }
            if drinkContent.contains("whiskey") || drinkContent.contains("whisky") {
                interests.insert(.whiskey)
            }
            if drinkContent.contains("gin") {
                interests.insert(.gin)
            }
            if drinkContent.contains("tequila") {
                interests.insert(.tequila)
            }
            if drinkContent.contains("rum") {
                interests.insert(.rum)
            }
            if drinkContent.contains("vodka") {
                interests.insert(.vodka)
            }
            
            // Check for wine
            if drinkContent.contains("wine") {
                if drinkContent.contains("red wine") || drinkContent.contains("redwine") {
                    interests.insert(.redWine)
                } else if drinkContent.contains("white wine") || drinkContent.contains("whitewine") {
                    interests.insert(.whiteWine)
                } else {
                    // Default to red wine if just "wine" is mentioned
                    interests.insert(.redWine)
                }
            }
            if drinkContent.contains("sparkling") || drinkContent.contains("champagne") {
                interests.insert(.sparkling)
            }
            
            // Check for beer
            if drinkContent.contains("ipa") {
                interests.insert(.ipa)
            }
            if drinkContent.contains("lager") {
                interests.insert(.lager)
            }
            if drinkContent.contains("stout") {
                interests.insert(.stout)
            }
            
            // Check for non-alcoholic
            if drinkContent.contains("mocktail") || drinkContent.contains("non-alcoholic") || drinkContent.contains("nonalcoholic") {
                interests.insert(.mocktails)
            }
            
            // Map by category as fallback
            switch drink.category {
            case .drinks:
                // If no specific interest found, add general cocktail interests
                if interests.isEmpty {
                    interests.insert(.negroni) // Default cocktail interest
                }
            case .social:
                // Social experiences/classes are not included in personalization
                break
            case .food:
                // Food items are not included in personalization
                break
            }
        }
        
        // Update the binding - this will trigger feed refresh in HomeView
        selectedInterests = interests
    }
}

// MARK: - Mood Card

struct MoodCard: View {
    let mood: Mood
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected ? mood.color.opacity(0.2) : Color.gray.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: mood.icon)
                        .font(.system(size: 32))
                        .foregroundColor(isSelected ? mood.color : .gray)
                }
                
                VStack(spacing: 4) {
                    Text(mood.rawValue)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(mood.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(isSelected ? mood.color.opacity(0.2) : Color.white.opacity(0.1))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? mood.color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Drink Selection Card

struct DrinkSelectionCard: View {
    let drink: Drink
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    // Drink image - use actual asset if available
                    Group {
                        if let imageName = getImageName(for: drink.name) {
                            Image(imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            // Fallback to gradient with icon
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            getCategoryColor(for: drink.category).opacity(0.6),
                                            getCategoryColor(for: drink.category).opacity(0.3)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    Image(systemName: getSystemIcon(for: drink.category))
                                        .font(.system(size: 40))
                                        .foregroundColor(.white.opacity(0.8))
                                )
                        }
                    }
                    .frame(height: 120)
                    .clipped()
                    .cornerRadius(12)
                    
                    // Selection indicator
                    if isSelected {
                        ZStack {
                            Circle()
                                .fill(Color.yellow)
                                .frame(width: 28, height: 28)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.black)
                        }
                        .padding(8)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(drink.name)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(drink.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    if let bartender = getBartenderForDrink(drink) {
                        HStack(spacing: 4) {
                            Image(systemName: "person.fill")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.6))
                            Text(bartender.name)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                                .lineLimit(1)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(isSelected ? Color.yellow.opacity(0.2) : Color.white.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getBartenderForDrink(_ drink: Drink) -> SocialUser? {
        // Find a bartender who might serve this drink
        // This is a simplified version - in a real app, drinks would be linked to bartenders
        let sampleData = SampleData.shared
        let bartenders = sampleData.sampleSocialUsers.filter { $0.userType == .bartender }
        
        // Match by drink category or tags
        for bartender in bartenders {
            if bartender.location != nil {
                // Simple matching - in real app, this would be more sophisticated
                return bartender
            }
        }
        
        return bartenders.first
    }
    
    // MARK: - Image Helpers
    
    private func getImageName(for drinkName: String) -> String? {
        switch drinkName {
        case "Negroni":
            return "Negroni"
        case "Scotch & Bourbon":
            return "Scotch"
        case "Spritzer":
            return "Spritzer"
        case "Martini":
            return "Dirty Martini"
        case "Red Wine":
            return "Red Wine"
        case "White Wine":
            return "White Wine"
        default:
            return nil
        }
    }
    
    private func getSystemIcon(for category: DrinkCategory) -> String {
        switch category {
        case .drinks:
            return "wineglass.fill"
        case .food:
            return "fork.knife"
        case .social:
            return "person.2.fill"
        }
    }
    
    private func getCategoryColor(for category: DrinkCategory) -> Color {
        switch category {
        case .drinks:
            return .red
        case .food:
            return UNPColors.creamMuted()
        case .social:
            return .blue
        }
    }
}

#Preview("Personalize feed") {
    PersonalizeFeedView(selectedInterests: .constant([]), onDone: {})
}

