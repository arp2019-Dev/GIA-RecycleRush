//
//  NewEntryViewController.swift
//  GIA-RecycleRush
//
//  Created by Akhil Raju on 6/25/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import CoreML
import Vision

class NewEntryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let database = Database.database().reference()
    let userID = Auth.auth().currentUser?.uid
    //new entry inputs
    @IBOutlet weak var CansTextField: UITextField!
    @IBOutlet weak var BottlesTextField: UITextField!
    @IBOutlet weak var PaperTextField: UITextField!
    var activityIndicator: UIActivityIndicatorView!
    
    var cansUpdated = false
    var bottlesUpdated = false
    var paperUpdated = false
    
    // Property to store the last analyzed image
    var lastAnalyzedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        // Setup activity indicator
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .gray
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    @IBAction func AddNewEntryButton(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera  // camera for live capture
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        activityIndicator.startAnimating()
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let image = info[.originalImage] as? UIImage {
                let resizedImage = self.resize(image: image, targetSize: CGSize(width: 300, height: 300))
                self.lastAnalyzedImage = resizedImage
                self.analyzeImage(image: resizedImage) { isTrash, error in
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        
                        if let error = error {
                            self.showAlert(title: "Error", message: error.localizedDescription)
                        } else if isTrash {
                            self.processNewEntry()
                        } else {
                            self.showNotTrashAlert()
                        }
                    }
                }
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func resize(image: UIImage, targetSize: CGSize) -> UIImage { //image processing 
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        let newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(origin: .zero, size: newSize)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? UIImage()
    }
    
    func analyzeImage(image: UIImage, completion: @escaping (Bool, Error?) -> Void) { //analyze if image has trash
        guard let ciImage = CIImage(image: image) else {
            completion(false, NSError(domain: "ImageAnalysisError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Couldn't convert UIImage to CIImage"]))
            return
        }
        
        guard let model = try? VNCoreMLModel(for: TrashClassifier().model) else {
            completion(false, NSError(domain: "ImageAnalysisError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Couldn't load ML model"]))
            return
        }
        
        let request = VNCoreMLRequest(model: model) { [weak self] (request, error) in
            guard let results = request.results as? [VNClassificationObservation],
                  let firstResult = results.first else {
                completion(false, NSError(domain: "ImageAnalysisError", code: -3, userInfo: [NSLocalizedDescriptionKey: "No results found"]))
                return
            }
            
            // Map "Unlabeled" to "no-trash"
            let isTrash = firstResult.identifier == "trash"
            completion(isTrash, nil)
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                completion(false, error)
            }
        }
    }
    
    private func processNewEntry() { //submits entry if ml detection works
        guard let image = lastAnalyzedImage else {
            showAlert(title: "Error", message: "No image to process")
            return
        }
        
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
        // Check if any of the updates are true, not really all
        if cansUpdated || bottlesUpdated || paperUpdated {
            updateTotalRecycled()
        }
    }
    
    func updateCans(_ newCansAddInt: Int, completion: @escaping () -> Void) { //updating recycling values for cans
        database.child(userID!).observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let self = self else { return }
            
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
                        completion()
                    }
                }
            }
        })
    }
    
    func updateBottles(_ newBottlesAddInt: Int, completion: @escaping () -> Void) { //updating recycling values for bottles
        database.child(userID!).observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let self = self else { return }
            
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
                        completion()
                    }
                }
            }
        })
    }
    
    func updatePaper(_ newPaperAddInt: Int, completion: @escaping () -> Void) { //updating recycling values for paper products
        database.child(userID!).observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let self = self else { return }
            
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
                        completion() 
                    }
                }
            }
        })
    }
    
    func updateTotalRecycled() { //update total
        database.child(userID!).observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let self = self else { return }
            
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
                        self.showSuccessAlert()
                    }
                }
            }
        })
    }
    
    func showSuccessAlert() { //recycling detected
        let alert = UIAlertController(title: "Success", message: "Your recycling entry has been recorded.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showNotTrashAlert() { //recycling not detected in image
        let alert = UIAlertController(title: "Entry Denied", message: "No trash detected in the uploaded image. Please upload a valid image.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}



