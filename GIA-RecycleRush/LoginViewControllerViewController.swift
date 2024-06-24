//
//  LoginViewControllerViewController.swift
//  GIA-RecycleRush
//
//  Created by Akhil Raju on 6/24/24.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class LoginViewControllerViewController: UIViewController {

    @IBOutlet var EmailTextField: UITextField!
    
    
    @IBOutlet var PasswordTextField: UITextField!
    
    @IBOutlet var ResetEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func LoginButton(_ sender: Any) {
        
        guard let email = EmailTextField.text
        else {return}
        
        guard let password = PasswordTextField.text
        else {return}
        
        Auth.auth().signIn(withEmail: email, password: password) { [self] firebaseResult, error in
            if let error = error {
                print(error)
                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) {
                    (action: UIAlertAction!) in
                    print("Ok button tapped");
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion: nil)
                
            }
            else {
                self.performSegue(withIdentifier: "goToNext", sender: self)
                
            }
        }
    }
    @IBAction func passwordreset(_ sender: Any) {
        
        guard let passreset = ResetEmail.text
        else {return}
        
        Auth.auth().sendPasswordReset(withEmail: passreset)
        self.performSegue(withIdentifier: "goToNext", sender: self)
        
    }
}
