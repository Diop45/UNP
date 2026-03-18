//
//  BartenderClassesView.swift
//  SIP SYNC
//
//  Created by AI Assistant on 10/28/25.
//

import SwiftUI

struct BartenderClassesView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var cartItems: [OrderItem]
    @State private var selectedClass: BartenderClass?
    @StateObject private var tipJarManager = TipJarManager.shared
    @State private var showSubscriptionPayment = false
    @State private var showInsufficientFundsAlert = false
    @State private var insufficientFundsMessage = ""
    @State private var showAddFundsSheet = false
    
    private let sampleData = SampleData.shared
    private let subscriptionPrice: Double = 9.99 // Monthly subscription price
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMMM d"
        return formatter
    }
    
    var body: some View {
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
                // Navigation Bar
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                            .font(.title3)
                            .padding(8)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("SipSync Originals")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Placeholder for balance
                    Color.clear
                        .frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)
                
                // Horizontal Scrollable Class Cards
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(sampleData.sampleBartenderClasses) { classItem in
                            BartenderClassCard(
                                classItem: classItem,
                                onTap: {
                                    selectedClass = classItem
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
                .padding(.bottom, 24)
                
                Spacer()
                
                // Bottom Section
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Get the party started with Classes")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("An SipSync Premium subscription is required to unlock classes.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    
                    Button(action: {
                        // Process subscription payment from tip jar
                        let result = tipJarManager.processSubscriptionPayment(amount: subscriptionPrice, subscriptionType: "Premium Monthly")
                        
                        if result.isSuccess {
                            // Subscription activated (in production, this would be handled by backend)
                            showSubscriptionPayment = false
                        } else {
                            // Show insufficient funds alert
                            if let errorMessage = result.errorMessage {
                                insufficientFundsMessage = errorMessage
                                showInsufficientFundsAlert = true
                            }
                        }
                    }) {
                        Text("Subscribe - $\(String(format: "%.2f", subscriptionPrice))/month")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.white)
                            .cornerRadius(28)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 34)
            }
        }
        .sheet(item: $selectedClass) { classItem in
            ClassDetailView(classItem: classItem, cartItems: $cartItems)
        }
        .alert("Insufficient Funds", isPresented: $showInsufficientFundsAlert) {
            Button("Add Funds") {
                showAddFundsSheet = true
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(insufficientFundsMessage)
        }
        .sheet(isPresented: $showAddFundsSheet) {
            AddFundsToTipJarSheet()
        }
    }
}

// MARK: - Bartender Class Card
struct BartenderClassCard: View {
    let classItem: BartenderClass
    let onTap: () -> Void
    
    private let sampleData = SampleData.shared
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMMM d"
        return formatter
    }
    
    // Get a unique image for each class card
    private var classCardImage: String {
        // Find matching bartender profile
        guard let profile = sampleData.sampleBartenderProfiles.first(where: { $0.author.id == classItem.bartender.id }) else {
            return classItem.image
        }
        
        // Get all classes by this bartender to determine which image to use
        let bartenderClasses = sampleData.sampleBartenderClasses.filter { $0.bartender.id == classItem.bartender.id }
        let classIndex = bartenderClasses.firstIndex(where: { $0.id == classItem.id }) ?? 0
        
        // Use profile image for first class, contentGallery images for subsequent classes
        if classIndex == 0 {
            return profile.profileImage
        } else {
            // Use images from contentGallery, cycling through them
            let galleryIndex = (classIndex - 1) % profile.contentGallery.count
            return profile.contentGallery[galleryIndex].image
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                // Class Image - use unique image for each class
                Image(classCardImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 300, height: 400)
                    .clipped()
                    .cornerRadius(16)
                
                // Gradient Overlay at Bottom
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        Color.black.opacity(0.3),
                        Color.black.opacity(0.7)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .cornerRadius(16)
                .frame(height: 400)
                
                // Top Elements
                VStack {
                    HStack {
                        // "Going" Badge
                        if classItem.isGoing {
                            Text("Going")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color(red: 0.7, green: 0.9, blue: 0.7))
                                .cornerRadius(8)
                        }
                        
                        Spacer()
                        
                        // Lock Icon (if locked)
                        if classItem.isLocked {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.white)
                                .font(.title3)
                                .padding(10)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                    }
                    .padding(12)
                    
                    Spacer()
                }
                
                // Bottom Info Overlay
                VStack(alignment: .leading, spacing: 6) {
                    // Attendee Profile Icons (above title)
                    if !classItem.attendees.isEmpty {
                        HStack(spacing: -6) {
                            ForEach(Array(classItem.attendees.prefix(3)), id: \.id) { attendee in
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.purple.opacity(0.9),
                                                Color.blue.opacity(0.9)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Text(String(attendee.name.prefix(1)))
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                            }
                            
                            // Additional attendees count
                            if classItem.attendees.count > 3 {
                                Circle()
                                    .fill(Color.white.opacity(0.9))
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Text("+\(classItem.attendees.count - 3)")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                            }
                        }
                        .padding(.bottom, 8)
                    }
                    
                    Text(classItem.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    Text("\(dateFormatter.string(from: classItem.date)), \(classItem.time)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text(classItem.location)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(width: 300, alignment: .leading)
                .padding(16)
            }
            .frame(width: 300, height: 400)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.4), radius: 12, x: 0, y: 6)
        }
    }
}

