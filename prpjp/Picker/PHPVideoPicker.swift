//
//  PHPVideoPicker.swift
//  prpjp
//
//  Created by mykim on 2022/07/26.
//

import UIKit
import SwiftUI
import PhotosUI

struct PHPVideoPicker: UIViewControllerRepresentable {
    
    @Binding var isShown: Bool
    @Binding var videoURL: URL?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .videos
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator:NSObject, PHPickerViewControllerDelegate {
        
        let parent: PHPVideoPicker
        init(_ parent: PHPVideoPicker){
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            
            picker.dismiss(animated: true) {
                
            }
            
            guard let provider = results.first?.itemProvider else {return}
            provider.loadFileRepresentation(forTypeIdentifier: "public.movie") { url, error in
                if let error = error {
                    print(error)
                    return
                }
                
                guard let url = url else { return }
                
                let fileName = "\(Int(Date().timeIntervalSince1970)).\(url.pathExtension)"
                let newUrl = URL(fileURLWithPath: NSTemporaryDirectory() + fileName)
                try? FileManager.default.copyItem(at: url, to: newUrl)
                print(">>> video picker's url is \(newUrl)")
                self.parent.videoURL = newUrl
            }
        }
    }
}
