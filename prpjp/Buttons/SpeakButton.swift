//
//  SpeakButton.swift
//  prpjp
//
//  Created by 이민기 on 2022/08/01.
//

import SwiftUI

struct SpeakButton : View {
    @State var isLongPressing : Bool = false
    let callback : (Bool) -> ()
    
    init (
        callback : @escaping (Bool)->()
    ){
        self.callback = callback
    }
    
    var body : some View {
        Button(action: {
            if(self.isLongPressing){
                //this tap was caused by the end of a longpress gesture, so stop our fastforwarding
                self.isLongPressing.toggle()
                self.callback(false)
            }
        }, label: {
            Image(systemName: self.isLongPressing ? "chevron.right.2": "chevron.right")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
            
        })
        .simultaneousGesture(LongPressGesture(minimumDuration: 0.2).onEnded { _ in
            
            self.isLongPressing = true
            self.callback(true)
        })
    }
}

struct SpeakButton_Previews: PreviewProvider {
    
    static var previews: some View {
        SpeakButton { start in
            print(start)
        }
    }
}
