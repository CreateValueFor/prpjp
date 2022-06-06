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

struct ContentView: View {
    
    
    @State private var resolution : String = DISPLAY_RESOLUTION.XS.text
    @State private var speakLanguage : String = SPEAK_LANGUAGE.ENGLISH.id
    @State private var translationLanguage : String = TRANSLATION_LANGUAGE.ENGLISH.id
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
    
    // STT 서비스 로직
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
