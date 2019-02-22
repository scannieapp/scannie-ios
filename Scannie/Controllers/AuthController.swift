//
//  AuthController.swift
//  hello-blocstack-ios
//
//  Created by André Sousa on 21/02/2019.
//  Copyright © 2019 Andre. All rights reserved.
//

import UIKit
import Blockstack

class AuthController: UIViewController {
    
    @IBOutlet var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signIn(_ sender: UIButton) {
        
        Blockstack.shared.signIn(redirectURI: "https://www.scannieapp.com/redirect-mobile.html",
                                 appDomain: URL(string: "https://www.scannieapp.com")!,
                                 manifestURI: nil,
                                 scopes: ["store_write", "publish_data"]) { authResult in
                                    switch authResult {
                                    case .success(let userData):
                                        print("Sign in SUCCESS", userData.profile?.name as Any)
                                        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                                            AppDelegate.shared.rootViewController.switchToMainScreen()
                                        })
                                    case .cancelled:
                                        print("Sign in CANCELLED")
                                    case .failed(let error):
                                        print("Sign in FAILED, error: ", error ?? "n/a")
                                    }
        }
    }
    
}
