//
//  WishlistViewController.swift
//  Apartments Croatia
//
//  Created by Ivan Kodrnja on 23/07/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import UIKit
import CoreData

class WishlistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
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
        self.navigationItem.title = NSLocalizedString("wishlist", comment: "Wishlist")
        self.navigationItem.rightBarButtonItem = editButtonItem
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
    
    lazy var fetchedResultsController: NSFetchedResultsController<House> = {
        
        let fetchRequest = NSFetchRequest<House>(entityName: "House")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "favorite == %@", "Y")
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.sharedContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    // MARK: - Table View
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 350
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /* Get cell type */
        
        let house = fetchedResultsController.object(at: indexPath) 
        
        let cellReuseIdentifier = "HousesCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)! as! HouseTableViewCell
        
        configureCell(cell, withHouse: house, atIndexPath: indexPath)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    }
    
    // MARK: - Configure Cell
    
    func configureCell(_ cell: HouseTableViewCell, withHouse house: House, atIndexPath indexPath: IndexPath) {
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
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let controller = storyboard!.instantiateViewController(withIdentifier: "HouseDetailTableViewController") as! HouseDetailTableViewController
        let house = fetchedResultsController.object(at: indexPath) 
        
        // set destination object in the detail VC
        controller.house = house
        
        self.navigationController!.pushViewController(controller, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCellEditingStyle,
                                      forRowAt indexPath: IndexPath) {
        
        switch (editingStyle) {
        case .delete:
            
            // set the house's favorite attribute to "N"
            let house = fetchedResultsController.object(at: indexPath) 
            house.favorite = "N"
            CoreDataStackManager.sharedInstance().saveContext()
            
        default:
            break
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
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
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            
            
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            
        case .update:
            let cell = tableView.cellForRow(at: indexPath!) as! HouseTableViewCell
            let house = controller.object(at: indexPath!) as! House
            self.configureCell(cell, withHouse: house, atIndexPath: indexPath!)
            
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
}
