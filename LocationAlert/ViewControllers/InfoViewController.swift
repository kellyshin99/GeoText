//
//  InfoViewController.swift
//  LocationAlert
//
//  Created by Kelly Shin on 8/4/15.
//  Copyright (c) 2015 KellyShin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class InfoViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var address: UITextView!
    var locationManager: CLLocationManager!
    var overlay: MKOverlay!
    var location: CLLocationCoordinate2D?
    
    @IBAction func cancel(sender: AnyObject?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        address.text = SharedData.locationAddress
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        mapView.showsUserLocation = true
        self.mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
        
        let region = locationManager.monitoredRegions
        if let circularRegion = region.first as? CLCircularRegion {
            let center = circularRegion.center
            var circle = MKCircle(centerCoordinate: center, radius: 60)
            mapView.addOverlay(circle)
            
            var annotation = MKPointAnnotation()
            annotation.coordinate = center
            self.mapView.addAnnotation(annotation)
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
 
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        var circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.lineWidth = 2.0
        circleRenderer.strokeColor = UIColor.purpleColor()
        circleRenderer.fillColor = UIColor.purpleColor().colorWithAlphaComponent(0.4)
        
        return circleRenderer
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        if region is CLCircularRegion {
//            SharedData.sendText()
            for region in locationManager.monitoredRegions {
                if let circularRegion = region as? CLCircularRegion {
                    if circularRegion.identifier == "geofence" {
                        locationManager.stopMonitoringForRegion(circularRegion)
                    }
                }
            }
        }
    }

    
}
