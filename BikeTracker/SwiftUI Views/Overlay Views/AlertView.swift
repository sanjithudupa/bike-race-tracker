//
//  AlertView.swift
//  BikeTracker
//
//  Created by Sanjith Udupa on 8/2/20.
//  Copyright © 2020 Sanjith Udupa. All rights reserved.
//

import Foundation
import SwiftUI

struct AlertView: View{
    @State var title = "Alert Title"
    @State var text = "Alert Body"
    var onOk: () -> Void = {}
    @Binding var trigger: Bool
    
    
    var body: some View{
        ZStack{
            Color.black
                .edgesIgnoringSafeArea(.all)
                .opacity(self.trigger ? 0.5 : 0)
            ZStack {
                Color.white
                VStack {
                    Text(self.title)
                    Spacer()
                    Text(self.text)
                        .multilineTextAlignment(.center)
                    Spacer()
                    Button(action: {
                        self.trigger = false
                        self.onOk()
                    }, label: {
                        Text("Okay")
                    })
                }.padding()
            }
            .frame(width: 300, height: 200)
            .cornerRadius(20).shadow(radius: 20)
            .shadow(radius: 3)
            .offset(y: self.trigger ? 0 : UIScreen.main.bounds.height)
            .animation(.spring())
        }
    }
}
