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
    

    
    @IBAction func segmentedControlAction(sender: AnyObject) {
        
        
        
        switch sender.selectedSegmentIndex {
        case 0:
            self.segmentedControlIndex = 0
            mapView.removeAnnotations(wishlistHousesAnnotationsArray!)
            clusteringManager.removeAnnotations(wishlistHousesAnnotationsArray!)
            clusteringManager.addAnnotations(allHousesAnnotationsArray!)
            self.showMapRect(latitude: 44.281863, longitude: 16.382595)
            
        case 1:
            self.segmentedControlIndex = 1
            self.showHousesFromWishlist()
            mapView.removeAnnotations(allHousesAnnotationsArray!)
            clusteringManager.removeAnnotations(allHousesAnnotationsArray!)
            self.showMapRect(latitude: 44.281862, longitude: 16.382594)
            
        case 2:
            self.segmentedControlIndex = 2
            return
            
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
}

    
extension MapTabViewController : FBClusteringManagerDelegate {
    
    func cellSizeFactorForCoordinator(coordinator:FBClusteringManager) -> CGFloat{
        return 1.0
    }
    
}


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

extension MapTabViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        NetworkClient.sharedInstance().userLocationLatitude = (locations.last?.coordinate.latitude)!
        NetworkClient.sharedInstance().userLocationLongitude = (locations.last?.coordinate.longitude)!
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
}