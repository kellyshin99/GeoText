//
//  ViewController.swift
//  LocationAlert
//
//  Created by Kelly Shin on 7/15/15.
//  Copyright (c) 2015 KellyShin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import MessageUI

class MapViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var bottomSpaceContraint: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    var matchingItems: [MKMapItem] = [MKMapItem]()
    let locationManager = CLLocationManager()
    var overlay: MKOverlay!
    
    var storedLocation: CLLocationCoordinate2D? = nil
    
    @IBAction func showUserLocation() {
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            mapView.delegate = self
            mapView.showsUserLocation = true
            mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
        case .Denied, .Restricted:
            self.displayCantShowLocationAlert()
        case .NotDetermined:
            println("not determined")
        }
    }
    
    override func viewDidLoad() {
        mapView.delegate = self
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.requestAlwaysAuthorization()
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        mapView.showsUserLocation = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        locationManager.monitoredRegions
        
        if let storedLocation = storedLocation {
            var circle = MKCircle(centerCoordinate: storedLocation, radius: 60)
            mapView.addOverlay(circle)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func performSearch() {
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBar.text
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        
        search.startWithCompletionHandler({(response: MKLocalSearchResponse!, error: NSError!) in
            
            if error != nil {
                println("Error occured in search: \(error.localizedDescription)")
            } else if response.mapItems.count == 0 {
                println("No matches found")
            } else {
                println("Matches found")
                
                for item in response.mapItems as! [MKMapItem] {
                    var placemarks: NSMutableArray = NSMutableArray()
                    self.matchingItems.append(item as MKMapItem)
                    
                    var annotation = MKPointAnnotation()
                    annotation.coordinate = item.placemark.coordinate
                    annotation.title = item.name
                    self.mapView.addAnnotation(annotation)
                    self.mapView.showAnnotations(self.mapView.annotations, animated: true)
                    
                }
            }
        })
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation is MKUserLocation{
            return nil
        }
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if( pinView == nil) {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.draggable = false
            pinView!.animatesDrop = true
            pinView!.pinColor = .Red
            
            var calloutButton = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
            pinView!.rightCalloutAccessoryView = calloutButton
        } else {
            pinView!.annotation = annotation
        }
        return pinView!
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if control == view.rightCalloutAccessoryView {
            performSegueWithIdentifier("Detail", sender: view.annotation)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Detail" {
            storedLocation = (sender as! MKAnnotation).coordinate
         
            var detailVC = segue.destinationViewController as! DetailViewController
            detailVC.locationManager = locationManager
            detailVC.location = storedLocation
        }
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
            var circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.strokeColor = UIColor.purpleColor()
            circleRenderer.fillColor = UIColor.purpleColor()
            
            return circleRenderer
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        if region is CLCircularRegion {
            let alert = UIAlertController(title: "test", message: "test", preferredStyle: .Alert)
            // send text
        }
    }
    
    // MARK: Map Settings Alert
    
    func displayCantShowLocationAlert() {
        let cantShowLocationAlert = UIAlertController(title: "Location Services is Turned Off",
            message: "You must give the app permission to use Location Services.",
            preferredStyle: .Alert)
        cantShowLocationAlert.addAction(UIAlertAction(title: "Change Settings",
            style: .Default,
            handler: { action in
                self.openLocationSettings()
        }))
        cantShowLocationAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        presentViewController(cantShowLocationAlert, animated: true, completion: nil)
    }
    
    func openLocationSettings() {
        let url = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(url!)
    }
}

extension MapViewController: UISearchBarDelegate {
    
    func keyboardWillShow(notification: NSNotification) {
        self.searchBar.setShowsCancelButton(true, animated: true)
        if let info = notification.userInfo {
            var keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            UIView.animateWithDuration(3.0) {
                self.bottomSpaceContraint.constant = keyboardFrame.height
                self.view.layoutIfNeeded()
            }
            
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        mapView.removeAnnotations(mapView.annotations)
        performSearch()
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        
        UIView.animateWithDuration(0.3) {
            self.bottomSpaceContraint.constant = 44
            self.view.layoutIfNeeded()
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        UIView.animateWithDuration(0.3) {
            self.bottomSpaceContraint.constant = 44
            self.view.layoutIfNeeded()
        }
        
    }
}



