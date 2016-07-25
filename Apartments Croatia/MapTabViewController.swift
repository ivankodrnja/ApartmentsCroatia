//
//  MapTabViewController.swift
//  Apartments Croatia
//
//  Created by Ivan Kodrnja on 25/07/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapTabViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!

    // latitude and longitude will be set from the previous VC
    var latitude: Double?
    var longitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        latitude = 45.34054
        longitude = 15.4757
        
        // Do any additional setup after loading the view.
        
        mapView.mapType = MKMapType.Hybrid
        
        // draw the location of the house
        let location = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        let span = MKCoordinateSpanMake(6.9, 6.9)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
    }
    
}
