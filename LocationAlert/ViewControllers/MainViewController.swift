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
    var location: CLLocationCoordinate2D!
    @IBOutlet weak var chooseContactButton: UIButton!
    @IBOutlet var locationAddress: UITextView!
    
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
            println("access denied")
        } else if (authorizationStatus == ABAuthorizationStatus.Authorized) {
            self.showContacts()
        }

    }
    
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {
        if segue.identifier == "unwindToMain" {
            segue.sourceViewController as! MapViewController
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        locationAddress.text = SharedData.locationAddress
    }

}

extension MainViewController: ABPeoplePickerNavigationControllerDelegate {
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
        } else {
            println("No phone number")
        }
        
        let nameCFString : CFString = ABRecordCopyCompositeName(person).takeRetainedValue()
        let name : NSString = nameCFString as NSString
        chooseContactButton.setTitle("\(name)", forState: .Normal)
//        contactName.text = name as String
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