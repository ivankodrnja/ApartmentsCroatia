//
//  HouseTableViewCell.swift
//  Apartments Croatia
//
//  Created by Ivan Kodrnja on 15/07/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import UIKit

class HouseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var houseMainImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var toTheSeaLabel: UILabel!
    @IBOutlet weak var toTheSeaDistance: UILabel!
    @IBOutlet weak var toTheCenterLabel: UILabel!
    @IBOutlet weak var toTheCenterDistance: UILabel!
    @IBOutlet weak var dailyFromLabel: UILabel!
    @IBOutlet weak var dailyFromPrice: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}