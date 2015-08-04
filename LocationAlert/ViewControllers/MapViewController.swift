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
import AddressBookUI

class MapViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var bottomSpaceContraint: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    var matchingItems: [MKMapItem] = [MKMapItem]()
    let locationManager = CLLocationManager()
    var overlay: MKOverlay!
    
    var storedLocation: CLLocationCoordinate2D? = nil
    
    @IBAction func showUserLocation() {
            mapView.delegate = self
            mapView.showsUserLocation = true
            mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
    }
    
    override func viewDidLoad() {
        mapView.delegate = self
        super.viewDidLoad()
        locationManager.requestAlwaysAuthorization()
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        mapView.showsUserLocation = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            println("authorized")
        case .Denied, .Restricted:
            self.displayCantShowLocationAlert()
        case .NotDetermined:
            println("not determined")
        }
    }
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(true)
//        
//        locationManager.monitoredRegions
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        if annotation is MKUserLocation {
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

//            var calloutButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
//            calloutButton.setTitle("Set", forState: .Normal)
//            calloutButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
//            pinView!.rightCalloutAccessoryView = calloutButton
            
        } else {
            pinView!.annotation = annotation
        }
        return pinView!
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if control == view.rightCalloutAccessoryView {
            storedLocation = view.annotation.coordinate
            
            let region = CLCircularRegion(center: storedLocation!, radius: 25.0, identifier: "geofence")
            self.locationManager.startMonitoringForRegion(region)

            geocodeLocation()
        }
    }
    
    func geocodeLocation() {
        var geocoder = CLGeocoder()
        var locationObject = CLLocation(latitude: storedLocation!.latitude, longitude: storedLocation!.longitude)
        geocoder.reverseGeocodeLocation(locationObject, completionHandler: { (placemarks, error) -> Void in
            if let placemarks = placemarks as? [CLPlacemark] {
                for placemark in placemarks {
                    var addressText = ABCreateStringWithAddressDictionary(placemark.addressDictionary, true)
//                    let addressArray = placemark.addressDictionary["FormattedAddressLines"] as! [String]
                    SharedData.locationAddress = addressText
                }
                self.performSegueWithIdentifier("unwindToMain", sender: self)
            } else {
                if error != nil {
                    let errorAlert = UIAlertController(title: "Error", message: "The address could not be loaded.", preferredStyle: .Alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                    self.presentViewController(errorAlert, animated: true, completion: nil)
                }
            }
        })
    }
    
    // MARK: Map Settings Alert
    
    func displayCantShowLocationAlert() {
        let cantShowLocationAlert = UIAlertController(title: "Location Services is Turned Off",
            message: "This app will not work without Location Services.",
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

