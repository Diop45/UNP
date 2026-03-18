//
//  VenueDashboardView.swift
//  SIP SYNC
//
//  Created by AI Assistant - UX Journey Implementation
//

import SwiftUI

// MARK: - Venue Dashboard
struct VenueDashboardView: View {
    @State private var selectedTab = 0
    @State private var showCreateEvent = false
    @State private var showEditVenue = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Tab Bar
            HStack(spacing: 0) {
                TabButton(title: "Overview", icon: "chart.bar.fill", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                TabButton(title: "Events", icon: "calendar", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
                TabButton(title: "Bookings", icon: "clock.fill", isSelected: selectedTab == 2) {
                    selectedTab = 2
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.3))
            
            // Content
            TabView(selection: $selectedTab) {
                VenueOverviewView(showEditVenue: $showEditVenue)
                    .tag(0)
                
                VenueEventsView(showCreateEvent: $showCreateEvent)
                    .tag(1)
                
                VenueBookingsView()
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showCreateEvent = true }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .frame(width: 56, height: 56)
                            .background(Color.yellow)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(isPresented: $showCreateEvent) {
            CreateEventView()
        }
        .sheet(isPresented: $showEditVenue) {
            EditVenueView()
        }
    }
}

// MARK: - Venue Overview
struct VenueOverviewView: View {
    @Binding var showEditVenue: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Venue Header Card
                VenueHeaderCard(showEditVenue: $showEditVenue)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                // Stats Grid
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        VenueStatCard(title: "Today's Bookings", value: "12", icon: "calendar", color: .blue)
                        VenueStatCard(title: "Revenue", value: "$2.4K", icon: "dollarsign.circle.fill", color: .green)
                    }
                    .padding(.horizontal, 20)
                    
                    HStack(spacing: 16) {
                        VenueStatCard(title: "Rating", value: "4.8", icon: "star.fill", color: .yellow)
                        VenueStatCard(title: "Followers", value: "1.2K", icon: "person.2.fill", color: .purple)
                    }
                    .padding(.horizontal, 20)
                }
                
                // Recent Activity
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Recent Activity", showChevron: false)
                        .padding(.horizontal, 20)
                    
                    ForEach(0..<3) { _ in
                        ActivityCard()
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.top, 8)
            }
            .padding(.bottom, 100)
        }
    }
}

// MARK: - Venue Events
struct VenueEventsView: View {
    @Binding var showCreateEvent: Bool
    @State private var events: [VenueEvent] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Upcoming Events
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Upcoming Events", showChevron: false)
                        .padding(.horizontal, 20)
                    
                    if events.isEmpty {
                        EmptyStateView(
                            icon: "calendar",
                            title: "No events scheduled",
                            message: "Create an event to attract customers"
                        )
                        .padding(.horizontal, 20)
                    } else {
                        ForEach(events) { event in
                            EventCard(event: event)
                                .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.top, 20)
            }
            .padding(.bottom, 100)
        }
        .onAppear {
            loadEvents()
        }
    }
    
    private func loadEvents() {
        // Sample events
        events = [
            VenueEvent(
                id: UUID(),
                title: "Wine Tasting Night",
                date: Date().addingTimeInterval(86400 * 2),
                attendees: 45,
                capacity: 60
            ),
            VenueEvent(
                id: UUID(),
                title: "Cocktail Masterclass",
                date: Date().addingTimeInterval(86400 * 5),
                attendees: 28,
                capacity: 40
            )
        ]
    }
}

// MARK: - Venue Bookings
struct VenueBookingsView: View {
    @State private var bookings: [Booking] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Today's Bookings
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Today's Bookings", showChevron: false)
                        .padding(.horizontal, 20)
                    
                    if bookings.isEmpty {
                        EmptyStateView(
                            icon: "clock",
                            title: "No bookings today",
                            message: "Bookings will appear here"
                        )
                        .padding(.horizontal, 20)
                    } else {
                        ForEach(bookings) { booking in
                            BookingCard(booking: booking)
                                .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.top, 20)
            }
            .padding(.bottom, 100)
        }
        .onAppear {
            loadBookings()
        }
    }
    
    private func loadBookings() {
        // Sample bookings
        bookings = [
            Booking(
                id: UUID(),
                customerName: "John Doe",
                time: "7:00 PM",
                partySize: 4,
                status: .confirmed
            ),
            Booking(
                id: UUID(),
                customerName: "Jane Smith",
                time: "8:30 PM",
                partySize: 2,
                status: .pending
            )
        ]
    }
}

// MARK: - Supporting Models
struct VenueEvent: Identifiable {
    let id: UUID
    var title: String
    var date: Date
    var attendees: Int
    var capacity: Int
}

struct Booking: Identifiable {
    let id: UUID
    var customerName: String
    var time: String
    var partySize: Int
    var status: BookingStatus
}

enum BookingStatus: String {
    case pending = "Pending"
    case confirmed = "Confirmed"
    case cancelled = "Cancelled"
    case completed = "Completed"
}

// MARK: - Supporting Views
struct VenueHeaderCard: View {
    @Binding var showEditVenue: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("The Nest Bar")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("Premium Cocktail Lounge")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    HStack(spacing: 8) {
                        Label("4.8", systemImage: "star.fill")
                            .foregroundColor(.yellow)
                        Text("• 1.2K reviews")
                            .foregroundColor(.gray)
                    }
                    .font(.caption)
                }
                
                Spacer()
                
                Button(action: { showEditVenue = true }) {
                    Image(systemName: "pencil")
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Location")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("Detroit, MI")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hours")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("5 PM - 2 AM")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
            }
        }
        .padding(20)
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
    }
}

struct VenueStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
    }
}

struct ActivityCard: View {
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.yellow.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "checkmark")
                        .foregroundColor(.yellow)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("New booking received")
                    .font(.subheadline)
                    .foregroundColor(.white)
                Text("2 hours ago")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
}

struct EventCard: View {
    let event: VenueEvent
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d 'at' h:mm a"
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(dateFormatter.string(from: event.date))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(event.attendees)/\(event.capacity)")
                        .font(.headline)
                        .foregroundColor(.yellow)
                    Text("Attendees")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.yellow)
                        .frame(width: geometry.size.width * CGFloat(event.attendees) / CGFloat(event.capacity), height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding(16)
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
    }
}

struct BookingCard: View {
    let booking: Booking
    
    var statusColor: Color {
        switch booking.status {
        case .pending: return .yellow
        case .confirmed: return .green
        case .cancelled: return .red
        case .completed: return .gray
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(booking.customerName)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(booking.time)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Party of \(booking.partySize)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(booking.status.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.2))
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
    }
}

// MARK: - Create/Edit Views
struct CreateEventView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.05, blue: 0.2)
                    .ignoresSafeArea()
                VStack {
                    Text("Create Event")
                        .foregroundColor(.white)
                    // Event creation form would go here
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationTitle("Create Event")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct EditVenueView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.05, blue: 0.2)
                    .ignoresSafeArea()
                VStack {
                    Text("Edit Venue")
                        .foregroundColor(.white)
                    // Venue editing form would go here
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationTitle("Edit Venue")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    VenueDashboardView()
}




