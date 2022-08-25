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


struct translateResposne: Decodable {
    var result: String
    var bytes: Int
}

struct ContentView: View {
    
    @State private var userDefault = UserDefaults.standard.object(forKey: "transfer") as? Data
    
    @State private var displayDefault = UserDefaults.standard.object(forKey: "displayPosition") as? Data
    @State private var imageDefault = UserDefaults.standard.data(forKey: "image")
    @State private var videoDefault = UserDefaults.standard.string(forKey: "video")
    
    
    @State private var displayPosition : DisplayPosition  = INIT_DISPLAY_POSITION
     
    @State private var resolution: DISPLAY_RESOLUTION = DISPLAY_RESOLUTION.XS
    @State private var mirrorWidth: CGFloat =  DISPLAY_RESOLUTION.XS.width
    @State private var mirrorHeight: CGFloat =  DISPLAY_RESOLUTION.XS.height / 2
    @State private var display: String = "D192X32"
    @State private var isMultiLine : Bool = false
    
    
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
    @State var showVideo : Bool = false
    
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
        print(translateLangCode)
        switch translateLangCode {
        case "en":
            speechText = "en_US"
        case "fr":
            speechText = "fr_FR"
        case "es":
            speechText = "es"
        case "ja":
            speechText = "ja_JP"
        case "ko":
            speechText = "ko_KR"
        default:
            print(speechText ?? "")
        }
        print( "speech Text is \(speechText)")
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
                                VideoView(url: videoURL,show: showVideo)
                            }
                            if isMultiLine {
                                Text(finalText)
                                    .lineLimit(2)
                                    .font(Font(uiFont: UIFont.systemFont(ofSize: fontSizeValue).styleType(font: fontStyle)))
                                    .foregroundColor(textColor.color)
                                    
                            }else {
                                MarqueeText(
                                    text: finalText,
                                    font: UIFont.systemFont(ofSize: fontSizeValue).styleType(font: fontStyle),
                                    leftFade: 0,
                                    rightFade: 16,
                                    startDelay: 0,
                                    alignment: .leading
                                )
                                .foregroundColor(textColor.color)
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
                                    
                                    
                                    display = resol.text
                                    isMultiLine = resol.isMultiLine
                                    
                                    print(resol.text)
                                    
                                    switch resol.text {
                                    case "D192X32":
                                        xLocation =  CGFloat(displayPosition.XS.first)
                                        yLocation =  CGFloat(displayPosition.XS.second)
                                    case "D192X64":
                                        xLocation =  CGFloat(displayPosition.SM.first)
                                        yLocation =  CGFloat(displayPosition.SM.second)
                                    case "D192X128":
                                        xLocation =  CGFloat(displayPosition.MD.first)
                                        yLocation =  CGFloat(displayPosition.MD.second)
                                    case "D384X64":
                                        xLocation =  CGFloat(displayPosition.LG.first)
                                        yLocation =  CGFloat(displayPosition.LG.second)
                                    case "D384X128":
                                        xLocation =  CGFloat(displayPosition.XL.first)
                                        yLocation =  CGFloat(displayPosition.XL.second)
                                    case "D360X28":
                                        xLocation =  CGFloat(displayPosition.SXL.first)
                                        yLocation =  CGFloat(displayPosition.SXL.second)
                                    default :
                                        xLocation =  CGFloat(displayPosition.XS.first)
                                        yLocation =  CGFloat(displayPosition.XS.second)
                                    }
                                    
                                    
                                }
                                .disabled(isLock)
                                Location(xLocation: xLocation, yLocation : yLocation,
                                         setF: { x, y in
                                    var tmpLocation : LocationData = LocationData(first: Int(x) ?? 0, second: Int(y) ?? 0)
                                    switch display {
                                    case "D192X32":
                                        displayPosition.XS = tmpLocation
                                    case "D192X64":
                                        displayPosition.SM = tmpLocation
                                    case "D192X128":
                                        displayPosition.MD = tmpLocation
                                    case "D384X64":
                                        displayPosition.LG = tmpLocation
                                    case "D384X128":
                                        displayPosition.XL = tmpLocation
                                    case "D360X28":
                                        displayPosition.SXL = tmpLocation
                                    default :
                                        print("error occured on location setting")
                                    }
                                    do {
                                        let jsonData = try  JSONEncoder().encode(displayPosition)
                                        UserDefaults.standard.set(jsonData, forKey: "displayPosition")
                                    }catch{
                                        print(error)
                                    }
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
                                        videoURL = nil
                                        image = nil
                                        self.showVideo = false
                                        background = color
                                        
                                        
                                    }
                                    .disabled(isLock)
                                    ZStack {
                                        
                                        VStack {
                                            
                                            Button(action: {
                                                videoURL = nil
                                                self.showVideo = false
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
                                                self.showVideo = true
                                                
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
                                    print("send image started")
                                    SocketServerManager.shared.send(text: self.text, background: uiImageVal!, backgroundPath: imageUrl!, color: textColor.rawValue, fontSize: fontSize, fontStyleBold: fontStyle, resolution: display, location:  LocationData(first: Int(xLocation), second: Int(yLocation)))
                                }else if (videoURL != nil){
                                    SocketServerManager.shared.send(text: self.text, video: videoURL!, color: textColor.rawValue, fontSize: fontSize, fontStyleBold: fontStyle, resolution: display, location:  LocationData(first: Int(xLocation), second: Int(yLocation)))
                                }else{
                                    SocketServerManager.shared.send(text: self.text, background: background.rawValue, color: textColor.rawValue, fontSize: fontSize, fontStyleBold: fontStyle, resolution: display, location: LocationData(first: Int(xLocation), second: Int(yLocation)))
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
                    
                    if imageDefault != nil {
                        
                        
                        guard let data =  imageDefault else {return}
                        let image = UIImage(data: data)
                        
                        
                        
                        self.image = Image(uiImage: image!)
                        
                    }
                    
                    if videoDefault != nil {
                        print(videoDefault)
                        guard let url = videoDefault else {return}
                        self.videoURL = URL(string: url)
                    }
                    
                    // Get UserDefault Data
                    if displayDefault != nil {
                        let decoder = JSONDecoder()
                        if let loadedPosition = try? decoder.decode(DisplayPosition.self, from: displayDefault!){
                            self.displayPosition = loadedPosition
                            print(loadedPosition)
                        }
                        
                    }
                    
                    if userDefault != nil {
                        let decoder = JSONDecoder()
                        if let loadedData = try? decoder.decode(TransferData.self, from: userDefault!) {
                            self.text = loadedData.text
                            self.finalText = loadedData.text
                            
                            self.xLocation = CGFloat(loadedData.location.first)
                            self.yLocation = CGFloat(loadedData.location.second)
                            
                            switch loadedData.displaySize {
                                
                                case "D192X32":
                                resolution = DISPLAY_RESOLUTION.XS
                                mirrorWidth =  DISPLAY_RESOLUTION.XS.width
                                    mirrorHeight =  DISPLAY_RESOLUTION.XS.height
                                case "D192X64":
                                resolution = DISPLAY_RESOLUTION.SM
                                mirrorWidth =  DISPLAY_RESOLUTION.SM.width
                                mirrorHeight =  DISPLAY_RESOLUTION.SM.height
                                case "D192X128":
                                resolution = DISPLAY_RESOLUTION.MD
                                mirrorWidth =  DISPLAY_RESOLUTION.MD.width
                                mirrorHeight =  DISPLAY_RESOLUTION.MD.height
                                case "D384X64":
                                resolution = DISPLAY_RESOLUTION.LG
                                mirrorWidth =  DISPLAY_RESOLUTION.LG.width
                                mirrorHeight =  DISPLAY_RESOLUTION.LG.height
                                case "D384X128":
                                resolution = DISPLAY_RESOLUTION.XL
                                mirrorWidth =  DISPLAY_RESOLUTION.XL.width
                                mirrorHeight =  DISPLAY_RESOLUTION.XL.height
                                case "D360X28":
                                resolution = DISPLAY_RESOLUTION.SXL
                                mirrorWidth =  DISPLAY_RESOLUTION.SXL.width
                                mirrorHeight =  DISPLAY_RESOLUTION.SXL.height
                                default :
                                resolution = DISPLAY_RESOLUTION.XS
                                mirrorWidth =  CGFloat(displayPosition.XS.first)
                                mirrorHeight =  CGFloat(displayPosition.XS.second)
                                
                            }
                            
                            
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
