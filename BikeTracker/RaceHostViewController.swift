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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SocketIOManager.getInstance.updateUsersLabel = updateUserLabel
        SocketIOManager.getInstance.updateIdLabel = updateIDLabel
        SocketIOManager.getInstance.showHomeVC = showHomeVC
        SocketIOManager.getInstance.newHost = newHost
    }
    
    
    
    func updateUserLabel(){
        let users = String(SocketIOManager.getInstance.users.joined(separator:"\n"))
        let boolIndex = users[users.startIndex] == "f" ? users.count - 5 : users.count - 4
        RaceUsers.text = "Users:" + users.suffix(boolIndex)
    }
    
    func updateIDLabel(){
        RaceID.text = String(SocketIOManager.getInstance.id)
    }
    
    func showHomeVC(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

        let homeVC = storyBoard.instantiateViewController(withIdentifier: "ViewC") as! ViewController

        self.present(homeVC, animated:true, completion:nil)
    }
    
    func newHost(){
        let alert = UIAlertController(title: "Host Left", message: "You are the new race host", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    
    @IBAction func StartRacePressed(_ sender: Any) {
        SocketIOManager.getInstance.startRace()
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