// MARK: - Class Detail View
struct ClassDetailView: View {
    let classItem: BartenderClass
    @Binding var cartItems: [OrderItem]
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var tipJarManager = TipJarManager.shared
    @State private var showInsufficientFundsAlert = false
    @State private var insufficientFundsMessage = ""
    @State private var showAddFundsSheet = false
    
    private let sampleData = SampleData.shared
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMMM d 'at' h:mm a"
        return formatter
    }
    
    var body: some View {
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
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Back Button
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.white)
                                .font(.title3)
                                .padding(8)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // Class Image - use unique image for each class
                    ZStack(alignment: .topTrailing) {
                        // Get unique image for this class
                        let classImage: String = {
                            guard let profile = sampleData.sampleBartenderProfiles.first(where: { $0.author.id == classItem.bartender.id }) else {
                                return classItem.image
                            }
                            
                            // Get all classes by this bartender to determine which image to use
                            let bartenderClasses = sampleData.sampleBartenderClasses.filter { $0.bartender.id == classItem.bartender.id }
                            let classIndex = bartenderClasses.firstIndex(where: { $0.id == classItem.id }) ?? 0
                            
                            // Use profile image for first class, contentGallery images for subsequent classes
                            if classIndex == 0 {
                                return profile.profileImage
                            } else {
                                // Use images from contentGallery, cycling through them
                                let galleryIndex = (classIndex - 1) % profile.contentGallery.count
                                return profile.contentGallery[galleryIndex].image
                            }
                        }()
                        
                        Image(classImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 300)
                            .clipped()
                            .cornerRadius(20)
                        
                        if classItem.isLocked {
                            VStack {
                                HStack {
                                    Spacer()
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.white)
                                        .font(.title)
                                        .padding(16)
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(Circle())
                                        .padding(16)
                                }
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Class Details
                    VStack(alignment: .leading, spacing: 16) {
                        Text(classItem.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        // Bartender Info
                        HStack(spacing: 12) {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.yellow.opacity(0.5),
                                            Color.orange.opacity(0.5)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Text(String(classItem.bartender.name.prefix(1)))
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(classItem.bartender.name)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                if let location = classItem.bartender.location {
                                    Text(location)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            
                            Spacer()
                        }
                        
                        // Date and Time
                        HStack(spacing: 12) {
                            Image(systemName: "calendar")
                                .foregroundColor(.yellow)
                            Text(dateFormatter.string(from: classItem.date) + ", \(classItem.time)")
                                .foregroundColor(.white)
                        }
                        .font(.subheadline)
                        
                        // Location
                        HStack(spacing: 12) {
                            Image(systemName: "location")
                                .foregroundColor(.yellow)
                            Text(classItem.location)
                                .foregroundColor(.white)
                        }
                        .font(.subheadline)
                        
                        // Description
                        Text(classItem.description)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(4)
                            .padding(.top, 8)
                        
                        // Attendees
                        if !classItem.attendees.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Attendees")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                HStack(spacing: 12) {
                                    ForEach(classItem.attendees, id: \.id) { attendee in
                                        VStack(spacing: 4) {
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            Color.yellow.opacity(0.5),
                                                            Color.orange.opacity(0.5)
                                                        ]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 50, height: 50)
                                                .overlay(
                                                    Text(String(attendee.name.prefix(1)))
                                                        .font(.headline)
                                                        .foregroundColor(.white)
                                                )
                                            
                                            Text(attendee.name.components(separatedBy: " ").first ?? "")
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                    }
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 100)
                }
            }
            
            // Bottom Action Button
            if classItem.isLocked {
                VStack {
                    Spacer()
                    Button(action: {
                        // Process class payment from tip jar
                        if let price = classItem.price {
                            let result = tipJarManager.processClassPayment(amount: price, classId: classItem.id)
                            
                            if result.isSuccess {
                                // Unlock the class (in production, this would be handled by backend)
                                // For now, we'll just show success
                                presentationMode.wrappedValue.dismiss()
                            } else {
                                // Show insufficient funds alert
                                if let errorMessage = result.errorMessage {
                                    insufficientFundsMessage = errorMessage
                                    showInsufficientFundsAlert = true
                                }
                            }
                        }
                    }) {
                        HStack {
                            if let price = classItem.price {
                                Text("Unlock Class - $\(Int(price))")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                            } else {
                                Text("Unlock Class")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.yellow)
                        .cornerRadius(28)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 34)
                }
            }
        }
        .alert("Insufficient Funds", isPresented: $showInsufficientFundsAlert) {
            Button("Add Funds") {
                showAddFundsSheet = true
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(insufficientFundsMessage)
        }
        .sheet(isPresented: $showAddFundsSheet) {
            AddFundsToTipJarSheet()
        }
    }
}

#Preview {
    BartenderClassesView(cartItems: .constant([]))
}

