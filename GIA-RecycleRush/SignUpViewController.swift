//
//  SignUpViewController.swift
//  GIA-RecycleRush
//
//  Created by Akhil Raju on 6/23/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore
import FirebaseStorage


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
class SignUpViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    
    
    let database = Database.database().reference()
    
    // account creation inputs: 
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var NameTextField: UITextField!
    
    
    
    @IBOutlet weak var EmailTextField: UITextField!
    
    @IBOutlet weak var PasswordTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let scrollView = UIScrollView(frame: view.bounds)
        
        // Add existing view as subview of the scroll view
        scrollView.addSubview(view)
        
        scrollView.backgroundColor = view.backgroundColor
        // Set content size of scroll view to match existing view's size
        scrollView.contentSize = view.bounds.size
        
        // Set the scroll view as the main view of the view controller
        view = scrollView
        
        self.hideKeyboardWhenTappedAround()
        
        
    }
    
    @IBAction func SignUpButton(_ sender: UIButton) {
        //writing to database
        
        //Auth
        guard let email = EmailTextField.text else {return}
        guard let password = PasswordTextField.text else {return}
        
        Auth.auth().createUser(withEmail: email, password: password) { [self] firebaseResult, error in
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
                
                let userID = Auth.auth().currentUser?.uid
                
                usernameTextField.delegate = self
                let username: String = usernameTextField.text!
                EmailTextField.delegate = self
                var email: String = EmailTextField.text!
                email = email.replacingOccurrences(of: ".", with: "_")
                NameTextField.delegate = self
                let name: String = NameTextField.text!
                let userData: [String: Any] = [
                    "name": name,
                    "email": email,
                    "username": username,
                ]
                
                database.child(userID!).setValue(userData)
                let userdata: [String: Int] = [
                    "totalRecycled": 0,
                ]
                
                database.child(userID!).updateChildValues(userdata)
                
                
            }
        }
    }
    
}
    
