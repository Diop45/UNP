//
//  AuthFlowView.swift
//  SIP SYNC
//
//  Created by AI Assistant - UX Journey Implementation
//

import SwiftUI

// MARK: - Enhanced Authentication Flow
struct AuthFlowView: View {
    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var selectedUserType: UserType? = nil
    @State private var showOnboarding = false
    @State private var showMainApp = false
    @State private var isNewUser = false
    
    var body: some View {
        if showOnboarding {
            OnboardingView(
                name: name,
                email: email,
                userType: selectedUserType ?? .consumer
            )
        } else if showMainApp {
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
                    
                    // Auth form
                    VStack(spacing: 20) {
                        if isSignUp {
                            TextField("Name", text: $name)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        TextField("Email", text: $email)
                            .textFieldStyle(CustomTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(CustomTextFieldStyle())
                        
                        if isSignUp {
                            // User type selection for sign up
                            VStack(alignment: .leading, spacing: 12) {
                                Text("I am a:")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 4)
                                
                                HStack(spacing: 12) {
                                    ForEach(UserType.allCases, id: \.self) { type in
                                        Button(action: {
                                            selectedUserType = type
                                        }) {
                                            HStack {
                                                Image(systemName: iconForUserType(type))
                                                    .font(.caption)
                                                Text(type.rawValue)
                                                    .font(.subheadline)
                                            }
                                            .foregroundColor(selectedUserType == type ? .black : .white)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(
                                                selectedUserType == type
                                                    ? Color.yellow
                                                    : Color.black.opacity(0.3)
                                            )
                                            .cornerRadius(20)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        
                        Button(action: {
                            // Simulate authentication
                            if isSignUp {
                                // New user - go to onboarding
                                isNewUser = true
                                showOnboarding = true
                            } else {
                                // Existing user - go to main app
                                showMainApp = true
                            }
                        }) {
                            Text(isSignUp ? "Sign Up" : "Sign In")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    canProceed()
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
                        .disabled(!canProceed())
                        
                        Button(action: {
                            isSignUp.toggle()
                            selectedUserType = nil
                        }) {
                            Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                                .foregroundColor(.white)
                                .font(.subheadline)
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
            }
        }
    }
    
    private func canProceed() -> Bool {
        if isSignUp {
            return !email.isEmpty && !password.isEmpty && !name.isEmpty && selectedUserType != nil
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }
    
    private func iconForUserType(_ type: UserType) -> String {
        switch type {
        case .consumer: return "person.fill"
        case .bartender: return "wineglass.fill"
        case .venue: return "building.2.fill"
        }
    }
}

#Preview {
    AuthFlowView()
}

