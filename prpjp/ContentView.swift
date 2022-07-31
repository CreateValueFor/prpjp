//
//  ContentView.swift
//  prpjp
//
//  Created by 이민기 on 2022/05/31.
//

import SwiftUI
import UIKit
import Speech
import AVFoundation
import Alamofire
import Network
import AVKit


struct translateResposne: Decodable {
    var result: String
    var bytes: Int
}

struct ContentView: View {
    @State private var resolution: DISPLAY_RESOLUTION = DISPLAY_RESOLUTION.XS
    @State private var mirrorWidth: CGFloat =  DISPLAY_RESOLUTION.XS.width
    @State private var mirrorHeight: CGFloat =  DISPLAY_RESOLUTION.XS.height / 2
    
    // button info
    @State private var isBrailMode: Bool = false
    @State private var isReverseMode: Bool = false
    @State private var isLock: Bool = false
    
    @State private var speakLanguage: String = SPEAK_LANGUAGE.ENGLISH.id
    @State private var translationLanguage: String = TRANSLATION_LANGUAGE.ENGLISH.id
    @State private var speakLangCode: String = "en"
    @State private var translateLangCode: String = "en"
    @State private var background: String = PRP_COLOR.BLUE.rawValue
    @State private var backgroundValue: Color = PRP_COLOR.BLUE.color
    
    @State private var textColor: String = PRP_COLOR.WHITE.rawValue
    @State private var textColorValue: Color = PRP_COLOR.WHITE.color
    
    @State private var fontSize: String = FONT_SIZE.SMALL.rawValue
    @State private var fontSizeValue: CGFloat = FONT_SIZE.SMALL.size
    
    
    @State private var fontStyleBold: String = FONT_STYLE.BOLD.rawValue
    @State private var fontStyleBoldValue: Font.Weight = Font.Weight.bold
    
    @State private var fontStyleItalic: String = ""
    
    
    @State private var IP: String = ""
    
    @State private var finalText: String = "Placeholder"
    @StateObject var speechRecognizer = SpeechRecognizer();
    //    var text : String = ""
    @State private var text: String = ""
    @State private var xLocation: CGFloat = DISPLAY_RESOLUTION.XS.xLocation
    @State private var yLocation: CGFloat = DISPLAY_RESOLUTION.XS.yLocation
    
    @State private var isSpeakBtnDisabled: Bool = false
    @State private var isDisplayBtnDisabled: Bool = false
    
    @State private var SpeakBtnPressed: Bool = false;
    @State private var DisplayBtnPressed: Bool = false;
    
    //image
    @State var isShowPicker: Bool = false
    @State var image: Image? = Image("placeholder")
    
    // video
    @State var videoURL: URL?
    @State var showVideoPicker: Bool = false
    @State var player = AVPlayer()
    
    //    @StateObject var udpManager = UDPManager()
    
    //    var TCPPort : Int32 = self.udpManager.port
    //    var TCPHost : String = self.udpManager.host
    
    
    // safe area inset
    
    let resolutions: [DISPLAY_RESOLUTION] = DISPLAY_RESOLUTION.allCases.map{
        $0
    }
    let speakLanguages: [String] = SPEAK_LANGUAGE.allCases.map{
        $0.id
    }
    let translationLanguages: [String] = TRANSLATION_LANGUAGE.allCases.map {
        $0.id
    }
    let fontSizes: [String] = FONT_SIZE.allCases.map{
        $0.rawValue
    }
    let fontStyles: [String] = FONT_STYLE.allCases.map{
        $0.rawValue
    }
    let colors: [PRP_COLOR] = PRP_COLOR.allCases.map{
        $0
    }
    let color: String = PRP_COLOR.BLACK.rawValue
    
    
    func colorConverter (color: String) -> Color {
        switch color {
        case "BLACK":
            return Color.black
        case "WHITE":
            return Color.white
        case "RED":
            return Color.red
        case "BLUE":
            return Color.blue
        case "GREEN":
            return Color.green
        case "YELLOW":
            return Color.yellow
        default:
            return Color.black
        }
    }


