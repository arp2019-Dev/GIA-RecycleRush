//
//  NewEntryViewController.swift
//  GIA-RecycleRush
//
//  Created by Akhil Raju on 6/25/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class NewEntryViewController: UIViewController {

    let database = Database.database().reference()
    let userID = Auth.auth().currentUser?.uid
    
    @IBOutlet weak var CansTextField: UITextField!
    @IBOutlet weak var BottlesTextField: UITextField!
    @IBOutlet weak var PaperTextField: UITextField!
    
    var cansUpdated = false
    var bottlesUpdated = false
    var paperUpdated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        // Fetch initial data or observe changes as needed
        database.child(userID!).observe(DataEventType.value) { [self] snapshot in
            let value = snapshot.value as? NSDictionary
            let name = value?["name"] as? String ?? ""
            let totalRecycled = value?["totalRecycled"] as? Int
            let totalCans = value?["totalCans"] as? Int
            let totalBottles = value?["totalBottles"] as? Int
            let totalPaperProduct = value?["totalPaperProduct"] as? Int
        }
    }
    
    @IBAction func AddNewEntryButton(_ sender: Any) {
        let newCansAdd = CansTextField.text!
        let newBottlesAdd = BottlesTextField.text!
        let newPaperProductsAdd = PaperTextField.text!
        
        if let newCansAddInt = Int(newCansAdd) {
            updateCans(newCansAddInt) {
                self.cansUpdated = true
                self.checkAndUpdateTotal()
            }
        }
        
        if let newBottlesAddInt = Int(newBottlesAdd) {
            updateBottles(newBottlesAddInt) {
                self.bottlesUpdated = true
                self.checkAndUpdateTotal()
            }
        }
        
        if let newPaperAddInt = Int(newPaperProductsAdd) {
            updatePaper(newPaperAddInt) {
                self.paperUpdated = true
                self.checkAndUpdateTotal()
            }
        }
    }
    
    private func checkAndUpdateTotal() {
        // Check if any of the updates are true, not necessarily all
        if cansUpdated || bottlesUpdated || paperUpdated {
            updateTotalRecycled()
            showAlert()
        }
    }
    
    func updateCans(_ newCansAddInt: Int, completion: @escaping () -> Void) {
        database.child(userID!).observeSingleEvent(of: .value, with: { snapshot in
            if let value = snapshot.value as? NSDictionary {
                let totalCans = value["totalCans"] as? Int ?? 0
                let newCans = totalCans + newCansAddInt
                
                let totalCansData: [String: Any] = [
                    "totalCans": newCans
                ]
                
                self.database.child(self.userID!).updateChildValues(totalCansData) { (error, ref) in
                    if let error = error {
                        print("Error updating cans: \(error.localizedDescription)")
                    } else {
                        self.CansTextField.text = ""
                        print("Cans updated")
                        completion() // Call completion handler
                    }
                }
            }
        })
    }
    
    func updateBottles(_ newBottlesAddInt: Int, completion: @escaping () -> Void) {
        database.child(userID!).observeSingleEvent(of: .value, with: { snapshot in
            if let value = snapshot.value as? NSDictionary {
                let totalBottles = value["totalBottles"] as? Int ?? 0
                let newBottles = totalBottles + newBottlesAddInt
                
                let totalBottlesData: [String: Any] = [
                    "totalBottles": newBottles
                ]
                
                self.database.child(self.userID!).updateChildValues(totalBottlesData) { (error, ref) in
                    if let error = error {
                        print("Error updating bottles: \(error.localizedDescription)")
                    } else {
                        self.BottlesTextField.text = ""
                        print("Bottles updated")
                        completion() // Call completion handler
                    }
                }
            }
        })
    }
    
    func updatePaper(_ newPaperAddInt: Int, completion: @escaping () -> Void) {
        database.child(userID!).observeSingleEvent(of: .value, with: { snapshot in
            if let value = snapshot.value as? NSDictionary {
                let totalPaperProduct = value["totalPaperProduct"] as? Int ?? 0
                let newPaper = totalPaperProduct + newPaperAddInt
                
                let totalPaperData: [String: Any] = [
                    "totalPaperProduct": newPaper
                ]
                
                self.database.child(self.userID!).updateChildValues(totalPaperData) { (error, ref) in
                    if let error = error {
                        print("Error updating paper: \(error.localizedDescription)")
                    } else {
                        self.PaperTextField.text = ""
                        print("Paper updated")
                        completion() // Call completion handler
                    }
                }
            }
        })
    }
    
    func updateTotalRecycled() {
        database.child(userID!).observeSingleEvent(of: .value, with: { snapshot in
            if let value = snapshot.value as? NSDictionary {
                let totalCans = value["totalCans"] as? Int ?? 0
                let totalBottles = value["totalBottles"] as? Int ?? 0
                let totalPaperProduct = value["totalPaperProduct"] as? Int ?? 0
                let newTotalRecycled = totalCans + totalBottles + totalPaperProduct
                
                let totalTotalData: [String: Any] = [
                    "totalRecycled": newTotalRecycled
                ]
                
                self.database.child(self.userID!).updateChildValues(totalTotalData) { (error, ref) in
                    if let error = error {
                        print("Error updating total recycled: \(error.localizedDescription)")
                    } else {
                        print("Total recycled updated")
                    }
                }
            }
        })
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "New Entry Added", message: "Your recycling entry has been recorded.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
