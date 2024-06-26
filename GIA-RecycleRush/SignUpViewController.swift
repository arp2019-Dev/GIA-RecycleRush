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
        
        fetchProfileImage()
        // Configure imageView for circular cropping
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
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
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var uploadButton: UIButton!

    @IBAction func uploadButtonTapped(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else { return }

        let circularImage = cropImageToCircle(selectedImage)
        imageView.image = circularImage

        guard let imageData = circularImage.jpegData(compressionQuality: 0.8) else { return }
        uploadImageToFirebase(imageData)
    }

    func cropImageToCircle(_ image: UIImage) -> UIImage {
        let minLength = min(image.size.width, image.size.height)
        let squareImage = image.cropToBounds(width: Double(minLength), height: Double(minLength))
        let imageView = UIImageView(image: squareImage)
        let layer = CAShapeLayer()
        let path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: CGSize(width: minLength, height: minLength)))
        layer.path = path.cgPath
        imageView.layer.mask = layer
        UIGraphicsBeginImageContextWithOptions(CGSize(width: minLength, height: minLength), false, image.scale)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let circularImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return circularImage
    }

    func uploadImageToFirebase(_ imageData: Data) {
        guard let user = Auth.auth().currentUser else { return }
        let storageRef = Storage.storage().reference().child(user.uid).child("profile.jpg")

        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Failed to upload image: \(error.localizedDescription)")
                return
            }

            storageRef.downloadURL { (url, error) in
                if let error = error {
                    print("Failed to get download URL: \(error.localizedDescription)")
                    return
                }

                guard let downloadURL = url else { return }
                self.saveProfileImageURL(downloadURL.absoluteString)
            }
        }
    }

    func saveProfileImageURL(_ url: String) {
        guard let user = Auth.auth().currentUser else { return }
        let databaseRef = Database.database().reference().child(user.uid)

        let userObject: [String: Any] = [
            "profileImageURL": url
        ]

        databaseRef.updateChildValues(userObject) { (error, ref) in
            if let error = error {
                print("Failed to save profile image URL: \(error.localizedDescription)")
                return
            }
            print("Successfully saved profile image URL")
            // Fetch and display the image after saving the URL
            self.fetchProfileImage()
        }
    }

    func fetchProfileImage() {
        guard let user = Auth.auth().currentUser else { return }
        let databaseRef = Database.database().reference().child(user.uid)

        databaseRef.observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? [String: AnyObject],
               let profileImageURL = value["profileImageURL"] as? String,
               let url = URL(string: profileImageURL) {
                self.downloadImage(from: url)
            }
        }
    }

    func downloadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Failed to download image: \(error.localizedDescription)")
                return
            }
            guard let data = data, let image = UIImage(data: data) else { return }
            let circularImage = self.cropImageToCircle(image)
            DispatchQueue.main.async {
                self.imageView.image = circularImage
            }
        }.resume()
    }
}

extension UIImage {
    func cropToBounds(width: Double, height: Double) -> UIImage {
        let contextImage = UIImage(cgImage: self.cgImage!)

        let contextSize: CGSize = contextImage.size

        let posX: CGFloat = (contextSize.width > contextSize.height) ? ((contextSize.width - contextSize.height) / 2) : 0
        let posY: CGFloat = (contextSize.height > contextSize.width) ? ((contextSize.height - contextSize.width) / 2) : 0

        let cgWidth: CGFloat = min(contextSize.width, contextSize.height)
        let cgHeight: CGFloat = min(contextSize.width, contextSize.height)

        let cropRect = CGRect(x: posX, y: posY, width: cgWidth, height: cgHeight)

        let imageRef: CGImage = contextImage.cgImage!.cropping(to: cropRect)!

        let image = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)

        return image
    }
        }
