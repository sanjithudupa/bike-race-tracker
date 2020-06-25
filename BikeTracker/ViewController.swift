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
        SocketIOManager.getInstance.showHostVC = showHostVC
        SocketIOManager.getInstance.showMemberVC = showMemberVC

    }
    
    @IBAction func JoinRace(_ sender: Any) {
        let id = (raceID.text ?? "").filter("0123456789.".contains)
        if(id != ""){
            SocketIOManager.getInstance.JoinRace(id: Int(id) ?? 0)
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
    
    
}

