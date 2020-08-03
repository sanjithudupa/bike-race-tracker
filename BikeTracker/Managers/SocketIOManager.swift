//
//  SocketIOManager.swift
//  BikeTracker
//
//  Created by Sanjith Udupa on 6/23/20.
//  Copyright © 2020 Sanjith Udupa. All rights reserved.
//

import Foundation
import SocketIO
import UIKit
import CoreLocation

class SocketIOManager: NSObject {
    @objc static let getInstance = SocketIOManager()

    let manager = SocketManager(socketURL: URL(string: "http://localhost:3000")!, config: [.log(true), .compress])
    var socket:SocketIOClient!
    
    var isConnected = false
    
    var inRace = false
    var raceOn = false
    
    var name:String!
    
    //race-specific variables
    var id:Int!
    var users = [String]()
    var userNames = [String: String]()
    var joinIndex:Int!
    var userId:String!
    var positions = [String: [CLLocationCoordinate2D]]()
    var distances = [String: Int]()
    var endpoint:CLLocationCoordinate2D!
    var endpointDistance = 0.0


    //host/member vc ui functions
    var updateIdLabel: (() -> Void)?
    var updateUsersLabel: (() -> Void)?
    var updateEndpointDistanceLabel: (() -> Void)?
    var endpointHasBeenSet: (() -> Void)?

    
    //show vc functions
    var showHostVC: (() -> Void)?
    var showMemberVC: (() -> Void)?
    var showHomeVC: (() -> Void)?
    var showRaceVC: (() -> Void)?
    var showSummaryVC: (() -> Void)?
    var showConnectingVC: (() -> Void)?
    var resetToHome: (() -> Void)?
    
    //race vc ui functions
    var updatePositionsLabel: ((/*_ addition:String*/) -> Void)?
    var showStopButton: (() -> Void)?
    var updateEndpoint: (() -> Void)?
    var showStoppedRecording: (() -> Void)?
    
    var fillRaceSummary: (() -> Void)?
    var hideConnectingView: ((/*_ above:Bool*/) -> Void)?

    //event functions (alerts)
    var raceAlreadyStarted: (() -> Void)?
    var newHost: (() -> Void)?
    var disconnected: (() -> Void)?
    var passedEndpoint: (() -> Void)?
    
    var timer : Timer?
    var reconnectTimer : Timer?
    
