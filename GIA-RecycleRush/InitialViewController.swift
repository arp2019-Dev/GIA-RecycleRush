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
        
//        print(Auth.auth().currentUser?.uid as Any)
 
        if Auth.auth().currentUser?.uid != nil {
            performSegue(withIdentifier: "home", sender: self)
                
            } else {
                
                return
            }
        }


}
