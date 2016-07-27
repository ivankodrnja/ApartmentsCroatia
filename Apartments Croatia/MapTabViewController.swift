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


class MapTabViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    // init of the FBClusterManager
    let clusteringManager = FBClusteringManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let array:[MKAnnotation] = houseLocations()
        clusteringManager.addAnnotations(array)
        clusteringManager.delegate = self
        // show the map
        let latitude = 44.281863
        let longitude = 16.382595
        mapView.mapType = MKMapType.Hybrid
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpanMake(7.9, 7.9)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        /*
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
         */
    }
    
    // MARK: - Core Data Convenience
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    func getAllLatLng() -> [House] {
        
        let getAllLatLngFetchRequest = NSFetchRequest(entityName: "House")
        let allLatLng = (try! sharedContext.executeFetchRequest(getAllLatLngFetchRequest)) as! [House]
        
        return allLatLng
        
    }
    
    // MARK: - Utility
    
    func houseLocations() -> [FBAnnotation] {
        var array:[FBAnnotation] = []
        let allLatLng = getAllLatLng()
        
        for house in allLatLng {
            let a:FBAnnotation = FBAnnotation()
            a.coordinate = CLLocationCoordinate2D(latitude:house.latitude, longitude: house.longitude )
            a.title = house.name
            a.house = house
            array.append(a)
        }

        return array
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
            
        } else {
            
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