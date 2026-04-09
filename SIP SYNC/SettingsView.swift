//
//  SettingsView.swift
//  SIP SYNC
//
//  Created by AI Assistant - UX Journey Implementation
//

import SwiftUI

// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject var theme: AppTheme
    @Environment(\.presentationMode) var presentationMode
    @State private var notificationsEnabled = true
    @State private var locationServicesEnabled = true
    @State private var showLogoutAlert = false
    @State private var showPaymentMethods = false
    @State private var showAddresses = false
    @State private var showNotifications = false
    
    var body: some View {
        ZStack {
            theme.primaryBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(theme.textPrimary)
                                .font(.title3)
                                .padding(8)
                                .background(theme.inputBackground)
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        Text("Settings")
                            .font(.headline)
                            .foregroundColor(theme.textPrimary)
                        
                        Spacer()
                        
                        Color.clear
                            .frame(width: 40, height: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // Account Section
                    SettingsSection(title: "Account") {
                        SettingsRow(icon: "creditcard.fill", title: "Payment Methods", action: {
                            showPaymentMethods = true
                        })
                        SettingsRow(icon: "location.fill", title: "Saved Addresses", action: {
                            showAddresses = true
                        })
                        SettingsRow(icon: "bell.fill", title: "Notifications", action: {
                            showNotifications = true
                        })
                    }
                    .padding(.horizontal, 20)
                    
                    // Preferences Section
                    SettingsSection(title: "Preferences") {
                        SettingsRow(icon: "location.fill", title: "Location Services", action: {}, hasToggle: true, toggleValue: $locationServicesEnabled)
                        SettingsRow(icon: "paintbrush.fill", title: "Appearance", action: {})
                        SettingsRow(icon: "globe", title: "Language", action: {})
                    }
                    .padding(.horizontal, 20)
                    
                    // Support Section
                    SettingsSection(title: "Support") {
                        SettingsRow(icon: "questionmark.circle.fill", title: "Help Center", action: {})
                        SettingsRow(icon: "envelope.fill", title: "Contact Us", action: {})
                        SettingsRow(icon: "doc.text.fill", title: "Terms of Service", action: {})
                        SettingsRow(icon: "lock.shield.fill", title: "Privacy Policy", action: {})
                    }
                    .padding(.horizontal, 20)
                    
                    // About Section
                    SettingsSection(title: "About") {
                        SettingsRow(icon: "info.circle.fill", title: "Version", subtitle: "1.0.0", action: {})
                        SettingsRow(icon: "star.fill", title: "Rate App", action: {})
                    }
                    .padding(.horizontal, 20)
                    
                    // Logout Button
                    Button(action: {
                        showLogoutAlert = true
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Logout")
                        }
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.red.opacity(0.5), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .alert("Logout", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                // Handle logout
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        .sheet(isPresented: $showPaymentMethods) {
            PaymentMethodsSheet()
        }
        .sheet(isPresented: $showAddresses) {
            AddressesSheet()
        }
        .sheet(isPresented: $showNotifications) {
            NotificationsSettingsSheet()
        }
    }
}

// MARK: - Settings Section
struct SettingsSection<Content: View>: View {
    @EnvironmentObject var theme: AppTheme
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(theme.textPrimary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                content
            }
            .background(theme.inputBackground)
            .cornerRadius(16)
        }
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    @EnvironmentObject var theme: AppTheme
    let icon: String
    let title: String
    var subtitle: String? = nil
    var hasToggle: Bool = false
    @Binding var toggleValue: Bool
    let action: () -> Void
    
    init(icon: String, title: String, subtitle: String? = nil, action: @escaping () -> Void, hasToggle: Bool = false, toggleValue: Binding<Bool> = .constant(false)) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.hasToggle = hasToggle
        self._toggleValue = toggleValue
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(theme.accent)
                    .font(.title3)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(theme.textPrimary)
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(theme.textSecondary)
                    }
                }
                
                Spacer()
                
                if hasToggle {
                    Toggle("", isOn: $toggleValue)
                        .labelsHidden()
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundColor(theme.textSecondary)
                        .font(.caption)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppTheme.shared)
}

