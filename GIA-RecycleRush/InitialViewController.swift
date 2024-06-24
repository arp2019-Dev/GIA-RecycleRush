//
//  InitialViewController.swift
//  GIA-RecycleRush
//
//  Created by Akhil Raju on 6/23/24.
//

import UIKit
import Firebase
import FirebaseAuth

class InitialViewController: UIViewController {
   
    let databaseRef = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
            if Auth.auth().currentUser != nil {
                
                navigateToHomePage()
            } else {
                
                return
            }
        }
        func navigateToHomePage() {
            performSegue(withIdentifier: "home", sender: nil)
        }

}
