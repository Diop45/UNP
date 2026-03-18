//
//  CheckoutView.swift
//  SIP SYNC
//
//  Created by Diop Shumake on 10/23/25.
//

import SwiftUI

struct CheckoutView: View {
    @Binding var cartItems: [OrderItem]
    @Environment(\.presentationMode) var presentationMode
    @State private var currentStep = 0
    @State private var promoCode = ""
    @State private var selectedPaymentMethod: PaymentMethod?
    @State private var deliveryAddress = ""
    @State private var customerName = ""
    @State private var showOrderSuccess = false
    @State private var searchText = ""
    @State private var selectedUserType: UserType? = nil
    
    let paymentMethods: [PaymentMethod] = [
        PaymentMethod(type: .creditCard, lastFour: "1234", isDefault: true),
        PaymentMethod(type: .applePay, lastFour: "5678"),
        PaymentMethod(type: .paypal, lastFour: "9012")
    ]
    
    var total: Double {
        cartItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
    
    var body: some View {
        ZStack {
            // Dark purple background
            Color(red: 0.1, green: 0.05, blue: 0.2)
                .ignoresSafeArea()
            
            if showOrderSuccess {
                OrderSuccessView()
            } else {
                VStack(spacing: 0) {
                    // Header
                    SSHeader(
                        logoText: "S",
                        location: currentStep == 0 ? "Payment" : "Review"
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Consistent global search + category chips
                    SearchPillField(text: $searchText)
                        .padding(.horizontal, 20)
                    UserTypeFilter(selectedType: $selectedUserType, types: UserType.allCases)
                        .padding(.bottom, 8)
                    
                    if currentStep == 0 {
                        // Payment Method Selection
                        PaymentMethodView(
                            promoCode: $promoCode,
                            paymentMethods: paymentMethods,
                            selectedPaymentMethod: $selectedPaymentMethod,
                            onNext: {
                                currentStep = 1
                            }
                        )
                    } else {
                        // Order Summary
                        OrderSummaryView(
                            cartItems: cartItems,
                            customerName: $customerName,
                            deliveryAddress: $deliveryAddress,
                            onPlaceOrder: {
                                showOrderSuccess = true
                            }
                        )
                    }
                }
            }
        }
    }
}

struct PaymentMethodView: View {
    @Binding var promoCode: String
    let paymentMethods: [PaymentMethod]
    @Binding var selectedPaymentMethod: PaymentMethod?
    let onNext: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Promo code input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Promo Code")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    TextField("Enter promo code", text: $promoCode)
                        .textFieldStyle(CustomTextFieldStyle())
                }
                .padding(.horizontal, 20)
                
                // Payment methods
                VStack(alignment: .leading, spacing: 16) {
                    Text("Payment Method")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                    
                    ForEach(paymentMethods) { method in
                        PaymentMethodRow(
                            method: method,
                            isSelected: selectedPaymentMethod?.id == method.id,
                            onSelect: {
                                selectedPaymentMethod = method
                            }
                        )
                    }
                }
                
                Spacer(minLength: 100)
            }
        }
        
        // Checkout button
        VStack {
            Spacer()
            Button(action: onNext) {
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
        }
    }
}

struct PaymentMethodRow: View {
    let method: PaymentMethod
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                // Payment method icon
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 30)
                    .overlay(
                        Image(systemName: "creditcard")
                            .foregroundColor(.white)
                    )
                
                // Payment details
                VStack(alignment: .leading, spacing: 4) {
                    Text(method.type.rawValue)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("**** \(method.lastFour)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .yellow : .gray)
                    .font(.title2)
            }
            .padding(16)
            .background(
                isSelected ? Color.yellow.opacity(0.1) : Color.black.opacity(0.3)
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 2)
            )
        }
        .padding(.horizontal, 20)
    }
}

struct OrderSummaryView: View {
    let cartItems: [OrderItem]
    @Binding var customerName: String
    @Binding var deliveryAddress: String
    let onPlaceOrder: () -> Void
    
    var total: Double {
        cartItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Title
                Text("Checkout")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                // Customer info
                VStack(spacing: 16) {
                    TextField("Name", text: $customerName)
                        .textFieldStyle(CustomTextFieldStyle())
                    
                    TextField("Delivery Address", text: $deliveryAddress)
                        .textFieldStyle(CustomTextFieldStyle())
                }
                .padding(.horizontal, 20)
                
                // Order summary
                VStack(alignment: .leading, spacing: 16) {
                    Text("Order Summary")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 12) {
                        ForEach(cartItems) { item in
                            HStack {
                                Text("\(item.drink.name) x\(item.quantity)")
                                    .foregroundColor(.white)
                                Spacer()
                                Text("$\(item.price * Double(item.quantity), specifier: "%.2f")")
                                    .foregroundColor(.yellow)
                            }
                        }
                        
                        Divider()
                            .background(Color.gray)
                        
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
                    .padding(16)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 100)
            }
        }
        
        // Place order button
        VStack {
            Spacer()
            Button(action: onPlaceOrder) {
                Text("Place Order")
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
        }
    }
}

#Preview {
    CheckoutView(cartItems: .constant([
        OrderItem(drink: SampleData.shared.sampleDrinks[0], quantity: 2, price: 12.99)
    ]))
}

