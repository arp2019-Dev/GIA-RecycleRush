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
        
        // Add an auth state listener
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else { return }
            if user != nil {
                // Perform segue on the main thread
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "home", sender: self)
                }
            } else {
                // Handle the case where there is no user logged in
                print("No user logged in")
            }
        }
    }
}
