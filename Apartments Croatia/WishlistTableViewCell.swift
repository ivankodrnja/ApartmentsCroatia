//
//  WishlistTableViewCell.swift
//  Apartments Croatia
//
//  Created by Ivan Kodrnja on 23/07/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import UIKit

class WishlistTableViewCell: UITableViewCell {

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var nameLabel: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
