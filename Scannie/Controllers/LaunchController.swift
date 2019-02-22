//
//  LaunchViewController.swift
//  Scannie
//
//  Created by André Sousa on 22/02/2019.
//  Copyright © 2019 Alves. All rights reserved.
//

import UIKit
import Blockstack

class LaunchController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if (Blockstack.shared.isUserSignedIn()) {
            print("Logged in")
            AppDelegate.shared.rootViewController.switchToMainScreen()
        } else {
            print("Not logged in")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                AppDelegate.shared.rootViewController.switchToAuthScreen()
            })
        }
    }
}
