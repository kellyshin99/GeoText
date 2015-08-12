//
//  AboutViewController.swift
//  LocationAlert
//
//  Created by Kelly Shin on 8/6/15.
//  Copyright (c) 2015 KellyShin. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBAction func done() {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
