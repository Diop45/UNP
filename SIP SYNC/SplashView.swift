//
//  SplashView.swift
//  SIP SYNC
//
//  Created by Diop Shumake on 10/23/25.
//

import SwiftUI

// MARK: - Name Entry View
struct NameEntryView: View {
    @State private var name: String = ""
    @State private var showMainApp = false
    
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
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // App Icon Logo
                    Image("SipSyncLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .cornerRadius(20)
                    
                    // App name
                    Text("SIP SYNC")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                    
                    // Name entry form
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("What's your name?")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            TextField("Enter your name", text: $name)
                                .textFieldStyle(CustomTextFieldStyle())
                                .autocapitalization(.words)
                                .submitLabel(.done)
                                .onSubmit {
                                    if !name.trimmingCharacters(in: .whitespaces).isEmpty {
                                        saveNameAndContinue()
                                    }
                                }
                        }
                        
                        Button(action: {
                            saveNameAndContinue()
                        }) {
                            Text("Continue")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    name.trimmingCharacters(in: .whitespaces).isEmpty
                                        ? LinearGradient(
                                            gradient: Gradient(colors: [Color.gray, Color.gray]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                        : LinearGradient(
                                            gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                )
                                .cornerRadius(28)
                        }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
            }
        }
    }
    
    private func saveNameAndContinue() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        // Save name to UserDefaults
        UserDefaults.standard.set(trimmedName, forKey: "userName")
        
        // Create user with just the name
        let user = User(
            name: trimmedName,
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
        
        // Update UserManager
        UserManager.shared.updateUser(user)
        
        // Navigate to main app
        withAnimation {
            showMainApp = true
        }
    }
}

struct SplashView: View {
    @State private var isActive = false
    @State private var showNameEntry = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive {
            ContentView()
        } else if showNameEntry {
            NameEntryView()
        } else {
            ZStack {
                // Dark purple background
                Color(red: 0.1, green: 0.05, blue: 0.2)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // App Icon Logo
                    Image("SipSyncLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .cornerRadius(20)
                    
                    // App name
                    Text("SIP SYNC")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Get Started button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showNameEntry = true
                        }
                    }) {
                        Text("Get Started")
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
            .onAppear {
                // Check if user name already exists
                if let savedName = UserDefaults.standard.string(forKey: "userName"), !savedName.isEmpty {
                    // User already has a name, go directly to app
                    let user = User(
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
                    UserManager.shared.updateUser(user)
                    isActive = true
                } else {
                    // Show splash animation
                    withAnimation(.easeInOut(duration: 1.2)) {
                        self.size = 0.9
                        self.opacity = 1.0
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}

