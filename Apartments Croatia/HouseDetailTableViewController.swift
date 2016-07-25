//
//  HouseDetailTableViewController.swift
//  Apartments Croatia
//
//  Created by Ivan Kodrnja on 21/07/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import MessageUI

class HouseDetailTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,MFMailComposeViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    
    // variable will be initialized from previous VC
    var house : House?
    
    // image array that will store urls for all apartment images
    var imageArray = [String]()
    
    // check if images have been loaded in the images slider cell
    var loadImages : Bool = true
    
    // will serve to check if it is already in the favorites list
    var isFavorite: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set rows of different dimensions
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        //tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        // make an array of urls of apartment photos
        // add other house photos
        for aPhoto in house!.photos {
            let photoUrl = NetworkClient.Constants.baseUrl + NetworkClient.Constants.imageFolder + aPhoto.path
            imageArray.append(photoUrl)
        }
        
        self.navigationItem.title = house?.name
        tableView.tableFooterView = UIView()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Core Data Convenience
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // different sections have different number of rows
        switch(section){
        case 0:
            return 4 // image slider, add to wishlist, labels cell and book cell
        case 1:
            return 1 // Apartment info
        case 2:
            return 1 // map cell
        default:
            return 4 // rental rates : nightly, weekend night, weekly, monthly
        }
        
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // different sections have different number of rows
        switch(section){
        case 1:
            return "Apartment info" // description and amenities
        case 2:
            return "Map" // map cell
        case 3:
            return "Contact info" // rental rates : nightly, weekend night, weekly, monthly
        default:
            return ""
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // cell type depends on section and a row inside the section
        switch(indexPath.section){
        // first section contains image slider, labels cell and book cell
        case 0:
            
            switch(indexPath.row){
            // image slider
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("ImageSliderCell", forIndexPath: indexPath) as! ImageSliderCell
                // make table cell separators stretch throught the screen width
                cell.preservesSuperviewLayoutMargins = false
                cell.layoutMargins = UIEdgeInsetsZero
                cell.separatorInset = UIEdgeInsetsZero
                
                // hide label "price from" if the price is stated as 0
                if house!.priceFrom == 0 {
                    cell.priceFromLabel.hidden = true
                } else {
                    cell.priceFromLabel.text = "EUR \(house!.priceFrom)+"
                }
                
                // load images only the first time cell appears
                if loadImages {
                    // cache downloaded images and use Auk image slideshow library from https://github.com/evgenyneu/Auk
                    Moa.settings.cache.requestCachePolicy = .ReturnCacheDataElseLoad
                    for imageUrl in imageArray {
                        cell.scrollView.auk.settings.placeholderImage = UIImage(named: "LoadingImage")
                        cell.scrollView.auk.settings.errorImage = UIImage(named: "NoImage")
                        cell.scrollView.auk.show(url: imageUrl)

                    }
                    loadImages = false
                }
                
                return cell
            // add to favorites
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("FavoritesCell", forIndexPath: indexPath)
                
                // make table cell separators stretch throught the screen width
                cell.preservesSuperviewLayoutMargins = false
                cell.layoutMargins = UIEdgeInsetsZero
                cell.separatorInset = UIEdgeInsetsZero
                
                cell.accessoryType = UITableViewCellAccessoryType.None
                cell.backgroundColor = UIColor.grayColor()
                cell.textLabel?.textAlignment = .Center
                cell.textLabel!.font = UIFont.boldSystemFontOfSize(20)
                cell.textLabel?.textColor = UIColor.whiteColor()
                if house!.favorite == "Y" {
                    cell.textLabel?.text = "Remove from Wishlist"
                } else {
                    cell.textLabel?.text = "Add to Wishlist"
                }
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                
                return cell
            // labels cell
            case 2:
                let cell = tableView.dequeueReusableCellWithIdentifier("LabelCell", forIndexPath: indexPath) as! LabelTableViewCell
                
                // make table cell separators stretch throught the screen width
                cell.preservesSuperviewLayoutMargins = false
                cell.layoutMargins = UIEdgeInsetsZero
                cell.separatorInset = UIEdgeInsetsZero
                
                cell.seaDistance.text = "Sea"
                cell.seaDistanceCount.text =  "\(house!.seaDistance)" + " m"
                cell.centerDistance.text = "Center"
                cell.centerDistanceCount.text =  "\(house!.centerDistance)" + " m"
                cell.parking.text = "Parking"
                
                if house!.parking == "Y" {
                    cell.hasParking.image = UIImage(named: "yescheckmark")
                } else {
                    cell.hasParking.image = UIImage(named: "nocheckmark")
                }
                

                cell.pets.text = "Pets"
                if house!.pets == "Y" {
                    cell.acceptsPets.image = UIImage(named: "yescheckmark")
                } else {
                    cell.acceptsPets.image = UIImage(named: "nocheckmark")
                }
                
                return cell
                
            // booking cell
            default:
                let cell = tableView.dequeueReusableCellWithIdentifier("BookCell", forIndexPath: indexPath)
                
                // make table cell separators stretch throught the screen width
                cell.preservesSuperviewLayoutMargins = false
                cell.layoutMargins = UIEdgeInsetsZero
                cell.separatorInset = UIEdgeInsetsZero
                
                cell.accessoryType = UITableViewCellAccessoryType.None
                cell.backgroundColor = UIColor.orangeColor()
                cell.textLabel?.textAlignment = .Center
                cell.textLabel!.font = UIFont.boldSystemFontOfSize(20)
                cell.textLabel?.textColor = UIColor.whiteColor()
                cell.textLabel?.text = NetworkClient.Constants.BookNow
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                
                return cell
                
            }
        // second section contains description and amenities
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("ApartmentInfoCell", forIndexPath: indexPath)
            cell.accessoryType = .DisclosureIndicator
            // make table cell separators stretch throught the screen width
            cell.preservesSuperviewLayoutMargins = false
            cell.layoutMargins = UIEdgeInsetsZero
            cell.separatorInset = UIEdgeInsetsZero
            
            
            let aptCount = house!.apartments.count
            var aptLabel = "apartments"
            if aptCount > 1 {
                aptLabel = "apartments"
            }
            cell.textLabel?.text = "\(aptCount) " + aptLabel
            return cell
            
        // third section contains the map
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("MapCell", forIndexPath: indexPath) as! MapTableViewCell
            cell.mapView.mapType = .Satellite
            
            let location = CLLocationCoordinate2D(latitude: house!.latitude, longitude: house!.longitude)
            
            let span = MKCoordinateSpanMake(0.03, 0.03)
            let region = MKCoordinateRegion(center: location, span: span)
            
            cell.mapView.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            
            cell.mapView.addAnnotation(annotation)
            
            return cell
            
        // fourth section contains contact info
        default:
            let cell = UITableViewCell(style: .Value1, reuseIdentifier: "ContactInfoCell")
            cell.detailTextLabel?.textColor = UIColor.blackColor()
            cell.selectionStyle = .None
            // make table cell separators stretch throught the screen width
            cell.preservesSuperviewLayoutMargins = false
            cell.layoutMargins = UIEdgeInsetsZero
            cell.separatorInset = UIEdgeInsetsZero

            switch(indexPath.row){
            // postal address
            case 0:
                
                cell.textLabel?.text = "Address:"
                cell.detailTextLabel?.text = house!.address + ", " + (house!.destination?.name)!
  
            // get directions
            case 1:
                
                cell.accessoryType = UITableViewCellAccessoryType.None
                cell.backgroundColor = UIColor.grayColor()
                cell.textLabel!.font = UIFont.boldSystemFontOfSize(20)
                cell.textLabel?.textColor = UIColor.whiteColor()
                cell.textLabel?.text = "Get directions"
                
                cell.accessoryType = .DisclosureIndicator
            // website
            case 2:

                cell.textLabel?.text = "Website:"
                
                let website = house!.website
                if website == "http://www.croapartments.net/nowebsite.html" {
                    cell.detailTextLabel?.text = "N/A"
                } else {
                    cell.detailTextLabel?.text = website
                    cell.accessoryType = .DisclosureIndicator
                }

            default:
                cell.accessoryType = UITableViewCellAccessoryType.None
                cell.backgroundColor = UIColor.orangeColor()
                cell.textLabel?.textAlignment = .Center
                cell.textLabel!.font = UIFont.boldSystemFontOfSize(20)
                cell.textLabel?.textColor = UIColor.whiteColor()
                cell.textLabel?.text = "Call us"
                
                cell.accessoryType = .DisclosureIndicator
            }
            return cell
            
        }
        
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch(indexPath.section){
        // first section contains image slider, add to wishlist, labels cell and book cell
        case 0:
            switch(indexPath.row){
            // image slider
            case 0:
                let controller = storyboard!.instantiateViewControllerWithIdentifier("ImageViewController") as! ImageViewController
                controller.imageArray = self.imageArray
                
                self.navigationController!.pushViewController(controller, animated: true)
            // add to/remove from wishlist
            case 1:
                if !isFavorite {
                    house!.favorite = "Y"
                    
                    isFavorite = true
                    tableView.reloadData()
                } else {
                    house!.favorite = "N"
                    isFavorite = false
                    tableView.reloadData()
                }
                CoreDataStackManager.sharedInstance().saveContext()
                
                
            // labels cell
            case 2:
                return
            // book now cell
            default:
                let mailComposeViewController = configuredMailComposeViewController()
                if MFMailComposeViewController.canSendMail() {
                    self.presentViewController(mailComposeViewController, animated: true, completion: nil)
                } else {
                    self.showAlertView("Your device could not send e-mail.  Please check e-mail configuration and try again.")
                }
                
            }
            
        // second section contains apartment info
        case 1:
            
            switch(indexPath.row){
            default:
                let controller = storyboard!.instantiateViewControllerWithIdentifier("ApartmentDetailViewController") as! ApartmentDetailViewController
                controller.apartments = house?.apartments
                
                self.navigationController!.pushViewController(controller, animated: true)
                
            }
        // map
        case 2:
            let controller = storyboard!.instantiateViewControllerWithIdentifier("MapViewController") as! MapViewController
            controller.latitude = house?.latitude
            controller.longitude = house?.longitude
            
            self.navigationController!.pushViewController(controller, animated: true)
            
        // contact info
        default:
            
            switch(indexPath.row){
            // house address
            case 0:
                return
                
            // get directions in Map App
            case 1:
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: house!.latitude, longitude: house!.longitude), addressDictionary: nil))
                let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                mapItem.openInMapsWithLaunchOptions(launchOptions)
                
            // website
            case 2:
                // check if website exists and show it if it does
                let website = house!.website
                if website == "http://www.croapartments.net/nowebsite.html" {
                    return
                } else {
                    if Reachability.isConnectedToNetwork() == true {
                        UIApplication.sharedApplication().openURL(NSURL(string:website)!)
                    } else {
                        print("Internet connection not present")
                        self.showAlertView("Internet connection not present")
                    }
                    
                }
            
            // call us
            default:
                let phoneUrlString = "tel://" + house!.phone
                UIApplication.sharedApplication().openURL(NSURL(string:phoneUrlString)!)
            
        }
     }
}
    
    
    // MARK: - Helpers
    
    @IBAction func openImageViewController(sender: AnyObject) {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("ImageViewController") as! ImageViewController
        controller.imageArray = self.imageArray
        
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    
    func showAlertView(errorMessage: String?) {
        
        let alertController = UIAlertController(title: nil, message: errorMessage!, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Dismiss", style: .Cancel) {(action) in
            
            
        }
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true){
            
        }
        
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients([house!.email])
        mailComposerVC.setSubject("Upit za Vaš apartman / Apartments Croatia iPhone-Android app")
        mailComposerVC.setMessageBody("Enter your query", isHTML: false)
        
        return mailComposerVC
    }
    
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        print(result)
        if result == MFMailComposeResultCancelled{
            print("cancelled")
        } else if result == MFMailComposeResultSent {
            print("sent")
        }
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

}
