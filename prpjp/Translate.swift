//
//  Translate.swift
//  prpjp
//
//  Created by 이민기 on 2022/06/29.
//

import Foundation
import Alamofire
import SwiftUI

class Translate : ObservableObject {
    private let TRANSLATE_PATH : String = "http://ec2-3-133-11-183.us-east-2.compute.amazonaws.com:8080/translate"
    
    @Published var trText = ""
    
//    init(text : String){
//        trText = text
//    }
    
    func translate(speakLangCode: String, translateLangCode: String, text : String) -> Void {
        
        let parameters: [String: Any] = [
            "msg": text,
            "inputLang" : speakLangCode,
            "outputLang" : translateLangCode
        ]
        print(parameters.description)
        
        
        AF.request(TRANSLATE_PATH, method: .post, parameters: parameters,encoding: URLEncoding.httpBody)
            .validate()
            .responseDecodable(of: translateResposne.self){ [self]
                resposne in
                print(resposne)
                guard let curText =  resposne.value?.result else {return}
                print(curText)
                trText = curText
//                print(Translate.text)
                
            }
        
        
        
        
    }
}
