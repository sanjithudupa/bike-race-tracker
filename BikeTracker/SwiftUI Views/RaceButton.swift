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
    @State private var statsView = 0
    
    init() {
        UISegmentedControl.appearance().selectedSegmentTintColor = .green
//        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
//        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack{
                VStack{
                    HStack{
                        Image("SanjithProfilePicture")
                            .resizable()
                            .cornerRadius(25)
                            .frame(width: geometry.size.width/3.5, height: geometry.size.width/3.5)
                            .offset(x: -geometry.size.width/4, y: 10)
                    }.offset(y:-geometry.size.height/3)
                    
                    Text("Sanjith Udupa")
                        .font(.system(.title))
                        .offset(x: geometry.size.width/30 + 48,y: -geometry.size.height/2.025)
                    Text("Primary Sport: Biking").offset(x: geometry.size.width/6.5,y: -geometry.size.height/2.025)
                    Text("Joined: June 2020")
                        .italic().offset(x: geometry.size.width/6.5,y: -geometry.size.height/2.025 + 4)
                }
                
//                Text("Statistics:")
//                    .font(.system(size: 17.5, weight:
//                    .semibold, design: .rounded))
//                    .offset(y: -155)
                Group{
                    Picker(selection: self.$statsView, label: EmptyView()) {
                        Text("Overall").tag(0)
                        Text("Goals").tag(1)
                    }.pickerStyle(SegmentedPickerStyle())
                    .shadow(color: .green, radius: 25, x: 15, y: 15)
                    .frame(width: geometry.size.width/2)
                    .offset(y: -125)
                    
                    VStack(spacing: 15){
                        StatisticView(label: "Total Races", value: "14", fontSize: 50)
                        StatisticView(label: "Average Rank", value: "1.64", fontSize: 45)
                        StatisticView(label: "Average Speed", value: "13.5 mph", fontSize: 45)
                        StatisticView(label: "Longest Race", value: "53.26 mi",secondary: "6:03:26", fontSize: 35)
                    }.offset(x: self.$statsView.wrappedValue == 0 ? 0 : -geometry.size.width, y: 95)
                    
                    
                    VStack(spacing: 25){
                        CircularProgress(label: "Distance: 13.2 mi", progress: 34)
                        CircularProgress(label: "Elevation Gain: 43.2 ft", progress: 57)
                        StatisticView(label: "Weekly Fastest:", value: "12.4 mph", fontSize: 45)
                        BarProgress(label: "Rides This Week: 6", progress: 6)
                    }.offset(x: self.$statsView.wrappedValue == 1 ? 0 : geometry.size.width, y: 90)
                }.offset(y:-20)
                
            }.animation(.spring())
                .offset(y:-20)
        }
    }
    
}

struct StatisticView: View{
    @State var label:String = ""
    @State var value:String = ""
    @State var secondary:String = ""
    @State var fontSize:CGFloat = 40
    
    var body: some View{
        VStack{
            Text(self.label)
                .font(.system(size: 20, weight:
                    .black, design: .rounded))
            Text(self.value)
                .font(.system(size: self.fontSize, weight: .black, design: .serif))
                .foregroundColor(.green)
                .shadow(color: .green, radius: 25, x: 15, y: 15)
            if(self.secondary != ""){
                Text(self.secondary)
                    .font(.system(size: self.fontSize * 0.8, weight: .black, design: .serif))
                    .foregroundColor(.green)
                    .shadow(color: .green, radius: 25, x: 15, y: 15)
            }
        }
    }
}

struct CircularProgress: View {
    @State var label:String = ""
    @State var progress: CGFloat = 0.3

    var body: some View {
    
        VStack{
            Text(self.label)
            .font(.system(size: 20, weight:
                .black, design: .rounded))
            ZStack {
               Circle()
                   .stroke(lineWidth: 10)
                   .opacity(0.3)
                   .foregroundColor(Color.gray)

                Text(String(format: "%.0f", Double(self.progress)) + "%")
                    .font(.system(size: 12.5, weight: .black, design: .serif))
                   .foregroundColor(.green)
                   .shadow(color: .green, radius: 25, x: 15, y: 15)
                    
               Circle()
                   .trim(from: 0.0, to: progress/100)
                   .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                   .foregroundColor(Color.green)
                   .rotationEffect(Angle(degrees: 270.0))

            }
            .shadow(color: .green, radius: 30)
            .frame(width: 50, height: 50)
        }
    }
}

struct BarProgress: View {
    @State var label:String = ""
    @State var progress: Int = 3

    var body: some View {
        VStack{
            Text(self.label)
                .font(.system(size: 20, weight:
                    .black, design: .rounded))
            HStack(spacing: 4) {
              ForEach(0 ..< 10) { index in
                Rectangle()
                    .foregroundColor(index < self.progress ? .green
                    : Color.gray.opacity(0.3))
              }
            }
            .frame(width: 250, height: 20)
            .clipShape(Capsule())
            
            .shadow(color: .green, radius: 25, x: 15, y: 15)
        }
//        VStack{
//            Text(self.label)
//            .font(.system(size: 20, weight:
//                .black, design: .rounded))
//            ZStack {
//               Rectangle()
//                   .stroke(lineWidth: 10)
//                    .frame(height:10)
//                   .opacity(0.3)
//                   .foregroundColor(Color.gray)
//
//                Text(String(format: "%.0f", Double(self.progress)) + "%")
//                    .font(.system(size: 12.5, weight: .black, design: .serif))
//                   .foregroundColor(.green)
//                   .shadow(color: .green, radius: 25, x: 15, y: 15)
//
//               Rectangle()
//                   .trim(from: 0.0, to: progress/100)
//                   .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
//                   .frame(height:10)
//                   .foregroundColor(Color.green)
//                   .rotationEffect(Angle(degrees: 270.0))
//
//            }
//            .shadow(color: .green, radius: 30)
//            .frame(width: 50, height: 50)
//        }
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
                .keyboardType(.namePhonePad)
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
