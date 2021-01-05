//
//  BeeTableViewCell.swift
//  BeeKit
//
//  Created by flqy on 2021/1/5.
//

import UIKit

class BeeTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func cellReuseIdentifier() -> String {
        return NSStringFromClass(BeeTableViewCell.classForCoder())
    }

}
