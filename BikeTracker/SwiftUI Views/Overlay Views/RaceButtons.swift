//
//  RaceButtons.swift
//  BikeTracker
//
//  Created by Sanjith Udupa on 8/17/20.
//  Copyright © 2020 Sanjith Udupa. All rights reserved.
//

import Foundation
import SwiftUI

struct RaceStatsButton: View{
    @Binding var raceStatsShown: Bool;
    var body: some View{
        GeometryReader{ geometry in
            ZStack{
                Color.green
                   .clipShape(Circle())
                   .shadow(radius: 10)
                
                Button(action: {
                    withAnimation{
                        self.raceStatsShown.toggle()
                    }
                }){
                    Image(systemName: "arrowtriangle.up.circle")
                        .resizable()
                        .foregroundColor(Color.white)
                        .frame(width: geometry.size.width * 0.75, height: geometry.size.width * 0.75)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                        .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
                    
                }

            }
        }
    }
}

struct RepositionButton: View{
    var body: some View{
        GeometryReader{ geometry in
            ZStack{
                Color.green
                   .clipShape(Circle())
                   .shadow(radius: 10)
                
                Button(action: {

                }){
                    Image(systemName: "location.circle")
                        .resizable()
                        .foregroundColor(Color.white)
                        .frame(width: geometry.size.width * 0.75, height: geometry.size.width * 0.75)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                        .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
                    
                }

            }
        }
    }
}

struct LeaveRaceButton: View{
    var body: some View{
        GeometryReader{ geometry in
            ZStack{
                Color.green
                   .clipShape(Circle())
                   .shadow(radius: 10)
                
                Button(action: {

                }){
                    Image(systemName: "chevron.left.circle")
                        .resizable()
                        .foregroundColor(Color.white)
                        .frame(width: geometry.size.width * 0.75, height: geometry.size.width * 0.75)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                        .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
                    
                }

            }
        }
    }
}
