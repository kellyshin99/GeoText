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
        
        navigationController!.popViewControllerAnimated(true)
        }
    }
    
//    @IBAction func sendMessage(sender: UIButton) {
//        if (MFMessageComposeViewController.canSendText()) {
//            let controller = MFMessageComposeViewController()
//            controller.body = "Hello world"
//            controller.recipients = []
//            controller.messageComposeDelegate = self
//            self.presentViewController(controller, animated: true, completion: nil)
//        } else {
//            let errorAlert = UIAlertView(title: "Cannot Send Message", message: "Sorry, your device is unable to send messages", delegate: self, cancelButtonTitle: "OK")
//            errorAlert.show()
//        }
//    }
//    
//    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
//        self.dismissViewControllerAnimated(true, completion: nil)
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
}



