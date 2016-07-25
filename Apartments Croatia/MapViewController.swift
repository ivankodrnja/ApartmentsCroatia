//
//  MapViewController.swift
//  Apartments Croatia
//
//  Created by Ivan Kodrnja on 25/07/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    // latitude and longitude will be set from the previous VC
    var latitude: Double?
    var longitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Get directions", style: .Plain, target: self, action: #selector(getDirections))
        
        
        mapView.mapType = MKMapType.Hybrid
        
        // draw the location of the house
        let location = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        let span = MKCoordinateSpanMake(0.03, 0.03)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getDirections(){
        
        
        
        print(NetworkClient.sharedInstance().userLocationLatitude)
        print(NetworkClient.sharedInstance().userLocationLongitude)
        
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!), addressDictionary: nil))
        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMapsWithLaunchOptions(launchOptions)

    }

}