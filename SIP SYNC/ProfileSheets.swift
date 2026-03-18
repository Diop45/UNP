//
//  ProfileSheets.swift
//  SIP SYNC
//
//  Profile menu sheet views - consolidated and actionable
//

import SwiftUI
import PhotosUI

// MARK: - Edit Profile Sheet
struct EditProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var user: User
    @State private var editedUser: User
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var showImagePicker = false
    
    init(user: Binding<User>) {
        self._user = user
        self._editedUser = State(initialValue: user.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Photo Section
                        VStack(spacing: 16) {
                            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                ZStack {
                                    if let profileImage = editedUser.profileImage, !profileImage.isEmpty {
                                        Image(profileImage)
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
                                                    .font(.system(size: 30))
                                            )
                                    }
                                }
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.yellow, lineWidth: 3)
                                )
                            }
                            
                            Text("Tap to change photo")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 20)
                        
                        // Basic Info
                        VStack(alignment: .leading, spacing: 16) {
                            Text("BASIC INFORMATION")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                                .tracking(1)
                            
                            VStack(spacing: 12) {
                                ProfileTextField(title: "Name", text: $editedUser.name)
                                ProfileTextField(title: "Email", text: $editedUser.email)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                ProfileTextField(title: "Location", text: $editedUser.location)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Professional Info
                        VStack(alignment: .leading, spacing: 16) {
                            Text("PROFESSIONAL")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                                .tracking(1)
                            
                            VStack(spacing: 12) {
                                ProfileTextField(title: "Profession", text: Binding(
                                    get: { editedUser.profession ?? "" },
                                    set: { editedUser.profession = $0.isEmpty ? nil : $0 }
                                ))
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Bio")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    TextEditor(text: Binding(
                                        get: { editedUser.bio ?? "" },
                                        set: { editedUser.bio = $0.isEmpty ? nil : $0 }
                                    ))
                                    .frame(height: 100)
                                    .padding(12)
                                    .background(Color.black.opacity(0.3))
                                    .cornerRadius(12)
                                    .foregroundColor(.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                                    )
                                    .scrollContentBackground(.hidden)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Social Media
                        VStack(alignment: .leading, spacing: 16) {
                            Text("SOCIAL MEDIA")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                                .tracking(1)
                            
                            VStack(spacing: 12) {
                                ProfileTextField(title: "Instagram", text: Binding(
                                    get: { editedUser.instagramHandle ?? "" },
                                    set: { editedUser.instagramHandle = $0.isEmpty ? nil : $0 }
                                ))
                                .autocapitalization(.none)
                                
                                ProfileTextField(title: "Twitter / X", text: Binding(
                                    get: { editedUser.twitterHandle ?? "" },
                                    set: { editedUser.twitterHandle = $0.isEmpty ? nil : $0 }
                                ))
                                .autocapitalization(.none)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Languages
                        VStack(alignment: .leading, spacing: 16) {
                            Text("LANGUAGES")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                                .tracking(1)
                            
                            LanguageSelectionView(languages: Binding(
                                get: { editedUser.languages },
                                set: { editedUser.languages = $0 }
                            ))
                        }
                        .padding(.horizontal, 20)
                        
                        // Interests
                        VStack(alignment: .leading, spacing: 16) {
                            Text("INTERESTS")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                                .tracking(1)
                            
                            NavigationLink(destination: InterestsEditView(interests: Binding(
                                get: { editedUser.interests },
                                set: { editedUser.interests = $0 }
                            ))) {
                                HStack {
                                    Text("\(editedUser.interests.count) selected")
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                            .frame(height: 40)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        user = editedUser
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                    .fontWeight(.semibold)
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
        }
        .onChange(of: selectedPhoto) { oldValue, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let _ = UIImage(data: data) {
                    // In a real app, upload image and get URL
                    editedUser.profileImage = "user_\(UUID().uuidString)"
                }
            }
        }
    }
}

// MARK: - Profile Text Field
struct ProfileTextField: View {
    let title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            TextField("", text: $text)
                .textFieldStyle(CustomTextFieldStyle())
        }
    }
}

// MARK: - Language Selection View
struct LanguageSelectionView: View {
    @Binding var languages: [String]
    
    private let commonLanguages = [
        "English", "Spanish", "French", "German", "Italian",
        "Portuguese", "Japanese", "Chinese", "Korean", "Arabic"
    ]
    
    var body: some View {
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
    }
}

// MARK: - Interests Edit View
struct InterestsEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var interests: Set<DrinkInterest>
    
    private let maxSelection = 7
    private var isAtLimit: Bool { interests.count >= maxSelection }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 16) {
                        Text("Select Your Interests")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Choose up to \(maxSelection) interests")
                            .font(.body)
                            .foregroundColor(.gray)
                        
                        if !interests.isEmpty {
                            Text("\(interests.count) selected")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Use the same interest section structure from OnboardingView
                    interestSection(title: "Spirits", items: [
                        (.whiskey, "takeoutbag.and.cup.and.straw", Color.orange),
                        (.bourbon, "flame", Color.red),
                        (.scotch, "drop", Color.blue),
                        (.gin, "leaf", Color.green),
                        (.tequila, "sun.max", Color.yellow),
                        (.rum, "sailboat", Color.purple),
                        (.vodka, "snow", Color.cyan)
                    ])
                    
                    interestSection(title: "Cocktails", items: [
                        (.negroni, "wineglass", Color.red),
                        (.martini, "martini.glass", Color.blue),
                        (.oldFashioned, "cube", Color.orange),
                        (.spritz, "sparkles", Color.yellow),
                        (.margarita, "tortilla", Color.green),
                        (.manhattan, "building.2", Color.purple)
                    ])
                    
                    interestSection(title: "Wine, Beer & NA", items: [
                        (.redWine, "wineglass", Color.red),
                        (.whiteWine, "wineglass", Color.yellow),
                        (.sparkling, "sparkles", Color.cyan),
                        (.ipa, "hare", Color.orange),
                        (.lager, "circle", Color.blue),
                        (.stout, "circle.fill", Color.black),
                        (.mocktails, "bubble", Color.green)
                    ])
                }
            }
        }
        .navigationTitle("Edit Interests")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.black, for: .navigationBar)
    }
    
    private func interestSection(title: String, items: [(DrinkInterest, String, Color)]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            
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
            .padding(.horizontal, 20)
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

// MARK: - Favorites Sheet
struct FavoritesSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var favoriteDrinks: [Drink]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if favoriteDrinks.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "heart")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Favorites Yet")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Start adding drinks to your favorites")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(favoriteDrinks, id: \.id) { drink in
                                FavoriteDrinkCard(drink: drink)
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
        }
    }
}

