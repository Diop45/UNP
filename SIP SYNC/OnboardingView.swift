//
//  OnboardingView.swift
//  SIP SYNC
//
//  Created by AI Assistant - UX Journey Implementation
//

import SwiftUI
import PhotosUI

// MARK: - Onboarding Data Model
struct OnboardingData {
    var name: String = ""
    var email: String = ""
    var userType: UserType = .consumer
    var profileImage: UIImage? = nil
    var location: String = ""
    var bio: String = ""
    var profession: String = ""
    var languages: [String] = []
    var interests: Set<DrinkInterest> = []
    var instagramHandle: String = ""
    var twitterHandle: String = ""
}

// MARK: - Onboarding Flow
struct OnboardingView: View {
    @State private var currentStep = 0
    @State private var onboardingData = OnboardingData()
    @State private var showMainApp = false
    @State private var selectedPhoto: PhotosPickerItem? = nil
    
    // Pass initial data from auth
    var initialName: String = ""
    var initialEmail: String = ""
    var initialUserType: UserType = .consumer
    
    init(name: String = "", email: String = "", userType: UserType = .consumer) {
        self.initialName = name
        self.initialEmail = email
        self.initialUserType = userType
    }
    
    var body: some View {
        if showMainApp {
            ContentView()
        } else {
            ZStack {
                // Dark purple background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.15, green: 0.1, blue: 0.25),
                        Color(red: 0.1, green: 0.05, blue: 0.2)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress indicator
                    ProgressBar(currentStep: currentStep, totalSteps: totalSteps)
                        .padding(.horizontal, 20)
                        .padding(.top, 60)
                    
                    TabView(selection: $currentStep) {
                        // Step 1: Profile Photo
                        ProfilePhotoStep(
                            profileImage: $onboardingData.profileImage,
                            selectedPhoto: $selectedPhoto
                        ) {
                            withAnimation {
                                currentStep = 1
                            }
                        }
                        .tag(0)
                        
                        // Step 2: Basic Info (Name, Location)
                        BasicInfoStep(
                            name: $onboardingData.name,
                            location: $onboardingData.location
                        ) {
                            withAnimation {
                                currentStep = 2
                            }
                        }
                        .tag(1)
                        
                        // Step 3: Bio & Profession
                        BioProfessionStep(
                            bio: $onboardingData.bio,
                            profession: $onboardingData.profession,
                            userType: onboardingData.userType
                        ) {
                            withAnimation {
                                currentStep = 3
                            }
                        }
                        .tag(2)
                        
                        // Step 4: Languages
                        LanguagesStep(
                            languages: $onboardingData.languages
                        ) {
                            withAnimation {
                                currentStep = 4
                            }
                        }
                        .tag(3)
                        
                        // Step 5: Interests
                        InterestsStep(
                            interests: $onboardingData.interests
                        ) {
                            withAnimation {
                                currentStep = 5
                            }
                        }
                        .tag(4)
                        
                        // Step 6: Social Media (Optional)
                        SocialMediaStep(
                            instagramHandle: $onboardingData.instagramHandle,
                            twitterHandle: $onboardingData.twitterHandle
                        ) {
                            // Complete onboarding
                            completeOnboarding()
                        }
                        .tag(5)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .disabled(true) // Disable swipe, use buttons only
                }
            }
            .onAppear {
                onboardingData.name = initialName
                onboardingData.email = initialEmail
                onboardingData.userType = initialUserType
            }
            .onChange(of: selectedPhoto) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        onboardingData.profileImage = image
                    }
                }
            }
        }
    }
    
    private var totalSteps: Int {
        6
    }
    
    private func completeOnboarding() {
        // Create user from onboarding data
        let user = UserManager.shared.createUser(from: onboardingData)
        UserManager.shared.updateUser(user)
        
        // Navigate to main app
        showMainApp = true
    }
}

// MARK: - Progress Bar
struct ProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { step in
                RoundedRectangle(cornerRadius: 2)
                    .fill(step <= currentStep ? Color.yellow : Color.gray.opacity(0.3))
                    .frame(height: 4)
            }
        }
    }
}

