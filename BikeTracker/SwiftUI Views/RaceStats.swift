//
//  RaceStats.swift
//  BikeTracker
//
//  Created by Sanjith Udupa on 8/11/20.
//  Copyright © 2020 Sanjith Udupa. All rights reserved.
//

import Foundation
import SwiftUI


struct RaceStats: View{
    @Binding var shown:Bool
    @State var time:Int = 0
    @State var speed:Double = 0.0
    @State var rank:Int = 0

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    func updateSpeedLabel(){
        speed = SocketIOManager.getInstance.speed
    }
    
    func updateRankingLabel(){
        rank = SocketIOManager.getInstance.rank
    }
    
    func rankFormat(r: Int) -> String{
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: r))!
    }
    
    func secondsToTime(seconds: Int) -> String {

        let (h,m,s) = (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)

        let h_string = h < 10 ? "0\(h)" : "\(h)"
        let m_string =  m < 10 ? "0\(m)" : "\(m)"
        let s_string =  s < 10 ? "0\(s)" : "\(s)"
        
        var returnString = ""
        
        if(h_string != "00"){
            returnString += h_string + ":0"
        }
        if(m_string != "00"){
            returnString += m_string + ":"
        }
        returnString += s_string
    
//        return "\(h_string):\(m_string):\(s_string)"
        return returnString
    }

    var body: some View{
        ZStack{
            Color.white
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            VStack{
                Spacer()
                
                Text(secondsToTime(seconds: ($time.wrappedValue)))
                .font(.system(size: 60, weight: .heavy, design: .default))
                    .offset(y: -30)
                
                Text("Leaderboard:")
                    .offset(y: -20)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Divider()
                    .offset(y: -25)
                    .frame(width: UIScreen.main.bounds.width/6 * 2)
                
                ScrollView(showsIndicators: false){
                    RankingView()
                        .offset(x: 20, y: 11)
                        .frame(width: UIScreen.main.bounds.width)
                }
                .frame(width: UIScreen.main.bounds.width, height: 250)
                .offset(y: -25)
                
                Text("Speed:")
                    .offset(y: -15)
                Text(String($speed.wrappedValue))
                    .font(.system(size: 80, weight: .heavy, design: .default))
                    .offset(y: -25)

                Text("mph")
                    .offset(y: -25)
                
                Text("You're in ").font(.system(size: 20)) + Text(rankFormat(r: $rank.wrappedValue)).font(.system(size: 20, weight: .bold)) + Text(" Place!").font(.system(size: 20))
                
                
                Spacer()
            }
            
        }
        .onAppear(){
            SocketIOManager.getInstance.updateSpeedLabel = self.updateSpeedLabel
            SocketIOManager.getInstance.updateRankingLabel = self.updateRankingLabel
        }
        .onReceive(timer) { time in
            guard SocketIOManager.getInstance.raceOn && SocketIOManager.getInstance.inRace  else{
                return
            }
            
            SocketIOManager.getInstance.time += 1
            self.time = SocketIOManager.getInstance.time
        }
        .offset(y: shown ? 0 : UIScreen.main.bounds.height)
    }
}

struct UserRanking: View {
    @State var rank:Int
    @Binding var name: String
    
    @Binding var disconnected: Bool
    
    @State var pfpSize:CGFloat = 50
    
    @Binding var userColor:Color
    
    var body: some View{
        GeometryReader{ geometry in
            HStack{
                RankNumberView(place: self.$rank, size: self.$pfpSize, userColor: self.$userColor) //replace with profile view for profile
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

struct RankNumberView: View{
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
                .offset(x: -20)
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
                let distanceStr = (distance <= 1609) ? String(format: "%.f", distance) + " meters" : String(format: "%.2f", distance / 1609.34) + " miles"
                let userName = (SocketIOManager.getInstance.userNames[user]! == SocketIOManager.getInstance.name ? "You" : SocketIOManager.getInstance.userNames[user]!) + " - "
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
