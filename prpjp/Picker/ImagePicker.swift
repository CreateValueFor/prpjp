//
//  ImagePicker.swift
//  prpjp
//
//  Created by 이민기 on 2022/06/27.
//

import Foundation
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {

    @Environment(\.presentationMode)
    var presentationMode

    @Binding var image: Image?
    @Binding var imageUrl: String?
    @Binding var uiImageVal : UIImage?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

        @Binding var presentationMode: PresentationMode
        @Binding var image: Image?
        @Binding var imageUrl : String?
        @Binding var uiImageVal : UIImage?

        init(presentationMode: Binding<PresentationMode>, image: Binding<Image?>, imageUrl : Binding<String?>, uiImageVal: Binding<UIImage?>) {
            _presentationMode = presentationMode
            _image = image
            _imageUrl = imageUrl
            _uiImageVal = uiImageVal
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let uiImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            
            uiImageVal = uiImage
            image = Image(uiImage: uiImage)
            imageUrl =  UIImagePickerController.InfoKey.imageURL.rawValue
            presentationMode.dismiss()

        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            presentationMode.dismiss()
        }

    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(presentationMode: presentationMode, image: $image, imageUrl: $imageUrl, uiImageVal: $uiImageVal)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<ImagePicker>) {

    }

}
