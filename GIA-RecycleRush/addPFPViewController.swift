//
//  addPFPViewController.swift
//  GIA-RecycleRush
//
//  Created by Akhil Raju on 6/26/24.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class addPFPViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator = UIActivityIndicatorView(style: .medium)
               activityIndicator.translatesAutoresizingMaskIntoConstraints = false
               activityIndicator.hidesWhenStopped = true
               view.addSubview(activityIndicator)

               // Center the activity indicator
               NSLayoutConstraint.activate([
                   activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                   activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
               ])
        
        fetchProfileImage()
        // Configure imageView for circular cropping
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
    }
    override func viewWillDisappear(_ animated: Bool) {
           super.viewWillDisappear(animated)
           // Ensure activity indicator stops when leaving the view controller
           activityIndicator.stopAnimating()
       }
    
    @IBAction func NextButton(_ sender: Any) {
        activityIndicator.startAnimating()

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

