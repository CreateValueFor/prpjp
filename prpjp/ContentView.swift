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
import SwiftSpeech
import MarqueeText


struct translateResposne: Decodable {
    var result: String
    var bytes: Int
}

struct ContentView: View {
    
    @State private var userDefault = UserDefaults.standard.object(forKey: "transfer") as? Data
    
    @State private var resolution: DISPLAY_RESOLUTION = DISPLAY_RESOLUTION.XS
    @State private var mirrorWidth: CGFloat =  DISPLAY_RESOLUTION.XS.width
    @State private var mirrorHeight: CGFloat =  DISPLAY_RESOLUTION.XS.height / 2
    @State private var display: String = "D192X32"
    
    
    // button info
    @State private var isBrailMode: Bool = false
    @State private var isReverseMode: Bool = false
    @State private var isLock: Bool = false
    
    @State private var speakLanguage: String = SPEAK_LANGUAGE.ENGLISH.id
    @State private var translationLanguage: String = TRANSLATION_LANGUAGE.ENGLISH.id
    @State private var speakLangCode: String = "en"
    @State private var translateLangCode: String = "en"
    @State private var STTLocale : Locale = Locale(identifier: "en-US")
    
    
    @State private var background: PRP_COLOR = PRP_COLOR.BLACK
    
    @State private var textColor: PRP_COLOR = PRP_COLOR.WHITE
    
    
    @State private var fontSize: String = "SMALL"
    @State private var fontSizeValue: CGFloat = FONT_SIZE.SMALL.size
    
    
    @State private var fontStyleBold: String = "NONE"
    @State private var fontStyleItalic: String = ""
    @State private var fontStyleBoldValue: Font.Weight = Font.Weight.bold
    @State private var fontStyle: String = "NONE"
    
    // server state
    @State private var IP: String = ""
    @State private var connected : Bool = false
    
    @State private var finalText: String = ""
    @StateObject var speechRecognizer = SpeechRecognizer(locale: "en_US");
    @State private var text: String = ""
    @State private var xLocation: CGFloat = DISPLAY_RESOLUTION.XS.xLocation
    @State private var tmpX: CGFloat = DISPLAY_RESOLUTION.XS.xLocation
    @State private var yLocation: CGFloat = DISPLAY_RESOLUTION.XS.yLocation
    @State private var tmpY: CGFloat = DISPLAY_RESOLUTION.XS.yLocation
    
    
    @State private var isSpeakBtnDisabled: Bool = false
    @State private var isDisplayBtnDisabled: Bool = false
    
    @State private var SpeakBtnPressed: Bool = false;
    @State private var DisplayBtnPressed: Bool = false;
    
    @State var scrollText = false
    
    
    //image
    @State var isShowPicker: Bool = false
    @State var image: Image? = nil
    @State var imageUrl : String? = ""
    @State var uiImageVal : UIImage? = UIImage()
    
    // video
    @State var playerLooper: AVPlayerLooper! // should be defined in class
    @State var queuePlayer: AVQueuePlayer!
    @State var playerItem : AVPlayerItem?
    @State var videoURL: URL?
    @State var showVideoPicker: Bool = false
    @State var player: AVPlayer?
    
    // translate
    @StateObject var translate = Translate()
    