// MARK: - Step 1: Profile Photo
struct ProfilePhotoStep: View {
    @Binding var profileImage: UIImage?
    @Binding var selectedPhoto: PhotosPickerItem?
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("Add Your Photo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Let others see who you are")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
            
            // Profile Photo Preview
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                ZStack {
                    if let profileImage = profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.yellow.opacity(0.3),
                                        Color.orange.opacity(0.3)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 40))
                            )
                    }
                }
                .frame(width: 200, height: 200)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.yellow, lineWidth: 4)
                )
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            
            if profileImage == nil {
                Button(action: {
                    // Photo picker will handle selection
                }) {
                    Text("Choose Photo")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(Color.yellow.opacity(0.2))
                        .cornerRadius(20)
                }
            }
            
            Spacer()
            
            Button(action: onContinue) {
                Text("Continue")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.yellow, Color.orange]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(28)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
    }
}

// MARK: - Step 2: Basic Info
struct BasicInfoStep: View {
    @Binding var name: String
    @Binding var location: String
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("Tell Us About Yourself")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("We'll use this to personalize your experience")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
            
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Full Name")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    TextField("Enter your name", text: $name)
                        .textFieldStyle(CustomTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Location")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    TextField("City, State", text: $location)
                        .textFieldStyle(CustomTextFieldStyle())
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: onContinue) {
                Text("Continue")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        !name.isEmpty && !location.isEmpty
                            ? LinearGradient(
                                gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            : LinearGradient(
                                gradient: Gradient(colors: [Color.gray, Color.gray]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                    )
                    .cornerRadius(28)
            }
            .disabled(name.isEmpty || location.isEmpty)
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
    }
}

// MARK: - Step 3: Bio & Profession
struct BioProfessionStep: View {
    @Binding var bio: String
    @Binding var profession: String
    let userType: UserType
    let onContinue: () -> Void
    
    private var professionPlaceholder: String {
        switch userType {
        case .consumer:
            return "e.g., Cocktail Enthusiast, Mixology Explorer"
        case .bartender:
            return "e.g., Master Mixologist, Craft Cocktail Specialist"
        case .venue:
            return "e.g., Bar Owner, Venue Manager"
        }
    }
    
    private var bioPlaceholder: String {
        switch userType {
        case .consumer:
            return "Tell us about your passion for drinks and cocktails..."
        case .bartender:
            return "Share your experience, specialties, and what makes you unique..."
        case .venue:
            return "Describe your venue, atmosphere, and what you offer..."
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                Spacer()
                    .frame(height: 20)
                
                VStack(spacing: 16) {
                    Text("Your Professional Profile")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Help others understand who you are")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)
                
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Profession / Title")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        TextField(professionPlaceholder, text: $profession)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bio")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        TextEditor(text: $bio)
                            .frame(height: 120)
                            .padding(12)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                            )
                            .scrollContentBackground(.hidden)
                        
                        Text("\(bio.count) / 200")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                    .frame(height: 40)
                
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(28)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
}

// MARK: - Step 4: Languages
struct LanguagesStep: View {
    @Binding var languages: [String]
    let onContinue: () -> Void
    
    private let commonLanguages = [
        "English", "Spanish", "French", "German", "Italian",
        "Portuguese", "Japanese", "Chinese", "Korean", "Arabic",
        "Russian", "Dutch", "Swedish", "Norwegian", "Danish"
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                Spacer()
                    .frame(height: 20)
                
                VStack(spacing: 16) {
                    Text("Languages You Speak")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Select all languages you're comfortable with")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(commonLanguages, id: \.self) { language in
                        LanguageTag(
                            language: language,
                            isSelected: languages.contains(language),
                            onToggle: {
                                if languages.contains(language) {
                                    languages.removeAll { $0 == language }
                                } else {
                                    languages.append(language)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                    .frame(height: 40)
                
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(28)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
}

// MARK: - Language Tag
struct LanguageTag: View {
    let language: String
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            Text(language)
                .font(.subheadline)
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    isSelected
                        ? Color.yellow
                        : Color.black.opacity(0.3)
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 2)
                )
        }
    }
}

// MARK: - Step 5: Interests
struct InterestsStep: View {
    @Binding var interests: Set<DrinkInterest>
    let onContinue: () -> Void
    
