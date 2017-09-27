//
//  MapTabViewController.swift
//  Apartments Croatia
//
//  Created by Ivan Kodrnja on 25/07/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import CoreLocation

class MapTabViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    // init of the FBClusterManager
    let clusteringManager = FBClusteringManager()
    
    // allhouses annotations array
    var allHousesAnnotationsArray : [MKAnnotation]?
    // wishlisthouses annotations array
    var wishlistHousesAnnotationsArray : [MKAnnotation]?
    
    //control over selcted segment in the segmented control
    var segmentedControlIndex: Int = 0
    
    // will serve for requesting the user current location
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("Map_Loaded")
        // show the map
        let latitude = 44.281863
        let longitude = 16.382595
        mapView.mapType = MKMapType.hybrid
        //showMapRect(latitude: latitude, longitude: longitude)
        
        // show all houses
        clusteringManager.delegate = self
        showAllHouses()
        showMapRect(latitude: latitude, longitude: longitude)
        // will serve for requesting the user current location
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        }
        
        segmentedControl.setTitle(NSLocalizedString("home", comment: "Home"), forSegmentAt: 0)
        segmentedControl.setTitle(NSLocalizedString("wishlist", comment: "Wishlist"), forSegmentAt: 1)
        segmentedControl.setTitle(NSLocalizedString("nearby", comment: "Nearby"), forSegmentAt: 2)
        segmentedControl.setTitle(NSLocalizedString("mapStyle", comment: "Map Style"), forSegmentAt: 3)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Start get the location on viewWillAppear
        locationManager.startUpdatingLocation()
        

    }
    
    // MARK: - Core Data Convenience
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    func getAllHousesLatLng() -> [House] {
        
        let getAllHousesLatLngFetchRequest = NSFetchRequest<House>(entityName: "House")
        let allLatLng = (try! sharedContext.fetch(getAllHousesLatLngFetchRequest))
        
        return allLatLng
        
    }
    
    func getWishlistHousesLatLng() -> [House] {
        
        let getAllHousesLatLngFetchRequest = NSFetchRequest<House>(entityName: "House")
        getAllHousesLatLngFetchRequest.predicate = NSPredicate(format: "favorite == %@", "Y")
        let allLatLng = (try! sharedContext.fetch(getAllHousesLatLngFetchRequest)) 
        
        return allLatLng
        
    }
    
    // MARK: - Utility
    
    func showAllHouses() {
        var fbArray:[FBAnnotation] = []
        let allLatLng = getAllHousesLatLng()
        
        for house in allLatLng {
            let a:FBAnnotation = FBAnnotation()
            a.coordinate = CLLocationCoordinate2D(latitude:house.latitude, longitude: house.longitude )
            a.title = house.name
            a.house = house
            fbArray.append(a)
        }
        allHousesAnnotationsArray = fbArray
        clusteringManager.add(annotations: allHousesAnnotationsArray!)
        

    }
    
    func showHousesFromWishlist() {
        var fbArray:[FBAnnotation] = []
        let allLatLng = getWishlistHousesLatLng()
        
        for house in allLatLng {
            let a:FBAnnotation = FBAnnotation()
            a.coordinate = CLLocationCoordinate2D(latitude:house.latitude, longitude: house.longitude )
            a.title = house.name
            a.house = house
            fbArray.append(a)
        }
        wishlistHousesAnnotationsArray = fbArray

        clusteringManager.add(annotations: wishlistHousesAnnotationsArray!)

    }
    
    func showMapRect(latitude: Double, longitude: Double) {
    
        mapView.showsPointsOfInterest = false
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpanMake(8.1, 8.1)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
    }
    
    func showNearbyMapRect(latitude: Double, longitude: Double) {
        
        mapView.showsPointsOfInterest = false
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpanMake(1.1, 1.1)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
    }


    
    @IBAction func segmentedControlAction(_ sender: AnyObject) {
        

        switch sender.selectedSegmentIndex {
        // show all houses
        case 0:
            // delete all previous annotations so they don't duplicate, depending if previous selection was wishlist or nearby
            if (self.segmentedControlIndex == 1){
                if wishlistHousesAnnotationsArray != nil {
                    mapView.removeAnnotations(wishlistHousesAnnotationsArray!)
                    //clusteringManager.removeAnnotations(wishlistHousesAnnotationsArray!)
                    clusteringManager.removeAll()
                }
            }
            if (self.segmentedControlIndex == 2){
                if allHousesAnnotationsArray != nil {
                    mapView.removeAnnotations(allHousesAnnotationsArray!)
                    //clusteringManager.removeAnnotations(allHousesAnnotationsArray!)
                    clusteringManager.removeAll()
                }
            }
            self.segmentedControlIndex = 0

            
            clusteringManager.add(annotations: allHousesAnnotationsArray!)
            self.showMapRect(latitude: 44.281863, longitude: 16.382595)
        // show houses from the wishlist
        case 1:
            // delete all previous annotations so they don't duplicate
            if (self.segmentedControlIndex == 0 || self.segmentedControlIndex == 2){
                if allHousesAnnotationsArray != nil {
                    mapView.removeAnnotations(allHousesAnnotationsArray!)
                    //clusteringManager.removeAnnotations(allHousesAnnotationsArray!)
                    clusteringManager.removeAll()
                }
            }
            self.segmentedControlIndex = 1
            
   
            
          //  if wishlistHousesAnnotationsArray != nil {
                self.showHousesFromWishlist()
            //}
            self.showMapRect(latitude: 44.281862, longitude: 16.382594)
        
        // show nearby houses
        case 2:
            // delete all previous annotations so they don't duplicate
            if (self.segmentedControlIndex == 0){
                if allHousesAnnotationsArray != nil {
                    mapView.removeAnnotations(allHousesAnnotationsArray!)
                    //clusteringManager.removeAnnotations(allHousesAnnotationsArray!)
                    clusteringManager.removeAll()
                }
            }
            if (self.segmentedControlIndex == 1){
                if wishlistHousesAnnotationsArray != nil {
                    mapView.removeAnnotations(wishlistHousesAnnotationsArray!)
                    //clusteringManager.removeAnnotations(wishlistHousesAnnotationsArray!)
                    clusteringManager.removeAll()
                }
            }
            clusteringManager.add(annotations: allHousesAnnotationsArray!)
            self.segmentedControlIndex = 2
            // check for location services
            if CLLocationManager.locationServicesEnabled() {
                switch(CLLocationManager.authorizationStatus()) {
                case .notDetermined:
                    locationManager.delegate = self
                    locationManager.requestWhenInUseAuthorization()
                    
                case .authorizedAlways, .authorizedWhenInUse:
                    locationManager.delegate = self
                    locationManager.startUpdatingLocation()
                    self.showNearbyMapRect(latitude: NetworkClient.sharedInstance().userLocationLatitude, longitude: NetworkClient.sharedInstance().userLocationLongitude)
                
                case .denied:
                    self.openSettingsToEnableLocationService()
                    
                case .restricted:
                    self.openSettingsToEnableLocationService()
                }
            }
            
            
        // choose map style
        case 3:
            // selected segment will remain the one which was previously selected
            self.segmentedControl.selectedSegmentIndex = self.segmentedControlIndex
            self.chooseMapStyle()
        default:
            return
        }
    }
    
    func chooseMapStyle() {
        
        let alert = UIAlertController(title: NSLocalizedString("chooseMapStyle", comment: "Choose Map Style"), message: nil, preferredStyle: .alert) // 1
        
        let firstAction = UIAlertAction(title: NSLocalizedString("standard", comment: "Standard"), style: .default) { (alert: UIAlertAction!) -> Void in
            self.mapView.mapType = MKMapType.standard
        }
        let secondAction = UIAlertAction(title: NSLocalizedString("satellite", comment: "Satellite"), style: .default) { (alert: UIAlertAction!) -> Void in
            self.mapView.mapType = MKMapType.satellite
        }
        let thirdAction = UIAlertAction(title: NSLocalizedString("hybrid", comment: "Hybrid"), style: .default) { (alert: UIAlertAction!) -> Void in
            self.mapView.mapType = MKMapType.hybrid
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: "Cancel"), style: .cancel) { (alert: UIAlertAction!) -> Void in
        }
        
        alert.addAction(firstAction)
        alert.addAction(secondAction)
        alert.addAction(thirdAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion:nil)
        
    }
    
    func openSettingsToEnableLocationService(){
        let alertController = UIAlertController (title: NSLocalizedString("enableLocationServices", comment: "Please enable location services in Settings"), message: NSLocalizedString("goToSettings", comment: "Go to Settings?"), preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: NSLocalizedString("settings", comment: "Settings"), style: .default) { (_) -> Void in
            let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
            if let url = settingsUrl {
                UIApplication.shared.openURL(url)
            }
    }
    
    let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: "Cancel"), style: .default, handler: nil)
    alertController.addAction(settingsAction)
    alertController.addAction(cancelAction)
    
    present(alertController, animated: true, completion: nil)
    }
}


