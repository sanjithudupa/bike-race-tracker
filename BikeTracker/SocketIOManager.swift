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
    
    override init() {
        socket = manager.defaultSocket
        
        socket.on("youConnected") { dataArray, ack in
            SocketIOManager.getInstance.sendConnect(long : 253, lat : 351)
        }
        
        
        super.init()
    }
    
    func connect() { socket.connect(timeoutAfter: 0, withHandler: { print("could not connect") }) }
     
    func disconnect() { socket.disconnect() }
    
    func sendConnect(long: Int, lat : Int) {
        let coord = [long, lat]
        socket.emit("sendConnect", coord)
    }
    
    func JoinRace(id: Int){
        socket.emit("joinRace", id)
    }

}
