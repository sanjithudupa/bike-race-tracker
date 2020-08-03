//
//  ConnectingViewController.swift
//  BikeTracker
//
//  Created by Sanjith Udupa on 6/30/20.
//  Copyright © 2020 Sanjith Udupa. All rights reserved.
//

import UIKit

class ConnectingViewController: UIViewController {

    @IBOutlet weak var Trying: UILabel!
    @IBOutlet weak var Loading: UIActivityIndicatorView!
    
    var dismiss = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(!SocketIOManager.getInstance.isConnected){
            Trying.text = "Trying to connect..."
            Loading.isHidden = false
            Loading.startAnimating()
            SocketIOManager.getInstance.tryToConnect()
        }else{
            hideConnectingView()
        }
        
        SocketIOManager.getInstance.hideConnectingView = hideConnectingView

    }
    
    func hideConnectingView(){
        Loading.stopAnimating()
        SocketIOManager.getInstance.isConnected = true
        showHomeVC()
        if(dismiss){
            SocketIOManager.getInstance.disconnected?()
        }
    }
    
    func showHomeVC(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

        let homeVC = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController

        self.present(homeVC, animated:true, completion:nil)
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
