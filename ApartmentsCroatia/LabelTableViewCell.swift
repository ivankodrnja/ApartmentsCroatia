//
//  LabelTableViewCell.swift
//  Apartments Croatia
//
//  Created by Ivan Kodrnja on 22/07/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import UIKit

class LabelTableViewCell: UITableViewCell {

    @IBOutlet weak var seaDistance: UILabel!
    @IBOutlet weak var centerDistance: UILabel!
    @IBOutlet weak var parking: UILabel!
    @IBOutlet weak var pets: UILabel!
    @IBOutlet weak var seaDistanceCount: UILabel!
    @IBOutlet weak var centerDistanceCount: UILabel!

    @IBOutlet weak var hasParking: UIImageView!
    @IBOutlet weak var acceptsPets: UIImageView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
