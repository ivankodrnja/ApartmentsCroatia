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
        let houseAnalyticsParameters = ["HouseName:" : house!.name, "WebHouseId": house!.houseid] as [String : Any]
        Flurry.logEvent("HouseLoaded", withParameters: houseAnalyticsParameters, timed: true)
        Flurry.logPageView()
        
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // different sections have different number of rows
        switch(section){
        case 1:
            return NSLocalizedString("apartmentInfo", comment: "Apartment info") // description and amenities
        case 2:
            return NSLocalizedString("map", comment: "Map") // map cell
        case 3:
            return NSLocalizedString("contactInfo", comment: "Contact info") // rental rates : nightly, weekend night, weekly, monthly
        default:
            return ""
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // cell type depends on section and a row inside the section
        switch(indexPath.section){
        // first section contains image slider, labels cell and book cell
        case 0:
            
            switch(indexPath.row){
            // image slider
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ImageSliderCell", for: indexPath) as! ImageSliderCell
                // make table cell separators stretch throught the screen width
                cell.preservesSuperviewLayoutMargins = false
                cell.layoutMargins = UIEdgeInsets.zero
                cell.separatorInset = UIEdgeInsets.zero
                
                // hide label "price from" if the price is stated as 0
                if house!.priceFrom == 0 {
                    cell.priceFromLabel.isHidden = true
                } else {
                    cell.priceFromLabel.text = "EUR \(house!.priceFrom)+"
                }
                
                // load images only the first time cell appears
                if loadImages {
                    // cache downloaded images and use Auk image slideshow library from https://github.com/evgenyneu/Auk
                    Moa.settings.cache.requestCachePolicy = .returnCacheDataElseLoad
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "FavoritesCell", for: indexPath)
                
                // make table cell separators stretch throught the screen width
                cell.preservesSuperviewLayoutMargins = false
                cell.layoutMargins = UIEdgeInsets.zero
                cell.separatorInset = UIEdgeInsets.zero
                
                cell.accessoryType = UITableViewCellAccessoryType.none
                cell.backgroundColor = UIColor.gray
                cell.textLabel?.textAlignment = .center
                cell.textLabel!.font = UIFont.boldSystemFont(ofSize: 20)
                cell.textLabel?.textColor = UIColor.white
                if house!.favorite == "Y" {
                    cell.textLabel?.text = NSLocalizedString("removeFromWishlist", comment: "Remove from Wishlist")
                } else {
                    cell.textLabel?.text = NSLocalizedString("addToWishlist", comment: "Add to Wishlist")
                }
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                
                return cell
            // labels cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelTableViewCell
                
                // make table cell separators stretch throught the screen width
                cell.preservesSuperviewLayoutMargins = false
                cell.layoutMargins = UIEdgeInsets.zero
                cell.separatorInset = UIEdgeInsets.zero
                
                cell.seaDistance.text = NSLocalizedString("sea", comment: "Sea")
                cell.seaDistanceCount.text =  "\(house!.seaDistance)" + " m"
                cell.centerDistance.text = NSLocalizedString("center", comment: "Center")
                cell.centerDistanceCount.text =  "\(house!.centerDistance)" + " m"
                cell.parking.text = NSLocalizedString("parking", comment: "Parking")
                
                if house!.parking == "Y" {
                    cell.hasParking.image = UIImage(named: "yescheckmark")
                } else {
                    cell.hasParking.image = UIImage(named: "nocheckmark")
                }
                

                cell.pets.text = NSLocalizedString("pets", comment: "Pets")
                if house!.pets == "Y" {
                    cell.acceptsPets.image = UIImage(named: "yescheckmark")
                } else {
                    cell.acceptsPets.image = UIImage(named: "nocheckmark")
                }
                
                return cell
                
            // booking cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath)
                
                // make table cell separators stretch throught the screen width
                cell.preservesSuperviewLayoutMargins = false
                cell.layoutMargins = UIEdgeInsets.zero
                cell.separatorInset = UIEdgeInsets.zero
                
                cell.accessoryType = UITableViewCellAccessoryType.none
                cell.backgroundColor = UIColor.orange
                cell.textLabel?.textAlignment = .center
                cell.textLabel!.font = UIFont.boldSystemFont(ofSize: 20)
                cell.textLabel?.textColor = UIColor.white
                cell.textLabel?.text = NSLocalizedString("bookNow", comment: "BOOK NOW")
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                
                return cell
                
            }
        // second section contains description and amenities
        case 1:
            self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ApartmentInfoCell")
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ApartmentInfoCell", for: indexPath) as UITableViewCell
            cell.accessoryType = .disclosureIndicator
            // make table cell separators stretch throught the screen width
            cell.preservesSuperviewLayoutMargins = false
            cell.layoutMargins = UIEdgeInsets.zero
            cell.separatorInset = UIEdgeInsets.zero
            
            
            let aptCount = house!.apartments.count
            var aptLabel = NSLocalizedString("apartment", comment: "apartment")
            if aptCount > 1 {
                aptLabel = NSLocalizedString("apartments", comment: "apartments")
            }
            cell.textLabel?.text = "\(aptCount) " + aptLabel
            return cell
            
        // third section contains the map
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MapCell", for: indexPath) as! MapTableViewCell
            cell.mapView.mapType = .satellite
            
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
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "ContactInfoCell")
            cell.detailTextLabel?.textColor = UIColor.black
            cell.selectionStyle = .none
            // make table cell separators stretch throught the screen width
            cell.preservesSuperviewLayoutMargins = false
            cell.layoutMargins = UIEdgeInsets.zero
            cell.separatorInset = UIEdgeInsets.zero

            switch(indexPath.row){
            // postal address
            case 0:
                
                cell.textLabel?.text = NSLocalizedString("address", comment: "Address") + ":"
                cell.detailTextLabel?.text = house!.address + ", " + (house!.destination?.name)!
  
            // get directions
            case 1:
                
                cell.accessoryType = UITableViewCellAccessoryType.none
                cell.backgroundColor = UIColor.gray
                cell.textLabel!.font = UIFont.boldSystemFont(ofSize: 20)
                cell.textLabel?.textColor = UIColor.white
                cell.textLabel?.text = NSLocalizedString("getDirections", comment: "Get directions")
                
                cell.accessoryType = .disclosureIndicator
            // website
            case 2:

                cell.textLabel?.text = "Website" + ":"
                
                let website = house!.website
                if website == "http://www.croapartments.net/nowebsite.html" || website == "http://www.croapartments.net/iphone/nowebsite.html" {
                    cell.detailTextLabel?.text = "N/A"
                } else {
                    cell.detailTextLabel?.text = website
                    cell.accessoryType = .disclosureIndicator
                }

            default:
                cell.accessoryType = UITableViewCellAccessoryType.none
                cell.backgroundColor = UIColor.orange
                cell.textLabel?.textAlignment = .center
                cell.textLabel!.font = UIFont.boldSystemFont(ofSize: 20)
                cell.textLabel?.textColor = UIColor.white
                cell.textLabel?.text = NSLocalizedString("callUs", comment: "Call us")
                
                cell.accessoryType = .disclosureIndicator
            }
            return cell
            
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(indexPath.section){
        // first section contains image slider, add to wishlist, labels cell and book cell
        case 0:
            switch(indexPath.row){
            // image slider
            case 0:
                let controller = storyboard!.instantiateViewController(withIdentifier: "ImageViewController") as! ImageViewController
                controller.imageArray = self.imageArray
                
                self.navigationController!.pushViewController(controller, animated: true)
            // add to/remove from wishlist
            case 1:
                
                print(house!)
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
                    self.present(mailComposeViewController, animated: true, completion: nil)
                } else {
                    self.showAlertView(NSLocalizedString("emailSendingError", comment: "Your device could not send e-mail. Please check e-mail configuration and try again."))
                }
                
            }
            
        // second section contains apartment info
        case 1:
            
            switch(indexPath.row){
            default:
                let controller = storyboard!.instantiateViewController(withIdentifier: "ApartmentDetailViewController") as! ApartmentDetailViewController
                controller.apartments = house?.apartments
                
                self.navigationController!.pushViewController(controller, animated: true)
                
            }
        // map
        case 2:
            let controller = storyboard!.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
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
                mapItem.openInMaps(launchOptions: launchOptions)
                
            // website
            case 2:
                // check if website exists and show it if it does
                let website = house!.website
                if website == "http://www.croapartments.net/nowebsite.html" || website == "http://www.croapartments.net/iphone/nowebsite.html" {
                    return
                } else {
                    if Reachability.shared.isConnectedToNetwork() == true {
                        UIApplication.shared.openURL(URL(string:website)!)
                    } else {
                        print("Internet connection not present")
                        self.showAlertView(NSLocalizedString("noInternet", comment: "Internet connection not present"))
                    }
                    
                }
            
            // call us
            default:
                let phoneUrlString = "tel://" + house!.phone
                UIApplication.shared.openURL(URL(string:phoneUrlString)!)
            
        }
     }
}
    
    
    // MARK: - Helpers
    
    @IBAction func openImageViewController(_ sender: AnyObject) {
        let imageSliderIndexPath = IndexPath(row: 0, section: 0)
        let imageSliderCell = self.tableView.cellForRow(at: imageSliderIndexPath) as! ImageSliderCell
        let controller = storyboard!.instantiateViewController(withIdentifier: "ImageViewController") as! ImageViewController
        controller.imageArray = self.imageArray
        controller.currentImageIndex = imageSliderCell.scrollView.auk.currentPageIndex
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    
    func showAlertView(_ errorMessage: String?) {
        
        let alertController = UIAlertController(title: nil, message: errorMessage!, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Dismiss", style: .cancel) {(action) in
            
            
        }
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true){
            
        }
        
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients([house!.email])
        mailComposerVC.setSubject("Upit za Vaš apartman \(String(describing: house!.name)) / Apartments Croatia iPhone-Android app")
        mailComposerVC.setMessageBody("Enter your query", isHTML: false)
        
        return mailComposerVC
    }
    
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        print(result)
        if result == MFMailComposeResult.cancelled{
            print("cancelled")
        } else if result == MFMailComposeResult.sent {
            print("sent")
        }
        controller.dismiss(animated: true, completion: nil)
    }

}
