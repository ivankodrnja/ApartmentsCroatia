//
//  RegionsViewController.swift
//  Apartments Croatia
//
//  Created by Ivan Kodrnja on 15/07/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class RegionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    

    
    
    
    @IBOutlet weak var tableView: UITableView!
    // will serve for requesting the user current location
    let locationManager = CLLocationManager()
    
    
    // initialize search controller
    var searchController: UISearchController!
    
    var destinationSearchResults: [Destination]?
    var houeseSearchResults: [House]?


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //adBannerView.loadAd()
        // fetch results
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
        fetchedResultsController.delegate = self

        
        
        // will serve for requesting the user current location
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestLocation()
        }
        
        self.navigationItem.title = NSLocalizedString("app-title", comment: "Apartments Croatia")
        // search
        
        // Initializing with searchResultsController set to nil means that
        // searchController will use this view controller to display the search results
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        
        // If we are using this same view controller to present the results
        // dimming it out wouldn't make sense. Should probably only set
        // this to yes if using another controller to display the search results.
        searchController.obscuresBackgroundDuringPresentation = false
        
        searchController.searchBar.sizeToFit()
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = true
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
        searchController.searchBar.scopeButtonTitles = [NSLocalizedString("destination", comment: "Destination"), NSLocalizedString("house", comment: "House")]
        searchController.searchBar.delegate = self
        
        // Sets this view controller as presenting view controller for the search interface
        definesPresentationContext = true

        tableView.tableFooterView = UIView()
        navigationItem.rightBarButtonItem = nil
    }

    @IBAction func searchButtonClicked(_ sender: AnyObject) {
        
        self.searchController.hidesNavigationBarDuringPresentation = true
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        self.searchController.searchBar.scopeButtonTitles = [NSLocalizedString("destination", comment: "Destination"), NSLocalizedString("house", comment: "House")]
        self.searchController.searchBar.delegate = self
        
        self.present(self.searchController, animated: true, completion: nil)
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getDestinationName(_ searchText: String) -> [Destination] {
        
        let getDestinationByNameFetchRequest = NSFetchRequest<Destination>(entityName: "Destination")
        getDestinationByNameFetchRequest.predicate = NSPredicate(format: "name CONTAINS[c] %@", searchText)
        let allDestinations = (try! sharedContext.fetch(getDestinationByNameFetchRequest)) 
        
        return allDestinations
        
    }
    
    func getHouseName(_ searchText: String) -> [House] {
        
        let getHouseByNameFetchRequest = NSFetchRequest<House>(entityName: "House")
        getHouseByNameFetchRequest.predicate = NSPredicate(format: "name CONTAINS[c] %@", searchText)
        let allHouses = (try! sharedContext.fetch(getHouseByNameFetchRequest)) 
        
        return allHouses
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // present UpdatingViewController if syncing of databse occured 7 or more days ago
/*
        let lastSyncDate = NetworkClient.sharedInstance().defaults.object(forKey: "lastSyncDate") as! Date
        
        
        print("RegionsViewController finalLastSyncDate from NSUserDefaults: \(lastSyncDate)")
        let today = Date()

        let diffDateComponents = Calendar.current.dateComponents([.day], from: lastSyncDate, to: today)
        
        //let diffDateComponents =   (Calendar.current as NSCalendar).components([NSCalendar.Unit.day], from: lastSyncDate, to: today, options: NSCalendar.Options.init(rawValue: 0))

            
           if (diffDateComponents.day! > 7){
            let updatingVC = self.storyboard?.instantiateViewController(withIdentifier: "UpdatingViewController") as! UpdatingViewController
            present(updatingVC, animated: true, completion: nil)
        }
        
*/
    }
    
    // MARK: - Core Data Convenience
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<Region> = {
        
        let fetchRequest = NSFetchRequest<Region>(entityName: "Region")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: true)]
        // return only regions that contain destinations 
        fetchRequest.predicate = NSPredicate(format: "destinations.@count > 0")
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.sharedContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    // MARK: - Table View

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if searchController.isActive && searchController.searchBar.text != "" {
            
            let scope = searchController.searchBar.scopeButtonTitles![searchController.searchBar.selectedScopeButtonIndex]
            
            if scope == NSLocalizedString("destination", comment: "Destination") {
                return (destinationSearchResults?.count)!
            } else {
                return (houeseSearchResults?.count)!
            }
            
        } else {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /* Get cell type */
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            let scope = searchController.searchBar.scopeButtonTitles![searchController.searchBar.selectedScopeButtonIndex]
            
            if scope == NSLocalizedString("destination", comment: "Destination") {
                let destination = destinationSearchResults![indexPath.row]
                
                tableView.register(UINib(nibName: "DestinationTableViewCell", bundle: nil), forCellReuseIdentifier: "DestinationTableViewCell")
            
                tableView.rowHeight = 80
                tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
                tableView.separatorColor = UIColor.lightGray
                let cell = tableView.dequeueReusableCell(withIdentifier: "DestinationTableViewCell", for: indexPath) as! DestinationTableViewCell
                

                // make table cell separators stretch throught the screen width, in Storyboard separator insets of the table view and the cell have also set to 0
                cell.preservesSuperviewLayoutMargins = false
                cell.layoutMargins = UIEdgeInsets.zero
            
   
                //***** set the apartment name or heading *****//
                cell.nameLabel.text = destination.name
                // show separately first letter of the name
                cell.firstLetterLabel.text = String(destination.name[destination.name.startIndex])
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                return cell
            } else {
                let house = houeseSearchResults![indexPath.row]
                
                tableView.register(UINib(nibName: "HouseTableViewCell", bundle: nil), forCellReuseIdentifier: "HousesCell")
                tableView.rowHeight = 350
                tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
                let cell = tableView.dequeueReusableCell(withIdentifier: "HousesCell", for: indexPath) as! HouseTableViewCell
                // make table cell separators stretch throught the screen width, in Storyboard separator insets of the table view and the cell have also set to 0
                cell.preservesSuperviewLayoutMargins = false
                cell.layoutMargins = UIEdgeInsets.zero
                
                // remove previous image from the newly created cell
                cell.scrollView.auk.removeAll()
                
                // enables scrolling to top by tappig status bar on top, there are two scrol views, this one and the uitableview, only one can have scrolls to top true
                cell.scrollView.scrollsToTop = false
                
                //***** set the apartment name or heading *****//
                // cache downloaded images and use Auk image slideshow library from https://github.com/evgenyneu/Auk
                Moa.settings.cache.requestCachePolicy = .returnCacheDataElseLoad
                
                let imageUrl = NetworkClient.Constants.baseUrl + NetworkClient.Constants.imageFolder + house.mainImagePath
                cell.scrollView.auk.settings.placeholderImage = UIImage(named: "LoadingImage")
                cell.scrollView.auk.settings.errorImage = UIImage(named: "NoImage")
                cell.scrollView.auk.show(url: imageUrl)
                
                cell.nameLabel.text = house.name
                cell.toTheSeaLabel.text = NSLocalizedString("sea", comment: "Sea") + ":"
                cell.toTheSeaDistance.text = "\(house.seaDistance) m"
                cell.toTheCenterLabel.text = NSLocalizedString("center", comment: "Center") + ":"
                cell.toTheCenterDistance.text = "\(house.centerDistance) m"
                cell.dailyFromLabel.text = NSLocalizedString("priceFrom", comment: "Daily from") + ":"
                if (house.priceFrom == 0){
                    cell.dailyFromPrice.text = NSLocalizedString("request", comment: "Request")
                } else{
                    cell.dailyFromPrice.text = "\(house.priceFrom) EUR"
                }
                cell.locationLabel.text = "\(house.destination!.name), \(house.destination!.region!.name)"
                
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                return cell
            }
            
        } else {
        
        
        let region = fetchedResultsController.object(at: indexPath)
        let cellReuseIdentifier = "RegionsCell"
        tableView.rowHeight = 104
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)! as! RegionTableViewCell
        
        configureCell(cell, withRegion: region, atIndexPath: indexPath)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
        }
    }
    

    
    // MARK: - Configure Cell
    
    func configureCell(_ cell: RegionTableViewCell, withRegion region: Region, atIndexPath indexPath: IndexPath) {
        // make table cell separators stretch throught the screen width, in Storyboard separator insets of the table view and the cell have also set to 0
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsets.zero
        
        var regionName: String!
        
        switch region.name {
        case "Istria":
            regionName = NSLocalizedString("istria", comment: "Istria")
        case "Kvarner":
            regionName = NSLocalizedString("kvarner", comment: "Kvarner")
        case "Northern Dalmatia":
            regionName = NSLocalizedString("northernDalmatia", comment: "Northern Dalmatia")
        case "Central Dalmatia":
            regionName = NSLocalizedString("centralDalmatia", comment: "Central Dalmatia")
        case "Southern Dalmatia":
            regionName = NSLocalizedString("southernDalmatia", comment: "Southern Dalmatia")
        case "Continental Croatia":
            regionName = NSLocalizedString("continentalCroatia", comment: "Continental Croatia")
        default:
            break
        }
        
        //***** set the region name or heading *****//
        cell.nameLabel.text = regionName
        cell.imgView.image = UIImage(named: region.name)
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            let scope = searchController.searchBar.scopeButtonTitles![searchController.searchBar.selectedScopeButtonIndex]
            
            if scope == NSLocalizedString("destination", comment: "Destination") {
                
                let controller = storyboard!.instantiateViewController(withIdentifier: "HousesViewController") as! HousesViewController
                let destination = destinationSearchResults![indexPath.row]
                
                // set destination object in the detail VC
                controller.destination = destination
                
                self.navigationController!.pushViewController(controller, animated: true)
                
                
            } else {
                let house = houeseSearchResults![indexPath.row]
                
                let controller = storyboard!.instantiateViewController(withIdentifier: "HouseDetailTableViewController") as! HouseDetailTableViewController
          
                
                // set destination object in the detail VC
                controller.house = house
                
                self.navigationController!.pushViewController(controller, animated: true)
    
            }
            
        } else {
        
            let controller = storyboard!.instantiateViewController(withIdentifier: "DestinationsViewController") as! DestinationsViewController
            let region = fetchedResultsController.object(at: indexPath) 
            
            // set region object in the detail VC
            controller.region = region

            
            self.navigationController!.pushViewController(controller, animated: true)
        }
        
    }
    
    // MARK: - Fetched Results Controller Delegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                                     atSectionIndex sectionIndex: Int,
                                             for type: NSFetchedResultsChangeType) {
        
        switch type {
        case .insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            
        case .delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                                    at indexPath: IndexPath?,
                                                for type: NSFetchedResultsChangeType,
                                                              newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            // check for previously cached images at indexPath.row
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            
            
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath){
                
                let region = controller.object(at: indexPath) as! Region
                self.configureCell(cell as! RegionTableViewCell, withRegion: region, atIndexPath: indexPath)
            }
            //let cell = tableView.cellForRow(at: indexPath!) as! RegionTableViewCell
            //let region = controller.object(at: indexPath!) as! Region
            //self.configureCell(cell, withRegion: region, atIndexPath: indexPath!)
            
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            
        @unknown default:
            print("Default case")
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }

}

// MARK: - Core Location Delegate

extension RegionsViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        NetworkClient.sharedInstance().userLocationLatitude = (locations.last?.coordinate.latitude)!
        NetworkClient.sharedInstance().userLocationLongitude = (locations.last?.coordinate.longitude)!

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

// MARK: - UISearchResultsUpdating

extension RegionsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        
        switch scope {
            case NSLocalizedString("destination", comment: "Destination"):
            destinationSearchResults = getDestinationName(searchController.searchBar.text!)
            tableView.reloadData()
            case NSLocalizedString("house", comment: "House"):
            houeseSearchResults = getHouseName(searchController.searchBar.text!)
            tableView.reloadData()
                default:
            return
        }
        
    }
}


// MARK: - SearchBarDelegate
extension RegionsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let scope = searchBar.scopeButtonTitles![selectedScope]
        switch scope {
        case NSLocalizedString("destination", comment: "Destination"):
           destinationSearchResults = getDestinationName(searchController.searchBar.text!)
        case NSLocalizedString("house", comment: "House"):
           houeseSearchResults = getHouseName(searchController.searchBar.text!)
            
        default:
            return
        }

    }
}
