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
    }
    
    func updateUserLabel(){
        RaceUsers.text = "Users: " + SocketIOManager.getInstance.users.joined(separator:"\n")
    }
    
    func updateIDLabel(){
        RaceID.text = String(SocketIOManager.getInstance.id)
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