extension MapTabViewController : FBClusteringManagerDelegate {
    func cellSizeFactor(forCoordinator coordinator: FBClusteringManager) -> CGFloat {
        return 1.0
    }
    
}

// MARK: - Map View Delegate

extension MapTabViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool){
        
        DispatchQueue.global(qos: .userInitiated).async{
            
            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            
            let mapRectWidth:Double = self.mapView.visibleMapRect.size.width
            
            let scale:Double = mapBoundsWidth / mapRectWidth
            
            let annotationArray = self.clusteringManager.clusteredAnnotations(withinMapRect: self.mapView.visibleMapRect, zoomScale:scale)
            DispatchQueue.main.async {
                self.clusteringManager.display(annotations:annotationArray, onMapView:self.mapView)
            }
            
        }
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var reuseId = ""
        
        if annotation.isKind(of: FBAnnotationCluster.self) {
            
            reuseId = "Cluster"
            var clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            
            if clusterView == nil {
                    clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId, configuration: FBAnnotationClusterViewConfiguration.default())
            } else {
                clusterView?.annotation = annotation
            }
            
            return clusterView
          
            // show user location as a blue dot
        } else if annotation.isKind(of: MKUserLocation.self) {
            return nil
            // show houses as green pins
        } else  {
            reuseId = "Pin"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
            
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pinView!.canShowCallout = true
                pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                
                pinView!.pinTintColor = UIColor.green
            } else {
                pinView?.annotation = annotation
            }
            
            return pinView
        }
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
            if control == annotationView.rightCalloutAccessoryView {
            let controller = storyboard!.instantiateViewController(withIdentifier: "HouseDetailTableViewController") as! HouseDetailTableViewController
            let object = annotationView.annotation as! FBAnnotation
            let house = object.house
            print(house!)
            // set destination object in the detail VC
            controller.house = house!
            
            self.navigationController!.pushViewController(controller, animated: true)

        }
    }
    
}

// MARK: - Location Delegate

extension MapTabViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        NetworkClient.sharedInstance().userLocationLatitude = (locations.last?.coordinate.latitude)!
        NetworkClient.sharedInstance().userLocationLongitude = (locations.last?.coordinate.longitude)!
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.startUpdatingLocation()

        }
    }
}
