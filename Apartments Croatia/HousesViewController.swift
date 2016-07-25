//
//  HousesViewController.swift
//  Apartments Croatia
//
//  Created by Ivan Kodrnja on 15/07/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import UIKit
import CoreData

class HousesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    

    @IBOutlet weak var tableView: UITableView!
    // variable will be initialized from previous VC
    var destination : Destination?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        // fetch results
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
        fetchedResultsController.delegate = self
        self.navigationItem.title = destination?.name

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
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "House")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "destination.name == %@", self.destination!.name)
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.sharedContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    // MARK: - Table View
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 350
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
        
        let house = fetchedResultsController.objectAtIndexPath(indexPath) as! House
        
        let cellReuseIdentifier = "HousesCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier)! as! HouseTableViewCell
        
        configureCell(cell, withHouse: house, atIndexPath: indexPath)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    // MARK: - Configure Cell
    
    func configureCell(cell: HouseTableViewCell, withHouse house: House, atIndexPath indexPath: NSIndexPath) {
        // make table cell separators stretch throught the screen width, in Storyboard separator insets of the table view and the cell have also set to 0
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
        
        // remove previous image from the newly created cell
        cell.scrollView.auk.removeAll()
        
        // enables scrolling to top by tappig status bar on top, there are two scrol views, this one and the uitableview, only one can have scrolls to top true
        cell.scrollView.scrollsToTop = false
        
        //***** set the apartment name or heading *****//
        // cache downloaded images and use Auk image slideshow library from https://github.com/evgenyneu/Auk
        Moa.settings.cache.requestCachePolicy = .ReturnCacheDataElseLoad
        
        let imageUrl = NetworkClient.Constants.baseUrl + NetworkClient.Constants.imageFolder + house.mainImagePath
        cell.scrollView.auk.settings.placeholderImage = UIImage(named: "LoadingImage")
        cell.scrollView.auk.settings.errorImage = UIImage(named: "NoImage")
        cell.scrollView.auk.show(url: imageUrl)
        
        cell.nameLabel.text = house.name
        // TODO: localization cell.toTheSeaLabel.text
        cell.toTheSeaDistance.text = "\(house.seaDistance) m"
        // TODO: localization cell.toTheCenterLabel.text
        cell.toTheCenterDistance.text = "\(house.centerDistance) m"
        // TODO: localization cell.dailyFromLabel.text
        if (house.priceFrom == 0){
            cell.dailyFromPrice.text = "Request"
        } else{
            cell.dailyFromPrice.text = "\(house.priceFrom) EUR"
        }
        cell.locationLabel.text = "\(house.destination!.name), \(house.destination!.region!.name)"
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let controller = storyboard!.instantiateViewControllerWithIdentifier("HouseDetailTableViewController") as! HouseDetailTableViewController
        let house = fetchedResultsController.objectAtIndexPath(indexPath) as! House
        
        // set destination object in the detail VC
        controller.house = house
        
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
            let cell = tableView.cellForRowAtIndexPath(indexPath!) as! HouseTableViewCell
            let house = controller.objectAtIndexPath(indexPath!) as! House
            self.configureCell(cell, withHouse: house, atIndexPath: indexPath!)
            
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            
        }
    }
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
}
