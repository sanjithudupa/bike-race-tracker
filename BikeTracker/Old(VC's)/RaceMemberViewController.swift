//
//  RaceMemberViewController.swift
//  BikeTracker
//
//  Created by Sanjith Udupa on 6/25/20.
//  Copyright © 2020 Sanjith Udupa. All rights reserved.
//

import UIKit

class RaceMemberViewController: UIViewController {
    
    @IBOutlet weak var RaceID: UILabel!
    @IBOutlet weak var RaceUsers: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SocketIOManager.getInstance.updateUsersLabel = updateUserLabel
        SocketIOManager.getInstance.updateIdLabel = updateIDLabel
        SocketIOManager.getInstance.showHomeVC = showHomeVC
        SocketIOManager.getInstance.showHostVC = showHostVC
        SocketIOManager.getInstance.showRaceVC = showRaceVC
        SocketIOManager.getInstance.showConnectingVC = showConnectingVC

    }
    
    @IBAction func LeaveRacePressed(_ sender: Any) {
        SocketIOManager.getInstance.leaveRace()
        showHomeVC()
        SocketIOManager.getInstance.inRace = false
    }
    
    func updateUserLabel(){
//        let users = String(SocketIOManager.getInstance.userNames.keys.joined(separator:"\n"))
        let users = String(SocketIOManager.getInstance.userNames.values.joined(separator:"\n"))
//        let boolIndex = users[users.startIndex] == "f" ? users.count - 5 : users.count - 4
        RaceUsers.text = "Users:\n" + users /*users.suffix(boolIndex)*/
    }
    
    func updateIDLabel(){
        RaceID.text = String(SocketIOManager.getInstance.id ?? 0)
    }
    
    func showHomeVC(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

        let homeVC = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController

        self.present(homeVC, animated:true, completion:nil)
    }
    
    func showHostVC(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

        let hostVC = storyBoard.instantiateViewController(withIdentifier: "RaceHostViewController") as! RaceHostViewController

        self.present(hostVC, animated:true, completion:nil)
    }
    
    func showRaceVC(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

        let raceVC = storyBoard.instantiateViewController(withIdentifier: "RaceViewController") as! RaceViewController

        self.present(raceVC, animated:true, completion:nil)
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
