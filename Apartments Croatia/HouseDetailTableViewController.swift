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

class HouseDetailTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    // variable will be initialized from previous VC
    var house : House?
    
    // image array that will store urls for all apartment images
    var imageArray = [String]()
    
    // check if images have been loaded in the images slider cell
    var loadImages : Bool = true
    
    // TODO: delete?
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
        print(imageArray)
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
                    cell.textLabel?.text = "Added to Wishlist"
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
                
                cell.seaDistance.text = "Sea distance"
                cell.seaDistanceCount.text =  "\(house!.seaDistance)"
                cell.centerDistance.text = "Center distance"
                cell.centerDistanceCount.text =  "\(house!.centerDistance)"
                cell.parking.text = "Parking"
                cell.hasParking.text =  house!.parking
                cell.pets.text = "Pets"
                cell.acceptsPets.text =  house!.pets
                
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
            
        // fourth section contains the rental rates: nightly, weekend night, weekly, monthly
        default:
            let cell = UITableViewCell(style: .Value1, reuseIdentifier: "ContactInfoCell")
            cell.detailTextLabel?.textColor = UIColor.blackColor()
            cell.selectionStyle = .None
            // make table cell separators stretch throught the screen width
            cell.preservesSuperviewLayoutMargins = false
            cell.layoutMargins = UIEdgeInsetsZero
            cell.separatorInset = UIEdgeInsetsZero
            
            // each of 4 rows shows different price type
            switch(indexPath.row){
            // postal address
            case 0:
                cell.textLabel?.text = "Address:"
                cell.detailTextLabel?.text = house!.address + ", " + (house!.destination?.name)!
        
            // website
            case 1:
                cell.textLabel?.text = "Website:"
                cell.detailTextLabel?.text = house!.website
            case 2:
                cell.textLabel?.text = "Call us"
                cell.detailTextLabel?.text = house!.phone
            default:
                cell.textLabel?.text = "Get directions:"
                cell.detailTextLabel?.text = house!.phone
                
            }
            return cell
            
        }
        
        
        
    }
    /*
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch(indexPath.section){
        // first section contains image slider, labels cell and book cell
        case 0:
            switch(indexPath.row){
            // image slider
            case 0:
                return
            // add to favorites
            case 1:
                // save to favorites list using Core Data only if already isn't added to favorites list
                if !isFavorite {
                    // prepare a dictionary to save as an Apartment object
                    let aptDict: [String : AnyObject] = [ZilyoClient.JSONResponseKeys.Id : (self.apartment?.id)!, ZilyoClient.JSONResponseKeys.LatLng : (self.apartment?.latLng)!, ZilyoClient.JSONResponseKeys.Location : (self.apartment?.location)!, ZilyoClient.JSONResponseKeys.Attr : (self.apartment?.attr)!, ZilyoClient.JSONResponseKeys.Provider : (self.apartment?.provider)!]
                    let apt = Apartment(dictionary: aptDict, context: self.sharedContext)
                    
                    // add amenities
                    for amenity in apartment!.amenities! {
                        let anAmenity = Amenity(dictionary: amenity, context: self.sharedContext)
                        anAmenity.apartment = apt
                    }
                    
                    
                    // add prices
                    let pricesDict = apartment?.price
                    let price = Price(dictionary: pricesDict!, context: self.sharedContext)
                    price.apartment = apt
                    
                    // add attributes
                    let attributesDict = apartment?.attr
                    let attribute = Attribute(dictionary: attributesDict!, context: self.sharedContext)
                    attribute.apartment = apt
                    
                    // add photo urls
                    for anImage in apartment!.photos! {
                        let photo = Photo(dictionary: anImage, context: self.sharedContext)
                        photo.apartment = apt
                    }
                    
                    // save the apartment data
                    CoreDataStackManager.sharedInstance().saveContext()
                    
                    isFavorite = true
                    tableView.reloadData()
                }
                
                
                
            // booking labels cell
            case 2:
                return
                
            default:
                
                if Reachability.isConnectedToNetwork() == true {
                    print("Internet connection OK")
                    let controller = storyboard!.instantiateViewControllerWithIdentifier("BookingViewController") as! BookingViewController
                    
                    // set description text in detail controller
                    controller.urlString = apartment!.provider!["url"] as? String
                    self.navigationController!.pushViewController(controller, animated: true)
                } else {
                    print("Internet connection not present")
                    self.showAlertView("Internet connection not present")
                }
                
                
            }
            
        // second section contains description and amenities
        case 1:
            
            switch(indexPath.row){
            // description
            case 0:
                
                let controller = storyboard!.instantiateViewControllerWithIdentifier("DescriptionDetailViewController") as! DescriptionDetailViewController
                
                // set description text in detail controller
                controller.descriptionText = apartment!.attr!["description"] as? String
                // set title text in detail controller
                controller.titleText = "Description"
                
                self.navigationController!.pushViewController(controller, animated: true)
                
            // amentites labels cell
            default:
                let controller = storyboard!.instantiateViewControllerWithIdentifier("DescriptionDetailViewController") as! DescriptionDetailViewController
                
                var amenitiesArray = String()
                for amenity in apartment!.amenities! {
                    let amenityText = amenity["text"] as! String
                    amenitiesArray += "\(amenityText) "
                }
                
                // set description text in detail controller
                controller.descriptionText = amenitiesArray
                // set title text in detail controller
                controller.titleText = "Amenities"
                
                self.navigationController!.pushViewController(controller, animated: true)
                
            }
            
        default:
            return
        }
    }
    */
    
    // MARK: - Helpers
    
    func showAlertView(errorMessage: String?) {
        
        let alertController = UIAlertController(title: nil, message: errorMessage!, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Dismiss", style: .Cancel) {(action) in
            
            
        }
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true){
            
        }
        
    }

}
