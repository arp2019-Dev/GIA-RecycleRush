//
//  NewEntryViewController.swift
//  GIA-RecycleRush
//
//  Created by Akhil Raju on 6/25/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore
import Firebase

class NewEntryViewController: UIViewController {
    
    let database = Database.database().reference()
    let userID = Auth.auth().currentUser?.uid
    
    
    @IBOutlet weak var CansTextField: UITextField!
    
    @IBOutlet weak var BottlesTextField: UITextField!
    
    @IBOutlet weak var PaperTextField: UITextField!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
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
                updateCans(newCansAddInt)
            } else {
                return
            }
            
            if let newBottlesAddInt = Int(newBottlesAdd) {
                updateBottles(newBottlesAddInt)
            } else {
                return
            }
            
            if let newPaperAddInt = Int(newPaperProductsAdd) {
                updatePaper(newPaperAddInt)
            } else {
                return
            }
            
            updateTotalRecycled()
        }

        func updateCans(_ newCansAddInt: Int) {
            database.child(userID!).observeSingleEvent(of: .value, with: { snapshot in
                if let value = snapshot.value as? NSDictionary {
                    let totalCans = value["totalCans"] as? Int ?? 0
                    let newCans = totalCans + newCansAddInt
                    
                    let totalCansData: [String: Int] = [
                        "totalCans": newCans
                    ]
                    
                    self.database.child(self.userID!).updateChildValues(totalCansData)
                    self.CansTextField.text = ""
                    print("Cans updated")
                }
            })
        }

        func updateBottles(_ newBottlesAddInt: Int) {
            database.child(userID!).observeSingleEvent(of: .value, with: { snapshot in
                if let value = snapshot.value as? NSDictionary {
                    let totalBottles = value["totalBottles"] as? Int ?? 0
                    let newBottles = totalBottles + newBottlesAddInt
                    
                    let totalBottlesData: [String: Int] = [
                        "totalBottles": newBottles
                    ]
                    
                    self.database.child(self.userID!).updateChildValues(totalBottlesData)
                    self.BottlesTextField.text = ""
                }
            })
        }

        func updatePaper(_ newPaperAddInt: Int) {
            database.child(userID!).observeSingleEvent(of: .value, with: { snapshot in
                if let value = snapshot.value as? NSDictionary {
                    let totalPaperProduct = value["totalPaperProduct"] as? Int ?? 0
                    let newPaper = totalPaperProduct + newPaperAddInt
                    
                    let totalPaperData: [String: Int] = [
                        "totalPaperProduct": newPaper
                    ]
                    
                    self.database.child(self.userID!).updateChildValues(totalPaperData)
                    self.PaperTextField.text = ""
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
                    
                    let totalTotalData: [String: Int] = [
                        "totalRecycled": newTotalRecycled
                    ]
                    
                    self.database.child(self.userID!).updateChildValues(totalTotalData)
                }
            })
        }

}
