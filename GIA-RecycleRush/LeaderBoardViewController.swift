//
//  LeaderBoardViewController.swift
//  GIA-RecycleRush
//
//  Created by Akhil Raju on 6/24/24.
//

import UIKit
import FirebaseAuth
class LeaderBoardViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser != nil {
            
          return
        } else {
            navigateToHomePage()
           
        }
    }
    func navigateToHomePage() {
        performSegue(withIdentifier: "account", sender: nil)
    }


    
}
