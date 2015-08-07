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
    var userLocation = MKUserLocation()
    
    @IBAction func cancel(sender: AnyObject?) {
        performSegueWithIdentifier("cancelToMain", sender: self)
        for region in locationManager.monitoredRegions {
            if let circularRegion = region as? CLCircularRegion {
                if circularRegion.identifier == "geofence" {
                    locationManager.stopMonitoringForRegion(circularRegion)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        address.text = SharedData.locationAddress
        cancelButton.layer.cornerRadius = 4.0
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        mapView.showsUserLocation = true
        self.mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
        
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
        println("did enter region")
        if region is CLCircularRegion {
            SharedData.sendText()
            for region in locationManager.monitoredRegions {
                if let circularRegion = region as? CLCircularRegion {
                    if circularRegion.identifier == "geofence" {
                        locationManager.stopMonitoringForRegion(circularRegion)
                    }
                }
            }
            dismissViewControllerAnimated(true, completion: nil)
        }
    }

    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        let region = locationManager.monitoredRegions
        if let circularRegion = region.first as? CLCircularRegion {
            let center = circularRegion.center
            var circle = MKCircle(centerCoordinate: center, radius: 60)
            mapView.addOverlay(circle)
            
            var annotation = MKPointAnnotation()
            annotation.coordinate = center
            self.mapView.addAnnotation(annotation)
            
            for annotation in mapView.annotations {
                var lat = mapView.userLocation.coordinate.latitude
                var long = mapView.userLocation.coordinate.longitude
                var userCoordinate = CLLocationCoordinate2DMake(lat, long)
                var userPoint: MKMapPoint = MKMapPointForCoordinate(userCoordinate)
                var pinPoint: MKMapPoint = MKMapPointForCoordinate(center)
                
                let padding = max(abs(userPoint.x - pinPoint.x), abs(userPoint.y - pinPoint.y)) * 0.2
                
                
                var userRect: MKMapRect = MKMapRectMake(userPoint.x - padding, userPoint.y - padding, padding*2, padding*2)
                var pinRect: MKMapRect = MKMapRectMake(pinPoint.x - padding, pinPoint.y - padding, padding*2, padding*2)
                var unionRect = MKMapRectUnion(userRect, pinRect)
                mapView.setVisibleMapRect(unionRect, animated: true)
                
                
            }
        }
    }
    
}