// MARK: - Favorite Drink Card
struct FavoriteDrinkCard: View {
    let drink: Drink
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Drink image
            Group {
                if let imageName = getImageName(for: drink.name) {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    RoundedRectangle(cornerRadius: 12)
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
                            Image(systemName: getSystemIcon(for: drink.category))
                                .font(.title)
                                .foregroundColor(.white)
                        )
                }
            }
            .frame(height: 120)
            .clipped()
            .cornerRadius(12)
            
            Text(drink.name)
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(2)
            
            Text("$\(String(format: "%.2f", drink.price))")
                .font(.subheadline)
                .foregroundColor(.yellow)
        }
    }
    
    private func getImageName(for drinkName: String) -> String? {
        switch drinkName {
        case "Negroni": return "Negroni"
        case "Scotch & Bourbon": return "Scotch"
        case "Spritzer": return "Spritzer"
        case "Martini": return "Dirty Martini"
        case "Red Wine": return "Red Wine"
        case "White Wine": return "White Wine"
        default: return nil
        }
    }
    
    private func getSystemIcon(for category: DrinkCategory) -> String {
        switch category {
        case .drinks: return "wineglass"
        case .food: return "fork.knife"
        case .social: return "person.2"
        }
    }
}

// MARK: - Order History Sheet
struct OrderHistorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var orders: [Order] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if orders.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Orders Yet")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Your order history will appear here")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(orders) { order in
                                OrderHistoryCard(order: order)
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("Order History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
            .onAppear {
                loadOrders()
            }
        }
    }
    
    private func loadOrders() {
        // In a real app, load from backend/database
        // For now, create sample orders
        orders = []
    }
}

// MARK: - Order History Card
struct OrderHistoryCard: View {
    let order: Order
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Order #\(String(order.id.uuidString.prefix(8)))")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(order.status.rawValue)
                    .font(.caption)
                    .foregroundColor(statusColor(for: order.status))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusColor(for: order.status).opacity(0.2))
                    .cornerRadius(8)
            }
            
            Text(order.createdAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundColor(.gray)
            
            Text("\(order.items.count) items • $\(String(format: "%.2f", order.total))")
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
    
    private func statusColor(for status: OrderStatus) -> Color {
        switch status {
        case .pending: return .yellow
        case .confirmed: return .blue
        case .preparing: return .orange
        case .ready: return .green
        case .delivered: return .gray
        }
    }
}

