//
//  DestinationsViewController.swift
//  Apartments Croatia
//
//  Created by Ivan Kodrnja on 28/03/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import UIKit
import CoreData


class DestinationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    // variable will be initialized from previous VC
    var region : Region?
    
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
        
        var regionName: String!
        
        switch region!.name {
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
        
        self.navigationItem.title = regionName
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
    
    lazy var fetchedResultsController: NSFetchedResultsController<Destination> = {
        
        let fetchRequest = NSFetchRequest<Destination>(entityName: "Destination")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))]

        // return only destiations that contain houses
        fetchRequest.predicate = NSPredicate(format: "region.name == %@ AND houses.@count > 0", self.region!.name)
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.sharedContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    // MARK: - Table View
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 80
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
        
        let destination = fetchedResultsController.object(at: indexPath) 
        /*
        let cellReuseIdentifier = "DestinationsCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)! as! DestinationTableViewCell
        */
        tableView.register(UINib(nibName: "DestinationTableViewCell", bundle: nil), forCellReuseIdentifier: "DestinationTableViewCell")
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DestinationTableViewCell", for: indexPath) as! DestinationTableViewCell
        
        configureCell(cell, withDestination: destination, atIndexPath: indexPath)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let controller = storyboard!.instantiateViewController(withIdentifier: "HousesViewController") as! HousesViewController
        let destination = fetchedResultsController.object(at: indexPath) 
        
        // set destination object in the detail VC
        controller.destination = destination
        
        self.navigationController!.pushViewController(controller, animated: true)
        
    }
    
    // MARK: - Configure Cell
    
    func configureCell(_ cell: DestinationTableViewCell, withDestination destination: Destination, atIndexPath indexPath: IndexPath) {
        // make table cell separators stretch throught the screen width, in Storyboard separator insets of the table view and the cell have also set to 0
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsets.zero
        
        
        //***** set the apartment name or heading *****//
        cell.nameLabel.text = destination.name
        // show separately first letter of the name
        cell.firstLetterLabel.text = String(destination.name[destination.name.startIndex])
        

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
            let cell = tableView.cellForRow(at: indexPath!) as! DestinationTableViewCell
            let destination = controller.object(at: indexPath!) as! Destination
            self.configureCell(cell, withDestination: destination, atIndexPath: indexPath!)
            
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
}