    private let maxSelection = 7
    private var isAtLimit: Bool { interests.count >= maxSelection }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer()
                    .frame(height: 20)
                
                VStack(spacing: 16) {
                    Text("What Are You Into?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Select up to \(maxSelection) favorite drinks and spirits")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    if !interests.isEmpty {
                        Text("\(interests.count) selected")
                            .font(.caption)
                            .foregroundColor(.yellow)
                            .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 40)
                
                // Spirits Section
                interestSection(title: "Spirits", items: [
                    (.whiskey, "takeoutbag.and.cup.and.straw", Color.orange),
                    (.bourbon, "flame", Color.red),
                    (.scotch, "drop", Color.blue),
                    (.gin, "leaf", Color.green),
                    (.tequila, "sun.max", Color.yellow),
                    (.rum, "sailboat", Color.purple),
                    (.vodka, "snow", Color.cyan)
                ])
                
                // Cocktails Section
                interestSection(title: "Cocktails", items: [
                    (.negroni, "wineglass", Color.red),
                    (.martini, "martini.glass", Color.blue),
                    (.oldFashioned, "cube", Color.orange),
                    (.spritz, "sparkles", Color.yellow),
                    (.margarita, "tortilla", Color.green),
                    (.manhattan, "building.2", Color.purple)
                ])
                
                // Wine, Beer & NA Section
                interestSection(title: "Wine, Beer & NA", items: [
                    (.redWine, "wineglass", Color.red),
                    (.whiteWine, "wineglass", Color.yellow),
                    (.sparkling, "sparkles", Color.cyan),
                    (.ipa, "hare", Color.orange),
                    (.lager, "circle", Color.blue),
                    (.stout, "circle.fill", Color.black),
                    (.mocktails, "bubble", Color.green)
                ])
                
                Spacer()
                    .frame(height: 40)
                
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(28)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
    
    private func interestSection(title: String, items: [(DrinkInterest, String, Color)]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 40)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(items, id: \.0) { (interest, icon, color) in
                    InterestSelectionTag(
                        interest: interest,
                        icon: icon,
                        color: color,
                        isSelected: interests.contains(interest),
                        isDisabled: !interests.contains(interest) && isAtLimit,
                        onToggle: {
                            toggle(interest)
                        }
                    )
                }
            }
            .padding(.horizontal, 40)
        }
    }
    
    private func toggle(_ interest: DrinkInterest) {
        if interests.contains(interest) {
            interests.remove(interest)
        } else {
            if !isAtLimit {
                interests.insert(interest)
            }
        }
    }
}

// MARK: - Interest Selection Tag
struct InterestSelectionTag: View {
    let interest: DrinkInterest
    let icon: String
    let color: Color
    let isSelected: Bool
    let isDisabled: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(isSelected ? .black : color)
                
                Text(interest.rawValue)
                    .font(.caption)
                    .foregroundColor(isSelected ? .black : .white)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                isSelected
                    ? Color.yellow
                    : (isDisabled ? Color.gray.opacity(0.2) : Color.black.opacity(0.3))
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 2)
            )
            .opacity(isDisabled ? 0.5 : 1.0)
        }
        .disabled(isDisabled)
    }
}

// MARK: - Step 6: Social Media (Optional)
struct SocialMediaStep: View {
    @Binding var instagramHandle: String
    @Binding var twitterHandle: String
    let onContinue: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                Spacer()
                    .frame(height: 20)
                
                VStack(spacing: 16) {
                    Text("Connect Your Socials")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Optional - Link your social media accounts")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)
                
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "camera.fill")
                                .foregroundColor(.yellow)
                            Text("Instagram")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        TextField("@username", text: $instagramHandle)
                            .textFieldStyle(CustomTextFieldStyle())
                            .autocapitalization(.none)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "bird.fill")
                                .foregroundColor(.yellow)
                            Text("Twitter / X")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        TextField("@username", text: $twitterHandle)
                            .textFieldStyle(CustomTextFieldStyle())
                            .autocapitalization(.none)
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                    .frame(height: 40)
                
                Button(action: onContinue) {
                    Text("Complete Setup")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(28)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    OnboardingView()
}
