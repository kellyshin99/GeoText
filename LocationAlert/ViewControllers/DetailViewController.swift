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

class DetailViewController: UIViewController, UITextFieldDelegate, ABPeoplePickerNavigationControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UITextViewDelegate {
    
    @IBOutlet weak var address: UITextView!
    @IBOutlet weak var contactName: UITextView!
    var addressBook: ABAddressBook!
    var person: ABRecord!
    var locationManager: CLLocationManager!
    var location: CLLocationCoordinate2D!
    
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
        if contactName.text == "Contact Name" {
            let alert = UIAlertView(title: "Select a Contact", message: "Please select a contact to message", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        } else {
            
            let region = CLCircularRegion(center: self.location, radius: 25.0, identifier: "geofence")
            self.locationManager.startMonitoringForRegion(region)
            
            performSegueWithIdentifier("chooseContact", sender: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        geocodeLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func geocodeLocation() {
        var geocoder = CLGeocoder()
        var locationObject = CLLocation(latitude: location.latitude, longitude: location.longitude)
        geocoder.reverseGeocodeLocation(locationObject, completionHandler: { (placemarks, error) -> Void in
            if let placemarks = placemarks as? [CLPlacemark] {
                for placemark in placemarks {
                    var addressText = ABCreateStringWithAddressDictionary(placemark.addressDictionary, true)
                    self.address.text = addressText
                    SharedData.locationAddress = addressText
                }
            } else {
                if error != nil {
                    let errorAlert = UIAlertView(title: "Error", message: "The address could not be loaded.", delegate: self, cancelButtonTitle: "OK")
                    errorAlert.show()
                }
            }
        })
    }
    
}

extension DetailViewController: ABPeoplePickerNavigationControllerDelegate {
    func showContacts() {
        var picker: ABPeoplePickerNavigationController =  ABPeoplePickerNavigationController()
        
        picker.peoplePickerDelegate = self
        self.presentViewController(picker, animated: true, completion:nil)
    }
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController!, shouldContinueAfterSelectingPerson person: ABRecordRef!) -> Bool {
        
        peoplePickerNavigationController(peoplePicker, shouldContinueAfterSelectingPerson: person)
        
        peoplePicker.dismissViewControllerAnimated(true, completion: nil)
        
        return false
    }
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController!, didSelectPerson person: ABRecord!) {
        let numbers: ABMultiValueRef = ABRecordCopyValue(person, kABPersonPhoneProperty).takeRetainedValue()
        if (ABMultiValueGetCount(numbers) > 0) {
            let index = 0 as CFIndex
            let phoneNumber = ABMultiValueCopyValueAtIndex(numbers, index).takeRetainedValue() as! String
            SharedData.currentPhoneNumber = phoneNumber
            SharedData.sendText()
        } else {
            println("No phone number")
        }
        
        let nameCFString : CFString = ABRecordCopyCompositeName(person).takeRetainedValue()
        let name : NSString = nameCFString as NSString
        contactName.text = name as String
    }
    
    
    func peoplePickerNavigationControllerDidCancel(peoplePicker: ABPeoplePickerNavigationController!) {
        peoplePicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Contact Settings Alert
    
    func displayCantShowContactsAlert() {
        let cantShowContactAlert = UIAlertController(title: "Cannot Show Contacts",
            message: "You must give the app permission to acces your contacts.",
            preferredStyle: .Alert)
        cantShowContactAlert.addAction(UIAlertAction(title: "Change Settings",
            style: .Default,
            handler: { action in
                self.openContactSettings()
        }))
        cantShowContactAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        presentViewController(cantShowContactAlert, animated: true, completion: nil)
    }
    
    func openContactSettings() {
        let url = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(url!)
    }
    
}

