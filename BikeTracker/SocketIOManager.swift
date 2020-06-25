//
//  SocketIOManager.swift
//  BikeTracker
//
//  Created by Sanjith Udupa on 6/23/20.
//  Copyright © 2020 Sanjith Udupa. All rights reserved.
//

import Foundation
import SocketIO

class SocketIOManager: NSObject {
    static let getInstance = SocketIOManager()

    let manager = SocketManager(socketURL: URL(string: "http://localhost:3000")!, config: [.log(true), .compress])
    var socket:SocketIOClient!
    
    var name:String!
    
    var id:Int!
    var users = [String]()
    
    var updateIdLabel: (() -> Void)?
    var updateUsersLabel: (() -> Void)?
    
    var showHostVC: (() -> Void)?
    var showMemberVC: (() -> Void)?
    
    override init() {
        socket = manager.defaultSocket
        
        socket.on("youConnected") { dataArray, ack in
//            SocketIOManager.getInstance.sendConnect(long : 253, lat : 351)
            SocketIOManager.getInstance.sendConnect(name: SocketIOManager.getInstance.name)

        }
        
        socket.on("youJoinedRace") { dataArray, ack in
            let joinState = dataArray[0] as? String ?? ""
            let usersCSV = dataArray[1] as? String ?? ""
            
            if(joinState == "join"){
                SocketIOManager.getInstance.showMemberVC?()
            }else{
                SocketIOManager.getInstance.showHostVC?()
            }

            SocketIOManager.getInstance.users = usersCSV.components(separatedBy: ",")
            SocketIOManager.getInstance.updateUsersLabel?()
            SocketIOManager.getInstance.updateIdLabel?()
        }
        
        socket.on("userListUpdate") { dataArray, ack in
            let usersCSV = dataArray[0] as? String ?? ""
            SocketIOManager.getInstance.users = usersCSV.components(separatedBy: ",")
            SocketIOManager.getInstance.updateUsersLabel?()
        }
        
        super.init()
    }
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func connect() { socket.connect(timeoutAfter: 0, withHandler: { print("could not connect") }) }
     
    func disconnect() { socket.disconnect() }
    
//    func sendConnect(long: Int, lat : Int) {
//        let coord = [long, lat]
//        socket.emit("sendConnect", coord)
//    }
    
    func sendConnect(name: String) {
//        let coord = [long, lat]
        socket.emit("sendConnect", name)
    }
    
    func JoinRace(id: Int){
        SocketIOManager.getInstance.id = id
        socket.emit("joinRace", id)
    }
    
    func StartRace(){
        socket.emit("startRace", SocketIOManager.getInstance.id)
    }
    
    

}
