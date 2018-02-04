//
//  HousesViewController.swift
//  Apartments Croatia
//
//  Created by Ivan Kodrnja on 15/07/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class HousesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, FBAdViewDelegate, FBNativeAdsManagerDelegate, FBNativeAdDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    // variable will be initialized from previous VC
    var destination : Destination?
    
    // FB Audience Network
    let adRowStep = 4
    var adsManager: FBNativeAdsManager!
    var adsCellProvider: FBNativeAdTableViewCellProvider!
    
    var nativeAd: FBNativeAd!
    
    lazy var adBannerView: FBAdView = {
        let adBannerView = FBAdView(placementID: "IMG_16_9_APP_INSTALL#287352068455477_291275918063092", adSize: kFBAdSizeHeight90Banner, rootViewController: self)
        adBannerView.delegate = self
        
        return adBannerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "adCell")
        
        
        // fetch results
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
        fetchedResultsController.delegate = self
        self.navigationItem.title = destination?.name
        Analytics.logEvent(AnalyticsEventViewItemList, parameters: [AnalyticsParameterItemCategory : destination!.name])
        
        tableView.tableFooterView = UIView()

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        configureAdManagerAndLoadAds()

        //adBannerView.loadAd()
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
        fetchRequest.predicate = NSPredicate(format: "destination.name == %@", self.destination!.name)
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.sharedContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    // MARK: - Table View
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if adsCellProvider != nil && adsCellProvider.isAdCell(at: indexPath, forStride: UInt(adRowStep)) {
            return adsCellProvider.tableView(tableView, heightForRowAt: indexPath)
        } else {
            return 350
        }

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
       // return sectionInfo.numberOfObjects
        
        if adsCellProvider != nil {
            return Int(adsCellProvider.adjustCount(UInt(sectionInfo.numberOfObjects), forStride: UInt(adRowStep)))
        }
        else {
            return sectionInfo.numberOfObjects
        }

    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /* Get cell type */
        /*
        let house = fetchedResultsController.object(at: indexPath)
        let cellReuseIdentifier = "HousesCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)! as! HouseTableViewCell
        
        configureCell(cell, withHouse: house, atIndexPath: indexPath)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
        */

     if adsCellProvider != nil && adsCellProvider.isAdCell(at: indexPath, forStride: UInt(adRowStep)) {

            return adsCellProvider.tableView(tableView, cellForRowAt: indexPath)
        }
        else {
 
            // we avoid crashes that can happen when scrolling to a row with an index greater than or equal to the length of the fetchedResultsController. Instead of e.g. 20 rows (as many as the items in the fetchedResultsController), we’re going to have six more rows because of the ads that will be added to the tableview, therefore it’s important to adjust the index of the array.
            let tempIndexPath = indexPath.row - Int(indexPath.row / adRowStep)
        
            
            let house = fetchedResultsController.object(at: IndexPath(row: tempIndexPath, section: indexPath.section))
            let cellReuseIdentifier = "HousesCell"
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)! as! HouseTableViewCell
            
            configureCell(cell, withHouse: house, atIndexPath: IndexPath(row: tempIndexPath, section: indexPath.section))
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            return cell
        }
 
    
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
        
        // we avoid crashes that can happen when scrolling to a row with an index greater than or equal to the length of the fetchedResultsController. Instead of e.g. 20 rows (as many as the items in the fetchedResultsController), we’re going to have six more rows because of the ads that will be added to the tableview, therefore it’s important to adjust the index of the array.
        let tempIndexPath = indexPath.row - Int(indexPath.row / adRowStep)
        
        
        let controller = storyboard!.instantiateViewController(withIdentifier: "HouseDetailTableViewController") as! HouseDetailTableViewController
        let house = fetchedResultsController.object(at: IndexPath(row: tempIndexPath, section: indexPath.section))
        //let house = fetchedResultsController.object(at: indexPath)
        // set destination object in the detail VC
        controller.house = house
        
        self.navigationController!.pushViewController(controller, animated: true)
        
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
    

    // MARK: FBAdViewDelegate Methods for banner ad
    
    func adViewDidLoad(_ adView: FBAdView) {
        
        print("Banner loaded successfully")
        
        // Reposition the banner ad to create a slide down effect
        let translateTransform = CGAffineTransform(translationX: 0, y: -adView.bounds.size.height)
        adView.transform = translateTransform
        
        UIView.animate(withDuration: 0.5) {
            self.tableView.tableHeaderView?.frame = adView.frame
            adView.transform = CGAffineTransform.identity
            self.tableView.tableHeaderView = adView
        }
        
    }
    
    func adView(_ adView: FBAdView, didFailWithError error: Error) {
        print(error)
    }
    
    func adViewDidClick(_ adView: FBAdView) {
        print("Did tap on ad view")
    }
    
    // MARK: FBAdViewDelegate Methods for native ads in tableview
    func configureAdManagerAndLoadAds() {
        if adsManager == nil {
            adsManager = FBNativeAdsManager(placementID: "IMG_16_9_APP_INSTALL#287352068455477_287361241787893", forNumAdsRequested: 5)
            adsManager.delegate = self
            adsManager.loadAds()
        }
    }
    
    func nativeAdsLoaded() {
        adsCellProvider = FBNativeAdTableViewCellProvider(manager: adsManager, for: FBNativeAdViewType.genericHeight120)
        adsCellProvider.delegate = self
        
        print("adsCellProvider:\(adsCellProvider)")
        
        /*
        if tableView != nil {
            tableView.reloadData()
        }
        */
    }
    
    func nativeAdsFailedToLoadWithError(_ error: Error) {
        print(error)
    }
    
    func nativeAdDidClick(_ nativeAd: FBNativeAd) {
        print("Ad tapped: \(String(describing: nativeAd.title))")
    }
    
}
