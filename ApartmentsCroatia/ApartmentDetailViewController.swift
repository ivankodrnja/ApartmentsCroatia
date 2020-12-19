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
        
        
        let apartmentIndex = indexPath.row.hashValue
        
        let apartment = apartments![indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ApartmentDetailCell", for: indexPath) as! ApartmentDetailCell
        
        // make table cell separators stretch throught the screen width
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsets.zero
        cell.separatorInset = UIEdgeInsets.zero

        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        switch apartment.type {
        case "Apartment":
            cell.apartmentType.text = NSLocalizedString("apartment", comment: "apartment").capitalized + " \(apartmentIndex + 1)"
        case "Room":
            cell.apartmentType.text = NSLocalizedString("room", comment: "Room").capitalized + " \(apartmentIndex + 1)"
         case "Studio Apartment":
            cell.apartmentType.text = NSLocalizedString("studioApartment", comment: "Studio Apartment").capitalized + " \(apartmentIndex + 1)"
        default:
            break
        }
        
        cell.numberOfBedsLabel.text = NSLocalizedString("numberOfBeds", comment: "Number of beds") + ":"
        cell.numberOfBedsValue.text = apartment.numberOfBeds
        cell.pricePerDayFromLabel.text = NSLocalizedString("pricePerDayFromInApartmentDetail", comment: "Price per day from") + ":"
        
        if apartment.priceRange == "0" {
            cell.pricePerDayFromValue.text = NSLocalizedString("onRequest", comment: "On request")
        } else {
            cell.pricePerDayFromValue.text = apartment.priceRange + " EUR"
        }
        cell.sizeLabel.text = NSLocalizedString("size", comment: "Size") + ":"
        cell.sizeValue.text = apartment.surface + " m2"
        
        cell.airConditionLabel.text = NSLocalizedString("airCondition", comment: "Air Condition")
        cell.satelliteTVLabel.text = NSLocalizedString("satelliteTV", comment: "Satellite TV")
        cell.internetLabel.text = NSLocalizedString("internet", comment: "Internet")
        
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
        
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return
    }

}
