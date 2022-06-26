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

struct data : Codable{
    var text : String
    var background : backgroundData
    var textColor: String
    var fontSize : String
    var fontStyle : String
    var displaySize : String
    var location : locationData
    var isReverse : Bool
}

struct backgroundData : Codable {
    var type: String
    var colorType : String
}
struct locationData  : Codable {
    var first : Int
    var second : Int
}

struct translateResposne : Decodable {
    var result : String
    var bytes : Int
    
}



struct ContentView: View {
    
    
    
    
    @State private var resolution : DISPLAY_RESOLUTION = DISPLAY_RESOLUTION.XS
    @State private var mirrorWidth : CGFloat =  DISPLAY_RESOLUTION.XS.width
    @State private var mirrorHeight : CGFloat =  DISPLAY_RESOLUTION.XS.height / 2
    
    
    @State private var speakLanguage : String = SPEAK_LANGUAGE.ENGLISH.id
    @State private var translationLanguage : String = TRANSLATION_LANGUAGE.ENGLISH.id
    @State private var speakLangCode : String = "en"
    @State private var translateLangCode : String = "en"
    @State private var background : String = PRP_COLOR.BLUE.rawValue
    @State private var backgroundValue : Color = PRP_COLOR.BLUE.color
    
    @State private var textColor : String = PRP_COLOR.WHITE.rawValue
    @State private var textColorValue : Color = PRP_COLOR.WHITE.color
    
    @State private var fontSize : String = FONT_SIZE.SMALL.rawValue
    @State private var fontSizeValue : CGFloat = FONT_SIZE.SMALL.size
    
    
    @State private var fontStyleBold : String = FONT_STYLE.BOLD.rawValue
    @State private var fontStyleBoldValue : Font.Weight = Font.Weight.bold
    
    @State private var fontStyleItalic : String = ""
    
    
    @State private var IP : String = ""
    
    @State private var finalText : String = "Placeholder"
    @State private var text : String = ""
    @State private var xLocation : CGFloat = 3
    @State private var yLocation : CGFloat = 0
    
    @State private var isSpeakBtnDisabled : Bool = false
    @State private var isDisplayBtnDisabled : Bool = false
    
