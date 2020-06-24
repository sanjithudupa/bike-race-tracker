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
}

