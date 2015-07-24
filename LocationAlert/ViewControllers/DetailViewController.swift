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
import MessageUI

protocol DetailViewControllerDelegate {
    
}

class DetailViewController: UIViewController, MKMapViewDelegate, ABPeoplePickerNavigationControllerDelegate, CLLocationManagerDelegate {

    var addressBook: ABAddressBook!
    var person: ABRecord!
    
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
    
    @IBAction func returnToMap() {
        navigationController!.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

