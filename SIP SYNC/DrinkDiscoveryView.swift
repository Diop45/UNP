//
//  DrinkDiscoveryView.swift
//  SIP SYNC
//
//  Created by AI Assistant on 10/28/25.
//

import SwiftUI

struct DrinkDiscoveryView: View {
    @Binding var selected: Set<DrinkInterest>
    var onDone: (() -> Void)?
    
    private let maxSelection = 7
    
    private var isAtLimit: Bool { selected.count >= maxSelection }
    
    var body: some View {
        ZStack {
            // Sophisticated gradient backdrop - 70% white, 30% yellow
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.white, location: 0.0),
                    .init(color: Color.white, location: 0.7),
                    .init(color: Color.yellow.opacity(0.3), location: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { onDone?() }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    // SipSync Logo
                    Image("SIP SYNC LOGO")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 32)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        // Title section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("What do you vibe with?")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            
                            Text("Select up to 7 drink interests to display on your profile.")
                                .font(.body)
                                .foregroundColor(.black.opacity(0.7))
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Spirits section
                        section(title: "Spirits", items: [
                            (.whiskey, "takeoutbag.and.cup.and.straw", .orange),
                            (.bourbon, "flame", .red),
                            (.scotch, "drop", .blue),
                            (.gin, "leaf", .green),
                            (.tequila, "sun.max", .yellow),
                            (.rum, "sailboat", .purple),
                            (.vodka, "snow", .cyan)
                        ])
                        
                        // Cocktails section
                        section(title: "Cocktails", items: [
                            (.negroni, "wineglass", .red),
                            (.martini, "martini.glass", .blue),
                            (.oldFashioned, "cube", .orange),
                            (.spritz, "sparkles", .yellow),
                            (.margarita, "tortilla", .green),
                            (.manhattan, "building.2", .purple)
                        ])
                        
                        // Wine, Beer & NA section
                        section(title: "Wine, Beer & NA", items: [
                            (.redWine, "wineglass", .red),
                            (.whiteWine, "wineglass", .yellow),
                            (.sparkling, "sparkles", .cyan),
                            (.ipa, "hare", .orange),
                            (.lager, "circle", .blue),
                            (.stout, "circle.fill", .black),
                            (.mocktails, "bubble", .green)
                        ])
                        
                        Spacer(minLength: 100)
                    }
                }
                
                // Bottom bar with counter and continue button
                HStack {
                    Text("\(selected.count)/\(maxSelection) Selected")
                        .font(.body)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(action: { onDone?() }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 48)
                            .background(selected.isEmpty ? Color.gray : Color.black)
                            .cornerRadius(24)
                    }
                    .disabled(selected.isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 34)
                .background(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.white, location: 0.0),
                            .init(color: Color.white, location: 0.7),
                            .init(color: Color.yellow.opacity(0.3), location: 1.0)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            }
        }
    }
    
    private func section(title: String, items: [(DrinkInterest, String, Color)]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.horizontal, 20)
            
            // Tags grid - 3 columns
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(items, id: \.0) { (interest, icon, color) in
                    SelectableTag(
                        title: interest.rawValue,
                        systemIcon: icon,
                        color: color,
                        isSelected: selected.contains(interest),
                        action: {
                            toggle(interest)
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func toggle(_ interest: DrinkInterest) {
        if selected.contains(interest) {
            selected.remove(interest)
        } else {
            if !isAtLimit {
                selected.insert(interest)
            }
        }
    }
}

#Preview {
    DrinkDiscoveryView(selected: .constant([]))
}


