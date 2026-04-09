//
//  UNPWelcomeLoginView.swift
//  Edge-to-edge welcome: full-bleed photo, centered logo + tagline, bottom pill CTAs (iOS 17+).
//

import AuthenticationServices
import SwiftUI
import UIKit

// MARK: - Welcome screen

struct UNPWelcomeLoginView: View {
    @EnvironmentObject private var unpStore: UNPDataStore
    var onTakeQuickTour: () -> Void
    var onAppleSignInSuccess: () -> Void
    @State private var showNameEntry = false
    @State private var enteredName = ""
    @State private var showMainApp = false

    private static let splashImageName = "LoginSplash"

    /// Horizontal inset so buttons are ~90% of screen width (5% margin each side).
    private func horizontalInset(for width: CGFloat) -> CGFloat { width * 0.05 }

    var body: some View {
        Group {
            if showMainApp {
                MainTabView()
                    .environmentObject(AppTheme.shared)
                    .environmentObject(UNPDataStore.shared)
            } else {
                GeometryReader { geo in
                    let inset = horizontalInset(for: geo.size.width)
                    
                    ZStack {
                        backgroundLayer(size: geo.size)
                            .ignoresSafeArea()
                        
                        // Soft vignette for legibility over bright sky / highlights
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.35),
                                Color.black.opacity(0.15),
                                Color.black.opacity(0.4)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .allowsHitTesting(false)
                        .ignoresSafeArea()
                        
                        VStack(spacing: 0) {
                            Spacer(minLength: 0)
                            
                            centerBranding
                                .padding(.horizontal, 24)
                            
                            Spacer(minLength: 0)
                            
                            bottomCTAStack
                                .padding(.horizontal, inset)
                                .padding(.bottom, 8)
                        }
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }
            }
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
        .modifier(UNPWelcomeStatusBarStyleModifier())
        .onAppear {
            syncPersistedNameIfNeeded()
            UNPWelcomeAppearance.pushLightStatusBarContent()
        }
        .onDisappear {
            UNPWelcomeAppearance.popLightStatusBarContent()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: Background (photo or gradient fallback)

    @ViewBuilder
    private func backgroundLayer(size: CGSize) -> some View {
        if UIImage(named: Self.splashImageName) != nil {
            Image(Self.splashImageName)
                .resizable()
                .scaledToFill()
                .frame(width: size.width, height: size.height)
                .clipped()
        } else {
            LinearGradient(
                colors: [
                    Color(red: 0.06, green: 0.05, blue: 0.07),
                    Color(red: 0.02, green: 0.02, blue: 0.03),
                    Color(red: 0.08, green: 0.05, blue: 0.04)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(width: size.width, height: size.height)
        }
    }

    // MARK: Center — small logo + 3–5 word tagline

    private var centerBranding: some View {
        VStack(spacing: 14) {
            Image("UNPLoginMark")
                .resizable()
                .renderingMode(.original)
                .scaledToFit()
                .frame(maxWidth: 200)
                .frame(maxHeight: 72)
                .accessibilityLabel("Until The Next Pour")

            Text("Until your next pour")
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(Color.white)
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.55), radius: 8, x: 0, y: 2)
                .shadow(color: .black.opacity(0.35), radius: 2, x: 0, y: 1)
        }
        .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 4)
    }

    // MARK: Bottom CTAs (~54pt, full pill ~27pt radius, 12pt gap)

    private var bottomCTAStack: some View {
        VStack(spacing: 12) {
            if showNameEntry {
                nameEntryStack
            } else {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showNameEntry = true
                    }
                } label: {
                    Text("Get Started")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [UNPColors.creamMuted(), UNPColors.creamMuted(0.65)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            
            Button(action: startQuickTourFlow) {
                Text("Take a quick tour")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color(white: 0.12))
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.white)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            SignInWithAppleButton(.signIn) { request in
                // Request is an ASAuthorizationAppleIDRequest produced by ASAuthorizationAppleIDProvider.
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                switch result {
                case .success:
                    onAppleSignInSuccess()
                case .failure:
                    break
                }
            }
            .signInWithAppleButtonStyle(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
    }
    
    private var nameEntryStack: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What's your name?")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.white.opacity(0.9))
            
            HStack(spacing: 10) {
                TextField("Enter your name", text: $enteredName)
                    .textInputAutocapitalization(.words)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .frame(height: 44)
                    .background(Color.black.opacity(0.35))
                    .clipShape(Capsule())
                
                Button {
                    saveNameAndContinue()
                } label: {
                    Text("Continue")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .frame(height: 44)
                        .background(
                            enteredName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? Color.gray
                            : UNPColors.accent
                        )
                        .clipShape(Capsule())
                }
                .disabled(enteredName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(Color.black.opacity(0.25))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
    
    private func saveNameAndContinue() {
        let trimmedName = enteredName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        UserDefaults.standard.set(trimmedName, forKey: "userName")
        
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
        UserManager.shared.updateUser(user)
        
        // Keep UNP profile name in sync so Home/Landing/Profile all show the same value.
        UNPDataStore.shared.user.displayName = trimmedName
        UNPDataStore.shared.persistProfile()
        
        withAnimation(.easeInOut(duration: 0.3)) {
            showMainApp = true
        }
    }
    
    private func syncPersistedNameIfNeeded() {
        let trimmed = UserDefaults.standard.string(forKey: "userName")?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !trimmed.isEmpty else { return }
        
        if UNPDataStore.shared.user.displayName != trimmed {
            UNPDataStore.shared.user.displayName = trimmed
            UNPDataStore.shared.persistProfile()
        }
    }

    private func startQuickTourFlow() {
        onTakeQuickTour()
        UserDefaults.standard.set(false, forKey: UNPTourKeys.completed)
        UNPDataStore.shared.showGuidedTourOverlay = true
        withAnimation(.easeInOut(duration: 0.3)) {
            showMainApp = true
        }
    }
}

// MARK: - Status bar (light content on dark hero)

private enum UNPWelcomeAppearance {
    private static var depth = 0

    static func pushLightStatusBarContent() {
        depth += 1
        guard depth == 1 else { return }
        applyLightStatusContent()
    }

    static func popLightStatusBarContent() {
        depth = max(0, depth - 1)
        guard depth == 0 else { return }
        resetWindowStyle()
    }

    private static func applyLightStatusContent() {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                window.overrideUserInterfaceStyle = .dark
            }
        }
    }

    private static func resetWindowStyle() {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                window.overrideUserInterfaceStyle = .unspecified
            }
        }
    }
}

/// Bridges to UIKit status bar so `preferredStatusBarStyle == .lightContent` while welcome is visible.
private struct UNPWelcomeStatusBarStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.background(UNPStatusBarConfigurator())
    }
}

private struct UNPStatusBarConfigurator: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UNPStatusBarViewController {
        UNPStatusBarViewController()
    }

    func updateUIViewController(_ uiViewController: UNPStatusBarViewController, context: Context) {}

    @available(iOS 16.0, *)
    func sizeThatFits(_ proposal: ProposedViewSize, uiViewController: UNPStatusBarViewController, context: Context) -> CGSize? {
        .zero
    }
}

private final class UNPStatusBarViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override var prefersStatusBarHidden: Bool { false }
}

#if DEBUG
#Preview {
    UNPWelcomeLoginView(
        onTakeQuickTour: {},
        onAppleSignInSuccess: {}
    )
    .environmentObject(UNPDataStore.shared)
}
#endif
