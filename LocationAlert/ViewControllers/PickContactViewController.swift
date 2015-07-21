//
//  SelectContactsTableViewController.swift
//  LocationAlert
//
//  Created by Kelly Shin on 7/17/15.
//  Copyright (c) 2015 KellyShin. All rights reserved.
//

import UIKit
import AddressBookUI

class PickContactViewController: UIViewController, ABPeoplePickerNavigationControllerDelegate {
    
    var addressBook: ABAddressBook!
    var authDone = false
    var person: ABRecord!
    
    @IBAction func showPicker(sender: AnyObject) {
        
        var picker: ABPeoplePickerNavigationController =  ABPeoplePickerNavigationController()
        
        picker.peoplePickerDelegate = self
        self.presentViewController(picker, animated: true, completion:nil)
    }//showPicker

    
    override func viewDidAppear(animated: Bool) {
        getContacts()
    }

    func getContacts() {
        let authorizationStatus = ABAddressBookGetAuthorizationStatus()
        if (authorizationStatus == ABAuthorizationStatus.NotDetermined) {
            var emptyDictionary: CFDictionaryRef?
            var addressBook = !(ABAddressBookCreateWithOptions(emptyDictionary, nil) != nil)
            ABAddressBookRequestAccessWithCompletion(addressBook,{success, error in
                if success {
                    self.addressBook = addressBook
                }
                else {
                    self.displayCantShowContactsAlert()
                }
            })
        } else if (authorizationStatus == ABAuthorizationStatus.Denied || authorizationStatus == ABAuthorizationStatus.Restricted) {
            println("access denied")
        } else if (authorizationStatus == ABAuthorizationStatus.Authorized) {
            println("access granted")
        }
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

func peoplePickerNavigationControllerDidCancel(peoplePicker: ABPeoplePickerNavigationController!) {
    peoplePicker.dismissViewControllerAnimated(true, completion: nil)
}

}


