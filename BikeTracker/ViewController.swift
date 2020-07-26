//
//  ViewController.swift
//  BikeTracker
//
//  Created by Sanjith Udupa on 6/22/20.
//  Copyright © 2020 Sanjith Udupa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var raceID: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("UserLoggedIn"), object: nil)
        
        if(!SocketIOManager.getInstance.isConnected){
            
            SocketIOManager.getInstance.tryToConnect()
        }else{
            hideConnectingView()
        }
        SocketIOManager.getInstance.showHostVC = showHostVC
        SocketIOManager.getInstance.showMemberVC = showMemberVC
        SocketIOManager.getInstance.showHomeVC = blank
        SocketIOManager.getInstance.raceAlreadyStarted = raceAlreadyStarted
        SocketIOManager.getInstance.hideConnectingView = hideConnectingView
        SocketIOManager.getInstance.disconnected = disconnected
        SocketIOManager.getInstance.showConnectingVC = showConnectingVC

    }
    
    @IBAction func JoinRace(_ sender: Any) {
        let id = (raceID.text ?? "").filter("0123456789.".contains)
        if(id != ""){
            SocketIOManager.getInstance.joinRace(id: Int(id) ?? 0)
        }else{
            let alert = UIAlertController(title: "Fill in inputs", message: "Inputs can't be empty", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    func showHostVC(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

        let hostVC = storyBoard.instantiateViewController(withIdentifier: "RaceHostViewController") as! RaceHostViewController

        self.present(hostVC, animated:true, completion:nil)
    }
    
    func showMemberVC(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

        let memberVC = storyBoard.instantiateViewController(withIdentifier: "RaceMemberViewController") as! RaceMemberViewController

        self.present(memberVC, animated:true, completion:nil)
    }
    
    func blank(){}
    
    func raceAlreadyStarted(){
        let alert = UIAlertController(title: "Couldn't Join Race", message: "Race already started", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func disconnected(){
        let alert = UIAlertController(title: "Disconnected", message: "You were disconnected from the server", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    
    func hideConnectingView(){
        SocketIOManager.getInstance.isConnected = true
    }
    
    func showConnectingVC(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

        let connectingVC = storyBoard.instantiateViewController(withIdentifier: "ConnectingViewController") as! ConnectingViewController
        connectingVC.dismiss = false
        self.present(connectingVC, animated:true, completion:nil)
    }
}

