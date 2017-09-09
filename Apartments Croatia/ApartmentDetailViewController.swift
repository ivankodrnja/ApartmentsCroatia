//
//  ApartmentDetailViewController.swift
//  Apartments Croatia
//
//  Created by Ivan Kodrnja on 24/07/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import UIKit
import CoreData

class ApartmentDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    // variable will be initialized from previous VC
    var apartments : [Apartment]?
    
    // apartments count
    var apartmentsCount = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set rows of different dimensions
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        //tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 250
        tableView.tableFooterView = UIView()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return apartments!.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let apartment = apartments![indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ApartmentDetailCell", for: indexPath) as! ApartmentDetailCell
        
        // make table cell separators stretch throught the screen width
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsets.zero
        cell.separatorInset = UIEdgeInsets.zero

        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        cell.apartmentType.text = apartment.type + " \(apartmentsCount)"
        cell.numberOfBedsValue.text = apartment.numberOfBeds
        cell.pricePerDayFromValue.text = apartment.priceRange + " EUR"
        cell.sizeValue.text = apartment.surface + " m2"
        
        if apartment.aircondition == "Y" {
                cell.airConditionImage.image = UIImage(named: "yescheckmark")
        } else {
            cell.airConditionImage.image = UIImage(named: "nocheckmark")
        }
        if apartment.tv == "Y" {
            cell.satelliteTVImage.image = UIImage(named: "yescheckmark")
        } else {
            cell.satelliteTVImage.image = UIImage(named: "nocheckmark")
        }
        if apartment.internet == "Y" {
            cell.internetImage.image = UIImage(named: "yescheckmark")
        } else {
            cell.internetImage.image = UIImage(named: "nocheckmark")
        }
        
        apartmentsCount+=1
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return
    }

}
