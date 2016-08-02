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

        // show the map
        let latitude = 44.281863
        let longitude = 16.382595
        mapView.mapType = MKMapType.Hybrid
        showMapRect(latitude: latitude, longitude: longitude)
        
        // show all houses
        clusteringManager.delegate = self
        showAllHouses()
        
        // will serve for requesting the user current location
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        // Start get the location on viewWillAppear
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Core Data Convenience
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    func getAllHousesLatLng() -> [House] {
        
        let getAllHousesLatLngFetchRequest = NSFetchRequest(entityName: "House")
        let allLatLng = (try! sharedContext.executeFetchRequest(getAllHousesLatLngFetchRequest)) as! [House]
        
        return allLatLng
        
    }
    
    func getWishlistHousesLatLng() -> [House] {
        
        let getAllHousesLatLngFetchRequest = NSFetchRequest(entityName: "House")
        getAllHousesLatLngFetchRequest.predicate = NSPredicate(format: "favorite == %@", "Y")
        let allLatLng = (try! sharedContext.executeFetchRequest(getAllHousesLatLngFetchRequest)) as! [House]
        
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

        clusteringManager.addAnnotations(allHousesAnnotationsArray!)
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

        clusteringManager.addAnnotations(wishlistHousesAnnotationsArray!)

    }
    
    func showMapRect(latitude latitude: Double, longitude: Double) {
    
        mapView.showsPointsOfInterest = false
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpanMake(8.1, 8.1)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
    }
    
    func showNearbyMapRect(latitude latitude: Double, longitude: Double) {
        
        mapView.showsPointsOfInterest = false
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpanMake(1.1, 1.1)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
    }


    
    @IBAction func segmentedControlAction(sender: AnyObject) {
        

        switch sender.selectedSegmentIndex {
        // show all houses
        case 0:
            // delete all previous annotations so they don't duplicate, depending if previous selection was wishlist or nearby
            if (self.segmentedControlIndex == 1){
                if wishlistHousesAnnotationsArray != nil {
                    mapView.removeAnnotations(wishlistHousesAnnotationsArray!)
                    clusteringManager.removeAnnotations(wishlistHousesAnnotationsArray!)
                }
            }
            if (self.segmentedControlIndex == 2){
                if allHousesAnnotationsArray != nil {
                    mapView.removeAnnotations(allHousesAnnotationsArray!)
                    clusteringManager.removeAnnotations(allHousesAnnotationsArray!)
                }
            }
            self.segmentedControlIndex = 0

            
            clusteringManager.addAnnotations(allHousesAnnotationsArray!)
            self.showMapRect(latitude: 44.281863, longitude: 16.382595)
        // show houses from the wishlist
        case 1:
            // delete all previous annotations so they don't duplicate
            if (self.segmentedControlIndex == 0 || self.segmentedControlIndex == 2){
                if allHousesAnnotationsArray != nil {
                    mapView.removeAnnotations(allHousesAnnotationsArray!)
                    clusteringManager.removeAnnotations(allHousesAnnotationsArray!)
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
                    clusteringManager.removeAnnotations(allHousesAnnotationsArray!)
                }
            }
            if (self.segmentedControlIndex == 1){
                if wishlistHousesAnnotationsArray != nil {
                    mapView.removeAnnotations(wishlistHousesAnnotationsArray!)
                    clusteringManager.removeAnnotations(wishlistHousesAnnotationsArray!)
                }
            }
            clusteringManager.addAnnotations(allHousesAnnotationsArray!)
            self.segmentedControlIndex = 2
            // check for location services
            if CLLocationManager.locationServicesEnabled() {
                switch(CLLocationManager.authorizationStatus()) {
                case .NotDetermined:
                    locationManager.delegate = self
                    locationManager.requestWhenInUseAuthorization()
                    
                case .AuthorizedAlways, .AuthorizedWhenInUse:
                    locationManager.delegate = self
                    locationManager.startUpdatingLocation()
                    self.showNearbyMapRect(latitude: NetworkClient.sharedInstance().userLocationLatitude, longitude: NetworkClient.sharedInstance().userLocationLongitude)
                
                case .Denied:
                    self.openSettingsToEnableLocationService()
                    
                case .Restricted:
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
        
        let alert = UIAlertController(title: "Choose Map Style", message: nil, preferredStyle: .Alert) // 1
        
        let firstAction = UIAlertAction(title: "Standard", style: .Default) { (alert: UIAlertAction!) -> Void in
            self.mapView.mapType = MKMapType.Standard
        }
        let secondAction = UIAlertAction(title: "Satellite", style: .Default) { (alert: UIAlertAction!) -> Void in
            self.mapView.mapType = MKMapType.Satellite
        }
        let thirdAction = UIAlertAction(title: "Hybrid", style: .Default) { (alert: UIAlertAction!) -> Void in
            self.mapView.mapType = MKMapType.Hybrid
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert: UIAlertAction!) -> Void in
        }
        
        alert.addAction(firstAction)
        alert.addAction(secondAction)
        alert.addAction(thirdAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion:nil)
        
    }
    
    func openSettingsToEnableLocationService(){
        let alertController = UIAlertController (title: "Please enable location services in Settings", message: "Go to Settings?", preferredStyle: .Alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .Default) { (_) -> Void in
            let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
            if let url = settingsUrl {
                UIApplication.sharedApplication().openURL(url)
            }
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
    alertController.addAction(settingsAction)
    alertController.addAction(cancelAction)
    
    presentViewController(alertController, animated: true, completion: nil)
    }
}


extension MapTabViewController : FBClusteringManagerDelegate {
    
    func cellSizeFactorForCoordinator(coordinator:FBClusteringManager) -> CGFloat{
        return 1.0
    }
    
}

// MARK: - Map View Delegate

extension MapTabViewController : MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool){
        
        NSOperationQueue().addOperationWithBlock({
            
            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            
            let mapRectWidth:Double = self.mapView.visibleMapRect.size.width
            
            let scale:Double = mapBoundsWidth / mapRectWidth
            
            let annotationArray = self.clusteringManager.clusteredAnnotationsWithinMapRect(self.mapView.visibleMapRect, withZoomScale:scale)
            
            self.clusteringManager.displayAnnotations(annotationArray, onMapView:self.mapView)
        
            
        })
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        var reuseId = ""
        
        if annotation.isKindOfClass(FBAnnotationCluster) {
            
            reuseId = "Cluster"
            var clusterView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId, options: nil)
            
            return clusterView
          
            // show user location as a blue dot
        } else if annotation.isKindOfClass(MKUserLocation) {
            return nil
            // show houses as green pins
        } else  {
            reuseId = "Pin"
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            
            pinView!.pinTintColor = UIColor.greenColor()
            
            return pinView
        }
        
    }
    
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let controller = storyboard!.instantiateViewControllerWithIdentifier("HouseDetailTableViewController") as! HouseDetailTableViewController
            let object = annotationView.annotation as! FBAnnotation
            let house = object.house
            print(house)
            // set destination object in the detail VC
            controller.house = house!
            
            self.navigationController!.pushViewController(controller, animated: true)

        }
    }
    
}

// MARK: - Location Delegate

extension MapTabViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        NetworkClient.sharedInstance().userLocationLatitude = (locations.last?.coordinate.latitude)!
        NetworkClient.sharedInstance().userLocationLongitude = (locations.last?.coordinate.longitude)!
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse || status == .AuthorizedAlways {
            manager.startUpdatingLocation()

        }
    }
}