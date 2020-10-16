//
//  ProfileView.swift
//  BikeTracker
//
//  Created by Sanjith Udupa on 10/15/20.
//  Copyright © 2020 Sanjith Udupa. All rights reserved.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    @State private var statsView = 0
    @State private var name: String = "Sanjith"
    
    @State private var changingName = false
    
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
                        .onTapGesture{
                            self.changingName = true
                        }
                    
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
                
                if(self.changingName){
                    HStack{
                        TextField("Enter your name", text: self.$name, onCommit: self.nameSet)
                        Button(action: {
                            UserDefaults.standard.removeObject(forKey: "racerName")
                            self.changingName = false
                            exit(-1)
                        }) {
                            Text("Reset")
                        }
                    }
                }
                
            }.animation(.spring())
                .offset(y:-20)
        }
        
    }
    
    func nameSet(){
        UserDefaults.standard.set(self.name, forKey: "racerName")
        
        self.changingName = false
        
        exit(-1)
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
