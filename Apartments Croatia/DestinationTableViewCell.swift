//
//  DestinationTableViewCell.swift
//  Apartments Croatia
//
//  Created by Ivan Kodrnja on 19/05/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import UIKit

class DestinationTableViewCell: UITableViewCell {

    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var active: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var centerDistance: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var favorite: UILabel!
    @IBOutlet weak var houseid: UILabel!
    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var longitude: UILabel!
    @IBOutlet weak var parking: UILabel!
    @IBOutlet weak var pets: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var priceFrom: UILabel!
    @IBOutlet weak var seaDistance: UILabel!
    @IBOutlet weak var statusID: UILabel!
    @IBOutlet weak var website: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
