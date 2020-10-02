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
