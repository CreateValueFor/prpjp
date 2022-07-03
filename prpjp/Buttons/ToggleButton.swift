//
//  ToggleButton.swift
//  prpjp
//
//  Created by 이민기 on 2022/07/01.
//

import SwiftUI

struct ToggleButton: View {
    @State var toggleIsOn: Bool = false
    var body: some View {
        VStack {
            Toggle(isOn: $toggleIsOn, label: {
                Text("로그인")
            })
                .toggleStyle(SwitchToggleStyle(tint: Color(hex:"0xff8882")))
            .padding(.horizontal, 100)
             Spacer()
        }
    }
}

struct ToggleButton_Previews: PreviewProvider {
    static var previews: some View {
        ToggleButton()
    }
}
