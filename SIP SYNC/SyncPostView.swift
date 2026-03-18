//
//  SyncPostView.swift
//  SIP SYNC
//
//  Created by AI Assistant - Sync Feature Implementation
//

import SwiftUI
import PhotosUI

// MARK: - Sync Post Creation View
struct SyncPostView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var socialPosts: [SocialPost] // Shared posts array
    @State private var selectedImage: UIImage?
    @State private var caption: String = ""
    @State private var tags: String = ""
    @State private var selectedPostType: PostType = .cocktail
    @State private var selectedUserType: UserType = .consumer
    @State private var showImagePicker = false
    @State private var showPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isPosting = false
    
    let currentUser: SocialUser // Current logged-in user
    
    init(socialPosts: Binding<[SocialPost]>, currentUser: SocialUser) {
        self._socialPosts = socialPosts
        self.currentUser = currentUser
        // Initialize with current user's type, but allow them to change it
        _selectedUserType = State(initialValue: currentUser.userType)
    }
    
    var body: some View {
        NavigationView {
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
                        // User Type Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Sync as:")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            HStack(spacing: 12) {
                                UserTypeSyncButton(
                                    type: .consumer,
                                    icon: "person.fill",
                                    title: "Consumer",
                                    isSelected: selectedUserType == .consumer
                                ) {
                                    selectedUserType = .consumer
                                }
                                
                                UserTypeSyncButton(
                                    type: .bartender,
                                    icon: "wineglass.fill",
                                    title: "Bartender",
                                    isSelected: selectedUserType == .bartender
                                ) {
                                    selectedUserType = .bartender
                                }
                                
                                UserTypeSyncButton(
                                    type: .venue,
                                    icon: "building.2.fill",
                                    title: "Venue",
                                    isSelected: selectedUserType == .venue
                                ) {
                                    selectedUserType = .venue
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.top, 20)
                        
                        // Image Upload Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Add Photo")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            if let image = selectedImage {
                                // Display selected image
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 300)
                                        .clipped()
                                        .cornerRadius(16)
                                    
                                    Button(action: {
                                        selectedImage = nil
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                            .background(Color.black.opacity(0.6))
                                            .clipShape(Circle())
                                    }
                                    .padding(12)
                                }
                                .padding(.horizontal, 20)
                            } else {
                                // Upload button
                                Button(action: {
                                    showPhotoPicker = true
                                }) {
                                    VStack(spacing: 16) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 50))
                                            .foregroundColor(.yellow)
                                        
                                        Text("Tap to add photo")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        
                                        Text("Choose from library or take a photo")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 200)
                                    .background(Color.black.opacity(0.3))
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                                            .foregroundColor(Color.yellow.opacity(0.5))
                                    )
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        // Caption Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Caption")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            TextField("What's on your mind?", text: $caption, axis: .vertical)
                                .textFieldStyle(CustomTextFieldStyle())
                                .lineLimit(5...10)
                                .padding(.horizontal, 20)
                        }
                        
                        // Tags Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Tags (optional)")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            TextField("#negroni #cocktail #mixology", text: $tags)
                                .textFieldStyle(CustomTextFieldStyle())
                                .padding(.horizontal, 20)
                            
                            Text("Add hashtags to help others discover your post")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 20)
                        }
                        
                        // Post Type Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Post Type")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(PostType.allCases, id: \.self) { type in
                                        PostTypeButton(
                                            type: type,
                                            isSelected: selectedPostType == type
                                        ) {
                                            selectedPostType = type
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
                
                // Bottom Post Button
                VStack {
                    Spacer()
                    Button(action: {
                        postToFeed()
                    }) {
                        HStack {
                            if isPosting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            } else {
                                Image(systemName: "arrow.2.squarepath")
                                Text("Sync to Feed")
                            }
                        }
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(canPost ? .black : .gray)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(canPost ? Color.yellow : Color.gray.opacity(0.3))
                        .cornerRadius(28)
                    }
                    .disabled(!canPost || isPosting)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Create Sync")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .photosPicker(
                isPresented: $showPhotoPicker,
                selection: $selectedPhotoItem,
                matching: .images
            )
            .onChange(of: selectedPhotoItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImage = uiImage
                    }
                }
            }
        }
    }
    
    private var canPost: Bool {
        selectedImage != nil && !caption.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func postToFeed() {
        guard let image = selectedImage else { return }
        
        isPosting = true
        
        // Simulate posting delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Create tags array from string
            let tagArray = tags
                .components(separatedBy: " ")
                .filter { $0.hasPrefix("#") }
                .map { $0.trimmingCharacters(in: CharacterSet(charactersIn: "#")) }
            
            // For demo purposes, we'll use a placeholder image name
            // In a real app, you'd upload the image and get a URL
            let imageName = "user_upload_\(UUID().uuidString.prefix(8))"
            
            // Create updated user with selected user type
            let updatedUser = SocialUser(
                name: currentUser.name,
                username: currentUser.username,
                profileImage: currentUser.profileImage,
                userType: selectedUserType,
                location: currentUser.location,
                verified: currentUser.verified
            )
            
            let newPost = SocialPost(
                author: updatedUser,
                content: caption,
                image: imageName, // In real app, this would be the uploaded image URL
                tags: tagArray.isEmpty ? [] : tagArray.map { "#\($0)" },
                createdAt: Date(),
                likes: 0,
                comments: 0,
                syncs: 0,
                isLiked: false,
                isSynced: false,
                postType: selectedPostType
            )
            
            // Add to the beginning of the posts array
            socialPosts.insert(newPost, at: 0)
            
            isPosting = false
            presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - User Type Sync Button
struct UserTypeSyncButton: View {
    let type: UserType
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.headline)
            }
            .foregroundColor(isSelected ? .black : .white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                isSelected
                    ? Color.yellow
                    : Color.black.opacity(0.3)
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.yellow : Color.gray.opacity(0.3), lineWidth: 2)
            )
        }
    }
}

// MARK: - Post Type Button
struct PostTypeButton: View {
    let type: PostType
    let isSelected: Bool
    let action: () -> Void
    
    var icon: String {
        switch type {
        case .cocktail: return "wineglass.fill"
        case .venue: return "building.2.fill"
        case .event: return "calendar"
        case .training: return "book.fill"
        case .tip: return "lightbulb.fill"
        case .experience: return "star.fill"
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                Text(type.rawValue)
                    .font(.caption)
            }
            .foregroundColor(isSelected ? .black : .white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                isSelected
                    ? Color.yellow
                    : Color.black.opacity(0.3)
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    SyncPostView(
        socialPosts: .constant([]),
        currentUser: SocialUser(
            name: "John Doe",
            username: "johndoe",
            userType: .consumer,
            location: "Detroit, MI"
        )
    )
}