    let tcpDidChangeConnectedPublisher = NotificationCenter.default.publisher(for: .tcpDidChangeConnectedState)
    
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
        
    }
    
    
    var body: some View {
        
        
        GeometryReader{
            proxy in
            
            ZStack(alignment: .topTrailing){
                
                // toggle buttons
                HStack(alignment: .top, spacing: 10){
                    
                    Toggle(isOn: $isBrailMode, label: {
                        Text("Braile Mode")
                            .font(Font.system(size: 12))
                            .foregroundColor(.white)
                    })
                    .toggleStyle(SwitchToggleStyle(tint: Color(hex:"#008577")))
                    .disabled(isLock)
                    
                    Toggle(isOn: $isReverseMode, label: {
                        Text("Reverse Mode")
                            .font(Font.system(size: 12))
                            .foregroundColor(.white)
                    })
                    .toggleStyle(SwitchToggleStyle(tint: Color(hex:"#008577")))
                    .disabled(isLock)
                    
                    
                    Toggle(isOn: $isLock, label: {
                        Text("Lock")
                            .font(Font.system(size: 12))
                            .foregroundColor(.white)
                    })
                    .toggleStyle(SwitchToggleStyle(tint: Color(hex:"#008577")))
                    
                }
                .frame(width: 450)
                .padding(10)
                .zIndex(1)
                
                ZStack(alignment: .topLeading){
                    // mirror state
                    
                    VStack(alignment: .trailing){
                        ZStack(alignment: .leading){
                            image?
                                .resizable()
                                .frame(width: mirrorWidth/2, height: mirrorHeight)
                            
                            if let videoURL = self.videoURL {
                                VideoView(url: videoURL)
                            }
                            if fontStyleItalic == "ITALIC" {
                                if fontStyleBoldValue == .bold {
                                    MarqueeText(
                                         text: finalText,
                                         font: UIFont.italicSystemFont(ofSize: fontSizeValue).boldItlc,
                                         leftFade: 16,
                                         rightFade: 16,
                                         startDelay: 0,
                                         alignment: .leading
                                         )
                                    
                                    .foregroundColor(textColor.color)
                                }else {
                                    MarqueeText(
                                         text: finalText,
                                         font: UIFont.italicSystemFont(ofSize: fontSizeValue),
                                         leftFade: 16,
                                         rightFade: 16,
                                         startDelay: 0,
                                         alignment: .leading
                                         )
                                    
                                    .foregroundColor(textColor.color)
                                }
                            }else {
                                if fontStyleBoldValue == .bold{
                                    MarqueeText(
                                         text: finalText,
                                         font: UIFont.systemFont(ofSize: fontSizeValue).bold,
                                         leftFade: 16,
                                         rightFade: 16,
                                         startDelay: 0,
                                         alignment: .leading
                                         )
                                    .foregroundColor(textColor.color)
                                }else {
                                    MarqueeText(
                                         text: finalText,
                                         font: UIFont.systemFont(ofSize: fontSizeValue),
                                         leftFade: 16,
                                         rightFade: 16,
                                         startDelay: 0,
                                         alignment: .leading
                                         )
                                    .foregroundColor(textColor.color)
                                }
                                    
                            }
                            
                        }
                    }
                    .frame(width: mirrorWidth / 2, height: mirrorHeight )
                    .rotationEffect(.degrees(isReverseMode ? 180 : 0))
                    .background(background.color)
                    .padding(EdgeInsets(top: yLocation / 4, leading: xLocation + 2, bottom: 0, trailing: 0))
                    
                    
                    
                    // contents
                    HStack (alignment: .top){
                        ScrollView(.vertical){
                            VStack(alignment: .leading) {
                                Connected(state: connected) { port in
                                    let portNum = Int(port) ?? 8000
                                    UDPManager.broadCastUDP(port:portNum)
                                    SocketServerManager.shared.rerun(portNum)
                                }
                                .onReceive(tcpDidChangeConnectedPublisher, perform: { notification in
                                    guard let userInfo = notification.userInfo,
                                          let isEmpty = userInfo["isEmpty"] as? Bool else { return }
                                    self.connected = !isEmpty
                                })
                                .disabled(isLock)
                                RadioButtonGroup(items: resolutions, selectedId: resolution) { resol in
                                    
                                    mirrorHeight = resol.height / 2
                                    mirrorWidth = resol.width
                                    xLocation = resol.xLocation
                                    yLocation = resol.yLocation
                                    display = resol.text
                                    
                                }
                                .disabled(isLock)
                                Location(xLocation: xLocation, yLocation : yLocation,
                                         setF: { x, y in
                                    xLocation = CGFloat(Int(x) ?? 0)
                                    yLocation = CGFloat(Int(y) ?? 0)
                                })
                                .disabled(isLock)
                                VStack(spacing: 1){
                                    TextField("", text: $text)
                                    
                                        .foregroundColor(.white)
                                        .frame(minWidth: 200, idealWidth: .infinity, maxWidth: .infinity
                                        )
                                        .padding(.trailing, 10)
                                    
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundColor(.white)
                                        .padding(.trailing, 10)
                                }.disabled(isLock)
                                
                                RectangleButtonGroup(items: speakLanguages, title: "Speak language", selectedId: speakLanguage) { speakLanguage in
                                    switch speakLanguage {
                                    case "ENGLISH":
                                        speakLangCode = "en"
                                        STTLocale = SPEAK_LANGUAGE.ENGLISH.lang
                                    case "FRENCH":
                                        speakLangCode = "fr"
                                        STTLocale = SPEAK_LANGUAGE.FRENCH.lang
                                        
                                    case "SPANISH":
                                        speakLangCode = "es"
                                        STTLocale = SPEAK_LANGUAGE.FRENCH.lang
                                    case "日本語":
                                        speakLangCode = "ja"
                                        STTLocale = SPEAK_LANGUAGE.日本語.lang
                                    case "한국어":
                                        speakLangCode = "ko"
                                        STTLocale = SPEAK_LANGUAGE.한국어.lang
                                    default:
                                        print(speakLanguage)
                                    }
                                }
                                .disabled(isLock)
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
                                .disabled(isLock)
                                HStack(alignment: .bottom, spacing: 20){
                                    CircleButtonGroup(items: colors, title: "Background", selectedId: background) { color in
                                        //                                        image = Image("placeholder")
                                        image = nil
                                        background = color
                                        
                                        
                                    }
                                    .disabled(isLock)
                                    ZStack {
                                        
                                        VStack {
                                            
                                            Button(action: {
                                                videoURL = nil
                                                withAnimation {
                                                    self.isShowPicker.toggle()
                                                }
                                            }) {
                                                
                                                Text("IMAGE").font(Font.system(size: 12))
                                                    .foregroundColor(.white)
                                            }.foregroundColor(.white)
                                                .frame(width: 60, height: 30)
                                                .background(.gray)
                                                .disabled(isLock)
                                        }
                                    }
                                    .sheet(isPresented: $isShowPicker) {
                                        ImagePicker(image: self.$image, imageUrl: self.$imageUrl, uiImageVal: self.$uiImageVal)
                                    }
                                    ZStack {
                                        
                                        VStack {
                                            
                                            Button(action: {
                                                image = nil
                                                videoURL = nil
                                                
                                                withAnimation {
                                                    
                                                    self.showVideoPicker.toggle()
                                                }
                                            }) {
                                                
                                                Text("Video").font(Font.system(size: 12))
                                                    .foregroundColor(.white)
                                            }.foregroundColor(.white)
                                                .frame(width: 60, height: 30)
                                                .background(.gray)
                                                .disabled(isLock)
                                        }
                                    }
                                    .sheet(isPresented: $showVideoPicker) {
                                        
                                        PHPVideoPicker(isShown: $showVideoPicker, videoURL: $videoURL, playerItem: $playerItem)
                                    }
                                }
                                
                                
                                CircleButtonGroup(items: colors, title: "Text color", selectedId: textColor) { color in
                                    textColor = color
                                    
                                    
                                }.disabled(isLock)
                                
                                
                                RectangleButtonGroup(items: fontSizes, title: "Font size", selectedId: fontSize) { fontSize in
                                    switch fontSize {
                                    case "LARGE":
                                        self.fontSize = "LARGE"
                                        fontSizeValue = 16
                                    case "MEDIUM":
                                        self.fontSize = "MEDIUM"
                                        fontSizeValue = 12
                                    case "SMALL":
                                        self.fontSize = "SMALL"
                                        fontSizeValue = 8
                                    default :
                                        fontSizeValue = 8
                                    }
                                }.disabled(isLock)
                                
                                FontStyleGroup(title: "Font style", isBold: fontStyleBold, isItalic: fontStyleItalic) { id, isSelected in
                                    
                                    if(isSelected){
                                        switch id {
                                        case "ITALIC":
                                            if fontStyleBold == "BOLD"{
                                                fontStyle = "BOTH"
                                            }else {
                                                fontStyle = "ITALIC"
                                            }
                                            fontStyleItalic = "ITALIC"
                                            
                                        case "BOLD":
                                            if fontStyleItalic == "ITALIC"{
                                                fontStyle = "BOTH"
                                            }else {
                                                fontStyle = "BOLD"
                                            }
                                            
                                            fontStyleBold = "BOLD"
                                            fontStyleBoldValue = Font.Weight.bold
                                        default:
                                            print("Something Wrong")
                                        }
                                        
                                    }else {
                                        switch id {
                                        case "ITALIC":
                                            if fontStyleBold == "BOLD"{
                                                fontStyle = "BOLD"
                                            }else {
                                                fontStyle = "NONE"
                                            }
                                            
                                            fontStyleItalic = ""
                                        case "BOLD":
                                            if fontStyleItalic == "ITALIC"{
                                                fontStyle = "ITALIC"
                                            }else {
                                                fontStyle = "NONE"
                                            }
                                            
                                            fontStyleBold = ""
                                            fontStyleBoldValue = Font.Weight.medium
                                        default:
                                            print("Something Wrong")
                                        }
                                    }
                                }.disabled(isLock)
                                
                                
                            }
                        }
                        VStack(alignment: .trailing){
                            
                            SwiftSpeech.RecordButton()
                                .swiftSpeechRecordOnHold(locale: STTLocale)
                                .onRecognizeLatest { result in
                                    if(result.isFinal){
                                        print(result.bestTranscription.formattedString)
                                        
                                        translate.translate(speakLangCode: speakLangCode, translateLangCode: translateLangCode, text: result.bestTranscription.formattedString)
                                        
                                        
                                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                                            
                                            self.text = translate.trText.replacingOccurrences(of: "&#39;", with: "'")
                                        }
                                        //
                                    }
                                    
                                } handleError: { error in
                                    print(error.localizedDescription)
                                }
                                .disabled(isLock)
                            
                            
                            PressButton("DISPLAY", callback: { isDisplay in
                                finalText = text
                                startTTS()
                                if(image != nil){
                                    SocketServerManager.shared.send(text: self.text, background: uiImageVal!, backgroundPath: imageUrl!, color: textColor.rawValue, fontSize: fontSize, fontStyleBold: fontStyle, resolution: display)
                                }else{
                                    SocketServerManager.shared.send(text: self.text, background: background.rawValue, color: textColor.rawValue, fontSize: fontSize, fontStyleBold: fontStyle, resolution: display)
                                }
                                
                            }, isPressed: DisplayBtnPressed, disabled: isDisplayBtnDisabled)
                        }
                        
                    }
                    .padding(EdgeInsets(top: 80, leading: 00, bottom: 0, trailing: 5))
                    .disabled(isLock)
                    
                    
                    
                    
                }
            }.background(Color(hex: "#333333"))
                .edgesIgnoringSafeArea([.top,.bottom])
                .onAppear{
                    // Get UserDefault Data
                    if userDefault != nil {
                        let decoder = JSONDecoder()
                        if let loadedData = try? decoder.decode(TransferData.self, from: userDefault!) {
                            self.text = loadedData.text
                            self.finalText = loadedData.text
                            switch loadedData.fontSize {
                            case "SMALL":
                                self.fontSize = "SMALL"
                                self.fontSizeValue = FONT_SIZE.SMALL.size
                                
                            case "MEDIUM":
                                self.fontSize = "MEDIUM"
                                self.fontSizeValue = FONT_SIZE.MEDIUM.size
                                
                            case "LARGE":
                                self.fontSize = "LARGE"
                                self.fontSizeValue = FONT_SIZE.LARGE.size
                            default :
                                fontSizeValue = FONT_SIZE.SMALL.size
                            }
                            
                            switch loadedData.fontStyle {
                            case "NONE":
                                break
                            case "BOLD":
                                self.fontStyleBold = "BOLD"
                                self.fontStyleBoldValue = Font.Weight.bold
                            case "ITALIC":
                                self.fontStyleItalic = "ITALIC"
                            case "BOTH":
                                self.fontStyleBoldValue = Font.Weight.bold
                                self.fontStyleBold = "BOLD"
                                self.fontStyleItalic = "ITALIC"
                            default:
                                break;
                            }
                            switch loadedData.background.colorType {
                            case "BLACK":
                                background = .BLACK
                            case "WHITE":
                                background = .WHITE
                            case "RED":
                                background = .RED
                            case "BLUE":
                                background = .BLUE
                            case "GREEN":
                                background = .GREEN
                            case "YELLOW":
                                background = .YELLOW
                            default :
                                break;
                                
                            }
                            
                            switch loadedData.textColor {
                            case "BLACK":
                                
                                textColor = .BLACK
                            case "WHITE":
                                textColor = .WHITE
                            case "RED":
                                textColor = .RED
                            case "BLUE":
                                textColor = .BLUE
                            case "GREEN":
                                textColor = .GREEN
                            case "YELLOW":
                                textColor = .YELLOW
                            default :
                                break;
                            }
                        }
                    }
                    
                    // How to use
                    LocalNetworkPrivacy().checkAccessState { granted in
                        print(granted)
                    }
                    SwiftSpeech.requestSpeechRecognitionAuthorization()
                    
                    UDPManager.broadCastUDP(port: 8000)
                    
                    SocketServerManager.shared.run()
                }
                .zIndex(0)
            
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
