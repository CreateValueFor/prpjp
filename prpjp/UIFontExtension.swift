//
//  UIFontExtension.swift
//  prpjp
//
//  Created by 이민기 on 2022/08/19.
//
import Foundation
import UIKit
import SwiftUI

public extension UIFont {
    
    func withTraits(_ traits: UIFontDescriptor.SymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor
            .withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
    }
    
    func styleType(font: String )-> UIFont {
        switch font {
        case "BOTH":
            return boldItlc
        case "ITALIC":
            return italic
        case "BOLD":
            return bold
        default :
            return noneFont
        }
    }
        
    var italic : UIFont {
        return withTraits(.traitItalic)
    }
        
    var bold : UIFont {
        return withTraits(.traitBold)
    }
    
    var boldItlc : UIFont {
        return withTraits(.traitBold, .traitItalic)
    }
    var noneFont : UIFont{
        return withTraits()
    }
}

public extension Font {
  init(uiFont: UIFont) {
    self = Font(uiFont as CTFont)
  }
}