    // TTS Logic
    func startTTS(){
        let synthesizeer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: text)
        
        var speechText : String?
        switch translateLangCode {
        case "ENGLISH":
            speechText = "en_US"
        case "FRENCH":
            speechText = "fr_FR"
        case "SPANISH":
            speechText = "es"
        case "日本語":
            speechText = "ja_JP"
        case "한국어":
            speechText = "ko_KR"
        default:
            print(speechText ?? "")
        }
        utterance.voice = AVSpeechSynthesisVoice(language: speechText)
        
        utterance.rate = 0.4
        synthesizeer.speak(utterance)

        SocketServerManager.shared.send(text: text, background: background, color: color, fontSize: fontSize, fontStyleBold: fontStyleBold, resolution: resolution)
    }
    
    
    var body: some View {
        GeometryReader{
            proxy in
            
            VStack(alignment: .trailing){
                // toggle buttons
                HStack(alignment: .center, spacing: 10){
                    
                    Toggle(isOn: $isBrailMode, label: {
                        Text("Braile Mode")
                            .font(Font.system(size: 12))
                            .foregroundColor(.white)
                    })
                    .toggleStyle(SwitchToggleStyle(tint: Color(hex:"#008577")))
                    //                        .padding(.horizontal, 10)
                    Toggle(isOn: $isReverseMode, label: {
                        Text("Reverse Mode")
                            .font(Font.system(size: 12))
                            .foregroundColor(.white)
                    })
                    .toggleStyle(SwitchToggleStyle(tint: Color(hex:"#008577")))
                    //                        .padding(.horizontal, 10)
                    Toggle(isOn: $isLock, label: {
                        Text("Lock")
                            .font(Font.system(size: 12))
                            .foregroundColor(.white)
                    })
                    .toggleStyle(SwitchToggleStyle(tint: Color(hex:"#008577")))
                    //                        .padding(.horizontal, 10)
                }
                .frame(width: 450)
                .padding(10)
                
                ZStack(alignment: .topLeading){
                    HStack (alignment: .top){
                        ScrollView(.vertical){
                            VStack(alignment: .leading) {
                                RadioButtonGroup(items: resolutions, selectedId: resolution) { resol in
                                    mirrorHeight = resol.height / 2
                                    mirrorWidth = resol.width
                                    xLocation = resol.xLocation
                                    yLocation = resol.yLocation
                                    
                                }
                                TextField("", text: $text)
                                    .padding()
                                    .foregroundColor(.white)
                                    .frame(minWidth: 200, idealWidth: .infinity, maxWidth: .infinity
                                    )
                                    .overlay(VStack{
                                        Divider().offset(x: 1, y: 12)
                                    })
                                RectangleButtonGroup(items: speakLanguages, title: "Speak language", selectedId: speakLanguage) { speakLanguage in
                                    switch speakLanguage {
                                    case "ENGLISH":
                                        speakLangCode = "en"
                                        //                                        speechRecognizer =
                                        //                                        SFSpeechRecognizer(locale: SPEAK_LANGUAGE.ENGLISH.lang)
                                    case "FRENCH":
                                        speakLangCode = "fr"
                                        //                                        SFSpeechRecognizer(locale: SPEAK_LANGUAGE.FRENCH.lang)
                                    case "SPANISH":
                                        speakLangCode = "es"
                                        //                                        SFSpeechRecognizer(locale: SPEAK_LANGUAGE.SPANISH.lang)
                                    case "日本語":
                                        speakLangCode = "ja"
                                        //                                        SFSpeechRecognizer(locale: SPEAK_LANGUAGE.日本語.lang)
                                    case "한국어":
                                        speakLangCode = "ko"
                                        //                                        SFSpeechRecognizer(locale: SPEAK_LANGUAGE.한국어.lang)
                                    default:
                                        print(speakLanguage)
                                    }
                                }
                                RectangleButtonGroup(items: translationLanguages, title: "Translation language", selectedId: translationLanguage) { translation in
                                    switch translation {
                                    case "ENGLISH":
                                        translateLangCode = "en"
                                    case "FRENCH":
                                        translateLangCode = "fr"
                                    case "SPANISH":
                                        translateLangCode = "es"
                                    case "日本語":
                                        translateLangCode = "ja"
                                    case "한국어":
                                        translateLangCode = "ko"
                                    default:
                                        print(translateLangCode)
                                    }
                                    
                                    
                                }
                                HStack(alignment: .bottom, spacing: 20){
                                    CircleButtonGroup(items: colors, title: "Background", selectedId: background) { color in
                                        image = Image("placeholder")
                                        backgroundValue = colorConverter(color: color)
                                    }
                                    
                                    ZStack {
                                        
                                        VStack {
                                            
                                            Button(action: {
                                                withAnimation {
                                                    self.isShowPicker.toggle()
                                                }
                                            }) {
                                                
                                                Text("IMAGE").font(Font.system(size: 12))
                                                    .foregroundColor(.white)
                                            }.foregroundColor(.white)
                                                .frame(width: 60, height: 30)
                                                .background(.gray)
                                        }
                                    }
                                    .sheet(isPresented: $isShowPicker) {
                                        ImagePicker(image: self.$image)
                                    }
                                    ZStack {
                                        
                                        VStack {
                                            
                                            Button(action: {
                                                withAnimation {
                                                    self.showVideoPicker.toggle()
                                                }
                                            }) {
                                                
                                                Text("Video").font(Font.system(size: 12))
                                                    .foregroundColor(.white)
                                            }.foregroundColor(.white)
                                                .frame(width: 60, height: 30)
                                                .background(.gray)
                                        }
                                    }
                                    .sheet(isPresented: $showVideoPicker) {
                                        
                                        PHPVideoPicker(isShown: $showVideoPicker, videoURL: $videoURL)
                                    }
                                }
                                
                                
                                CircleButtonGroup(items: colors, title: "Text color", selectedId: textColor) { color in
                                    textColorValue = colorConverter(color: color)
                                    
                                }
                                
                                
                                RectangleButtonGroup(items: fontSizes, title: "Font size", selectedId: fontSize) { fontSize in
                                    switch fontSize {
                                    case "LARGE":
                                        fontSizeValue = 16
                                    case "MEDIUM":
                                        fontSizeValue = 12
                                    case "SMALL":
                                        fontSizeValue = 8
                                    default :
                                        fontSizeValue = 8
                                    }
                                }
                                
                                FontStyleGroup(title: "Font style", isBold: fontStyleBold, isItalic: fontStyleItalic) { id, isSelected in
                                    
                                    if(isSelected){
                                        switch id {
                                        case "ITALIC":
                                            fontStyleItalic = "ITALIC"
                                            
                                        case "BOLD":
                                            fontStyleBold = "BOLD"
                                            fontStyleBoldValue = Font.Weight.bold
                                        default:
                                            print("Something Wrong")
                                        }
                                        
                                    }else {
                                        switch id {
                                        case "ITALIC":
                                            fontStyleItalic = ""
                                        case "BOLD":
                                            fontStyleBold = ""
                                            fontStyleBoldValue = Font.Weight.medium
                                        default:
                                            print("Something Wrong")
                                        }
                                    }
                                }
                                
                                
                            }
                        }
                        VStack(alignment: .trailing){
                            PressButton("SPEAK", callback: { isSpeak in
                                print("함수실행 실행인자\(isSpeak)")
                                if(isSpeak){
                                    speechRecognizer.reset()
                                    
                                    speechRecognizer.transcribe()
                                    
                                    
                                }else{
                                    print(speechRecognizer.transcript)
                                    speechRecognizer.stopTranscribing()
                                    text = speechRecognizer.transcript
                                    
                                }
                                
                            }, isPressed: SpeakBtnPressed, disabled: isSpeakBtnDisabled)
                            PressButton("DISPLAY", callback: { isDisplay in
                                
                                
                                finalText = text
                                _ = Translate.translate(speakLangCode: speakLangCode, translateLangCode: translateLangCode, text: text)
                                SocketServerManager.shared.send(text: self.text, background: background, color: color, fontSize: fontSize, fontStyleBold: fontStyleBold, resolution: resolution)
                                //                                translate(text: text)
                                if(isDisplay){
                                    startTTS()
                                    if(image != nil){
                                        SocketServerManager.shared.send(text: text, background: background, color: textColor, fontSize: fontSize, fontStyleBold: fontStyleBold, resolution: resolution)
                                    }else{
                                        SocketServerManager.shared.send(text: text, background: background, color: textColor, fontSize: fontSize, fontStyleBold: fontStyleBold, resolution: resolution)
                                    }

                                    
                                }
                            }, isPressed: DisplayBtnPressed, disabled: isDisplayBtnDisabled)
                        }
                        
                    }
                    .padding(EdgeInsets(top: 60, leading: 30, bottom: 0, trailing: 30))
                    // mirror state
                    
                    VStack(alignment: .trailing){
                        ZStack(alignment: .topLeading){
                            if fontStyleItalic == "ITALIC" {
                                
                                
                                image?
                                    .resizable()
                                //                                        .scaledToFill()
                                    .frame(width: mirrorWidth, height: mirrorHeight)
//                                VideoPlayer(player: player)
//                                    .onAppear(){
//                                        if player.currentItem == nil {
//                                            let item = AVPlayerItem(url: videoURL!)
//                                            player.replaceCurrentItem(with: item)
//                                        }
//                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                                            player.play()
//                                        }
//                                    }.frame(width: mirrorWidth, height: mirrorHeight)
//
                                
                                Text(finalText)
                                    .foregroundColor(textColorValue)
                                    .font(.system(size: fontSizeValue,weight: fontStyleBoldValue) )
                                    .italic()
                                
                                
                                
                            }else {
                                
                                image?
                                    .resizable()
                                //                                        .scaledToFill()
                                    .frame(width: mirrorWidth, height: mirrorHeight)
//                                VideoPlayer(player: player)
//                                    .onAppear(){
//                                        guard let videoURL = videoURL else {return}
//                                        if player.currentItem == nil {
//                                            let item = AVPlayerItem(url: videoURL)
//                                            player.replaceCurrentItem(with: item)
//                                        }
//                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                                            player.play()
//                                        }
//                                    }
//
//                                    .frame(width: mirrorWidth, height: mirrorHeight)
                                Text(finalText)
                                    .foregroundColor(textColorValue)
                                    .font(.system(size: fontSizeValue,weight: fontStyleBoldValue) )
                                
                            }
                            
                        }
                    }
                    .frame(width: mirrorWidth, height: mirrorHeight)
                    .background(backgroundValue)
                    .padding(EdgeInsets(top: yLocation, leading: xLocation + 2, bottom: 0, trailing: 0))
                }
            }.background(Color(hex: "#333333"))
                .edgesIgnoringSafeArea([.top,.bottom])
                .onAppear{
                    // How to use
                    LocalNetworkPrivacy().checkAccessState { granted in
                        print(granted)
                    }
                    
                    UDPManager.broadCastUDP()
#if targetEnvironment(simulator)
                    SocketServerManager.shared.run()
#else
//                    SocketClientManager.shared.run(address: "172.20.10.4", port: 8000)
#endif
                }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .previewInterfaceOrientation(.landscapeRight)
        }
    }
}
