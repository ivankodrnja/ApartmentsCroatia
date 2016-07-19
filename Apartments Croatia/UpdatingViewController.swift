//
//  UpdatingViewController.swift
//  Apartments Croatia
//
//  Created by Ivan Kodrnja on 18/07/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import UIKit

class UpdatingViewController: UIViewController {

    @IBOutlet weak var syncingLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // check when is the database last synced
        self.syncingLabel.text = "Syncing database with the server. Please wait."
        print(NetworkClient.sharedInstance().defaults.objectForKey("lastSyncDate") as? NSDate)
        let lastSyncDate = NetworkClient.sharedInstance().defaults.objectForKey("lastSyncDate") as? NSDate ?? NSDate()
        print("UpdatingViewController lastSyncDate from NSUserDefaults: \(lastSyncDate)")
        
        NetworkClient.sharedInstance().getRentals(lastSyncDate){(result, error) in
            
            if error == nil {
                
                self.activityIndicator.hidesWhenStopped = true
                self.activityIndicator.stopAnimating()

                //store date of today's sync
               let lastSyncDate = result!["lastUpdate"]!
                NetworkClient.sharedInstance().defaults.setObject(lastSyncDate, forKey: "lastSyncDate")
                print("UpdatingViewController lastSyncDate from NSUserDefaults after sync: \(lastSyncDate)")
                
                self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                //TODO: handle error
            } else {
                self.activityIndicator.hidesWhenStopped = true
                self.activityIndicator.stopAnimating()
                
                self.showAlertView(error?.localizedDescription)
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.activityIndicator.startAnimating()
    }

    
    
    // MARK: - Helpers
    
    func showAlertView(errorMessage: String?) {
        
        let alertController = UIAlertController(title: nil, message: errorMessage!, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Dismiss", style: .Cancel) {(action) in
         self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true){
            
        }
        
    }
}
