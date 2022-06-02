//
//  ContentView.swift
//  prpjp
//
//  Created by 이민기 on 2022/05/31.
//

import SwiftUI

struct ContentView: View {
    
    @State private var resolution : String = DISPLAY_RESOLUTION.XS.text
    @State private var speakLanguage : String = SPEAK_LANGUAGE.ENGLISH.id
    @State private var translationLanguage : String = TRANSLATION_LANGUAGE.ENGLISH.id
    @State private var background : String = PRP_COLOR.BLACK.rawValue
    @State private var textColor : String = PRP_COLOR.BLACK.rawValue
    @State private var fontSize : String = FONT_SIZE.SMALL.rawValue
    @State private var fontStyle : String = FONT_STYLE.BOLD.rawValue
    @State private var IP : String = ""
    
    let resolutions: [String] = DISPLAY_RESOLUTION.allCases.map{
        $0.text
    }
    let speakLanguages : [String] = SPEAK_LANGUAGE.allCases.map{
        $0.id
    }
    let translationLanguages : [String] = TRANSLATION_LANGUAGE.allCases.map {
        $0.id
    }
    let fontSizes : [String] = FONT_SIZE.allCases.map{
        $0.rawValue
    }
    let fontStyles : [String] = FONT_STYLE.allCases.map{
        $0.rawValue
    }
    let colors : [PRP_COLOR] = PRP_COLOR.allCases.map{
        $0
    }
    let color : String = PRP_COLOR.BLACK.rawValue
    
    
    
    var body: some View {
        Color(.darkGray).overlay(
            VStack{
                RadioButtonGroup(items: resolutions, selectedId: resolution) { text in
                    print(text)
                }
                RectangleButtonGroup(items: speakLanguages, title: "Speak language", selectedId: speakLanguage) { speakLanguage in
                    print(speakLanguage)
                }
                RectangleButtonGroup(items: translationLanguages, title: "Translation language", selectedId: translationLanguage) { translation in
                    print(translation)
                }
                CircleButtonGroup(items: colors, title: "Background", selectedId: background) { color in
                    print(color)
                }
                CircleButtonGroup(items: colors, title: "Text color", selectedId: textColor) { color in
                    print(color)
                }
                
                RectangleButtonGroup(items: fontSizes, title: "Font size", selectedId: fontSize) { fontSize in
                    print(fontSize)
                }
                RectangleButtonGroup(items: fontStyles, title: "Font style", selectedId: fontStyle) { fontStyle in
                    print(fontStyle)
                }
                
                
            }
        )
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
