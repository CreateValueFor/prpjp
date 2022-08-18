//
//  Connected.swift
//  prpjp
//
//  Created by 이민기 on 2022/08/16.
//

import SwiftUI

struct Connected: View {
    
    let state : Bool
    let callback: (String)-> ()
    @State var port : String = "8000"
    
    init(
        state: Bool = false,
        callback: @escaping (String)->()
    ){
        self.state = state
        self.callback = callback
    }
    
    var body: some View {
        HStack(){
            Text("Client State :").foregroundColor(.white)
            Circle()
                .strokeBorder(Color.white,lineWidth: 1)
                .frame(width: 10, height: 10)
                .background(Circle().foregroundColor(state ? .green : Color.red))
                
            Spacer()
            Text("Port Number :").foregroundColor(.white)
            VStack(spacing: 1) {
                TextField("email", text: $port)
                    .padding(.trailing, 16)
                    
                    .foregroundColor(.white)
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.white)
//                    .padding(.leading, 16)
                    .padding(.trailing, 16)
            }
            Button(action: {
                self.callback(self.port)
            }){
                Text("RECONNECT")
                    .font(Font.system(size: 12))
            }
            .foregroundColor(.white)
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
            .background(.gray)
            .padding(.trailing, 16)
        }
        
    }
}

//struct Connected_Previews: PreviewProvider {
//    
//    @State var state : Bool = true
//    
//    static var previews: some View {
//        Connected(state: self.state) { aa in
//            print(aa)
//        }
//    }
//}
