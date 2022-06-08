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

struct ContentView: View {
    
    @State private var resolution : String = DISPLAY_RESOLUTION.XS.text
    @State private var speakLanguage : String = SPEAK_LANGUAGE.ENGLISH.id
    @State private var translationLanguage : String = TRANSLATION_LANGUAGE.ENGLISH.id
    @State private var speakLangCode : String = "en"
    @State private var translateLangCode : String = "en"
    @State private var background : String = PRP_COLOR.BLACK.rawValue
    @State private var textColor : String = PRP_COLOR.BLACK.rawValue
    @State private var fontSize : String = FONT_SIZE.SMALL.rawValue
    @State private var fontStyle : String = FONT_STYLE.BOLD.rawValue
    @State private var IP : String = ""
    @State private var text : String = ""
    @State private var isSpeakBtnDisabled : Bool = false
    @State private var isDisplayBtnDisabled : Bool = false
    
    @State private var SpeakBtnPressed : Bool = false;
    @State private var DisplayBtnPressed : Bool = false;
    
    
    
    
    
    
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
    
    
    // 소켓 연결 로직
    private let defaultIP: String = "192.168.43.84"
    @State var connection: NWConnection?

    func someFunc() {

        self.connection = NWConnection(host: "255.255.255.255", port: 6000, using: .udp)

        self.connection?.stateUpdateHandler = { (newState) in
            switch (newState) {
            case .ready:
                print("ready")
                self.send()
                self.receive()
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
        self.connection?.start(queue: .global())

    }

    func send() {
        self.connection?.send(content: "Test message".data(using: String.Encoding.utf8), completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
            print(NWError)
        })))
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
        
        let parameters: [String: Any] = [
            "msg": text,
            "inputLang" : speakLangCode,
            "outputLang" : translateLangCode
            
        ]
        
        AF.request(TRANSLATE_PATH, method: .post, parameters: parameters,encoding: URLEncoding.httpBody).responseJSON { response in
            switch response.result {
              case .success:
                if let data = try! response.result.get() as? [String: Any] {
                  print(data)
                }
              case .failure(let error):
                print("Error: \(error)")
                return
              }
        }
    }
    
    
    
    var body: some View {
        Color(hex: "#333333").overlay(
            HStack (alignment: .top){
                ScrollView(.vertical){
                    VStack{
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
                        translate(text: text)
                        if(isDisplay){
                            let synthesizeer = AVSpeechSynthesizer()
                            let utterance = AVSpeechUtterance(string: text)
                            utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
                            utterance.rate = 0.4
                            synthesizeer.speak(utterance)
                            
                        }
                    }, isPressed: DisplayBtnPressed, disabled: isDisplayBtnDisabled)
                }
                
            }
                .padding()
            
            
        )
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .previewInterfaceOrientation(.landscapeRight)
            ContentView()
        }
    }
}
