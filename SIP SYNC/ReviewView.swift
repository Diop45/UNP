//
//  ReviewView.swift
//  SIP SYNC
//
//  Yelp-Style Review System
//

import SwiftUI
import UIKit

// MARK: - Review Model (Yelp-style)
struct Review: Identifiable {
    let id = UUID()
    var author: SocialUser
    var rating: Int // 1-5 stars
    var reviewText: String
    var photos: [String] // Image names
    var createdAt: Date
    var helpfulCount: Int = 0
    var isHelpful: Bool = false
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: createdAt)
    }
    
    var timeAgo: String {
        let interval = Date().timeIntervalSince(createdAt)
        let days = Int(interval / 86400)
        let months = Int(interval / 2592000)
        let years = Int(interval / 31536000)
        
        if years > 0 {
            return "\(years) year\(years > 1 ? "s" : "") ago"
        } else if months > 0 {
            return "\(months) month\(months > 1 ? "s" : "") ago"
        } else if days > 0 {
            return "\(days) day\(days > 1 ? "s" : "") ago"
        } else {
            return "Today"
        }
    }
}

// MARK: - Yelp-Style Review Card
struct YelpReviewCard: View {
    let review: Review
    let onHelpful: () -> Void
    let onPhotoTap: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // User Info and Rating
            HStack(alignment: .top, spacing: 12) {
                // Profile Picture
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.yellow.opacity(0.3), UNPColors.creamMuted(0.3)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: review.author.userType == .bartender ? "wineglass.fill" : "person.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    // Name and Verified Badge
                    HStack(spacing: 4) {
                        Text(review.author.name)
                            .font(.headline)
                            .foregroundColor(.black)
                        if review.author.verified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                        }
                    }
                    
