//
//  LeaderboardCell.swift
//  GIA-RecycleRush
//
//  Created by Akhil Raju on 6/25/24.
//

import UIKit
// sets view cell settings for the leaderboard
class LeaderboardCell: UICollectionViewCell {
// adds in the data into the collection view
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var trophyImageView: UIImageView!
    @IBOutlet weak var numberRecycled: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = .clear
    }
}

