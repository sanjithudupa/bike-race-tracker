//
//  HomeTabs.swift
//  BikeTracker
//
//  Created by Sanjith Udupa on 10/15/20.
//  Copyright © 2020 Sanjith Udupa. All rights reserved.
//

import SwiftUI
import Combine

struct HomeView: View {
    var body: some View {
        TrailsFeed()
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
