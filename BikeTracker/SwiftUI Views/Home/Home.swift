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
//struct Home: View {
//    @State var expanded = false
//    @State var currentView:CurrentView = .home
//
//    var body: some View {
//        ZStack{
//            ZStack{
//                TabBar(viewHandler: TabHandler())
//                RaceButton(expanded: $expanded, showing: $currentView)
//            }
//        }
//    }
//}

    
struct Home: View {
    @State var expanded = false
//    @State var currentView:CurrentView = .home
    
    @State private var raceID: String = ""
    @State private var currentView: CurrentView = .home
    @State private var inputsEmpty = false
    @State private var youNewHost = false
    @State private var disconnectedNow = false
    @State private var raceAlreadyStarted = false
    @State private var raceIdString: String = ""
    
    @State private var raceStatsShown: Bool = false
    
    var body: some View {
        return GeometryReader{geometry in
            ZStack{
                TabBar(viewHandler: TabHandler())
                RaceButton(expanded: self.$expanded, showing: self.$currentView, raceIdString: self.$raceIdString, joinRace: self.joinRace)
                    .offset(y: 75)
                ZStack{
//                    VStack {
//                        TextField("Race ID", text: self.$raceID).textFieldStyle(RoundedBorderTextFieldStyle())
//                            .keyboardType(.numberPad)
//
//                        Button(action: {
//                            self.joinRace()
//                        }) {
//                            Text("Join Race")
//                        }
//
//
//                    }.padding(82.5)
                    
                    //empty inputs alert
                    if(self.$inputsEmpty.wrappedValue){
                        AlertView(title: "Race ID Empty", text: "Please fill it in", trigger: self.$inputsEmpty)
                    }
                    
    //                NavigationLink(destination: Text("SearchResultList"),
    //                               isActive:
    //                            Binding<Bool>(
    //                                get: { currentView == .home },
    //                                set: { currentView = $0 }
    //                            )) {
    //                    EmptyView()
    //                }
                    
                    
    //Binding<Bool>(
    //    get: { !yourBindingBool },
    //    set: { yourBindingBool = !$0 }
    //)
                    
                    if(self.$currentView.wrappedValue == .host){
                        RaceLobby(host: true, users: SocketIOManager.getInstance.users, currentView: self.$currentView, youNewHost: false, justDisconnected: self.$disconnectedNow)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .background(Color.white)
//                        HostView(currentView: self.$currentView, justDisconnected: self.$disconnectedNow)
//                            .frame(width: geometry.size.width, height: geometry.size.height)
//                            .background(Color.white)
                        

                    }else if(self.$currentView.wrappedValue == .member){
                        RaceLobby(host: false, users: SocketIOManager.getInstance.users, currentView: self.$currentView, youNewHost: false, justDisconnected: self.$disconnectedNow)
//                        MemberView(currentView: self.$currentView, youNewHost: self.$youNewHost, justDisconnected: self.$disconnectedNow)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .background(Color.white)
                    }
                    
                    NavigationLink(destination: RaceStats(shown: self.$raceStatsShown),
                                   isActive: self.$raceStatsShown) {
                                    EmptyView()
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
            }
            
        }.onAppear(){
            print("appeared")
            SocketIOManager.getInstance.joinRaceShow = self.joinRaceShow
            SocketIOManager.getInstance.showHostVC = self.showHostView
            SocketIOManager.getInstance.showMemberVC = self.showMemberView
            SocketIOManager.getInstance.raceAlreadyStarted = self.raceAlreadyStartedF
            SocketIOManager.getInstance.showRaceStats = self.showRaceStats
        }
        
    }
    
    func showHostView(){
        currentView = .host
    }
    
    func showMemberView(){
        currentView = .member
    }
    
    func showRaceStats(){
        print("\n\n\n\n\n\n\n\n\n\n showing \n\n\n\n\n\n")
        self.raceStatsShown = true
    }
    
    func raceAlreadyStartedF(){
        raceAlreadyStarted = true
    }
    
    func joinRace(){
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        let id = (String(raceIdString.prefix(4))).filter("0123456789.".contains)
        if(id != ""){
            SocketIOManager.getInstance.joinRace(id: Int(id) ?? 0)
        }else{
            inputsEmpty = true
        }
    }
    
    func joinRaceShow(id:Int){
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        SocketIOManager.getInstance.joinRace(id: id)
    }
    
}
