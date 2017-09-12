//
//  DestinationTableViewCell.swift
//  Apartments Croatia
//
//  Created by Ivan Kodrnja on 19/05/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import UIKit

class DestinationTableViewCell: UITableViewCell {

    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var firstLetterLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
