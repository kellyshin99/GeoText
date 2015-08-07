//
//  MainViewController.swift
//  LocationAlert
//
//  Created by Kelly Shin on 8/3/15.
//  Copyright (c) 2015 KellyShin. All rights reserved.
//

import UIKit
import CoreLocation
import AddressBookUI

class MainViewController: UIViewController {

    var addressBook: ABAddressBook!
    var person: ABRecord!
    var location: CLLocationCoordinate2D? = nil
    let locationManager = CLLocationManager()
    var nameTextField: UITextField!

    @IBOutlet weak var chooseContactButton: UIButton!
    @IBOutlet weak var chooseLocationButton: UIButton!
    @IBOutlet weak var setButton: UIButton!
    
    @IBAction func chooseContact(sender: AnyObject) {
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
            self.displayCantShowContactsAlert()
        } else if (authorizationStatus == ABAuthorizationStatus.Authorized) {
            self.showContacts()
        }

    }
    
    @IBAction func set(sender: AnyObject) {
        if locationManager.monitoredRegions.isEmpty {
            let chooseLocationAlert = UIAlertController(title: "Please choose a location.", message: "", preferredStyle: .Alert)
            chooseLocationAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            presentViewController(chooseLocationAlert, animated: true, completion: nil)
        } else if SharedData.currentPhoneNumber.isEmpty == true {
            let addContactAlert = UIAlertController(title: "Select a Contact", message: "Please select a contact to send a text message to.", preferredStyle: .Alert)
            addContactAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            presentViewController(addContactAlert, animated: true, completion: nil)
        } else {
            nameAlert()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        chooseLocationButton.layer.cornerRadius = 4.0
        chooseContactButton.layer.cornerRadius = 4.0
        setButton.layer.cornerRadius = 4.0
        
        chooseLocationButton.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        chooseLocationButton.titleLabel?.textAlignment = NSTextAlignment.Left
        
        if SharedData.locationAddress.isEmpty == false {
            chooseLocationButton.setTitle(SharedData.locationAddress, forState: .Normal)
        } else {
                chooseLocationButton.setTitle("Choose Location", forState: .Normal)
        }
        
        if SharedData.contactName.isEmpty == false {
            chooseContactButton.setTitle(SharedData.contactName, forState: .Normal)
        } else {
            chooseContactButton.setTitle("Choose Contact", forState: .Normal)
        }
        
        locationManager.delegate = nil
    }
    
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {
        if segue.identifier == "unwindToMain" {
            locationManager.delegate = nil
            var vc = segue.sourceViewController as! MapViewController
            vc.location = location
        } else {
            if segue.identifier == "cancelToMain" {
                segue.sourceViewController as! InfoViewController
                locationManager.delegate = nil
                SharedData.locationAddress = ""
                SharedData.currentPhoneNumber = ""
                SharedData.contactName = ""
                chooseContactButton.setTitle("Choose Contact", forState: .Normal)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMap" {
            var mapVC = segue.destinationViewController as! MapViewController
            mapVC.locationManager = locationManager
        } else {
            if segue.identifier == "showInfo" {
            var showInfoVC = segue.destinationViewController as! InfoViewController
            showInfoVC.locationManager = locationManager
            }
        }
    }
    
    func nameAlert() {
        var nameAlert = UIAlertController(title: "What is your name?", message: "This will be included in the text message.", preferredStyle: .Alert)
        nameAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        nameAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                self.performSegueWithIdentifier("showInfo", sender: nil)
                SharedData.currentUserName = self.nameTextField.text
            }))
        
        nameAlert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Enter name"
            textField.secureTextEntry = false
            textField.autocapitalizationType = UITextAutocapitalizationType.Words
            self.nameTextField = textField
        })
        self.presentViewController(nameAlert, animated: true, completion: nil)
    }
    
}

extension MainViewController: ABPeoplePickerNavigationControllerDelegate {
    func showContacts() {
        var picker: ABPeoplePickerNavigationController =  ABPeoplePickerNavigationController()
        
        picker.peoplePickerDelegate = self
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor()]

        self.presentViewController(picker, animated: true, completion:nil)
    }
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController!, didSelectPerson person: ABRecord!) {
        let numbers: ABMultiValueRef = ABRecordCopyValue(person, kABPersonPhoneProperty).takeRetainedValue()
        if (ABMultiValueGetCount(numbers) > 0) {
            let index = 0 as CFIndex
            let phoneNumber = ABMultiValueCopyValueAtIndex(numbers, index).takeRetainedValue() as! String
            SharedData.currentPhoneNumber = phoneNumber
        } else {
            println("No phone number")
        }
        
        let nameCFString : CFString = ABRecordCopyCompositeName(person).takeRetainedValue()
        let name : NSString = nameCFString as NSString
        SharedData.contactName = name as String
        chooseContactButton.setTitle("\(name)", forState: .Normal)
        peoplePicker.dismissViewControllerAnimated(true, completion: nil)

    }
    
    
    func peoplePickerNavigationControllerDidCancel(peoplePicker: ABPeoplePickerNavigationController!) {
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
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