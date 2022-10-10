import SwiftUI

struct CustomProgressView: View {

var title: String
var total: Double = 100
@Binding var isShown: Bool
@Binding var value: Double

var body: some View {
    ZStack{
        Color(hex: "#black").ignoresSafeArea()
            .opacity(0.5)
            .isHidden(!isShown)
        VStack {
        
            ProgressView(value: value, total: total) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
            }
            .padding(EdgeInsets(top: 20, leading: 10, bottom: 0, trailing: 10))
            .background(RoundedRectangle(cornerRadius: 10.0)
                            .fill(Color(hex: "#333333"))
                            
            )
            .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#008577")))
            
            
        
        }
    //    .padding(.top)
        .isHidden(!isShown)
        
    }
    
}
}
