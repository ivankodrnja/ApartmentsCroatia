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

        tableView.tableFooterView = UIView()
        
        // will serve for requesting the user current location
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestLocation()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // TODO:delete
    var loop = 1
    
    override func viewDidAppear(animated: Bool) {

        // TODO:delete and handle error in UpdatingVC
        if (loop == 1){
        let dateString = "2015-06-22"
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateFromString = dateFormatter.dateFromString(dateString)
        
        NetworkClient.sharedInstance().defaults.setObject(dateFromString, forKey: "lastSyncDate")
            
        loop += 1
        }
        
        // present UpdatingViewController if syncing of databse occured 7 or more days ago
        let lastSyncDate = NetworkClient.sharedInstance().defaults.objectForKey("lastSyncDate") as? NSDate ?? NSDate()
        print("RegionsViewController lastSyncDate from NSUserDefaults: \(lastSyncDate)")
        let today = NSDate()
        
        let diffDateComponents = NSCalendar.currentCalendar().components([NSCalendarUnit.Day], fromDate: lastSyncDate, toDate: today, options: NSCalendarOptions.init(rawValue: 0))

            
           if (diffDateComponents.day > 7){
            let updatingVC = self.storyboard?.instantiateViewControllerWithIdentifier("UpdatingViewController") as! UpdatingViewController
            presentViewController(updatingVC, animated: true, completion: nil)
        }
        

    }
    
    // MARK: - Core Data Convenience
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Region")
        
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 100
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
        
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        /* Get cell type */
        
        let region = fetchedResultsController.objectAtIndexPath(indexPath) as! Region
        
        let cellReuseIdentifier = "RegionsCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier)! as! RegionTableViewCell
        
        configureCell(cell, withRegion: region, atIndexPath: indexPath)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    

    
    // MARK: - Configure Cell
    
    func configureCell(cell: RegionTableViewCell, withRegion region: Region, atIndexPath indexPath: NSIndexPath) {
        // make table cell separators stretch throught the screen width, in Storyboard separator insets of the table view and the cell have also set to 0
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
        
        
        
        //***** set the region name or heading *****//
        cell.nameLabel.text = region.name
        cell.imgView.image = UIImage(named: region.name)
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let controller = storyboard!.instantiateViewControllerWithIdentifier("DestinationsViewController") as! DestinationsViewController
        let region = fetchedResultsController.objectAtIndexPath(indexPath) as! Region
        
        // set region object in the detail VC
        controller.region = region
        
        self.navigationController!.pushViewController(controller, animated: true)
        
    }
    
    // MARK: - Fetched Results Controller Delegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
                    didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
                                     atIndex sectionIndex: Int,
                                             forChangeType type: NSFetchedResultsChangeType) {
        
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController,
                    didChangeObject anObject: AnyObject,
                                    atIndexPath indexPath: NSIndexPath?,
                                                forChangeType type: NSFetchedResultsChangeType,
                                                              newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            // check for previously cached images at indexPath.row
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            
            
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            
        case .Update:
            let cell = tableView.cellForRowAtIndexPath(indexPath!) as! RegionTableViewCell
            let region = controller.objectAtIndexPath(indexPath!) as! Region
            self.configureCell(cell, withRegion: region, atIndexPath: indexPath!)
            
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            
        }
    }
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

}


extension RegionsViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        NetworkClient.sharedInstance().userLocationLatitude = (locations.last?.coordinate.latitude)!
        NetworkClient.sharedInstance().userLocationLongitude = (locations.last?.coordinate.longitude)!

    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
}