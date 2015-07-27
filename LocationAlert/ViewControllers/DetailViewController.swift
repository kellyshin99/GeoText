//
//  DetailViewController.swift
//  LocationAlert
//
//  Created by Kelly Shin on 7/22/15.
//  Copyright (c) 2015 KellyShin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AddressBookUI

class DetailViewController: UIViewController, UITextFieldDelegate, ABPeoplePickerNavigationControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var address: UITextView!
    @IBOutlet weak var contactName: UITextField!
    var addressBook: ABAddressBook!
    var person: ABRecord!
    let locationManager = CLLocationManager()
    var location = kCLLocationCoordinate2DInvalid
    var DViewController: MapViewController = MapViewController()
    
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
            self.showContacts()
        }
        
    }
    
    @IBAction func set() {
        locationManager.delegate = self
        let region = CLCircularRegion(center: self.location, radius: 100.0, identifier: "geofence")
        self.locationManager.startMonitoringForRegion(region)
        
        navigationController!.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contactName.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayAddress() {

    }
    
    func geofenceRegion() {
        
    }
    
}

