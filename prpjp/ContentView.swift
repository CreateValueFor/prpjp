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

struct ContentView: View {
    
    
    
    
    @State private var resolution : String = DISPLAY_RESOLUTION.XS.text
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
    @State private var isSpeakBtnDisabled : Bool = false
    @State private var isDisplayBtnDisabled : Bool = false
    
    @State private var SpeakBtnPressed : Bool = false;
    @State private var DisplayBtnPressed : Bool = false;
    
    
    // safe area inset
    
    
    
    
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

    func findUDP(){
        let params = NWParameters.udp
        udpListener = try? NWListener(using: params, on: 8200)
        print(udpListener)
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
          print("connection")
            print(connection.endpoint)
            connection.receiveMessage { completeContent, contentContext, isComplete, error in
                guard let data = completeContent,
                      let data2 = contentContext
                
                    else {return}
                
                
                if let string = String(bytes: data, encoding: .utf8) {
                    print(string)
                    let text = string.components(separatedBy: ":")
                    if text[0] == "Hyuns"{
                        let port = Int32(text[1]) ?? 0
                        mysock.InitSocket(address: "172.20.10.4", portNum: port)
                        mysock.sendMessage(msg: "hello")
                    }
                } else {
                    print("not a valid UTF-8 sequence")
                }
                
                
            }
            
        
            createConnection(connection: connection)
            
          self.udpListener?.cancel()
        }
        udpListener?.start(queue: self.backgroundQueueUdpListener)
    }
    
    func createConnection(connection: NWConnection) {
       self.udpConnection = connection
         self.udpConnection?.stateUpdateHandler = { (newState) in
           switch (newState) {
           case .ready:
             print("ready")
//             self.send()
//             self.receive()
           case .setup:
             print("setup")
           case .cancelled:
             print("cancelled")
           case .preparing:
             print("Preparing")
           default:
             print("waiting or failed")
           }
         }
         self.udpConnection?.start(queue: .global())
    }

    func send() {
        let backgroundData = backgroundData(type: "com.example.flexibledisplaypanel.socket.data.Background.Color", colorType: background)
        let locationData = locationData(first: 0, second: 0)
        
        let data = data(text: text, background: backgroundData, textColor: color, fontSize: fontSize, fontStyle: fontStyleBold, displaySize: resolution, location: locationData, isReverse: false)
        
        
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

    func receive() {
        self.connection?.receiveMessage { (data, context, isComplete, error) in
            print("Got it")
            print(data)
        }
    }
    
    
    
    
    // STT service logic
    @State private var speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ko-KR"))
    
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var audioEngine = AVAudioEngine()
    
    
    
    func startRecording() {
            
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
                
                if result != nil {
                    
                    
                    
                    print(result?.bestTranscription.formattedString)
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
        
        AF.request(TRANSLATE_PATH, method: .post, parameters: parameters,encoding: URLEncoding.httpBody).responseJSON { response in
            switch response.result {
              case .success:
                print("번역 성공")
                if let data = try! response.result.get() as? [String : String] {
                  
                    guard let translatedText = data["result"] else {return}
                    self.text = translatedText
                    
                }
              case .failure(let error):
                print("Error: \(error)")
                return
              }
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
                                RadioButtonGroup(items: resolutions, selectedId: resolution) { text in
                                    print(text)
                                }
                                TextField("", text: $text)
                                    .padding()
                                    .frame(minWidth: 200, idealWidth: .infinity, maxWidth: .infinity
                                    )
                                    .overlay(VStack{
                                        Divider().offset(x: 0, y: 12)
                                    })
                                
                                RectangleButtonGroup(items: speakLanguages, title: "Speak language", selectedId: speakLanguage) { speakLanguage in
                                    print(speakLanguage)
                                    switch speakLanguage {
                                    case "ENGLISH":
                                        speakLangCode = "en"
                                    case "FRENCH":
                                        speakLangCode = "fr"
                                    case "SPANISH":
                                        speakLangCode = "es"
                                    case "日本語":
                                        speakLangCode = "ja"
                                    case "한국어":
                                        speakLangCode = "ko"
                                    default:
                                        print(speakLanguage)
                                    }
                                }
                                RectangleButtonGroup(items: translationLanguages, title: "Translation language", selectedId: translationLanguage) { translation in
                                    
                                    print(translation)
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
                                    print(color)
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
                                    print(fontSize)
                                }
//                                RectangleButtonGroup(items: fontStyles, title: "Font style", selectedId: fontStyle) { fontStyle in
//                                    print(fontStyle)
//                                }
                                FontStyleGroup(title: "Font style", isBold: fontStyleBold, isItalic: fontStyleItalic) { id, isSelected in
                                    print(id, isSelected)
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
                                if(isSpeak){
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
                                    let synthesizeer = AVSpeechSynthesizer()
                                    let utterance = AVSpeechUtterance(string: text)
                                    utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
                                    utterance.rate = 0.4
                                    synthesizeer.speak(utterance)
                                    send()
                                    
                                }
                            }, isPressed: DisplayBtnPressed, disabled: isDisplayBtnDisabled)
                        }
                        
                    }
                        .padding(EdgeInsets(top: 80, leading: 30, bottom: 0, trailing: 30))
                    // ZStack 분기점
                    VStack(alignment: .trailing){
                        ZStack{
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
                    
                        .frame(width: 100, height: 40)
                        .background(backgroundValue)
                        .position(x: proxy.safeAreaInsets.leading + 5, y: proxy.safeAreaInsets.top + 20)
                        
                        
                }
                    
                
                
            )
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
