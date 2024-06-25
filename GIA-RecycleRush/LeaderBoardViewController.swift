//
//  LeaderBoardViewController.swift
//  GIA-RecycleRush
//
//  Created by Akhil Raju on 6/24/24.
// used this page for the orange view - mihir

import UIKit
import FirebaseAuth
class LeaderBoardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var players: [Player] = [
            Player(name: "Alice", score: 120),
            Player(name: "Bob", score: 150),
            Player(name: "Charlie", score: 90)
        ]
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardCell", for: indexPath)
                let player = players[indexPath.row]
                cell.textLabel?.text = "\(player.name) - \(player.score)"
                return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser != nil {
            
          return
        } else {
            navigateToHomePage()
           
        }
        tableView.dataSource = self
                tableView.delegate = self
                players.sort { $0.score > $1.score }
    }
    func navigateToHomePage() {
        performSegue(withIdentifier: "account", sender: nil)
    }


    
}
