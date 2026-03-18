//
//  MultipleImagePicker.swift
//  SIP SYNC
//
//  Image Picker for Multiple Photos
//

import SwiftUI
import UIKit

class MultipleImagePickerCoordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @Binding var isPresented: Bool
    @Binding var selectedImages: [UIImage]
    let sourceType: UIImagePickerController.SourceType
    
    init(isPresented: Binding<Bool>, selectedImages: Binding<[UIImage]>, sourceType: UIImagePickerController.SourceType) {
        _isPresented = isPresented
        _selectedImages = selectedImages
        self.sourceType = sourceType
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            selectedImages.append(image)
        }
        isPresented = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isPresented = false
    }
}

struct MultipleImagePicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var selectedImages: [UIImage]
    let sourceType: UIImagePickerController.SourceType
    
    func makeCoordinator() -> MultipleImagePickerCoordinator {
        MultipleImagePickerCoordinator(isPresented: $isPresented, selectedImages: $selectedImages, sourceType: sourceType)
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




