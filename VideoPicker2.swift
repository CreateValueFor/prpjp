//
//  VideoPicker2.swift
//  prpjp
//
//  Created by 이민기 on 2022/06/27.
//

import UIKit
import Foundation
import SwiftUI
import MobileCoreServices

struct VideoPicker2: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.mediaTypes = [kUTTypeMovie as String]
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }

      @Binding var isShown: Bool
      @Binding var url: URL?

      class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        
          @Binding var isShown: Bool
          @Binding var url: URL?

         // I have tried using a new variable (parentImagePicker) here and I added it to the initializer so that I can store the imageData in it in the function (imagePickerController) below but I wasn't able to implement it correctly
        
          init( isShown: Binding<Bool>, url: Binding<URL?>) {
              _isShown = isShown
              _url = url
              
          }
        

          func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

              
  
                          guard let mediaType = info[.mediaType] as? String,
                              mediaType == (kUTTypeMovie as String),
                              let uiURL = info[.mediaURL] as? URL
                              else { return }
            
            
            
                          url = uiURL
                          isShown = false
                      }

          func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
              isShown = false
          }

      }

      func makeCoordinator() -> Coordinator {
        return Coordinator( isShown: $isShown, url: $url)
      }

      
  }

  fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
      return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
  }

  fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
      return input.rawValue
  }
