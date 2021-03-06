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
        print(NetworkClient.sharedInstance().defaults.object(forKey: "lastSyncDate") as? Date as Any)
        let lastSyncDate = NetworkClient.sharedInstance().defaults.object(forKey: "lastSyncDate")
        
        NetworkClient.sharedInstance().getRentals(lastSyncDate as! Date){(result, error) in
            
            if error == nil {
                DispatchQueue.main.async {
                    self.activityIndicator.hidesWhenStopped = true
                    self.activityIndicator.stopAnimating()
                }
                //store date of today's sync
               let lastSyncDate = result!["lastUpdate"]!
                NetworkClient.sharedInstance().defaults.set(lastSyncDate, forKey: "lastSyncDate")
                print("UpdatingViewController lastSyncDate from NSUserDefaults after sync: \(lastSyncDate)")
                
                self.presentingViewController?.dismiss(animated: true, completion: nil)

            } else {
                self.activityIndicator.hidesWhenStopped = true
                self.activityIndicator.stopAnimating()
                
                self.showAlertView(error?.localizedDescription)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.activityIndicator.startAnimating()
    }

    
    
    // MARK: - Helpers
    
    func showAlertView(_ errorMessage: String?) {
        
        let alertController = UIAlertController(title: nil, message: errorMessage!, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Dismiss", style: .cancel) {(action) in
         self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true){
            
        }
        
    }
}