    @State private var SpeakBtnPressed : Bool = false;
    @State private var DisplayBtnPressed : Bool = false;
    
    
    // safe area inset
    
    
    
    
    let resolutions: [DISPLAY_RESOLUTION] = DISPLAY_RESOLUTION.allCases.map{
        $0
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
    
    
    // 소켓 연결 로직
    
    
    private let defaultIP: String = "192.168.43.84"
    @State var connection: NWConnection?
    @State var udpListener : NWListener?
    @State  var udpConnection: NWConnection?
    var backgroundQueueUdpListener = DispatchQueue.main
    var mysock = SwiftSockMine.mInstance
    
    func portForEndpoint(_ endpoint: NWEndpoint) -> NWEndpoint.Host? {
        switch endpoint {
        case .hostPort(let host, let port):
            return host
        default:
            return nil
        }
    }

    func findUDP(){
        let params = NWParameters.udp
        udpListener = try? NWListener(using: params, on: 8200)
        udpListener?.service = NWListener.Service.init(type: "_appname._udp")
        self.udpListener?.stateUpdateHandler = { update in
              switch update {
              case .failed:
                print("failed")
              default:
                print("default update")
              }
            }
        
        self.udpListener?.newConnectionHandler = { connection in
            
            
            guard let hostEnum = portForEndpoint(connection.endpoint) else {return }
            let host = String(describing: hostEnum)
            print("extracted Host is \(host)")
            
            
            connection.receiveMessage { completeContent, contentContext, isComplete, error in
                guard let data = completeContent,
                      let data2 = contentContext
                
                    else {return}
                
                
                if let string = String(bytes: data, encoding: .utf8) {
                    print("sended UDP PACKET is \(string)" )
                    let text = string.components(separatedBy: ":")
                    if text[0] == "Hyuns"{
                        let port = Int32(text[1]) ?? 0
                        mysock.InitSocket(address: host, portNum: port)
                        
                    }
                } else {
                    print("not a valid UTF-8 sequence")
                }
                
                
            }
            
        
//            createConnection(connection: connection)
            self.udpConnection = connection
            self.udpConnection?.start(queue: .global())
            
          self.udpListener?.cancel()
        }
        udpListener?.start(queue: self.backgroundQueueUdpListener)
    }
    

    func send() {
        let backgroundData = backgroundData(type: "com.example.flexibledisplaypanel.socket.data.Background.Color", colorType: background)
        let locationData = locationData(first: 0, second: 0)
        
        let data = data(text: text, background: backgroundData, textColor: color, fontSize: fontSize, fontStyle: fontStyleBold, displaySize: resolution.text, location: locationData, isReverse: false)
        
        
        do {
            let jsonData = try JSONEncoder().encode(data)
            
//            let jsonString = String(data: jsonData, encoding: .utf8)!
            mysock.sendMessage(msg: "hello")
//            connection!.send(content: jsonData, completion: .contentProcessed({ sendError in
//                if let error = sendError {
//                    NSLog("Unable to process and send the data: \(error)")
//                } else {
//                    NSLog("Data has been sent")
//                    connection!.receiveMessage { (data, context, isComplete, error) in
//                        guard let myData = data else { return }
//                        NSLog("Received message: " + String(decoding: myData, as: UTF8.self))
//                    }
//                }
//            }))
        }catch{
            print(error)
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
            print(speechText)
        }
        utterance.voice = AVSpeechSynthesisVoice(language: speechText)
        
        utterance.rate = 0.4
        synthesizeer.speak(utterance)
        send()
    }
    
    // STT service logic
    @State private var speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en_US"))
    
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var audioEngine = AVAudioEngine()
    
    
    
    func startRecording() {
            print("음성 녹음 시작")
            if recognitionTask != nil {
                recognitionTask?.cancel()
                recognitionTask = nil
            }
            
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(AVAudioSession.Category.record)
                try audioSession.setMode(AVAudioSession.Mode.measurement)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            } catch {
                print("audioSession properties weren't set because of an error.")
            }
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            
            let inputNode = audioEngine.inputNode
            
            guard let recognitionRequest = recognitionRequest else {
                fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
            }
            
            recognitionRequest.shouldReportPartialResults = true
            
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
                var isFinal = false
                print(result?.bestTranscription.formattedString)
                
                if result != nil {
                    translate(text : (result?.bestTranscription.formattedString)!
                              as String
                    )
                    
                    isFinal = (result?.isFinal)!
                }
                
                if error != nil || isFinal {
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                }
            })
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
                self.recognitionRequest?.append(buffer)
            }
            
            audioEngine.prepare()
            
            do {
                try audioEngine.start()
            } catch {
                print("audioEngine couldn't start because of an error.")
            }
            
        print("Say something, I'm listening!")
            
            
        }
        
        
       
        func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
            if available {
                isSpeakBtnDisabled = false
                print("인식 가능")
                
            } else {
                isSpeakBtnDisabled = true
                print("인식 불가")
                
            }
        }
    
    // 번역 로직
    
    private let TRANSLATE_PATH : String = "http://ec2-3-133-11-183.us-east-2.compute.amazonaws.com:8080/translate"
    
    func translate (text : String) {
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
                self.text = trText
            }
    }
    
    
    
    var body: some View {
        GeometryReader{
            proxy in
            Color(hex: "#333333").overlay(
                ZStack(alignment: .topLeading) {
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
                                    .frame(minWidth: 200, idealWidth: .infinity, maxWidth: .infinity
                                    )
                                    .overlay(VStack{
                                        Divider().offset(x: 0, y: 12)
                                    })
                                RectangleButtonGroup(items: speakLanguages, title: "Speak language", selectedId: speakLanguage) { speakLanguage in
                                    switch speakLanguage {
                                    case "ENGLISH":
                                        speakLangCode = "en"
                                        speechRecognizer =
                                        SFSpeechRecognizer(locale: SPEAK_LANGUAGE.ENGLISH.lang)
                                    case "FRENCH":
                                        speakLangCode = "fr"
                                        SFSpeechRecognizer(locale: SPEAK_LANGUAGE.FRENCH.lang)
                                    case "SPANISH":
                                        speakLangCode = "es"
                                        SFSpeechRecognizer(locale: SPEAK_LANGUAGE.SPANISH.lang)
                                    case "日本語":
                                        speakLangCode = "ja"
                                        SFSpeechRecognizer(locale: SPEAK_LANGUAGE.日本語.lang)
                                    case "한국어":
                                        speakLangCode = "ko"
                                        SFSpeechRecognizer(locale: SPEAK_LANGUAGE.한국어.lang)
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
                                CircleButtonGroup(items: colors, title: "Background", selectedId: background) { color in
                                    backgroundValue = colorConverter(color: color)
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
                                    if audioEngine.isRunning{
                                        audioEngine.stop()
                                        recognitionRequest?.endAudio()
                                        isSpeakBtnDisabled = true
                                    }
                                    startRecording()
                                }else{
                                    if audioEngine.isRunning{
                                        audioEngine.stop()
                                        recognitionRequest?.endAudio()
                                        isSpeakBtnDisabled = true
                                    }
                                    print("말하지 마세요")
                                }
                                
                            }, isPressed: SpeakBtnPressed, disabled: isSpeakBtnDisabled)
                            PressButton("DISPLAY", callback: { isDisplay in
                                print(isDisplay)
                                finalText = text
                                translate(text: text)
                                if(isDisplay){
                                    startTTS()
                                    
                                }
                            }, isPressed: DisplayBtnPressed, disabled: isDisplayBtnDisabled)
                        }
                        
                    }
                        .padding(EdgeInsets(top: 80, leading: 30, bottom: 0, trailing: 60))
                    // ZStack 분기점
                    
                        VStack(alignment: .trailing){
                            ZStack(alignment: .topLeading){
                                if fontStyleItalic == "ITALIC" {
                                    Text(finalText)
                                        .foregroundColor(textColorValue)
                                        .font(.system(size: fontSizeValue,weight: fontStyleBoldValue) )
                                        .italic()
                                        
                                        
                                }else {
                                    Text(finalText)
                                        .foregroundColor(textColorValue)
                                        .font(.system(size: fontSizeValue,weight: fontStyleBoldValue) )
                                        
                                }
                                
                                    
                            }
    //                        .padding(EdgeInsets(top: 10, leading: proxy.safeAreaInsets.leading, bottom: 10, trailing: 0))
                        }
                        
                        
                            .frame(width: mirrorWidth, height: mirrorHeight)
                            .background(backgroundValue)
                            .padding(EdgeInsets(top: yLocation, leading: xLocation, bottom: 0, trailing: 0))
                            
                
                   
                        
                        
                        
                        
                }
                    
                
                
            )
            .edgesIgnoringSafeArea([.leading,.trailing,.top,.bottom])
            .padding(.leading, proxy.safeAreaInsets.leading / 2)
            .onAppear{
                print("Content loaded")
                // How to use

                LocalNetworkPrivacy().checkAccessState { granted in
                    print(granted)
                }

                findUDP()
                
                
                
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