    override init() {
        socket = manager.defaultSocket
                
        
        socket.on("error"){ dataArray, ack in
            if((dataArray[0] as? String ?? "") == "Could not connect to the server." && SocketIOManager.getInstance.isConnected){
                SocketIOManager.getInstance.couldntConnect()
                SocketIOManager.getInstance.tryToConnect()
            }
        }
        
        socket.on("reconnect"){ dataArray, ack in
            SocketIOManager.getInstance.isConnected = true
            SocketIOManager.getInstance.hideConnectingView?()
        }
        
        socket.on("youConnected") { dataArray, ack in
            SocketIOManager.getInstance.isConnected = true
            SocketIOManager.getInstance.hideConnectingView?()
//            SocketIOManager.getInstance.sendConnect(long : 253, lat : 351)
//            let joined = dataArray[0] as? String ?? "false"
//            if(joined.contains("false")){
////                SocketIOManager.getInstance.showHomeVC?()
//            }
            SocketIOManager.getInstance.sendConnect(name: SocketIOManager.getInstance.name)

        }
        
        socket.on("youJoinedRace") { dataArray, ack in
            SocketIOManager.getInstance.inRace = true;
            let joinState = dataArray[0] as? String ?? ""
            let usersCSV = dataArray[1] as? String ?? ""
            
            if(joinState == "join"){
                SocketIOManager.getInstance.showMemberVC?()
            }else{
                SocketIOManager.getInstance.showHostVC?()
                print("showHost")
            }
            
            SocketIOManager.getInstance.userId = dataArray[2] as? String ?? ""

            SocketIOManager.getInstance.users = usersCSV.components(separatedBy: ",")
            SocketIOManager.getInstance.updateUsersLabel?()
            SocketIOManager.getInstance.updateIdLabel?()
        }
        
        socket.on("userListUpdate") { dataArray, ack in
            let usersCSV = dataArray[0] as? String ?? ""
            SocketIOManager.getInstance.users = usersCSV.components(separatedBy: ",")
            
            if(dataArray.count > 1){
                let userNamesCSV = dataArray[1] as? String ?? ""
                let userNamesArray = userNamesCSV.components(separatedBy: ",")
                var count = 0
                var firstDone = false
                for user in SocketIOManager.getInstance.users {
                    if(firstDone){
                        SocketIOManager.getInstance.userNames[user] = userNamesArray[count]
                        count += 1
                    }else{
                        firstDone = true
                    }
                }
            }
            
            SocketIOManager.getInstance.updateUsersLabel?()
        }
        
//        socket.on("userNamesUpdate") { dataArray, ack in
//            let userNamesCSV = dataArray[0] as? String ?? ""
//            let userNameArray = userNamesCSV.components(separatedBy: ",")
//
//            var count = 0
//
//            for user in SocketIOManager.getInstance.users {
//                SocketIOManager.getInstance.userNames[user] = userNameArray[count]
//                count += 1
//            }
//
//            SocketIOManager.getInstance.updateUsersLabel?()
//        }
        
        socket.on("raceAlreadyStarted") { dataArray, ack in
            SocketIOManager.getInstance.raceAlreadyStarted?()
        }
        
        socket.on("newHost"){ dataArray, ack in
            print("y\ny\ny\ny\ny\ny\ny\ny\ny\ny\ny\n")
            SocketIOManager.getInstance.showHostVC?()
            SocketIOManager.getInstance.updateIdLabel?()
            SocketIOManager.getInstance.newHost?()
        }
        
        
        socket.on("startRace"){ dataArray, ack in
            SocketIOManager.getInstance.showRaceVC?()
            SocketIOManager.getInstance.raceOn = true
            SocketIOManager.getInstance.raceLoop()
            if  SocketIOManager.getInstance.timer == nil {
                SocketIOManager.getInstance.timer = Timer.scheduledTimer(timeInterval: 5, target: SocketIOManager.getInstance, selector: #selector(SocketIOManager.getInstance.raceLoop), userInfo: nil, repeats: true)
            }
//            Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
//                SocketIOManager.getInstance.raceLoop()
////                print("sent")
////
////                var farthest = false
////
////                for user in SocketIOManager.getInstance.users {
////                    let you = SocketIOManager.getInstance.positions["you"]
////                    let other = SocketIOManager.getInstance.positions[user]
////                    if((you ?? 0) > (other ?? 0)){
////                        farthest = true
////                        break
////                    }
////                }
////
////
////                print(SocketIOManager.getInstance.userId ?? "" + String(farthest))
//
//
//            }
            
        }
        
        socket.on("setEndpoint"){ dataArray, ack in
            let position = dataArray[0] as? String ?? "0,0"
            let locationCSV = position.components(separatedBy: ",")
            let location = CLLocationCoordinate2D(latitude: Double(locationCSV[0]) ?? 0.0, longitude: Double(locationCSV[1]) ?? 0.0)
            
            SocketIOManager.getInstance.endpoint = location
            SocketIOManager.getInstance.updateEndpoint?()
        }
        
        socket.on("stopRecording"){ dataArray, ack in
            print("Stop")
            SocketIOManager.getInstance.stopTimer()
            SocketIOManager.getInstance.showStoppedRecording?()
        }
        
        socket.on("stopRace"){ dataArray, ack in
            print("Stop RACe")
            SocketIOManager.getInstance.stopTimer()
//            SocketIOManager.getInstance.leaveRace()
            SocketIOManager.getInstance.showSummaryVC?()
            SocketIOManager.getInstance.fillRaceSummary?()
            
            LocationManager.getInstance.stop()
        }
        
        socket.on("positionUpdate"){ dataArray, ack in
            print("positionUpdate")
//            print(SocketIOManager.getInstance.userId)
            let position = dataArray[0] as? String ?? "0,0"
            let locationCSV = position.components(separatedBy: ",")
            let location = CLLocationCoordinate2D(latitude: Double(locationCSV[0]) ?? 0.0, longitude: Double(locationCSV[1]) ?? 0.0)
            let user = dataArray[1] as? String ?? ""
            
//            let curPos = SocketIOManager.getInstance.positions[user] ?? 0
//            let totalPos = curPos + (Int(position) ?? 0)
            
            if(SocketIOManager.getInstance.users.contains(user)){
                SocketIOManager.getInstance.positions[user]?.append(location)
            }
            
            //TODO: get endpoint working
            
//            if(SocketIOManager.getInstance.endpoint != nil && totalPos > SocketIOManager.getInstance.endpoint){
//                SocketIOManager.getInstance.passedEndpoint?()
//            }
            
//            let commaIndex = dataCSV.distance(from: dataCSV.startIndex, to:dataCSV.firstIndex(of: ",") ?? dataCSV.index(after: dataCSV.startIndex))
//            let position = dataCSV.prefix(upTo: dataCSV.index(dataCSV.startIndex, offsetBy: commaIndex))
//            print(dataCSV)
//            print(SocketIOManager.getInstance.userId + "" + String(farthest))
            
//
//            let user = dataCSV.suffix(dataCSV.count - commaIndex + 1)
            
//            if(position != "0" && user != "" && user != SocketIOManager.getInstance.userId){
//                SocketIOManager.getInstance.updatePositionsLabel?(/*"\n" + user + " is now at " + position*/)
//            }
            
            SocketIOManager.getInstance.showStopButton?()
        }

        
        super.init()
    }
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func connect() { socket.connect() }
    
    func disconnect() { socket.disconnect() }
    

    func stopTimer()
    {
      if timer != nil {
        timer!.invalidate()
        timer = nil
      }
    }
    
    
//    func sendConnect(long: Int, lat : Int) {
//        let coord = [long, lat]
//        socket.emit("sendConnect", coord)
//    }
    
    func sendConnect(name: String) {
//        let coord = [long, lat]
        socket.emit("sendConnect", name)
    }
    
    func joinRace(id: Int){
        SocketIOManager.getInstance.id = id
        socket.emit("joinRace", id)
    }
    
    func startRace(){
        socket.emit("startRace", SocketIOManager.getInstance.id)
    }
    
    func leaveRace(){
        stopTimer()
        socket.emit("leaveRace", SocketIOManager.getInstance.id)
        resetRaceSpecificVaraibles()
    }
    
    func resetRaceSpecificVaraibles(){
        LocationManager.getInstance.stop()
        SocketIOManager.getInstance.inRace = false
        SocketIOManager.getInstance.id = nil
        SocketIOManager.getInstance.users = [String]()
        SocketIOManager.getInstance.userNames = [String: String]()
        SocketIOManager.getInstance.joinIndex = nil
        SocketIOManager.getInstance.userId = nil
        SocketIOManager.getInstance.positions = [String: [CLLocationCoordinate2D]]()
        SocketIOManager.getInstance.endpoint = nil
        SocketIOManager.getInstance.endpointDistance = 0.0
    }
    
    @objc func raceLoop(){
        print("raceLoop")
        print(SocketIOManager.getInstance.userId)
        let location = LocationManager.getInstance.getLocation()
        if(location != nil){
            let position = String(location!.coordinate.latitude) + "," +  String(location!.coordinate.longitude)//Int.random(in: 1...20)
            let sendData = [(position), SocketIOManager.getInstance.id as Any] as [Any]
        
            SocketIOManager.getInstance.socket.emit("positionUpdate", sendData)
            
//            let curPos = SocketIOManager.getInstance.positions["you"] ?? 0
//            let totalPos = curPos + Int(position)
            
//            SocketIOManager.getInstance.positions["you"] = totalPos
            SocketIOManager.getInstance.updatePositionsLabel?()
            SocketIOManager.getInstance.updateEndpoint?()
        }else{
            print("location nil")
        }
    }
    
    func stopRace(){
        SocketIOManager.getInstance.raceOn = false
        print("SocketIOManager.getInstance.positions")
        print(SocketIOManager.getInstance.positions)
        socket.emit("stopRace", SocketIOManager.getInstance.id)
    }
    
    func setEndpoint(){
        let endpointCSV: String = String(SocketIOManager.getInstance.endpoint.latitude) + "," + String(SocketIOManager.getInstance.endpoint.longitude)
        socket.emit("setEndpoint", String(SocketIOManager.getInstance.id) + "," + endpointCSV)
    }
    
    func stopRecording(){
        socket.emit("stopRecording")
    }
    
    func tryToConnect(){
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            SocketIOManager.getInstance.connect()
            print("trying")
            SocketIOManager.getInstance.socket.on("youConnected") { dataArray, ack in
                    SocketIOManager.getInstance.resetToHome?()
                    timer.invalidate()
                }
            }
    }
    
    func couldntConnect(){
        SocketIOManager.getInstance.isConnected = false
        SocketIOManager.getInstance.showConnectingVC?()
    }
    
    func testU(){
        SocketIOManager.getInstance.updateUsersLabel?()
    }
}
