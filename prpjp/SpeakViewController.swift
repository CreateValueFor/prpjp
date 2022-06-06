//
//  SpeakViewController.swift
//  prpjp
//
//  Created by 이민기 on 2022/06/06.
//

import SwiftUI
import Speech

struct SpeakViewController<Page: View>: UIViewControllerRepresentable {
    let vc = 
    var speakLanguage : SPEAK_LANGUAGE
    var translationlanguage : TRANSLATION_LANGUAGE
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let speakViewController = UIViewController();
        
        speakViewController.delegate = context.coordinator
        
    }
    
}
