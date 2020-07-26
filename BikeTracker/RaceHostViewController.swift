//
//  RaceHostViewController.swift
//  BikeTracker
//
//  Created by Sanjith Udupa on 6/24/20.
//  Copyright © 2020 Sanjith Udupa. All rights reserved.
//

import UIKit

class RaceHostViewController: UIViewController {

    @IBOutlet weak var RaceID: UILabel!
    @IBOutlet weak var RaceUsers: UILabel!
    @IBOutlet weak var Created: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SocketIOManager.getInstance.showRaceVC = showRaceVC
        SocketIOManager.getInstance.updateUsersLabel = updateUserLabel
        SocketIOManager.getInstance.updateIdLabel = updateIDLabel
        SocketIOManager.getInstance.showHomeVC = showHomeVC
        SocketIOManager.getInstance.showConnectingVC = showConnectingVC
        SocketIOManager.getInstance.newHost = newHost
    }
    
    @IBAction func StartRacePressed(_ sender: Any) {
//        if(SocketIOManager.getInstance.users.count > 2){
        let alert = UIAlertController(title: "Set an endpoint", message: "Can be left blank", preferredStyle: .alert)
        
        var endpointField:UITextField!
        
//        FOR ADDING MAP:
//        let margin:CGFloat = 10.0
//        let rect = CGRect(x: margin, y: margin, width: alert.view.bounds.size.width - margin * 4.0, height: 120)
//        let customView = UIView(frame: rect)
//
//        customView.backgroundColor = .green
//        alert.view.addSubview(customView)
        
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Endpoint"
            endpointField = textField
        }
        alert.addAction(UIAlertAction(title: "Done", style: .cancel){ (action:UIAlertAction!) in
            let endpoint = Int(endpointField.text ?? "")
            if(endpoint != nil){
                SocketIOManager.getInstance.endpoint = endpoint
                SocketIOManager.getInstance.setEndpoint()
            }else{
                SocketIOManager.getInstance.endpoint = nil
            }
            SocketIOManager.getInstance.startRace()
        })

        self.present(alert, animated: true)
        
//        }else{
//            oneUserRace()
//        }
    }
    
    @IBAction func LeaveRacePressed(_ sender: Any) {
        SocketIOManager.getInstance.leaveRace()
        showHomeVC()
        SocketIOManager.getInstance.inRace = false
    }
    
    func updateUserLabel(){
//        let users = String(SocketIOManager.getInstance.users.joined(separator:"\n"))
        let users = String(SocketIOManager.getInstance.userNames.values.joined(separator:"\n"))
//        let boolIndex = users[users.startIndex] == "f" ? users.count - 5 : users.count - 4
        RaceUsers.text = "Users:\n" + users
    }
    
    func updateIDLabel(){
        RaceID.text = String(SocketIOManager.getInstance.id)
    }
    
    func showHomeVC(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

        let homeVC = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController

        self.present(homeVC, animated:true, completion:nil)
    }
    
    func newHost(){
        Created.text = "You Host Race:"
        let alert = UIAlertController(title: "Host Left", message: "You are the new race host", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alert, animated: true)
        
    }
    
//    func oneUserRace(){
//        let alert = UIAlertController(title: "Get more racers", message: "You can't start an online race with one person!", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
//        self.present(alert, animated: true)
//
//    }
    
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
