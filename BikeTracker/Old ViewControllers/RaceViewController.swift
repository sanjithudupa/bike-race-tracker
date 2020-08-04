//
//  RaceViewController.swift
//  BikeTracker
//
//  Created by Sanjith Udupa on 6/27/20.
//  Copyright © 2020 Sanjith Udupa. All rights reserved.
//

import UIKit
import MapKit

class RaceViewController: UIViewController {

    @IBOutlet weak var Log: UILabel!
    @IBOutlet weak var EndRaceButton: UIButton!
    @IBOutlet weak var RaceLeaderLabel: UILabel!
    @IBOutlet weak var RecordingStopped: UILabel!
    @IBOutlet weak var Endpoint: UILabel!
    @IBOutlet weak var FirstPlaceLabel: UILabel!
    
    var lastHost:Bool!
    var alreadyPassed = false
     
    override func viewDidLoad() {
        super.viewDidLoad()
        RecordingStopped.isHidden = true;
        Endpoint.text = "No endpoint set"
        SocketIOManager.getInstance.updatePositionsLabel = updatePositionsLabel//(_:)
        SocketIOManager.getInstance.showStopButton = showStopButton
        SocketIOManager.getInstance.showSummaryVC = showSummaryVC
        SocketIOManager.getInstance.newHost = newHost
        SocketIOManager.getInstance.showConnectingVC = showConnectingVC
        SocketIOManager.getInstance.showHomeVC = showHomeVC
        SocketIOManager.getInstance.showStoppedRecording = showStoppedRecording
        SocketIOManager.getInstance.updateEndpoint = updateEndpoint
        SocketIOManager.getInstance.passedEndpoint = passedEndpoint
        lastHost = SocketIOManager.getInstance.users[1] == SocketIOManager.getInstance.userId
        FirstPlaceLabel.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    func updatePositionsLabel(){
//        Log.text = ""
//        print(SocketIOManager.getInstance.positions)
//        for (user, pos) in SocketIOManager.getInstance.positions{
//            guard(SocketIOManager.getInstance.userNames[user] != nil || user == "you") else{continue}
//            if(user == "you"){
//                Log.text! += "you are at " + String(pos) + "\n"
//            }else{
//                Log.text! += SocketIOManager.getInstance.userNames[user]! + " is at " + String(pos) + "\n"
//            }
//            
//        }
//        if((SocketIOManager.getInstance.positions.max { a, b in a.value < b.value })?.key ?? "you" == "you"){
//            FirstPlaceLabel.isHidden = false
//        }else{
//            FirstPlaceLabel.isHidden = true
//        }
    }
    
    func showStopButton(){
//        let bool = (SocketIOManager.getInstance.positions.max { a, b in a.value < b.value })?.key ?? "you" == "you"
        let bool = SocketIOManager.getInstance.users[1] == SocketIOManager.getInstance.userId
        if(!lastHost && bool){
            newHost()
        }
        RaceLeaderLabel.isHidden = !bool
        EndRaceButton.isHidden = !bool
        EndRaceButton.isEnabled = bool
        lastHost = bool
    }
    
    @IBAction func EndRacePressed(_ sender: Any) {
        SocketIOManager.getInstance.stopRace()
    }
    @IBAction func LeaveRacePressed(_ sender: Any) {
        let alert = UIAlertController(title: "Do you want to stop?", message: "Choose an option", preferredStyle: .alert)
        
//        if(((SocketIOManager.getInstance.positions.max { a, b in a.value < b.value })?.key ?? "you" == "you") && SocketIOManager.getInstance.endpoint == nil){
//            alert.addAction(UIAlertAction(title: "Set as Endpoint and Stop", style: .default) { (action:UIAlertAction!) in
//                if(((SocketIOManager.getInstance.positions.max { a, b in a.value < b.value })?.key ?? "you" == "you") && SocketIOManager.getInstance.endpoint == nil){
//                SocketIOManager.getInstance.endpoint = SocketIOManager.getInstance.positions["you"] ?? 0
//                SocketIOManager.getInstance.setEndpoint()
//                SocketIOManager.getInstance.stopRecording()
//                    self.alreadyPassed = true
//                    
//                }
//                
//            })
//        }else{
//            alert.addAction(UIAlertAction(title: "Stop Recording", style: .default) { (action:UIAlertAction!) in
//                SocketIOManager.getInstance.stopRecording()
//            })
//        }

        
        
        alert.addAction(UIAlertAction(title: "Leave Race", style: .default){ (action:UIAlertAction!) in
            SocketIOManager.getInstance.leaveRace()
            self.showHomeVC()
            SocketIOManager.getInstance.inRace = false
        })

        alert.addAction(UIAlertAction(title: "Nevermind", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func showSummaryVC(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

        let homeVC = storyBoard.instantiateViewController(withIdentifier: "RaceSummaryViewController") as! RaceSummaryViewController

        self.present(homeVC, animated:true, completion:nil)
    }
    
    func newHost(){
        let alert = UIAlertController(title: "Host Left", message: "You are the new race host", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alert, animated: true)
        
    }
    
    func showHomeVC(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

        let homeVC = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController

        self.present(homeVC, animated:true, completion:nil)
    }
    
    func showStoppedRecording(){
        RecordingStopped.isHidden = false;
    }
    
    func updateEndpoint(){
        guard SocketIOManager.getInstance.endpoint != nil else{ return }
        print("updating enpoint to " + SocketIOManager.getInstance.endpoint.debugDescription)
        Endpoint.text = "Endpoint set to: " + SocketIOManager.getInstance.endpoint.debugDescription
        print(alreadyPassed)
    }
    
    func showConnectingVC(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

        let connectingVC = storyBoard.instantiateViewController(withIdentifier: "ConnectingViewController") as! ConnectingViewController
        connectingVC.dismiss = true
        self.present(connectingVC, animated:true, completion:nil)
    }
    
    func passedEndpoint(){
        if(!alreadyPassed){
            let alert = UIAlertController(title: "You passed the endpoint", message: "Would you like to continue?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Stop Recording", style: .default){ (action:UIAlertAction!) in
                SocketIOManager.getInstance.stopRecording()
                self.alreadyPassed = true
            })
            alert.addAction(UIAlertAction(title: "Continue Racing", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }else{
            alreadyPassed = true
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
