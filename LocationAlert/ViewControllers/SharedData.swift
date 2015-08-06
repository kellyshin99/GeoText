//
//  SharedData.swift
//  LocationAlert
//
//  Created by Kelly Shin on 7/30/15.
//  Copyright (c) 2015 KellyShin. All rights reserved.
//

import Foundation

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
    
    static func sendText() {
        var swiftRequest = SwiftRequest();
        
        println("phone number \(SharedData.currentPhoneNumber)")
        
        var data = [
            "To" : SharedData.currentPhoneNumber,
            "From" : "+12516164888",
            "Body" : "\(currentUserName) has arrived at \(locationAddress)"
        ];
        
        swiftRequest.post("https://api.twilio.com/2010-04-01/Accounts/ACe59ae55b5f1d2a999a8bcb9cf2ad5a2f/Messages.json",
            auth: ["username" : "ACe59ae55b5f1d2a999a8bcb9cf2ad5a2f", "password" : "6aadae36ac8be174451c7432e9795ec4"],
            data: data,
            callback: {err, response, body in
                if err == nil {
                    println("Success: \(response)")
                } else {
                    println("Error: \(err)")
                }
        });
    }
}