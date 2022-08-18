////
////  Location.swift
////  prpjp
////
////  Created by 이민기 on 2022/08/16.
////

import SwiftUI

struct Location: View {
    
    
    let xLocation : CGFloat
    let yLocation : CGFloat
    @State var tmpX : String = "0"
    @State var tmpY : String = "0"
    
    let setF : (String, String)-> ()
    
    init(xLocation: CGFloat,
         yLocation: CGFloat,
         setF: @escaping (String, String)->()
    ){
        self.xLocation = xLocation
        self.yLocation = yLocation
        self.setF = setF
        
        
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 10){
            Text("X location").foregroundColor(.white)
            VStack(spacing: 1) {
                TextField("xLocation", text: $tmpX)
                    .padding(.trailing, 16)
                    .foregroundColor(.white)
                    .keyboardType(.decimalPad)
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.white)
                    .padding(.trailing, 16)
            }.frame(width: 80)
            
            Text("Y location").foregroundColor(.white)
            VStack(spacing: 1) {
                TextField("yLocation", text: $tmpY)
                    .padding(.trailing, 16)
                    .foregroundColor(.white)
                    .keyboardType(.decimalPad)
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.white)
                    .padding(.trailing, 16)
            }.frame(width: 80)
            Button(action: {
                self.tmpX = Int(self.xLocation).description
                self.tmpY = Int(self.yLocation).description
            }){
                Text("GET")
                    .font(Font.system(size: 12))
            }
            .foregroundColor(.white)
            .padding(EdgeInsets(top: 8, leading: 15, bottom: 8, trailing: 15))
            .background(.gray)
            .padding(.trailing, 16)
            Button(action: {
                self.setF(self.tmpX, self.tmpY)
            }){
                Text("SET")
                    .font(Font.system(size: 12))
            }
            .foregroundColor(.white)
            .padding(EdgeInsets(top: 8, leading: 15, bottom: 8, trailing: 15))
            .background(.gray)
            .padding(.trailing, 16)
        }
        .padding(.top, 20)
    }
    
}


