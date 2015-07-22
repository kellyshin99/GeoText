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
import AddressBook
import AddressBookUI

class MapViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate, ABPeoplePickerNavigationControllerDelegate {
    
    var delegate: ABPeoplePickerNavigationControllerDelegate!
    
    @IBOutlet weak var bottomSpaceContraint: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    var matchingItems: [MKMapItem] = [MKMapItem]()
    let locationManager = CLLocationManager()
    var addressBook: ABAddressBook!
    var person: ABRecord!
    
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
    
    @IBAction func showPicker(sender: AnyObject) {
        
        let authorizationStatus = ABAddressBookGetAuthorizationStatus()
        if (authorizationStatus == ABAuthorizationStatus.NotDetermined) {
            var emptyDictionary: CFDictionaryRef?
            var addressBook = !(ABAddressBookCreateWithOptions(emptyDictionary, nil) != nil)
            ABAddressBookRequestAccessWithCompletion(addressBook,{success, error in
                if success {
                    self.addressBook = addressBook
                    self.showContacts()
                }
                else {
                    self.displayCantShowContactsAlert()
                }
            })
        } else if (authorizationStatus == ABAuthorizationStatus.Denied || authorizationStatus == ABAuthorizationStatus.Restricted) {
            println("access denied")
        } else if (authorizationStatus == ABAuthorizationStatus.Authorized) {
            println("access granted")
            self.showContacts()
        }
       
    }

    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {

        mapView.removeAnnotations(mapView.annotations)
        performSearch()
        searchBar.resignFirstResponder()
        
        UIView.animateWithDuration(0.3) {
            self.bottomSpaceContraint.constant = 44
            self.view.layoutIfNeeded()
        }
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
    
    override func viewDidLoad() {
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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


// MARK: People Picker

    func showContacts() {
        var picker: ABPeoplePickerNavigationController =  ABPeoplePickerNavigationController()
        
        picker.peoplePickerDelegate = self
        self.presentViewController(picker, animated: true, completion:nil)
    }
    
    func displayCantShowContactsAlert() {
        let cantShowContactAlert = UIAlertController(title: "Cannot Show Contacts",
            message: "You must give the app permission to acces your contacts.",
            preferredStyle: .Alert)
        cantShowContactAlert.addAction(UIAlertAction(title: "Change Settings",
            style: .Default,
            handler: { action in
                self.openSettings()
        }))
        cantShowContactAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        presentViewController(cantShowContactAlert, animated: true, completion: nil)
    }

    func openSettings() {
        let url = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(url!)
    }

    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController!, shouldContinueAfterSelectingPerson person: ABRecordRef!) -> Bool {
        
        peoplePickerNavigationController(peoplePicker, shouldContinueAfterSelectingPerson: person)
        
        peoplePicker.dismissViewControllerAnimated(true, completion: nil)
        
        return false;
    }
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController!, didSelectPerson person: ABRecord!) {
        let numbers: ABMultiValueRef = ABRecordCopyValue(person, kABPersonPhoneProperty).takeRetainedValue()
        if (ABMultiValueGetCount(numbers) > 0) {
            let index = 0 as CFIndex
            let phoneNumber = ABMultiValueCopyValueAtIndex(numbers, index).takeRetainedValue() as! String
            println(phoneNumber)
        } else {
            println("No phone number")
        }
        
    }
    
    func peoplePickerNavigationControllerDidCancel(peoplePicker: ABPeoplePickerNavigationController!) {
        peoplePicker.dismissViewControllerAnimated(true, completion: nil)
    }

}


