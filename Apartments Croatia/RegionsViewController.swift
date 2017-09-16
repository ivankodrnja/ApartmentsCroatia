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
    //var resultsTableController = UITableViewController(style: .Plain)
    //var searchController = UISearchController(searchResultsController: nil)
    var resultsTableController: SearchResultsViewController!
    var searchController: UISearchController!
    
    var destinationSearchResults: [Destination]?
    var houeseSearchResults: [House]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        
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
        resultsTableController = SearchResultsViewController()
        self.searchController = UISearchController(searchResultsController: resultsTableController)
        
        /*
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
         */
        tableView.tableFooterView = UIView()
    }
    

    @IBAction func searchButtonClicked(_ sender: AnyObject) {
        
        self.searchController.hidesNavigationBarDuringPresentation = true
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
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
        getDestinationByNameFetchRequest.predicate = NSPredicate(format: "name CONTAINS %@", searchText)
        let allDestinations = (try! sharedContext.fetch(getDestinationByNameFetchRequest)) 
        
        return allDestinations
        
    }
    
    func getHouseName(_ searchText: String) -> [House] {
        
        let getHouseByNameFetchRequest = NSFetchRequest<House>(entityName: "House")
        getHouseByNameFetchRequest.predicate = NSPredicate(format: "name CONTAINS %@", searchText)
        let allHouses = (try! sharedContext.fetch(getHouseByNameFetchRequest)) 
        
        return allHouses
        
    }

    // TODO:delete
    var loop = 1
    
    override func viewDidAppear(_ animated: Bool) {

        // TODO:delete and handle error in UpdatingVC
        if (loop == 1){
        let dateString = "2015-06-22"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateFromString = dateFormatter.date(from: dateString)
        
        NetworkClient.sharedInstance().defaults.set(dateFromString, forKey: "lastSyncDate")
            
        loop += 1
        }
        
        // present UpdatingViewController if syncing of databse occured 7 or more days ago
        let lastSyncDate = NetworkClient.sharedInstance().defaults.object(forKey: "lastSyncDate") as? Date ?? Date()
        print("RegionsViewController lastSyncDate from NSUserDefaults: \(lastSyncDate)")
        let today = Date()
        
        let diffDateComponents = (Calendar.current as NSCalendar).components([NSCalendar.Unit.day], from: lastSyncDate, to: today, options: NSCalendar.Options.init(rawValue: 0))

            
           if (diffDateComponents.day! > 7){
            let updatingVC = self.storyboard?.instantiateViewController(withIdentifier: "UpdatingViewController") as! UpdatingViewController
            present(updatingVC, animated: true, completion: nil)
        }
        

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
    
    /*
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 100
    }
 */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: delete
        if searchController.isActive && searchController.searchBar.text != "" {
            
            let scope = searchController.searchBar.scopeButtonTitles![searchController.searchBar.selectedScopeButtonIndex]
            
            if scope == "Destination" {
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
        
        //TODO: delete
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            let scope = searchController.searchBar.scopeButtonTitles![searchController.searchBar.selectedScopeButtonIndex]
            
            if scope == "Destination" {
                let destination = destinationSearchResults![indexPath.row]
                let cell = tableView.dequeueReusableCell(withIdentifier: "DestinationsCell", for: indexPath) as! DestinationTableViewCell
                cell.nameLabel.text = destination.name
                return cell
            } else {
                let house = houeseSearchResults![indexPath.row]
                let cell = tableView.dequeueReusableCell(withIdentifier: "HousesCell", for: indexPath) as! HouseTableViewCell
                cell.nameLabel.text = house.name
                // TODO: localization cell.toTheSeaLabel.text
                cell.toTheSeaDistance.text = "\(house.seaDistance) m"
                // TODO: localization cell.toTheCenterLabel.text
                cell.toTheCenterDistance.text = "\(house.centerDistance) m"
                // TODO: localization cell.dailyFromLabel.text
                if (house.priceFrom == 0){
                    cell.dailyFromPrice.text = NSLocalizedString("request", comment: "Request")
                } else{
                    cell.dailyFromPrice.text = "\(house.priceFrom) EUR"
                }
                cell.locationLabel.text = "\(house.destination!.name), \(house.destination!.region!.name)"
                return cell
            }
            
        } else {
        
        
        let region = fetchedResultsController.object(at: indexPath)
            

        
        let cellReuseIdentifier = "RegionsCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)! as! RegionTableViewCell
        
        
        
        configureCell(cell, withRegion: region, atIndexPath: indexPath)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
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
            
            if scope == "Destination" {
                
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
            let cell = tableView.cellForRow(at: indexPath!) as! RegionTableViewCell
            let region = controller.object(at: indexPath!) as! Region
            self.configureCell(cell, withRegion: region, atIndexPath: indexPath!)
            
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            
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
            case "Destination":
            destinationSearchResults = getDestinationName(searchController.searchBar.text!)
            tableView.reloadData()
            case "House":
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
        case "Destination":
           destinationSearchResults = getDestinationName(searchController.searchBar.text!)
            
        case "House":
           houeseSearchResults = getHouseName(searchController.searchBar.text!)
        default:
            return
        }

    }
}
