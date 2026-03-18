//
//  CameraView.swift
//  SIP SYNC
//
//  Created by AI Assistant - Camera Integration for Stories
//

import SwiftUI
import AVFoundation
import UIKit

// MARK: - Camera Permission Manager
class CameraPermissionManager: ObservableObject {
    @Published var permissionStatus: AVAuthorizationStatus = .notDetermined
    
    init() {
        checkPermission()
    }
    
    func checkPermission() {
        permissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    func requestPermission() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            await MainActor.run {
                permissionStatus = granted ? .authorized : .denied
            }
            return granted
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }
}

// MARK: - Image Picker Coordinator
class ImagePickerCoordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @Binding var isPresented: Bool
    @Binding var selectedImage: UIImage?
    let sourceType: UIImagePickerController.SourceType
    
    init(isPresented: Binding<Bool>, selectedImage: Binding<UIImage?>, sourceType: UIImagePickerController.SourceType) {
        _isPresented = isPresented
        _selectedImage = selectedImage
        self.sourceType = sourceType
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            selectedImage = image
        }
        isPresented = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isPresented = false
    }
}

// MARK: - Image Picker View
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var selectedImage: UIImage?
    let sourceType: UIImagePickerController.SourceType
    
    func makeCoordinator() -> ImagePickerCoordinator {
        ImagePickerCoordinator(isPresented: $isPresented, selectedImage: $selectedImage, sourceType: sourceType)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        if sourceType == .camera {
            picker.cameraCaptureMode = .photo
            picker.cameraDevice = .rear
        }
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

// MARK: - Add Story View
struct AddStoryView: View {
    @Binding var isPresented: Bool
    @StateObject private var permissionManager = CameraPermissionManager()
    @State private var showCamera = false
    @State private var showPhotoLibrary = false
    @State private var selectedImage: UIImage?
    @State private var showStoryEditor = false
    @State private var reviewText: String = ""
    @State private var rating: Int? = nil
    @State private var showPermissionAlert = false
    
    let onStoryCreated: (UIImage?, String?, Int?) -> Void
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.title2)
                            .padding(12)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Add Story")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Spacer for balance
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                Spacer()
                
                // Options
                VStack(spacing: 20) {
                    // Camera Button
                    Button(action: {
                        handleCameraTap()
                    }) {
                        VStack(spacing: 12) {
                            ZStack {
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
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "camera.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 32))
                            }
                            
                            Text("Take Photo")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(16)
                    
                    // Photo Library Button
                    Button(action: {
                        showPhotoLibrary = true
                    }) {
                        VStack(spacing: 12) {
                            ZStack {
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
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "photo.on.rectangle")
                                    .foregroundColor(.white)
                                    .font(.system(size: 32))
                            }
                            
                            Text("Choose from Library")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(16)
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(
                isPresented: $showCamera,
                selectedImage: $selectedImage,
                sourceType: .camera
            )
        }
        .sheet(isPresented: $showPhotoLibrary) {
            ImagePicker(
                isPresented: $showPhotoLibrary,
                selectedImage: $selectedImage,
                sourceType: .photoLibrary
            )
        }
        .onChange(of: selectedImage) { newValue in
            if newValue != nil {
                showStoryEditor = true
            }
        }
        .sheet(isPresented: $showStoryEditor) {
            StoryEditorView(
                image: selectedImage,
                reviewText: $reviewText,
                rating: $rating,
                isEditing: false,
                onSave: {
                    onStoryCreated(selectedImage, reviewText.isEmpty ? nil : reviewText, rating)
                    selectedImage = nil
                    reviewText = ""
                    rating = nil
                    isPresented = false
                },
                onCancel: {
                    selectedImage = nil
                    reviewText = ""
                    rating = nil
                    showStoryEditor = false
                }
            )
        }
        .alert("Camera Permission Required", isPresented: $showPermissionAlert) {
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable camera access in Settings to take photos for your story.")
        }
    }
    
    private func handleCameraTap() {
        Task {
            let granted = await permissionManager.requestPermission()
            await MainActor.run {
                if granted {
                    showCamera = true
                } else {
                    showPermissionAlert = true
                }
            }
        }
    }
}

// MARK: - Review Editor View (Story Editor)
struct StoryEditorView: View {
    let image: UIImage?
    @Binding var reviewText: String
    @Binding var rating: Int?
    let onSave: () -> Void
    let onCancel: () -> Void
    let isEditing: Bool
    
    init(image: UIImage?, reviewText: Binding<String>, rating: Binding<Int?> = .constant(nil), isEditing: Bool = false, onSave: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.image = image
        self._reviewText = reviewText
        self._rating = rating
        self.isEditing = isEditing
        self.onSave = onSave
        self.onCancel = onCancel
    }
    
    var body: some View {
        ZStack {
            // Image background
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
            }
            
            // Dark overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: onCancel) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.title2)
                            .padding(12)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text(isEditing ? "Edit Review" : "Add Review")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: onSave) {
                        Text("Save")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.yellow)
                            .cornerRadius(20)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                Spacer()
                
                // Review Input Section
                VStack(spacing: 16) {
                    // Rating Stars
                    VStack(spacing: 8) {
                        Text("Rating")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        HStack(spacing: 8) {
                            ForEach(1...5, id: \.self) { star in
                                Button(action: {
                                    rating = star
                                }) {
                                    Image(systemName: star <= (rating ?? 0) ? "star.fill" : "star")
                                        .foregroundColor(star <= (rating ?? 0) ? .yellow : .gray)
                                        .font(.title2)
                                }
                            }
                        }
                    }
                    
                    // Review Text Input
                    ZStack(alignment: .topLeading) {
                        if reviewText.isEmpty {
                            Text("Write your review...")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 12)
                        }
                        
                        TextEditor(text: $reviewText)
                            .font(.body)
                            .foregroundColor(.white)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .frame(minHeight: 120)
                            .padding(8)
                    }
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Edit Review View
struct EditReviewView: View {
    @Binding var isPresented: Bool
    let story: Story
    @State private var reviewText: String
    @State private var rating: Int?
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showImageSourceSelection = false
    
    let onSave: (Story) -> Void
    
    init(story: Story, isPresented: Binding<Bool>, onSave: @escaping (Story) -> Void) {
        self.story = story
        self._isPresented = isPresented
        self._reviewText = State(initialValue: story.reviewText ?? "")
        self._rating = State(initialValue: story.rating)
        self.onSave = onSave
    }
    
    var body: some View {
        StoryEditorView(
            image: selectedImage,
            reviewText: $reviewText,
            rating: $rating,
            isEditing: true,
            onSave: {
                var updatedStory = story
                updatedStory.reviewText = reviewText.isEmpty ? nil : reviewText
                updatedStory.rating = rating
                onSave(updatedStory)
                isPresented = false
            },
            onCancel: {
                isPresented = false
            }
        )
        .sheet(isPresented: $showImageSourceSelection) {
            ImageSourceSelectionView(
                onCameraSelected: {
                    showImagePicker = true
                },
                onLibrarySelected: {
                    showImagePicker = true
                }
            )
        }
    }
}

// MARK: - Image Source Selection View
struct ImageSourceSelectionView: View {
    let onCameraSelected: () -> Void
    let onLibrarySelected: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Camera") {
                onCameraSelected()
                presentationMode.wrappedValue.dismiss()
            }
            .buttonStyle(.borderedProminent)
            
            Button("Photo Library") {
                onLibrarySelected()
                presentationMode.wrappedValue.dismiss()
            }
            .buttonStyle(.borderedProminent)
            
            Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .padding()
    }
}

#Preview {
    AddStoryView(isPresented: .constant(true)) { image, text, rating in
        print("Review created with image, text: \(text ?? "no text"), rating: \(rating?.description ?? "none")")
    }
}

