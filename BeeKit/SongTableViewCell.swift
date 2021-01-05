//
//  SongTableViewCell.swift
//  BeeKit
//
//  Created by flqy on 2021/1/5.
//

import UIKit

class SongTableViewCell: BeeTableViewCell {

    static let cellReuseIdentifier = "SongTableViewCell"
    
    @IBOutlet weak var artworImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
