//
//  CartView.swift
//  SIP SYNC
//
//  Created by Diop Shumake on 10/23/25.
//

import SwiftUI

struct CartView: View {
    @Binding var cartItems: [OrderItem]
    @State private var showCheckout = false
    @State private var searchText = ""
    @State private var selectedUserType: UserType? = nil
    
    var total: Double {
        cartItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
    
    var body: some View {
        ZStack {
            // Dark purple background that flows from navigation
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
                // New TopNavigationBar with raised background and shadow
                TopNavigationBar(selectedCategory: $selectedUserType)
                
                // Search field below the navigation
                SearchPillField(text: $searchText)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                
                
                if cartItems.isEmpty {
                    // Empty cart
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "cart")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Your cart is empty")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Text("Add some drinks to get started")
                            .font(.body)
                            .foregroundColor(.gray)
                        
                        Spacer()
                    }
                } else {
                    // Cart content
                    ScrollView {
                        VStack(spacing: 20) {
                            // Title
                            SectionHeader(title: "Cart")
                                .padding(.top, 20)
                            
                            // Main content area
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.3))
                                .frame(height: 200)
                                .overlay(
                                    VStack {
                                        Text("Bartender's Notes")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                )
                                .padding(.horizontal, 20)
                            
                            // Cart items
                            VStack(spacing: 12) {
                                ForEach(cartItems) { item in
                                    CartItemRow(item: item, cartItems: $cartItems)
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Order summary
                            VStack(spacing: 12) {
                                SectionHeader(title: "Summary")
                                HStack {
                                    Text("Subtotal")
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text("$\(total, specifier: "%.2f")")
                                        .foregroundColor(.white)
                                }
                                
                                HStack {
                                    Text("Tax")
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text("$\(total * 0.08, specifier: "%.2f")")
                                        .foregroundColor(.white)
                                }
                                
                                Divider()
                                    .background(Color.gray)
                                
                                HStack {
                                    Text("Total")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("$\(total * 1.08, specifier: "%.2f")")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        }
                    }
                }
                
                Spacer()
            }
            
            // Checkout button (fixed at bottom)
            if !cartItems.isEmpty {
                VStack {
                    Spacer()
                    Button(action: {
                        showCheckout = true
                    }) {
                        Text("Checkout")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.yellow)
                            .cornerRadius(28)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                    
                    // Hidden NavigationLink to keep TabView visible
                    NavigationLink(destination: CheckoutView(cartItems: $cartItems), isActive: $showCheckout) { EmptyView() }
                        .hidden()
                }
            }
        }
        // Removed sheet; navigation handled by NavigationLink above
    }
}

struct CartItemRow: View {
    let item: OrderItem
    @Binding var cartItems: [OrderItem]
    
    var body: some View {
        HStack(spacing: 12) {
            // Drink image
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "wineglass")
                        .foregroundColor(.white)
                )
            
            // Drink info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.drink.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("$\(item.price, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.yellow)
            }
            
            Spacer()
            
            // Quantity controls
            HStack(spacing: 12) {
                Button(action: {
                    if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
                        if cartItems[index].quantity > 1 {
                            cartItems[index].quantity -= 1
                        } else {
                            cartItems.remove(at: index)
                        }
                    }
                }) {
                    Image(systemName: "minus")
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(Color.gray.opacity(0.3))
                        .clipShape(Circle())
                }
                
                Text("\(item.quantity)")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(minWidth: 20)
                
                Button(action: {
                    if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
                        cartItems[index].quantity += 1
                    }
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(Color.yellow)
                        .clipShape(Circle())
                }
            }
        }
        .padding(12)
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
}

#Preview {
    CartView(cartItems: .constant([
        OrderItem(drink: SampleData.shared.sampleDrinks[0], quantity: 2, price: 12.99),
        OrderItem(drink: SampleData.shared.sampleDrinks[1], quantity: 1, price: 15.99)
    ]))
}
