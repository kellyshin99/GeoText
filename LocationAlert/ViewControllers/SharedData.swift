//
//  SharedData.swift
//  LocationAlert
//
//  Created by Kelly Shin on 7/30/15.
//  Copyright (c) 2015 KellyShin. All rights reserved.
//

import Foundation
import UIKit

struct SharedData {
    static var currentPhoneNumber = "" {
        didSet {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setValue(currentPhoneNumber, forKey: "currentPhoneNumber")
        }
    }
    static var currentUserName = "" {
        didSet {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setValue(currentUserName, forKey: "currentUserName")
        }
    }
    static var locationAddress = "" {
        didSet {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setValue(locationAddress, forKey: "locationAddress")
        }
    }
    
    static var contactName = "" {
        didSet {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setValue(contactName, forKey: "contactName")
        }
    }
    
}