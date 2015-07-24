//
//  PeoplePicker.swift
//  LocationAlert
//
//  Created by Kelly Shin on 7/23/15.
//  Copyright (c) 2015 KellyShin. All rights reserved.
//

import Foundation
import AddressBookUI

extension DetailViewController: ABPeoplePickerNavigationControllerDelegate {
    func showContacts() {
        var picker: ABPeoplePickerNavigationController =  ABPeoplePickerNavigationController()
        
        picker.peoplePickerDelegate = self
        self.presentViewController(picker, animated: true, completion:nil)
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