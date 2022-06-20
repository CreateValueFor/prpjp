//
//  Constants.swift
//  prpjp
//
//  Created by 이민기 on 2022/06/02.
//

import Foundation
import SwiftUI


enum DISPLAY_RESOLUTION :CaseIterable{
    case XS
    case SM
    case MD
    case LG
    case XL
    
    var text : String {
        switch self {
        case .XS:
            return "192 X 32"
        case .SM :
            return "192 X 64"
        case .MD:
            return "192 X 128"
        case .LG:
            return "384 X 64"
        case .XL:
            return "384 X 128"
        }
    }
    
    var width : Int {
        switch self {
        case .XS:
            return 192
        case .SM :
            return 192
        case .MD:
            return 192
        case .LG:
            return 384
        case .XL:
            return 384
        }
    }
    
    var height : Int {
        switch self {
        case .XS:
            return 32
        case .SM :
            return 64
        case .MD:
            return 128
        case .LG:
            return 64
        case .XL:
            return 128
        }
    }
    
    
}

enum SPEAK_LANGUAGE : String, CaseIterable {
    case ENGLISH
    case FRENCH
    case SPANISH
    case 日本語
    case 한국어
    
    var code: String {
        switch self {
        case .ENGLISH :
            return "en"
        case .FRENCH:
            return "fr"
        case .SPANISH :
            return "es"
        case .日本語:
            return "ja"
        case .한국어:
            return "ko"
        }
    }
    
    var id: String{
        return self.rawValue
    }
}

enum TRANSLATION_LANGUAGE : String,CaseIterable {
    case ENGLISH
    case FRENCH
    case SPANISH
    case 日本語
    case 한국어
    
    var code: String {
        switch self {
        case .ENGLISH :
            return "en"
        case .FRENCH:
            return "fr"
        case .SPANISH :
            return "es"
        case .日本語:
            return "ja"
        case .한국어:
            return "ko"
        }
    }
    
    var id: String{
        return self.rawValue
    }
}

enum BACKGROUND :  String, CaseIterable{
    case BLACK
    case WHITE
    case RED
    case BLUE
    case GREEN
    case YELLOW
    
    var color: Color{
        switch self {
        case .BLACK:
            return Color.black
        case .WHITE:
            return Color.white
        case .RED:
            return Color.red
        case .BLUE:
            return Color.blue
        case .GREEN:
            return Color.green
        case .YELLOW:
            return Color.yellow
        }
    }
}

enum PRP_COLOR :  String, CaseIterable{
    case BLACK
    case WHITE
    case RED
    case BLUE
    case GREEN
    case YELLOW
    
    var color: Color{
        switch self {
        case .BLACK:
            return Color.black
        case .WHITE:
            return Color.white
        case .RED:
            return Color.red
        case .BLUE:
            return Color.blue
        case .GREEN:
            return Color.green
        case .YELLOW:
            return Color.yellow
        }
    }
}

enum FONT_SIZE : String ,CaseIterable{
    case SMALL
    case MEDIUM
    case LARGE
    
    var size: CGFloat{
        switch self {
        case .LARGE:
            return 16
        case .MEDIUM:
            return 12
        case .SMALL:
            return 10
        }
    }
}

enum FONT_STYLE : String ,CaseIterable{
    case BOLD
    case ITALIC
    
    var style: String{
        switch self {
        case .BOLD:
            return "BOLD"
        case .ITALIC:
            return "ITALIC"
        
        }
    }
}




