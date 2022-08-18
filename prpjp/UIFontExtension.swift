//
//  UIFontExtension.swift
//  prpjp
//
//  Created by 이민기 on 2022/08/19.
//
import Foundation
import UIKit

public extension UIFont {
    
    public func withTraits(_ traits: UIFontDescriptor.SymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor
            .withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
    }
        
    public var italic : UIFont {
        return withTraits(.traitItalic)
    }
        
    public var bold : UIFont {
        return withTraits(.traitBold)
    }
    
    public var boldItlc : UIFont {
        return withTraits(.traitBold, .traitItalic)
    }
}