                    // Star Rating
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= review.rating ? "star.fill" : "star")
                                .foregroundColor(star <= review.rating ? .yellow : .gray.opacity(0.3))
                                .font(.caption)
                        }
                    }
                    
                    // Date
                    Text(review.timeAgo)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            // Review Text
            if !review.reviewText.isEmpty {
                Text(review.reviewText)
                    .font(.body)
                    .foregroundColor(.black)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Photos
            if !review.photos.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(review.photos, id: \.self) { photoName in
                            Button(action: {
                                onPhotoTap(photoName)
                            }) {
                                Image(photoName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipped()
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            
            // Helpful Button
            HStack(spacing: 8) {
                Button(action: onHelpful) {
                    HStack(spacing: 4) {
                        Image(systemName: review.isHelpful ? "hand.thumbsup.fill" : "hand.thumbsup")
                            .foregroundColor(review.isHelpful ? .yellow : .gray)
                            .font(.caption)
                        Text(review.isHelpful ? "Helpful" : "Helpful")
                            .font(.caption)
                            .foregroundColor(review.isHelpful ? .yellow : .gray)
                        if review.helpfulCount > 0 {
                            Text("(\(review.helpfulCount))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Yelp-Style Review Form
struct YelpReviewForm: View {
    @Binding var isPresented: Bool
    @State private var rating: Int = 0
    @State private var reviewText: String = ""
    @State private var selectedPhotos: [UIImage] = []
    @State private var showImagePicker = false
    @State private var showImageSourceSelection = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    let location: Location
    let onSave: (Review) -> Void
    
    private var currentUser: SocialUser {
        SampleData.shared.sampleSocialUsers.first ?? SocialUser(
            name: "You",
            username: "user",
            userType: .consumer,
            location: "Detroit"
        )
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Write a Review")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        Text(location.name)
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Star Rating Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Rating")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        HStack(spacing: 12) {
                            ForEach(1...5, id: \.self) { star in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        rating = star
                                    }
                                }) {
                                    Image(systemName: star <= rating ? "star.fill" : "star")
                                        .foregroundColor(star <= rating ? .yellow : .gray.opacity(0.3))
                                        .font(.system(size: 40))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        if rating > 0 {
                            Text(ratingText(for: rating))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    
                    // Review Text Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Review")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        ZStack(alignment: .topLeading) {
                            if reviewText.isEmpty {
                                Text("Share details about your experience at this place...")
                                    .foregroundColor(.gray.opacity(0.6))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 12)
                            }
                            
                            TextEditor(text: $reviewText)
                                .font(.body)
                                .foregroundColor(.black)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .frame(minHeight: 150)
                                .padding(8)
                        }
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        
                        Text("\(reviewText.count) characters")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    
                    // Photos Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Photos")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        if selectedPhotos.isEmpty {
                            Button(action: {
                                showImageSourceSelection = true
                            }) {
                                HStack {
                                    Image(systemName: "camera.fill")
                                        .foregroundColor(.yellow)
                                    Text("Add Photos")
                                        .foregroundColor(.black)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(Array(selectedPhotos.enumerated()), id: \.offset) { index, photo in
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: photo)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 100, height: 100)
                                                .clipped()
                                                .cornerRadius(8)
                                            
                                            Button(action: {
                                                selectedPhotos.remove(at: index)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.white)
                                                    .background(Color.black.opacity(0.6))
                                                    .clipShape(Circle())
                                            }
                                            .padding(4)
                                        }
                                    }
                                    
                                    Button(action: {
                                        showImageSourceSelection = true
                                    }) {
                                        VStack {
                                            Image(systemName: "plus")
                                                .foregroundColor(.gray)
                                                .font(.title2)
                                            Text("Add")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        .frame(width: 100, height: 100)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    
                    // Submit Button
                    Button(action: {
                        let photoNames = selectedPhotos.enumerated().map { index, _ in
                            "review_photo_\(UUID().uuidString.prefix(8))"
                        }
                        
                        let newReview = Review(
                            author: currentUser,
                            rating: rating,
                            reviewText: reviewText,
                            photos: photoNames,
                            createdAt: Date(),
                            helpfulCount: 0,
                            isHelpful: false
                        )
                        
                        onSave(newReview)
                        isPresented = false
                    }) {
                        Text("Post Review")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(rating > 0 ? Color.yellow : Color.gray.opacity(0.3))
                            .cornerRadius(12)
                    }
                    .disabled(rating == 0)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .background(Color.gray.opacity(0.05))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.black)
                }
            }
        }
        .sheet(isPresented: $showImageSourceSelection) {
            ImageSourceSelectionView(
                onCameraSelected: {
                    imageSourceType = .camera
                    showImagePicker = true
                },
                onLibrarySelected: {
                    imageSourceType = .photoLibrary
                    showImagePicker = true
                }
            )
        }
        .sheet(isPresented: $showImagePicker) {
            MultipleImagePicker(
                isPresented: $showImagePicker,
                selectedImages: $selectedPhotos,
                sourceType: imageSourceType
            )
        }
    }
    
    private func ratingText(for rating: Int) -> String {
        switch rating {
        case 1: return "Poor"
        case 2: return "Fair"
        case 3: return "Good"
        case 4: return "Very Good"
        case 5: return "Excellent"
        default: return ""
        }
    }
}

// MARK: - Reviews Section Component
struct ReviewsSection: View {
    let reviews: [Review]
    let averageRating: Double
    let reviewCount: Int
    let onAddReview: () -> Void
    let onHelpful: (Review) -> Void
    let onPhotoTap: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with Rating Summary
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(String(format: "%.1f", averageRating))
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.black)
                        HStack(spacing: 2) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= Int(averageRating) ? "star.fill" : "star")
                                    .foregroundColor(star <= Int(averageRating) ? .yellow : .gray.opacity(0.3))
                                    .font(.caption)
                            }
                        }
                    }
                    Text("\(reviewCount) review\(reviewCount != 1 ? "s" : "")")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Add Review Button
                Button(action: onAddReview) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                            .font(.headline)
                        Text("Write a Review")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.yellow)
                    .cornerRadius(20)
                }
            }
            
            // Reviews List
            if reviews.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "star.circle")
                        .font(.system(size: 50))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("No reviews yet")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("Be the first to review!")
                        .font(.subheadline)
                        .foregroundColor(.gray.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 12) {
                    ForEach(reviews) { review in
                        YelpReviewCard(
                            review: review,
                            onHelpful: {
                                onHelpful(review)
                            },
                            onPhotoTap: { photoName in
                                onPhotoTap(photoName)
                            }
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    let sampleReview = Review(
        author: SampleData.shared.sampleSocialUsers[0],
        rating: 5,
        reviewText: "Amazing cocktails and great atmosphere! The bartender really knows their craft. Highly recommend the Negroni.",
        photos: ["Negroni"],
        createdAt: Date().addingTimeInterval(-86400),
        helpfulCount: 3,
        isHelpful: false
    )
    
    return YelpReviewCard(
        review: sampleReview,
        onHelpful: {},
        onPhotoTap: { _ in }
    )
    .padding()
}

