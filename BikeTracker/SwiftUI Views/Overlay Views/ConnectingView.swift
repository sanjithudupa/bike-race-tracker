//
//  ConnectingView.swift
//  BikeTracker
//
//  Created by Sanjith Udupa on 7/31/20.
//  Copyright © 2020 Sanjith Udupa. All rights reserved.
//

import Foundation
import SwiftUI

struct ConnectingView: View{
    @Binding var status: String
    
    @State var changingIp = false
    @State var ip = "http:// .ngrok.io"
    var body: some View{
        VStack{
            Text(status)
                .onTapGesture {
                    self.changingIp = true
                }
            ZStack{
                Image(systemName: "checkmark")
                    .opacity($status.wrappedValue == "Trying to Connect" ? 1.0 : 0.0)
                ActivityIndicator(style: .medium)
                    .opacity($status.wrappedValue == "Trying to Connect" ? 0.0 : 1.0)
                
                if(self.changingIp){
                    HStack{
                        TextField("Enter ip", text: self.$ip, onCommit: self.ipSet)
                        Button(action: {
                            UserDefaults.standard.removeObject(forKey: "ip")
                            self.changingIp = false
                            exit(-1)
                        }) {
                            Text("Reset")
                        }
                    }
                }
            }
        }
    }
    
    func ipSet(){
        UserDefaults.standard.set(self.ip, forKey: "ip")
        
        self.changingIp = false
        
        exit(-1)
    }
    
    
}


struct ActivityIndicator : UIViewRepresentable {
  
    typealias UIViewType = UIActivityIndicatorView
    let style : UIActivityIndicatorView.Style
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> ActivityIndicator.UIViewType {
        return UIActivityIndicatorView(style: style)
    }
    
    func updateUIView(_ uiView: ActivityIndicator.UIViewType, context: UIViewRepresentableContext<ActivityIndicator>) {
        uiView.startAnimating()
    }
  
}
