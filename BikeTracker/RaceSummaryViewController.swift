//
//  RaceSummaryViewController.swift
//  BikeTracker
//
//  Created by Sanjith Udupa on 6/28/20.
//  Copyright © 2020 Sanjith Udupa. All rights reserved.
//

import UIKit

class RaceSummaryViewController: UIViewController {

    @IBOutlet weak var RaceResults: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SocketIOManager.getInstance.fillRaceSummary = fillRaceSummary
        SocketIOManager.getInstance.showConnectingVC = showConnectingVC
    }
    
    func fillRaceSummary(){
        var count = 1
        RaceResults.text = ""
        print(SocketIOManager.getInstance.positions)
//        for (user, _) in SocketIOManager.getInstance.positions.sorted(by: {$0.value > $1.value}){
//            if(user == "you"){
//                RaceResults.text! += String(count) + ". you\n"
//            }else{
//                guard(SocketIOManager.getInstance.userNames[user] != nil) else{continue}
//                RaceResults.text! += String(count) + ". " + SocketIOManager.getInstance.userNames[user]! + "\n"
//            }
//            count += 1
//        }
//        print(RaceResults.text)
        
//        print("summ " + RaceResults.text + " should be " + raceSummary)
    }
    
    @IBAction func DoneButtonPressed(_ sender: Any) {
        SocketIOManager.getInstance.inRace = false
        SocketIOManager.getInstance.leaveRace()
        showHomeVC()
    }
    
    
    func showHomeVC(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

        let homeVC = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController

        self.present(homeVC, animated:true, completion:nil)
    }
    
    func showConnectingVC(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

        let connectingVC = storyBoard.instantiateViewController(withIdentifier: "ConnectingViewController") as! ConnectingViewController
        connectingVC.dismiss = true
        self.present(connectingVC, animated:true, completion:nil)
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
