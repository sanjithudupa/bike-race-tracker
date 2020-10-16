//
//  HostMemberView.swift
//  BikeTracker
//
//  Created by Sanjith Udupa on 8/14/20.
//  Copyright © 2020 Sanjith Udupa. All rights reserved.
//

import SwiftUI

struct HostView: View{
    @State var raceID = "0"
    @State var users = "Users:"
    @State var youNewHost = false
    @State var raceStarted = false
    @State var selectingEndpoint = false
    @State var comingBack = false
    @Binding var currentView: CurrentView
    @Binding var justDisconnected: Bool
    
    func updateIdLabel(){
        if(!comingBack){
            self.raceID = String(SocketIOManager.getInstance.id)
        }else{
            currentView = .home
        }
    }
    
    func updateUserLabel(){
        var users = ""
        for user in SocketIOManager.getInstance.users{
            if(user != "true" && user != "false" && SocketIOManager.getInstance.userNames.keys.contains(user)){
//                if(user == SocketIOManager.getInstance.name){
                
                users += user == SocketIOManager.getInstance.name ? "You" : (SocketIOManager.getInstance.userNames[user] ?? "")
//                }
//                users += (SocketIOManager.getInstance.userNames[user] ?? "")
                users += "\n"
            }
        }
//        let users = String(SocketIOManager.getInstance.userNames.values.joined(separator:"\n"))
        self.users = "Users:\n" + users
        print("updatingUsers")
        print(users)
    }
    
    func newHost(){
        print("Users:\nS\nD\nS\nS\nS\nS\nS\nS")
    }
    
    func resetToHome(){
        self.currentView = .home
        self.justDisconnected = true
    }
    
    var body: some View{
        NavigationView{
            GeometryReader{geometry in
                ZStack{
                    
                    NavigationLink(destination: RaceMap(currentView: self.$currentView, comingBack: self.$comingBack).navigationBarBackButtonHidden(true)
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                        .edgesIgnoringSafeArea(.all), isActive: self.$raceStarted) {
                        EmptyView()
                    }
                    
                    VStack{
                        HStack{
                            Button(action: {
                                print("Leave Race")
                                SocketIOManager.getInstance.leaveRace()
                                SocketIOManager.getInstance.inRace = false
                                self.currentView = .home
                            }) {
                                Text("Leave Race")
                                   
                            }.padding()
                            Spacer()
                        }
                        Spacer()
                    }
                    
                    VStack{
                        Spacer()
                        Group{
                            Text("You Host Race:")
                            Text(self.raceID)
                                .font(.largeTitle)
                        }.offset(y: -geometry.size.height/3.5)
                        Spacer()
                    }
                    
                    /*Text("Users:\n").bold() + */Text(self.users)
                        .multilineTextAlignment(.center)
                    
                    
                    Button(action: {
                        self.selectingEndpoint = true
                    }) {
                        ZStack{
                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: geometry.size.width/3, height: 40)
                                .cornerRadius(15)
                            Text("Start Race")
                                .foregroundColor(Color.white)
                        }
                    }.offset(y: geometry.size.height/3)
                    
                    if(self.$selectingEndpoint.wrappedValue){
                        EndpointSelectorAlert(onOk: {
                            self.raceStarted = true
                            print("Start Race")
                            SocketIOManager.getInstance.startRace()
                        }, trigger: self.$selectingEndpoint)
                    }
                    
    //                if(self.youNewHost){
    //                    AlertView(title: "Host Left", text: "You are now the Race Host", trigger: self.$youNewHost)
    //                }
                    
                }
            }.onAppear(){
                SocketIOManager.getInstance.updateIdLabel = self.updateIdLabel
                SocketIOManager.getInstance.updateUsersLabel = self.updateUserLabel
                self.justDisconnected = false
                SocketIOManager.getInstance.resetToHome = self.resetToHome
                
                SocketIOManager.getInstance.updateIdLabel?()
                SocketIOManager.getInstance.updateUsersLabel?()
                LocationManager.getInstance.start()
    //            SocketIOManager.getInstance.testU()
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
    }
}


struct MemberView: View {
    @State var raceID = "0"
    @State var users = "Users:"
    @State var raceStarted = false
    @Binding var currentView: CurrentView
    @Binding var youNewHost: Bool
    @State var comingBack = false
    @Binding var justDisconnected: Bool
    
