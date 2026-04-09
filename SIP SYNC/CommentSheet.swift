//
//  CommentSheet.swift
//  SIP SYNC
//
//  Comment functionality for social posts
//

import SwiftUI

struct CommentSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var post: SocialPost
    @State private var commentText: String = ""
    @State private var currentUser: SocialUser
    
    init(post: Binding<SocialPost>, currentUser: SocialUser) {
        self._post = post
        self._currentUser = State(initialValue: currentUser)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Post content at top
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 40, height: 40)
                                .overlay(Image(systemName: "person").foregroundColor(.white))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(post.author.username)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text(timeAgoString(from: post.createdAt))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                        }
                        
                        Text(post.content)
                            .font(.body)
                            .foregroundColor(.white)
                        
                        if let imageName = post.image {
                            Image(imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 150)
                                .clipped()
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.3))
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    
                    // Comments list
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 16) {
                            if post.commentsList.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "bubble.left")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                    Text("No comments yet")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                    Text("Be the first to comment!")
                                        .font(.subheadline)
                                        .foregroundColor(.gray.opacity(0.7))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 60)
                            } else {
                                ForEach(post.commentsList) { comment in
                                    CommentRow(comment: comment)
                                }
                            }
                        }
                        .padding()
                    }
                    
                    // Comment input
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 36, height: 36)
                            .overlay(Image(systemName: "person.fill").foregroundColor(.white).font(.caption))
                        
                        TextField("Add a comment...", text: $commentText, axis: .vertical)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(20)
                            .lineLimit(1...4)
                        
                        Button(action: {
                            addComment()
                        }) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title2)
                                .foregroundColor(commentText.isEmpty ? .gray : .yellow)
                        }
                        .disabled(commentText.isEmpty)
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                }
            }
            .navigationTitle("Comments")
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
    
    private func addComment() {
        guard !commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newComment = Comment(
            author: currentUser,
            text: commentText.trimmingCharacters(in: .whitespacesAndNewlines),
            createdAt: Date(),
            likes: 0,
            isLiked: false
        )
        
        post.commentsList.append(newComment)
        post.comments += 1
        commentText = ""
    }
    
    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let hours = Int(interval / 3600)
        let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
        if hours > 24 {
            let days = hours / 24
            return "\(days)d"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
}

struct CommentRow: View {
    let comment: Comment
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color.gray)
                .frame(width: 32, height: 32)
                .overlay(Image(systemName: "person.fill").foregroundColor(.white).font(.caption))
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(comment.author.username)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    if comment.author.verified {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.yellow)
                            .font(.caption2)
                    }
                    
                    Text(timeAgoString(from: comment.createdAt))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(comment.text)
                    .font(.body)
                    .foregroundColor(.white)
                
                HStack(spacing: 16) {
                    Button(action: {}) {
                        HStack(spacing: 4) {
                            Image(systemName: comment.isLiked ? "heart.fill" : "heart")
                                .foregroundColor(comment.isLiked ? .red : .gray)
                                .font(.caption)
                            Text("\(comment.likes)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.top, 4)
            }
            
            Spacer()
        }
    }
    
    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let hours = Int(interval / 3600)
        let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
        if hours > 24 {
            let days = hours / 24
            return "\(days)d"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
}

private struct CommentSheetPreview: View {
    @State private var post = SampleData.shared.sampleSocialPosts[0]

    var body: some View {
        CommentSheet(post: $post, currentUser: SampleData.shared.sampleSocialUsers[0])
    }
}

#Preview("Comment sheet") {
    CommentSheetPreview()
}