// MARK: - Payment Methods Sheet
struct PaymentMethodsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var paymentMethods: [PaymentMethod] = []
    @State private var showAddPayment = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if paymentMethods.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "creditcard")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Payment Methods")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Add a payment method to get started")
                            .font(.body)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            showAddPayment = true
                        }) {
                            Text("Add Payment Method")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(20)
                        }
                        .padding(.top, 8)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(paymentMethods) { method in
                                PaymentMethodCard(method: method)
                            }
                            
                            Button(action: {
                                showAddPayment = true
                            }) {
                                HStack {
                                    Image(systemName: "plus")
                                    Text("Add Payment Method")
                                }
                                .font(.headline)
                                .foregroundColor(.yellow)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("Payment Methods")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
            .sheet(isPresented: $showAddPayment) {
                AddPaymentMethodSheet { method in
                    paymentMethods.append(method)
                }
            }
            .onAppear {
                loadPaymentMethods()
            }
        }
    }
    
    private func loadPaymentMethods() {
        // In a real app, load from backend/database
        paymentMethods = []
    }
}

// MARK: - Payment Method Card
struct PaymentMethodCard: View {
    let method: PaymentMethod
    
    var body: some View {
        HStack {
            Image(systemName: iconForPaymentType(method.type))
                .font(.title2)
                .foregroundColor(.yellow)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(method.type.rawValue)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("•••• \(method.lastFour)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if method.isDefault {
                Text("DEFAULT")
                    .font(.caption2)
                    .foregroundColor(.yellow)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
    
    private func iconForPaymentType(_ type: PaymentType) -> String {
        switch type {
        case .creditCard: return "creditcard.fill"
        case .applePay: return "applelogo"
        case .paypal: return "p.circle.fill"
        }
    }
}

// MARK: - Add Payment Method Sheet
struct AddPaymentMethodSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onAdd: (PaymentMethod) -> Void
    
    @State private var selectedType: PaymentType = .creditCard
    @State private var cardNumber = ""
    @State private var cardName = ""
    @State private var expiryDate = ""
    @State private var cvv = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Payment Type Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Payment Type")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            HStack(spacing: 12) {
                                ForEach([PaymentType.creditCard, PaymentType.applePay, PaymentType.paypal], id: \.self) { type in
                                    Button(action: {
                                        selectedType = type
                                    }) {
                                        VStack {
                                            Image(systemName: iconForPaymentType(type))
                                                .font(.title2)
                                                .foregroundColor(selectedType == type ? .yellow : .gray)
                                            Text(type.rawValue)
                                                .font(.caption)
                                                .foregroundColor(selectedType == type ? .white : .gray)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(selectedType == type ? Color.yellow.opacity(0.2) : Color.black.opacity(0.3))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        if selectedType == .creditCard {
                            VStack(spacing: 16) {
                                ProfileTextField(title: "Card Number", text: $cardNumber)
                                    .keyboardType(.numberPad)
                                
                                ProfileTextField(title: "Cardholder Name", text: $cardName)
                                
                                HStack(spacing: 12) {
                                    ProfileTextField(title: "Expiry", text: $expiryDate)
                                        .keyboardType(.numbersAndPunctuation)
                                    
                                    ProfileTextField(title: "CVV", text: $cvv)
                                        .keyboardType(.numberPad)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer()
                            .frame(height: 40)
                    }
                }
            }
            .navigationTitle("Add Payment Method")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let lastFour = cardNumber.count >= 4 ? String(cardNumber.suffix(4)) : "0000"
                        let method = PaymentMethod(
                            type: selectedType,
                            lastFour: lastFour,
                            isDefault: false
                        )
                        onAdd(method)
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                    .fontWeight(.semibold)
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
        }
    }
    
    private func iconForPaymentType(_ type: PaymentType) -> String {
        switch type {
        case .creditCard: return "creditcard.fill"
        case .applePay: return "applelogo"
        case .paypal: return "p.circle.fill"
        }
    }
}

// MARK: - Addresses Sheet
struct AddressesSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var addresses: [String] = []
    @State private var showAddAddress = false
    @State private var newAddress = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if addresses.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "location")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Saved Addresses")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Add an address for faster checkout")
                            .font(.body)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            showAddAddress = true
                        }) {
                            Text("Add Address")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(20)
                        }
                        .padding(.top, 8)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(addresses, id: \.self) { address in
                                AddressCard(address: address)
                            }
                            
                            Button(action: {
                                showAddAddress = true
                            }) {
                                HStack {
                                    Image(systemName: "plus")
                                    Text("Add Address")
                                }
                                .font(.headline)
                                .foregroundColor(.yellow)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("Saved Addresses")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
            .sheet(isPresented: $showAddAddress) {
                AddAddressSheet { address in
                    addresses.append(address)
                }
            }
            .onAppear {
                loadAddresses()
            }
        }
    }
    
    private func loadAddresses() {
        // In a real app, load from backend/database
        addresses = []
    }
}

