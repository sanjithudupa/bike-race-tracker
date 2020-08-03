//
//  ContentView.swift
//  BikeTracker
//
//  Created by Sanjith Udupa on 7/26/20.
//  Copyright © 2020 Sanjith Udupa. All rights reserved.
//

import SwiftUI
import CoreLocation

enum CurrentView{
    case home
    case host
    case member
}

struct AppView: View {
    @State var connectionIssue = true
    @State var connectionStatus = "Trying to connect"
    
    func showConnectingView(){
        self.connectionStatus = "Trying to connect"
        self.connectionIssue = true
    }
    
    func hideConnectingView(){
        self.connectionStatus = "Connected!"
        Thread.sleep(forTimeInterval: 1)
        self.connectionIssue = false
    }
    
    var body: some View {
        GeometryReader{geometry in
            Home()
                .blur(radius: self.$connectionIssue.wrappedValue ? 5 : 0)

//            if(self.$connectionIssue.wrappedValue){
            Color.black
                .edgesIgnoringSafeArea(.all)
                .opacity(self.$connectionIssue.wrappedValue ? 0.5 : 0)
            ConnectingView(status: self.$connectionStatus)
                .frame(width: geometry.size.width/2, height: geometry.size.height/6)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 3)
                .position()
                .offset(x: geometry.size.width/2, y: geometry.size.height/2)
                .opacity(self.$connectionIssue.wrappedValue ? 1 : 0)
//            }
        
        }.onAppear(){
            SocketIOManager.getInstance.showConnectingVC = self.showConnectingView
            SocketIOManager.getInstance.hideConnectingView = self.hideConnectingView
        }
        .animation(.easeInOut)
    }
}

struct Home: View {
    @State private var raceID: String = ""
    @State private var currentView: CurrentView = .home
    @State private var inputsEmpty = false
    @State private var youNewHost = false
    @State private var disconnectedNow = false
    @State private var raceAlreadyStarted = false
    
    var body: some View {
        return GeometryReader{geometry in
            ZStack{
                VStack {
                    TextField("Race ID", text: self.$raceID).textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)

                    Button(action: {
                        let id = (self.raceID).filter("0123456789.".contains)
                        if(id != ""){
                            SocketIOManager.getInstance.joinRace(id: Int(id) ?? 0)
                        }else{
                            self.inputsEmpty = true
                        }
                    }) {
                        Text("Join Race")
                    }
                    
    //                    .alert(isPresented: $inputsEmpty) {
    //                        Alert(title: Text("Fill in race ID"), message: Text("ID can't be empty"), dismissButton: .default(Text("Okay")))
    //                    }

                }.padding(82.5)
                
                //empty inputs alert
                if(self.$inputsEmpty.wrappedValue){
                    AlertView(title: "Race ID Empty", text: "Please fill it in", trigger: self.$inputsEmpty)
                }
                
                
                if(self.$currentView.wrappedValue == .host){
                        
                    
                    HostView(currentView: self.$currentView, justDisconnected: self.$disconnectedNow)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .background(Color.white)
                    

                }else if(self.$currentView.wrappedValue == .member){
                    MemberView(currentView: self.$currentView, youNewHost: self.$youNewHost, justDisconnected: self.$disconnectedNow)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .background(Color.white)

                }
                
                //host left alert
                
                AlertView(title: "Host Left", text: "You are now the Race Host", trigger: self.$youNewHost)
                
                //race started alert
                AlertView(title: "Race Already Started", text: "Couldn't join the race because it has already started", trigger: self.$raceAlreadyStarted)
                
                //disconnected
                if(SocketIOManager.getInstance.inRace){
                    AlertView(title: "Disconnected from Server", text: "If you were in a race, you were disconnected. If you were not in a race, this shouldn't matter.", onOk: {
                            SocketIOManager.getInstance.resetRaceSpecificVaraibles()
                        SocketIOManager.getInstance.inRace = false
                            print("yeye")
                        }, trigger: self.$disconnectedNow)
                }
                
                
    //            NavigationLink(destination: HostView(), isActive: (self.currentView == .host)) {
    //                EmptyView()
    //            }
                
                
                    
            }.animation(.spring(dampingFraction: 0.75))
        }.onAppear(){
            print("appeared")
            SocketIOManager.getInstance.showHostVC = self.showHostView
            SocketIOManager.getInstance.showMemberVC = self.showMemberView
            SocketIOManager.getInstance.raceAlreadyStarted = self.raceAlreadyStartedF

        }
        
    }
    
    func showHostView(){
        currentView = .host
    }
    
    func showMemberView(){
        currentView = .member
    }
    
    func raceAlreadyStartedF(){
        raceAlreadyStarted = true
    }
    
}

struct HostView: View{
    @State var raceID = "0"
    @State var users = "Users:"
    @State var youNewHost = false
    @State var raceStarted = false
    @State var selectingEndpoint = false
    @Binding var currentView: CurrentView
    @Binding var justDisconnected: Bool
    
    func updateIdLabel(){
        self.raceID = String(SocketIOManager.getInstance.id)
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
                    
                    NavigationLink(destination: Map(currentView: self.$currentView).navigationBarBackButtonHidden(true)
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
    @Binding var justDisconnected: Bool
    
    func updateIdLabel(){
        self.raceID = String(SocketIOManager.getInstance.id)
    }
    
    func updateUserLabel(){
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
                    
                    NavigationLink(destination: Map(currentView: self.$currentView).navigationBarBackButtonHidden(true)
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

struct LocationTest: View{
//    var locationManager = CLLocationManager()

    var body: some View{
        Button(action: {
//            var currentLoc: CLLocation!
//            if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse) {
//                currentLoc = self.locationManager.location
//               print(currentLoc.coordinate.latitude)
//               print(currentLoc.coordinate.longitude)
//            }else{
//                print("couldn't get location")
//            }
            
            print(LocationManager.getInstance.getLocation())
            
            
        }) {
            Text("Get Location")
        }.onAppear(){
            LocationManager.getInstance.start()
        }
    }
}
