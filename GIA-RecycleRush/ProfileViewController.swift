//
//  ProfileViewController.swift
//  GIA-RecycleRush
//
//  Created by Akhil Raju on 6/26/24.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class ProfileViewController: UIViewController {

    let database = Database.database().reference()
    let userID = Auth.auth().currentUser?.uid
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var totalRecycledLabel: UILabel!
    @IBOutlet weak var totalCansLabel: UILabel!
    @IBOutlet weak var totalBottlesLabel: UILabel!
    @IBOutlet weak var totalPaperLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var logoutButton: UIButton!
    
    var activityIndicator: UIActivityIndicatorView! // Activity indicator
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        setupActivityIndicator()
        database.child(userID!).observe(DataEventType.value) { [self] snapshot in
            
            let value = snapshot.value as? NSDictionary
            let name = value?["name"] as? String ?? ""
            let totalRecycled = value?["totalRecycled"] as? Int ?? 0
            let totalCans = value?["totalCans"] as? Int ?? 0
            let totalBottles = value?["totalBottles"] as? Int ?? 0
            let totalPaperProduct = value?["totalPaperProduct"] as? Int ?? 0
                
            nameLabel.text = "Howdy \(name)!"
            totalRecycledLabel.text = "Total Recycled: \(totalRecycled)"
            totalCansLabel.text = "Total Cans Recycled: \(totalCans)"
            totalBottlesLabel.text = "Total Bottles Recycled \(totalBottles)"
            totalPaperLabel.text = "Total Paper Products Recycled: \(totalPaperProduct)"
            
        }
        fetchProfileImage()
        logoutButton.isHidden = true

        // Add tap gesture recognizer to the image view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
    }

    @objc func imageViewTapped() {
        // Show the logout button when image view is tapped
        if logoutButton.isHidden == true {
            logoutButton.isHidden = false
        } else if logoutButton.isHidden == false {
            logoutButton.isHidden = true
        }
    }
    
    @IBAction func Logout(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            performSegue(withIdentifier: "logout", sender: nil)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            let alertController = UIAlertController(title: "Error", message: signOutError.localizedDescription, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) {
                (action: UIAlertAction!) in
                print("Ok button tapped");
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
        }
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
    
    func fetchProfileImage() {
        guard let user = Auth.auth().currentUser else { return }
        let databaseRef = Database.database().reference().child(user.uid)

        // Show activity indicator and reduce image view opacity while fetching image
        activityIndicator.startAnimating()
        imageView.alpha = 0.5
        
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
                self.activityIndicator.stopAnimating() // Stop activity indicator when image is downloaded
                self.imageView.alpha = 1.0 
            }
        }.resume()
    }
    
    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }
}
