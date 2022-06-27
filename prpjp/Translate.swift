//
//  Translate.swift
//  prpjp
//
//  Created by 이민기 on 2022/06/27.
//

import Foundation
import Alamofire

class Translate {
    private static let TRANSLATE_PATH : String = "http://ec2-3-133-11-183.us-east-2.compute.amazonaws.com:8080/translate"
    static var text = ""
    
    static func translate(speakLangCode: String, translateLangCode: String, text : String) {
        print("번역 시작")
        print("번역 옵션 \(speakLangCode) \(translateLangCode)")
        
        let parameters: [String: Any] = [
            "msg": text,
            "inputLang" : speakLangCode,
            "outputLang" : translateLangCode
            
        ]
        
        AF.request(TRANSLATE_PATH, method: .post, parameters: parameters,encoding: URLEncoding.httpBody)
            .validate()
            .responseDecodable(of: translateResposne.self){
                resposne in
                
                guard let trText =  resposne.value?.result else {return}
                Translate.text = trText
            }
    }
}
