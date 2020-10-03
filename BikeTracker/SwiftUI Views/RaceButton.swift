//
//  RaceButton.swift
//  BikeTracker
//
//  Created by Sanjith Udupa on 10/1/20.
//  Copyright © 2020 Sanjith Udupa. All rights reserved.
//

import SwiftUI
import Combine

struct HomeView: View {
    var body: some View {
        Text("Home")
    }
    
}
struct ProfileView: View {
    
    var body: some View {
        GeometryReader { geometry in
            VStack{
                Spacer()
                    .frame(height: geometry.size.height/50)
                Text("User Profile")
                    .font(.system(.title))
                    .offset(y: -geometry.size.height/3)
                HStack{
                    Image(systemName: "person.crop.square.fill")
                        .resizable()
                        .frame(width: geometry.size.width/3.5, height: geometry.size.width/3.5)
                        .offset(x: -geometry.size.width/4, y: 10)
                }.offset(y:-geometry.size.height/3)
                
                Text("Name")
                    .font(.system(.title))
                    .offset(x: geometry.size.width/30,y: -geometry.size.height/2.025)
                Text("Primary Sport: Biking").offset(x: geometry.size.width/6.5,y: -geometry.size.height/2.025)
            }
        }
    }
    
}
struct TabBar: View {
    @ObservedObject var viewHandler: TabHandler

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                if self.viewHandler.currentPage == "home" {
                        HomeView()
                } else if self.viewHandler.currentPage == "profile" {
                    ProfileView()
                }
                Spacer()
                HStack {
                    Image(systemName: "house")
                      .resizable()
                      .aspectRatio(contentMode: .fit)
                      .padding(20)
                      .frame(width: geometry.size.width/3, height: 75)
                      .foregroundColor(self.viewHandler.currentPage == "home" ? Color.green : Color.gray)
                      .animation(.spring(dampingFraction: 0.75))
                      .onTapGesture {
                        self.viewHandler.currentPage = "home"
                      }
                        
                    Spacer().frame(width: geometry.size.width/4.5)
                    
                    Image(systemName: "person.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(20)
                        .frame(width: geometry.size.width/3, height: 75)
                        .foregroundColor(self.viewHandler.currentPage == "profile" ? Color.green : Color.gray)
                        .animation(.spring(dampingFraction: 0.75))
                        .onTapGesture {
                            self.viewHandler.currentPage = "profile"
                        }
                    
                }
                    .frame(width: geometry.size.width, height: geometry.size.height/10)
                    .background(Color.white.shadow(radius: 2))
            }.edgesIgnoringSafeArea(.bottom)
        }
    }
}
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
struct CodeView: View {
    @Binding var codeString:String
    @Binding var ready:Bool
    @Binding var joinRace:() -> Void
    
    var body: some View {
        ZStack{
            CodeInputs(codeString: $codeString)
            
            TextField("", text: $codeString, onCommit: doneEditing)
                .foregroundColor(.clear)
                .accentColor(.clear)
                .textContentType(.telephoneNumber)
        }
//        MapView()
    }
    
    func doneEditing(){
        self.joinRace()
    }
}


class TabHandler: ObservableObject {
    
//    @Published var getInstance = TabHandler()
    
    let objectWillChange = PassthroughSubject<TabHandler,Never>()
    
//    var currentView : CurrentView = .Main {
//        didSet {
//            objectWillChange.send(self)
//        }
//    }
    var currentPage: String = "home" {
        didSet {
            objectWillChange.send(self)
        }
    }
}
