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

    let manager = SocketManager(socketURL: URL(string: UserDefaults.standard.object(forKey:"ip") as? String ?? "http://localhost:3000")!, config: [.log(true), .compress])
    var socket:SocketIOClient!
    
    var isConnected = false
    
    var inRace = false
    var raceOn = false
    var amHost = false
    
    var name:String!
    
    var raceTimeInterval = 2.5
    
    //race-specific variables
    var id:Int!
    var users = [String]()
    var userNames = [String: String]()
    var joinIndex:Int!
    var userId:String!
    var positions = [String: [CLLocationCoordinate2D]]()
    var distances = [String: Double]()
    var speed:Double = 0.0
    var time:Int = 0
    var rank:Int = 0
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
    var showRaceStats: (() -> Void)?
    var joinRaceShow: ((_ id:Int) -> Void)?
    
    //race vc ui functions
    var updatePositionsLabel: ((/*_ addition:String*/) -> Void)?
    var showStopButton: (() -> Void)?
    var updateEndpoint: (() -> Void)?
    var showStoppedRecording: (() -> Void)?
    var updateRanking: ((/*_ addition:String*/) -> Void)?
    var updateSpeedLabel: ((/*_ addition:String*/) -> Void)?
    var updateRankingLabel: ((/*_ addition:String*/) -> Void)?


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
        
        print(UserDefaults.standard.object(forKey:"ip") as? String ?? "not found" + "\n\n\n\n\n\n\n\n\n\n\n\n\n\n")
                
        
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
        
        socket.on("randomKey") { dataArray, ack in
            let randomKey = dataArray[0] as? Int ?? 0
            print("JOINING WITH RANDOM KEY " + String(randomKey))
            SocketIOManager.getInstance.joinRaceShow?(randomKey)
        }
        
        socket.on("youJoinedRace") { dataArray, ack in
            SocketIOManager.getInstance.inRace = true;
            let joinState = dataArray[0] as? String ?? ""
            let usersCSV = dataArray[1] as? String ?? ""
            
            if(joinState == "join"){
                SocketIOManager.getInstance.showMemberVC?()
            }else{
                SocketIOManager.getInstance.showHostVC?()
                SocketIOManager.getInstance.amHost = true
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
            SocketIOManager.getInstance.amHost = true
            if(!SocketIOManager.getInstance.raceOn){
                SocketIOManager.getInstance.showHostVC?()
                SocketIOManager.getInstance.updateIdLabel?()
            }
            SocketIOManager.getInstance.newHost?()
        }
         
        
        socket.on("startRace"){ dataArray, ack in
            SocketIOManager.getInstance.showRaceVC?()
            SocketIOManager.getInstance.raceOn = true
            LocationManager.getInstance.start()
            SocketIOManager.getInstance.raceLoop()
            if  SocketIOManager.getInstance.timer == nil {
                SocketIOManager.getInstance.timer = Timer.scheduledTimer(timeInterval: SocketIOManager.getInstance.raceTimeInterval, target: SocketIOManager.getInstance, selector: #selector(SocketIOManager.getInstance.raceLoop), userInfo: nil, repeats: true)
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
            SocketIOManager.getInstance.stopRecording()
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
            
            if(SocketIOManager.getInstance.positions[user] == nil){
                SocketIOManager.getInstance.positions[user] = [CLLocationCoordinate2D]()
            }
            
//            if(SocketIOManager.getInstance.positions[user]!.count > 1){
//                let lastLocation = CLLocation(latitude: SocketIOManager.getInstance.positions[user]!.last!.latitude, longitude: SocketIOManager.getInstance.positions[user]!.last!.longitude)
//                var totalDist = SocketIOManager.getInstance.distances[user] ?? 0
//                totalDist += ((LocationManager.getInstance.getLocation()?.distance(from: lastLocation))!)
//                SocketIOManager.getInstance.distances[user] = totalDist
//            }else{
//                SocketIOManager.getInstance.distances[user] = 0
//            }
            
            var curpos = SocketIOManager.getInstance.positions[user] ?? [CLLocationCoordinate2D]()
            curpos.append(location)
            
            SocketIOManager.getInstance.positions[user] = curpos
            
            
            
            
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
        
        socket.on("updatePositionLabels"){ dataArray, ack in
            SocketIOManager.getInstance.updatePositionsLabel?()
            let usersCSV = (dataArray[0] as? String ?? "")
            let distancesCSV = (dataArray[1] as? String ?? "")
            
            let usersArr = usersCSV.components(separatedBy: ",")
            let distancesArr = distancesCSV.components(separatedBy: ",")
            
            var countA = 0
            for userA in usersArr{
                SocketIOManager.getInstance.distances[userA] = Double(distancesArr[countA])
                countA += 1
            }
            
            var countD = 0
            for(user, _) in ((SocketIOManager.getInstance.distances.sorted { $0.1 < $1.1 }).reversed()){
                if(user == String(SocketIOManager.getInstance.id)){
                    break;
                }
                countD += 1
            }
            
            SocketIOManager.getInstance.rank = countD
            
            SocketIOManager.getInstance.updateRanking?()
            SocketIOManager.getInstance.updateRankingLabel?()
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
    
    func joinRandomRace(){
        socket.emit("joinRandomRace")
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
        SocketIOManager.getInstance.stopTimer()
        SocketIOManager.getInstance.inRace = false
        SocketIOManager.getInstance.amHost = false
        SocketIOManager.getInstance.id = nil
        SocketIOManager.getInstance.users = [String]()
        SocketIOManager.getInstance.userNames = [String: String]()
        SocketIOManager.getInstance.joinIndex = nil
        SocketIOManager.getInstance.userId = nil
        SocketIOManager.getInstance.positions = [String: [CLLocationCoordinate2D]]()
        SocketIOManager.getInstance.distances = [String: Double]()
        SocketIOManager.getInstance.endpoint = nil
        SocketIOManager.getInstance.endpointDistance = 0.0
        SocketIOManager.getInstance.time = 0
        SocketIOManager.getInstance.speed = 0.0
        SocketIOManager.getInstance.rank = 0
        SocketIOManager.getInstance.raceTimeInterval = 2.5
    }
    
    @objc func raceLoop(){
        print("raceLoop")
        let location = LocationManager.getInstance.getLocation()
        if(location != nil){
            let position = String(location!.coordinate.latitude) + "," +  String(location!.coordinate.longitude)//Int.random(in: 1...20)
            let sendData = [(position), SocketIOManager.getInstance.id as Any] as [Any]
            
            var curpos = SocketIOManager.getInstance.positions[SocketIOManager.getInstance.userId] ?? [CLLocationCoordinate2D]()
            curpos.append(location!.coordinate)
            
            if(SocketIOManager.getInstance.positions[SocketIOManager.getInstance.userId] == nil){
                SocketIOManager.getInstance.positions[SocketIOManager.getInstance.userId] = [CLLocationCoordinate2D]()
            }
            
            if(SocketIOManager.getInstance.positions[SocketIOManager.getInstance.userId]!.count > 1){
                let lastLocation = CLLocation(latitude:
                SocketIOManager.getInstance.positions[SocketIOManager.getInstance.userId]!.last!.latitude, longitude: SocketIOManager.getInstance.positions[SocketIOManager.getInstance.userId]!.last!.longitude)
                var recentDist = SocketIOManager.getInstance.distances[SocketIOManager.getInstance.userId] ?? 0
                recentDist = ((LocationManager.getInstance.getLocation()?.distance(from: lastLocation))!)
                
                let mps = recentDist/SocketIOManager.getInstance.raceTimeInterval
                let mph = mps * 2.237
                
                SocketIOManager.getInstance.speed = mph.truncate(places: 2)
                
                SocketIOManager.getInstance.updateSpeedLabel?()
                
                let distSendData = [(recentDist), SocketIOManager.getInstance.id as Any] as [Any]
                SocketIOManager.getInstance.socket.emit("distanceUpdate", distSendData)
            }

//            if(SocketIOManager.getInstance.positions[SocketIOManager.getInstance.userId]!.count > 1){
//                let lastLocation = CLLocation(latitude:
//                    SocketIOManager.getInstance.positions[SocketIOManager.getInstance.userId]!.last!.latitude, longitude: SocketIOManager.getInstance.positions[SocketIOManager.getInstance.userId]!.last!.longitude)
//                var totalDist = SocketIOManager.getInstance.distances[SocketIOManager.getInstance.userId] ?? 0
//                totalDist += ((LocationManager.getInstance.getLocation()?.distance(from: lastLocation))!)
//                SocketIOManager.getInstance.distances[SocketIOManager.getInstance.userId] = totalDist
//
//            }else{
//                SocketIOManager.getInstance.distances[SocketIOManager.getInstance.userId] = 0
//
//            }
            
            SocketIOManager.getInstance.positions[SocketIOManager.getInstance.userId] = curpos

            SocketIOManager.getInstance.socket.emit("positionUpdate", sendData)
            
//            let curPos = SocketIOManager.getInstance.positions["you"] ?? 0
//            let totalPos = curPos + Int(position)
            
//            SocketIOManager.getInstance.positions["you"] = totalPos
            SocketIOManager.getInstance.updateEndpoint?()
        }else{
            print("location nil")
        }
        
        if(!SocketIOManager.getInstance.raceOn){
            SocketIOManager.getInstance.stopTimer()
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
        SocketIOManager.getInstance.stopTimer()
        SocketIOManager.getInstance.showConnectingVC?()
    }
    
    func testU(){
        SocketIOManager.getInstance.updateUsersLabel?()
    }
}

extension Double
{
    func truncate(places : Int)-> Double
    {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