    func updateIdLabel(){
        if(!comingBack){
            self.raceID = String(SocketIOManager.getInstance.id)
        }else{
            currentView = .home
        }
    }
    
    func updateUserLabel(){
        
//        var users = ""
//        
//        for(_, name) in SocketIOManager.getInstance.userNames {
//            users += (name == SocketIOManager.getInstance.name ? "You" : name)
//            users += "/n"
//        }
        
        let users = String(SocketIOManager.getInstance.userNames.values.joined(separator:"\n"))
        self.users = "Users:\n" + users
    }
    
    func newHost(){
        self.youNewHost = true
    }
    
    func showRaceView(){
        self.raceStarted = true
    }
    
    func resetToHome(){
        self.currentView = .home
        self.justDisconnected = true
    }
    
    var body: some View{
        NavigationView{
            GeometryReader{geometry in
                ZStack{
                    
                    NavigationLink(destination: RaceMap(currentView: self.$currentView, comingBack: self.$comingBack).navigationBarBackButtonHidden(true)
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                        .edgesIgnoringSafeArea(.all), isActive: self.$raceStarted) {
                        EmptyView()
                    }
                    
                    VStack{
                        HStack{
                            Button(action: {
                                print("Leave Race")
                                SocketIOManager.getInstance.leaveRace()
                                SocketIOManager.getInstance.inRace = false
                                self.currentView = .home
                            }) {
                                Text("Leave Race")
                                   
                            }.padding()
                            Spacer()
                        }
                        Spacer()
                    }
                    VStack{
                        Spacer()
                        Group{
                            Text("You Joined Race:")
                            Text(String(self.raceID))
                                .font(.largeTitle)
                        }.offset(y: -geometry.size.height/3.5)
                        Spacer()
                    }
                    
                    Text(self.users)
                        .multilineTextAlignment(.center)
                    
                }
            }.onAppear(){
                SocketIOManager.getInstance.updateIdLabel = self.updateIdLabel
                SocketIOManager.getInstance.updateUsersLabel = self.updateUserLabel
                SocketIOManager.getInstance.newHost = self.newHost
                SocketIOManager.getInstance.showRaceVC = self.showRaceView
                self.justDisconnected = false
                SocketIOManager.getInstance.resetToHome = self.resetToHome
                
                SocketIOManager.getInstance.updateIdLabel?()
                SocketIOManager.getInstance.updateUsersLabel?()
                LocationManager.getInstance.start()
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
    }
}

struct RaceLobby: View{
    @State var host = false
    @State var leaveRacePressed = false
    
    @State var users: [String]
    @Binding var currentView: CurrentView
    
    
    @State var raceID = "0"
    @State var raceStarted = false
    @State var youNewHost: Bool = false
    @State var comingBack = false
    @Binding var justDisconnected: Bool
    
    var body: some View{
        NavigationView{
            ZStack{
                NavigationLink(destination: RaceMap(currentView: self.$currentView, comingBack: self.$comingBack).navigationBarBackButtonHidden(true)
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
                    .edgesIgnoringSafeArea(.all), isActive: self.$raceStarted) {
                    EmptyView()
                }
                
                VStack{
                    Text(host ? "You are the Race Host" : "You Joined the Race")
                        .shadow(color: .green, radius: 25, x: 10, y: 10)
                        .font(.system(size: 17, weight:
                        .black, design: .rounded))
                    
                    Text(raceID)
                        .font(.system(size: 90, weight: .bold, design: .serif))
                        .foregroundColor(.green)
                        .shadow(color: .green, radius: 25, x: 10, y: 10)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: -7, y: -7)
                    
                    Text("Share the code!")
                        .shadow(color: .green, radius: 25, x: 10, y: 10)
                        .font(.system(size: 17, weight:
                        .black, design: .rounded))
                    
                    Spacer()
                        .frame(height: 35)
                    
                    Text("Racers:")
                        .shadow(color: .green, radius: 25, x: 10, y: 10)
                        .font(.system(size: 17, weight:
                        .black, design: .rounded))
                    
                    Spacer()
                        .frame(height: 20)
                    
                    UserView(users: self.$users)
                    
                }.offset(y: -205)
                
                if(host){
                    StartButton(startRace: startRace)
                        .offset(y: 210)
                }
                
                LeaveLobbyButton(leaveRace: leaveRace)
                    
                    .frame(width: 50, height: 50)
                    .offset(x: -(UIScreen.main.bounds.width/2 - 50), y: -(UIScreen.main.bounds.height/2 - 50) - 55)
                
            }
        }.onAppear(){
                SocketIOManager.getInstance.updateIdLabel = self.updateIdLabel
                SocketIOManager.getInstance.updateUsersLabel = self.updateUserLabel
                self.justDisconnected = false
                SocketIOManager.getInstance.resetToHome = self.resetToHome
                
                SocketIOManager.getInstance.newHost = self.newHost
                SocketIOManager.getInstance.showRaceVC = self.showRaceView
            
                SocketIOManager.getInstance.updateIdLabel?()
                SocketIOManager.getInstance.updateUsersLabel?()
                LocationManager.getInstance.start()
            
                
    //            SocketIOManager.getInstance.testU()
        }.navigationBarTitle("")
        .navigationBarHidden(true)
    }
    
    func leaveRace(){
        SocketIOManager.getInstance.leaveRace()
        SocketIOManager.getInstance.inRace = false
        self.currentView = .home
    }
    
    func updateIdLabel(){
        if(!comingBack){
            self.raceID = String(SocketIOManager.getInstance.id)
        }else{
            currentView = .home
        }
    }
    
    func updateUserLabel(){
        var usersTemp = [String]()
        for(_, name) in SocketIOManager.getInstance.userNames {
            usersTemp.append(name == SocketIOManager.getInstance.name ? "You" : name)
        }
        self.users = usersTemp
    }
    
    func newHost(){
        self.youNewHost = true
    }
    
    func showRaceView(){
        self.raceStarted = true
    }
    
    func resetToHome(){
        self.currentView = .home
        self.justDisconnected = true
    }
    
    func startRace(){
        self.raceStarted = true
        print("Start Race")
        SocketIOManager.getInstance.startRace()
    }
}

struct UserView: View{
    @Binding var users : [String]
    var body: some View{
        ZStack{
            ForEach(self.$users.wrappedValue, id: \.self) {user in
                User(name: user, you: user == "You")
                    .offset(x: user == "You" && self.users.count > 1 ? -30 : 0, y: (CGFloat((self.users.firstIndex(of: user) ?? 0) * 75)))
            }
        }
        .animation(.spring())
    }
}

struct User: View{
    @State var name:String = "Sanjith"
    @State var you:Bool = false
    var body: some View{
        ZStack{
            Rectangle()
                .foregroundColor(.white)
                .cornerRadius(15)
                .shadow(color: .green, radius: 25, x: self.you ? 5 : 10, y: self.you ? 5 : 10)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: -7, y: -7)
            
            Text(self.name)
                .shadow(color: .green, radius: 25, x: 10, y: 10)
                .font(.system(size: 17, weight:
                    self.you ? .semibold : .light, design: .rounded))
        }
        .frame(width: 150, height: 50)
//        .offset(x: self.you ? -30 : 0)
    }
}

struct StartButton: View {
    @State var startRace: () -> Void

    var body: some View {
        ZStack{
           
            Button(action:{
                print("start")
                self.startRace()
            }){
                ZStack{
                    Rectangle()
                        .fill(Color.green)
                        .cornerRadius(25)
                        .frame(width:110, height:85)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                        .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
                        .animation(.spring(dampingFraction: 0.75))

                    Text("Go!")
                        .font(.system(size: 57, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                        .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
                }
                
            }
        }
        .shadow(color: .green, radius: 30, x: 5, y: 5)
        
    }
}

struct LeaveLobbyButton: View{
    @State var leaveRace: () -> Void
    
    var body: some View{
        GeometryReader{ geometry in
            ZStack{
                Color.green
                   .clipShape(Circle())
                   .shadow(radius: 10)
                
                Button(action: {
                    self.leaveRace()
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
