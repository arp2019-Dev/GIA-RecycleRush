//
//  LeaderBoardViewController.swift
//  GIA-RecycleRush
//
//  Created by Akhil Raju on 6/24/24.
//  Used this page for the orange view - mihir

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class LeaderBoardViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    let database = Database.database().reference()
    
    var collectionData: [leaderboard] = []
    var databaseRef: DatabaseReference!
    var activityIndicator: UIActivityIndicatorView! // Activity indicator
    
    @IBOutlet var leaderboardCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        leaderboardCollectionView.backgroundColor = UIColor.white.withAlphaComponent(0.5)

        
        databaseRef = Database.database().reference()
        
        leaderboardCollectionView.dataSource = self
        leaderboardCollectionView.delegate = self
        
        // Initialize and configure activity indicator
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.transform = CGAffineTransform(scaleX: 3, y: 3) 
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        // Center the activity indicator
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Start animating the activity indicator
        activityIndicator.startAnimating()
        
        // Fetch data from Firebase
        fetchLeaderboardData()
    }
    
    private func fetchLeaderboardData() {
        databaseRef.observe(DataEventType.value) { [weak self] (snapshot: DataSnapshot) in
            guard let self = self else { return }
            
            self.collectionData.removeAll()  // Clear old data
            
            guard let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            
            for childSnapshot in dataSnapshot {
                if let leaderboardObject = self.parseChildSnapshot(childSnapshot) {
                    self.collectionData.append(leaderboardObject)
                }
            }
            
            self.sortCollectionData()

            // Stop animating the activity indicator
            self.activityIndicator.stopAnimating()
            
            // Reload collection view data
            self.leaderboardCollectionView.reloadData()
        }
    }
    
    private func sortCollectionData() {
        collectionData.sort { $0.numberRecycled > $1.numberRecycled }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        return CGSize(width: screenWidth, height: 58)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LeaderboardCell", for: indexPath) as! LeaderboardCell
        
        let object = collectionData[indexPath.item]
        cell.nameLabel.text = object.name
        let intValue = object.numberRecycled
        cell.numberRecycled.text = "TotalRecycled: " + String(intValue)
        
        // Assign trophy images based on position
        switch indexPath.item {
        case 0:
            cell.trophyImageView.image = UIImage(named: "gold_trophy.png")
        case 1:
            cell.trophyImageView.image = UIImage(named: "silver_trophy.png")
        case 2:
            cell.trophyImageView.image = UIImage(named: "bronze_trophy.png")
        default:
            cell.trophyImageView.image = UIImage(named: "blue_trophy.png")
        }
        
        return cell
    }
    
    private func parseChildSnapshot(_ snapshot: DataSnapshot) -> leaderboard? {
        guard let value = snapshot.value as? [String: Any],
              let name = value["username"] as? String,
              let recycled = value["totalRecycled"] as? Int,
              let fieldToSort = value["totalRecycled"] as? Int else {
            return nil
        }
        
        let leaderboardObject = leaderboard(name: name, numberRecycled: recycled, fieldToSort: fieldToSort)
        
        return leaderboardObject
    }
    
    struct leaderboard {
        let name: String
        let numberRecycled: Int
        let fieldToSort: Int
    }
}

