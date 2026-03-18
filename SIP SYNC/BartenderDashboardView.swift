//
//  BartenderDashboardView.swift
//  SIP SYNC
//
//  Created by AI Assistant - UX Journey Implementation
//

import SwiftUI

// MARK: - Bartender Dashboard
struct BartenderDashboardView: View {
    @State private var selectedTab = 0
    @State private var showCreatePost = false
    @State private var showCreateClass = false
    @State private var showCreateStory = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Tab Bar
            HStack(spacing: 0) {
                TabButton(title: "Content", icon: "photo.fill", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                TabButton(title: "Classes", icon: "calendar", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
                TabButton(title: "Analytics", icon: "chart.bar.fill", isSelected: selectedTab == 2) {
                    selectedTab = 2
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.3))
            
            // Content
            TabView(selection: $selectedTab) {
                ContentManagementView(
                    showCreatePost: $showCreatePost,
                    showCreateStory: $showCreateStory
                )
                .tag(0)
                
                ClassesManagementView(showCreateClass: $showCreateClass)
                    .tag(1)
                
                AnalyticsView()
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Menu {
                        Button(action: { showCreatePost = true }) {
                            Label("Create Post", systemImage: "square.and.pencil")
                        }
                        Button(action: { showCreateStory = true }) {
                            Label("Create Story", systemImage: "camera.fill")
                        }
                        Button(action: { showCreateClass = true }) {
                            Label("Create Class", systemImage: "calendar.badge.plus")
                        }
                    } label: {
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
        .sheet(isPresented: $showCreatePost) {
            CreatePostView()
        }
        .sheet(isPresented: $showCreateClass) {
            CreateClassView()
        }
        .sheet(isPresented: $showCreateStory) {
            CreateStoryView()
        }
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .yellow : .gray)
                Text(title)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isSelected ? Color.yellow.opacity(0.1) : Color.clear)
            .cornerRadius(12)
        }
    }
}

// MARK: - Content Management
struct ContentManagementView: View {
    @Binding var showCreatePost: Bool
    @Binding var showCreateStory: Bool
    @State private var posts: [SocialPost] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Stats Cards
                HStack(spacing: 16) {
                    StatCard(title: "Posts", value: "\(posts.count)", icon: "photo.fill", color: .blue)
                    StatCard(title: "Views", value: "1.2K", icon: "eye.fill", color: .green)
                    StatCard(title: "Engagement", value: "89%", icon: "heart.fill", color: .red)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Recent Posts
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Recent Posts", showChevron: false)
                        .padding(.horizontal, 20)
                    
                    if posts.isEmpty {
                        EmptyStateView(
                            icon: "photo",
                            title: "No posts yet",
                            message: "Create your first post to share with the community"
                        )
                        .padding(.horizontal, 20)
                    } else {
                        ForEach(posts) { post in
                            PostPreviewCard(post: post)
                                .padding(.horizontal, 20)
                        }
                    }
                }
            }
            .padding(.bottom, 100)
        }
        .onAppear {
            loadPosts()
        }
    }
    
    private func loadPosts() {
        posts = SampleData.shared.sampleSocialPosts.filter { $0.author.userType == .bartender }
    }
}

// MARK: - Classes Management
struct ClassesManagementView: View {
    @Binding var showCreateClass: Bool
    @State private var classes: [BartenderClass] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Upcoming Classes
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "My Classes", showChevron: false)
                        .padding(.horizontal, 20)
                    
                    if classes.isEmpty {
                        EmptyStateView(
                            icon: "calendar",
                            title: "No classes scheduled",
                            message: "Create a class to share your expertise"
                        )
                        .padding(.horizontal, 20)
                    } else {
                        ForEach(classes) { classItem in
                            ClassManagementCard(classItem: classItem)
                                .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.top, 20)
            }
            .padding(.bottom, 100)
        }
        .onAppear {
            loadClasses()
        }
    }
    
    private func loadClasses() {
        classes = SampleData.shared.sampleBartenderClasses
    }
}

// MARK: - Analytics View
struct AnalyticsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Overview Stats
                VStack(spacing: 16) {
                    SectionHeader(title: "Performance Overview", showChevron: false)
                        .padding(.horizontal, 20)
                    
                    HStack(spacing: 12) {
                        AnalyticsCard(title: "Total Views", value: "12.5K", change: "+15%", isPositive: true)
                        AnalyticsCard(title: "Engagement", value: "89%", change: "+5%", isPositive: true)
                    }
                    .padding(.horizontal, 20)
                    
                    HStack(spacing: 12) {
                        AnalyticsCard(title: "New Followers", value: "234", change: "+12%", isPositive: true)
                        AnalyticsCard(title: "Classes Booked", value: "18", change: "+8%", isPositive: true)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 20)
                
                // Engagement Chart Placeholder
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Engagement Trends", showChevron: false)
                        .padding(.horizontal, 20)
                    
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.3))
                        .frame(height: 200)
                        .overlay(
                            VStack {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("Engagement chart will appear here")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        )
                        .padding(.horizontal, 20)
                }
            }
            .padding(.bottom, 100)
        }
    }
}

// MARK: - Supporting Views
struct StatCard: View {
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

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
    }
}

struct PostPreviewCard: View {
    let post: SocialPost
    
    var body: some View {
        HStack(spacing: 12) {
            if let imageName = post.image {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipped()
                    .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(post.content)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                HStack(spacing: 12) {
                    Label("\(post.likes)", systemImage: "heart.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Label("\(post.comments)", systemImage: "bubble.left.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Label("\(post.syncs)", systemImage: "arrow.2.squarepath")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
}

struct ClassManagementCard: View {
    let classItem: BartenderClass
    
    var body: some View {
        HStack(spacing: 12) {
            Image(classItem.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipped()
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(classItem.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text("\(classItem.attendees.count) attendees")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                if let price = classItem.price {
                    Text("$\(Int(price))")
                        .font(.subheadline)
                        .foregroundColor(.yellow)
                }
            }
            
            Spacer()
            
            if classItem.isLocked {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding(12)
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
}

struct AnalyticsCard: View {
    let title: String
    let value: String
    let change: String
    let isPositive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            HStack(spacing: 4) {
                Image(systemName: isPositive ? "arrow.up" : "arrow.down")
                    .font(.caption2)
                Text(change)
                    .font(.caption)
            }
            .foregroundColor(isPositive ? .green : .red)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
    }
}

// MARK: - Create Views (Placeholders)
struct CreatePostView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.05, blue: 0.2)
                    .ignoresSafeArea()
                VStack {
                    Text("Create Post")
                        .foregroundColor(.white)
                    // Post creation form would go here
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationTitle("Create Post")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct CreateClassView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.05, blue: 0.2)
                    .ignoresSafeArea()
                VStack {
                    Text("Create Class")
                        .foregroundColor(.white)
                    // Class creation form would go here
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationTitle("Create Class")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct CreateStoryView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.05, blue: 0.2)
                    .ignoresSafeArea()
                VStack {
                    Text("Create Story")
                        .foregroundColor(.white)
                    // Story creation form would go here
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationTitle("Create Story")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    BartenderDashboardView()
}




