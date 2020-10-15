//
//  RaceButton.swift
//  BikeTracker
//
//  Created by Sanjith Udupa on 10/1/20.
//  Copyright © 2020 Sanjith Udupa. All rights reserved.
//

import SwiftUI

struct RaceButton: View {
    @Binding var expanded : Bool
    @Binding var showing : CurrentView
    var buttonDown = UIScreen.main.bounds.height/4 + 25
    @Binding var raceIdString: String
    @State var progress = 0.4
    
    @State var joinRace: () -> Void
    
    @State var ready = false;
    
    var body: some View {
        ZStack{
            
            Rectangle()
                .opacity(0)
                .allowsHitTesting(expanded)
            
           
            Rectangle()
                .fill(expanded ? Color.green : Color.green)
                .cornerRadius(expanded ? 25 : 150)
                .frame(width: expanded ? 300 : 100, height: expanded ? 140 : 100)
                .offset(y:expanded ? 0 : self.buttonDown)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
                .animation(.spring(dampingFraction: 0.75))
                .onTapGesture{
                    self.expanded.toggle()
//                    RaceButtonHandler.expanded.toggle()
                }
            
            
            Text(expanded ? "Enter the Race Host's Join Code" : "Race!")
                .fontWeight(expanded ? .light : .bold)
                .offset(y:expanded ? -50 : self.buttonDown)
                .animation(.spring(dampingFraction: 0.75))
            
            CodeView(codeString: self.$raceIdString, ready: self.$ready, joinRace: $joinRace)
                .frame(width: expanded ? 230 : 0, height: expanded ? 245 : 0)
                .offset(y:expanded ? 0 : self.buttonDown)
                .opacity(expanded ? 1 : 0)
                .animation(.spring(dampingFraction: 0.75))
            
            Text(expanded ? "or\nCreate a New Race" : "").fontWeight(.bold).font(.system(size: 15)).multilineTextAlignment(.center) .offset(y:expanded ? 45 : self.buttonDown)
                .foregroundColor(Color.black)
                .animation(.spring(dampingFraction: 0.75))
                .onTapGesture{
                    SocketIOManager.getInstance.joinRandomRace()
                }
            
        }
        
    }
}
