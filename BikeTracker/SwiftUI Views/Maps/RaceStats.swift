//
//  RaceStats.swift
//  BikeTracker
//
//  Created by Sanjith Udupa on 8/11/20.
//  Copyright © 2020 Sanjith Udupa. All rights reserved.
//

import Foundation
import SwiftUI


struct UserRanking: View {
    @State var rank:Int
    @Binding var name: String
    
    @Binding var disconnected: Bool
    
    @State var pfpSize:CGFloat = 50
    
    @Binding var userColor:Color
    
    var body: some View{
        GeometryReader{ geometry in
            HStack{
                PlaceNumberView(place: self.$rank, size: self.$pfpSize, userColor: self.$userColor) //replace with profile view for profile
                ZStack{
                    Text(self.name)
                        .foregroundColor(self.disconnected ? Color.gray : self.userColor)
                        .offset(/*x:self.disconnected ? -9 : 0,*/ y:self.disconnected ? -5: 0)
                    if(self.disconnected){
                        Text("disconnected")
                            .foregroundColor(.gray)
                            .font(.footnote)
                            .offset(y:10)
                    }
                }
                Spacer()
            }
        }

    }
}

struct ProfileImage: View{
    @Binding var pfp: UIImage/*(named: "profile_pic.jpg")!*/
    @Binding var size:CGFloat/* = 50*/
    var body: some View{
        Image(uiImage: self.pfp)
            .resizable()
            .clipShape(Circle())
            .frame(width: self.size, height: self.size)
            .overlay(Circle().stroke(Color.white, lineWidth: 3))
            .shadow(radius: 10)
    }
}

struct PlaceNumberView: View{
    @Binding var place: Int/*(named: "profile_pic.jpg")!*/
    @Binding var size:CGFloat/* = 50*/
    @Binding var userColor:Color
    var body: some View{
        Text(String(self.place))
            .font(.title)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .offset(x:-0.1)
            .frame(width: self.size, height: self.size)
            .overlay(
                Circle().stroke(Color.white, lineWidth: 5))
            .background(self.userColor)
            .colorMultiply(.white)
            .clipShape(Circle())
            .shadow(radius: 10)
    }
}

struct RankingView: View{
    @State var distances = ["Rankings not set yet"]
    @State var disconnectedPeople = [Bool]()
    @State var colors = [Color.black]
    
    @State var notSet = true
    
    @State var curRank = 1
    
    var body: some View{
        ZStack{
            Text("Rankings not set yet, please wait.")
                .opacity(notSet ? 1 : 0)
            if(!notSet){
                VStack{
                    ForEach(0..<distances.count, id: \.self){ index in
                        UserRanking(rank: index+1, name: self.$distances[index], disconnected:
                            self.$disconnectedPeople[index], userColor: self.$colors[index])
                            .frame(width: 250, height: 50)
                            .opacity(self.$disconnectedPeople.wrappedValue[index] ? 0.3 : 1)

                    }
                }
            }
            
        }
        .onAppear(){
            SocketIOManager.getInstance.updateRanking = self.updateRanking
        }
    }
    
    func updateRanking(){
        
        guard SocketIOManager.getInstance.distances.values.max() != nil && SocketIOManager.getInstance.distances.values.max()! > 0.0 else{
            return
        }
        
        self.distances = []
        self.disconnectedPeople = []
        self.colors = []
        
        for(user, distance) in ((SocketIOManager.getInstance.distances.sorted { $0.1 < $1.1 }).reversed()){
            if(SocketIOManager.getInstance.userNames.keys.contains(user)){
                
                //get distance
                let distanceStr = (distance <= 1609) ? String(format: "%.f", distance) + "meters" : String(format: "%.2f", distance / 1609.34) + " miles"
                let userName = SocketIOManager.getInstance.userNames[user]! + " - "
                let newDistLine = userName + distanceStr/* + (SocketIOManager.getInstance.users.contains(user) ? "" : " - disconnected")*/
                
                
                self.distances.append(newDistLine)
                self.disconnectedPeople.append(!SocketIOManager.getInstance.users.contains(user))
                
                
                //get color
                let index = Array(SocketIOManager.getInstance.positions.keys).firstIndex(of: user) ?? 0
                let color = SocketIOManager.getInstance.users.contains(user) ? UIColor.randomColorFromSeed(input: index) : UIColor.gray
                self.colors.append(Color(color))
    
            }
        }
        
        print(disconnectedPeople)
        self.notSet = false
    }
}
