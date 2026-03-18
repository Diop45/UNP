//
//  OrderTrackingView.swift
//  SIP SYNC
//
//  Created by AI Assistant - UX Journey Implementation
//

import SwiftUI

// MARK: - Order Tracking View
struct OrderTrackingView: View {
    let order: Order
    @Environment(\.presentationMode) var presentationMode
    @State private var estimatedTimeRemaining: Int = 30 // minutes
    
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
                VStack(spacing: 24) {
                    // Header
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
                        
                        Text("Order Tracking")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Placeholder for balance
                        Color.clear
                            .frame(width: 40, height: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // Order Status Card
                    OrderStatusCard(order: order, timeRemaining: estimatedTimeRemaining)
                        .padding(.horizontal, 20)
                    
                    // Timeline
                    OrderTimelineView(status: order.status)
                        .padding(.horizontal, 20)
                    
                    // Order Details
                    OrderDetailsCard(order: order)
                        .padding(.horizontal, 20)
                    
                    // Delivery Info
                    if !order.deliveryAddress.isEmpty {
                        DeliveryInfoCard(address: order.deliveryAddress)
                            .padding(.horizontal, 20)
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            // Contact support
                        }) {
                            HStack {
                                Image(systemName: "message.fill")
                                Text("Contact Support")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(16)
                        }
                        
                        Button(action: {
                            // View order details
                        }) {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                Text("View Order Details")
                            }
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.yellow)
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

// MARK: - Order Status Card
struct OrderStatusCard: View {
    let order: Order
    let timeRemaining: Int
    
    var statusIcon: String {
        switch order.status {
        case .pending: return "clock.fill"
        case .confirmed: return "checkmark.circle.fill"
        case .preparing: return "hourglass"
        case .ready: return "checkmark.circle"
        case .delivered: return "checkmark.circle.fill"
        }
    }
    
    var statusColor: Color {
        switch order.status {
        case .pending, .confirmed: return .yellow
        case .preparing: return .orange
        case .ready: return .green
        case .delivered: return .blue
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Status Icon
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: statusIcon)
                    .font(.system(size: 40))
                    .foregroundColor(statusColor)
            }
            
            // Status Text
            VStack(spacing: 8) {
                Text(order.status.rawValue)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                if order.status != .delivered {
                    Text("Estimated arrival: \(timeRemaining) min")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else {
                    Text("Delivered on \(formatDate(order.createdAt))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color.black.opacity(0.3))
        .cornerRadius(20)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Order Timeline
struct OrderTimelineView: View {
    let status: OrderStatus
    
    private let allStatuses: [OrderStatus] = [.pending, .confirmed, .preparing, .ready, .delivered]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Order Timeline")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 8)
            
            ForEach(Array(allStatuses.enumerated()), id: \.element) { index, orderStatus in
                HStack(alignment: .top, spacing: 16) {
                    // Timeline indicator
                    VStack(spacing: 0) {
                        Circle()
                            .fill(isCompleted(orderStatus) ? Color.yellow : Color.gray.opacity(0.3))
                            .frame(width: 24, height: 24)
                        
                        if index < allStatuses.count - 1 {
                            Rectangle()
                                .fill(isCompleted(orderStatus) ? Color.yellow : Color.gray.opacity(0.3))
                                .frame(width: 2, height: 40)
                        }
                    }
                    
                    // Status info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(orderStatus.rawValue)
                            .font(.subheadline)
                            .fontWeight(isActive(orderStatus) ? .bold : .regular)
                            .foregroundColor(isActive(orderStatus) ? .white : .gray)
                        
                        if isActive(orderStatus) {
                            Text(statusMessage(for: orderStatus))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(20)
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
    }
    
    private func isCompleted(_ orderStatus: OrderStatus) -> Bool {
        let statusOrder: [OrderStatus: Int] = [
            .pending: 0,
            .confirmed: 1,
            .preparing: 2,
            .ready: 3,
            .delivered: 4
        ]
        return (statusOrder[orderStatus] ?? 0) <= (statusOrder[status] ?? 0)
    }
    
    private func isActive(_ orderStatus: OrderStatus) -> Bool {
        return orderStatus == status
    }
    
    private func statusMessage(for status: OrderStatus) -> String {
        switch status {
        case .pending: return "Your order is being processed"
        case .confirmed: return "Order confirmed by venue"
        case .preparing: return "Your drinks are being prepared"
        case .ready: return "Ready for pickup/delivery"
        case .delivered: return "Enjoy your order!"
        }
    }
}

// MARK: - Order Details Card
struct OrderDetailsCard: View {
    let order: Order
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Order Details")
                .font(.headline)
                .foregroundColor(.white)
            
            ForEach(order.items) { item in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.drink.name)
                            .font(.subheadline)
                            .foregroundColor(.white)
                        Text("Qty: \(item.quantity)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text("$\(item.price * Double(item.quantity), specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundColor(.yellow)
                }
                
                if item.id != order.items.last?.id {
                    Divider()
                        .background(Color.gray.opacity(0.3))
                }
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            HStack {
                Text("Total")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("$\(order.total, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(.yellow)
            }
        }
        .padding(20)
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
    }
}

// MARK: - Delivery Info Card
struct DeliveryInfoCard: View {
    let address: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.yellow)
                Text("Delivery Address")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Text(address)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
    }
}

#Preview {
    OrderTrackingView(order: Order(
        items: [
            OrderItem(drink: SampleData.shared.sampleDrinks[0], quantity: 2, price: 22.00)
        ],
        total: 44.00,
        status: .preparing,
        deliveryAddress: "123 Main St, Detroit, MI 48201",
        estimatedDelivery: "30-45 minutes"
    ))
}




