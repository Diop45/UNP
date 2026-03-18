//
//  OrderSuccessView.swift
//  SIP SYNC
//
//  Created by Diop Shumake on 10/23/25.
//

import SwiftUI

struct OrderSuccessView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showOrderTracking = false
    @State private var order: Order?
    
    var body: some View {
        ZStack {
            // Dark purple background
            Color(red: 0.1, green: 0.05, blue: 0.2)
                .ignoresSafeArea()
            
            if showOrderTracking, let order = order {
                OrderTrackingView(order: order)
            } else {
            VStack(spacing: 30) {
                Spacer()
                
                    // Success icon with animation
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.black)
                    )
                        .scaleEffect(1.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6), value: UUID())
                
                // Success message
                VStack(spacing: 12) {
                    Text("Order Placed!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Estimated Delivery: 30-45 minutes")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        
                        Text("Order #\(order?.id.uuidString.prefix(8) ?? "1234")")
                            .font(.caption)
                            .foregroundColor(.gray)
                }
                
                Spacer()
                
                    // Action buttons
                VStack(spacing: 16) {
                        Button(action: {
                            // Create a sample order for tracking
                            let sampleOrder = Order(
                                items: [],
                                total: 0,
                                status: .confirmed,
                                deliveryAddress: "123 Main St, Detroit, MI",
                                estimatedDelivery: "30-45 minutes"
                            )
                            self.order = sampleOrder
                            withAnimation {
                                showOrderTracking = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "location.fill")
                                Text("Track Order")
                            }
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.yellow)
                            .cornerRadius(28)
                        }
                        
                        Button(action: {
                            // Dismiss and go back to home
                        presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Continue Shopping")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(28)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 28)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        }
                }
                .padding(.horizontal, 20)
                    .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            // Create a sample order when view appears
            let sampleOrder = Order(
                items: [],
                total: 0,
                status: .confirmed,
                deliveryAddress: "123 Main St, Detroit, MI",
                estimatedDelivery: "30-45 minutes"
            )
            self.order = sampleOrder
        }
    }
}

struct MenuOptionRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(.yellow)
                    .font(.title2)
                    .frame(width: 24)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding(.vertical, 12)
        }
    }
}

#Preview {
    OrderSuccessView()
}