// MARK: - Address Card
struct AddressCard: View {
    let address: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "location.fill")
                .font(.title3)
                .foregroundColor(.yellow)
                .frame(width: 24)
            
            Text(address)
                .font(.body)
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
}

// MARK: - Add Address Sheet
struct AddAddressSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onAdd: (String) -> Void
    
    @State private var address = ""
    @State private var city = ""
    @State private var state = ""
    @State private var zipCode = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        ProfileTextField(title: "Street Address", text: $address)
                        ProfileTextField(title: "City", text: $city)
                        ProfileTextField(title: "State", text: $state)
                        ProfileTextField(title: "ZIP Code", text: $zipCode)
                            .keyboardType(.numberPad)
                        
                        Spacer()
                            .frame(height: 40)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Add Address")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let fullAddress = "\(address), \(city), \(state) \(zipCode)"
                        onAdd(fullAddress)
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                    .fontWeight(.semibold)
                    .disabled(address.isEmpty || city.isEmpty || state.isEmpty || zipCode.isEmpty)
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
        }
    }
}

// MARK: - Notifications Settings Sheet
struct NotificationsSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var pushNotifications = true
    @State private var emailNotifications = true
    @State private var orderUpdates = true
    @State private var promotions = false
    @State private var newDrinks = true
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        SettingsSection(title: "Notification Preferences") {
                            SettingsRow(
                                icon: "bell.fill",
                                title: "Push Notifications",
                                action: {},
                                hasToggle: true,
                                toggleValue: $pushNotifications
                            )
                            
                            SettingsRow(
                                icon: "envelope.fill",
                                title: "Email Notifications",
                                action: {},
                                hasToggle: true,
                                toggleValue: $emailNotifications
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        SettingsSection(title: "What to Notify") {
                            SettingsRow(
                                icon: "shippingbox.fill",
                                title: "Order Updates",
                                action: {},
                                hasToggle: true,
                                toggleValue: $orderUpdates
                            )
                            
                            SettingsRow(
                                icon: "gift.fill",
                                title: "Promotions",
                                action: {},
                                hasToggle: true,
                                toggleValue: $promotions
                            )
                            
                            SettingsRow(
                                icon: "wineglass.fill",
                                title: "New Drinks",
                                action: {},
                                hasToggle: true,
                                toggleValue: $newDrinks
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
        }
    }
}

// MARK: - Help & Support Sheet
struct HelpSupportSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // FAQ Section
                        SettingsSection(title: "Frequently Asked Questions") {
                            HelpSupportRow(
                                icon: "questionmark.circle.fill",
                                title: "How do I place an order?",
                                action: {}
                            )
                            
                            HelpSupportRow(
                                icon: "questionmark.circle.fill",
                                title: "How do I track my order?",
                                action: {}
                            )
                            
                            HelpSupportRow(
                                icon: "questionmark.circle.fill",
                                title: "What payment methods are accepted?",
                                action: {}
                            )
                            
                            HelpSupportRow(
                                icon: "questionmark.circle.fill",
                                title: "How do I cancel an order?",
                                action: {}
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Contact Section
                        SettingsSection(title: "Contact Support") {
                            HelpSupportRow(
                                icon: "envelope.fill",
                                title: "Email Support",
                                subtitle: "support@sipsync.com",
                                action: {}
                            )
                            
                            HelpSupportRow(
                                icon: "phone.fill",
                                title: "Phone Support",
                                subtitle: "1-800-SIP-SYNC",
                                action: {}
                            )
                            
                            HelpSupportRow(
                                icon: "message.fill",
                                title: "Live Chat",
                                action: {}
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Resources
                        SettingsSection(title: "Resources") {
                            HelpSupportRow(
                                icon: "doc.text.fill",
                                title: "Terms of Service",
                                action: {}
                            )
                            
                            HelpSupportRow(
                                icon: "lock.shield.fill",
                                title: "Privacy Policy",
                                action: {}
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationTitle("Help & Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
        }
    }
}

// MARK: - Help Support Row
struct HelpSupportRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(.yellow)
                    .font(.title3)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - About Sheet
struct AboutSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // App Logo
                        Image("SipSyncLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                            .cornerRadius(20)
                            .padding(.top, 40)
                        
                        VStack(spacing: 12) {
                            Text("SIP SYNC")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Version 1.0.0")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        VStack(spacing: 16) {
                            Text("About SipSync")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("SipSync is your ultimate destination for discovering, ordering, and enjoying premium drinks. Connect with bartenders, explore venues, and sync your favorite drinks with ease.")
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .padding(.top, 20)
                        
                        VStack(spacing: 12) {
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "star.fill")
                                    Text("Rate Us on App Store")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(12)
                            }
                            
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share App")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        Text("© 2025 SipSync. All rights reserved.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, 20)
                            .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
        }
    }
}

