//
//  BartenderBadge.swift
//  SIP SYNC
//
//  Sip Sync Bartender Badge Component
//

import SwiftUI

// MARK: - Sip Sync Bartenders Badge
struct SipSyncBartendersBadge: View {
    let bartenders: [SocialUser]
    @State private var showBartenderDetails = false
    @State private var selectedBartender: SocialUser?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.yellow)
                    .font(.headline)
                Text("Sip Sync Bartender")
                    .font(.headline)
                    .foregroundColor(.black)
                Text("\(bartenders.count)")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(8)
            }
            
            // Bartender Cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(bartenders) { bartender in
                        BartenderMiniCard(bartender: bartender) {
                            selectedBartender = bartender
                            showBartenderDetails = true
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.yellow.opacity(0.1),
                    Color.orange.opacity(0.05)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
        )
        .sheet(isPresented: $showBartenderDetails) {
            if let bartender = selectedBartender {
                BartenderQuickDetailSheet(bartender: bartender)
            }
        }
    }
}

// MARK: - Bartender Mini Card
struct BartenderMiniCard: View {
    let bartender: SocialUser
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                // Profile Image
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
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "wineglass.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(bartender.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .lineLimit(1)
                        if bartender.verified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.yellow)
                                .font(.caption2)
                        }
                    }
                    
                    if let location = bartender.location {
                        Text(location)
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding(8)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: 200)
    }
}

// MARK: - Bartender Detail Sheet (Quick View)
struct BartenderQuickDetailSheet: View {
    let bartender: SocialUser
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Profile Header
                    VStack(spacing: 12) {
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
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "wineglass.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 40))
                            )
                        
                        VStack(spacing: 4) {
                            HStack(spacing: 4) {
                                Text(bartender.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                if bartender.verified {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.yellow)
                                        .font(.title3)
                                }
                            }
                            
                            Text("@\(bartender.username)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            if let location = bartender.location {
                                HStack(spacing: 4) {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                    Text(location)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding(.top, 4)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    
                    // Sip Sync Badge
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.yellow)
                        Text("Sip Sync Verified Bartender")
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(12)
                    
                    // About Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .font(.headline)
                            .foregroundColor(.black)
                        Text("Professional mixologist specializing in craft cocktails and premium spirits.")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                }
                .padding(20)
            }
            .background(Color.white)
            .navigationTitle("Bartender Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
        }
    }
}

#Preview {
    let sampleBartender = SocialUser(
        name: "Miranda Lrouge",
        username: "miranda.Lrouge",
        userType: .bartender,
        location: "PORT",
        verified: true
    )
    
    return SipSyncBartendersBadge(bartenders: [sampleBartender])
        .padding()
}

