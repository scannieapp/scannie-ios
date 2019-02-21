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
    
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        checkUserIsLoggedIn()
    }
    
    func checkUserIsLoggedIn() {
        
        DispatchQueue.main.async {
            
            self.statusLabel.text = "Checking login status..."
            
            if Blockstack.shared.isUserSignedIn() {
                // Read user profile data
                let retrievedUserData = Blockstack.shared.loadUserData()
                print(retrievedUserData?.profile?.name as Any)
                let name = retrievedUserData?.profile?.name ?? "Nameless Person"
                print("user \(name) is logged in")
                print("present scan screen")
                let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "mainVC") as! MainController
                self.present(mainVC, animated: true, completion: nil)
            } else {
                self.statusLabel?.text = "Please login with Blockstack"
                self.signInButton?.setTitle("Sign into Blockstack", for: .normal)
                self.signInButton.isHidden = false
                self.signInButton.isUserInteractionEnabled = true
            }
        }
    }
    
    @IBAction func signIn(_ sender: UIButton) {
        
        if Blockstack.shared.isUserSignedIn() {
            print("User is already signed in")
        } else {
            print("Currently signed out so signing in.")
            // Address of deployed example web app
            Blockstack.shared.signIn(redirectURI: "http://localhost:8080/public/redirect.html",
                                     appDomain: URL(string: "http://localhost:8080")!) { authResult in
                                        switch authResult {
                                        case .success(let userData):
                                            print("Sign in SUCCESS", userData.profile?.name as Any)
                                            self.checkUserIsLoggedIn()
                                        case .cancelled:
                                            print("Sign in CANCELLED")
                                            self.statusLabel.text = "Sign in cancelled. Please login."
                                        case .failed(let error):
                                            print("Sign in FAILED, error: ", error ?? "n/a")
                                            self.statusLabel.text = "Sign in failed."
                                        }
            }
        }
        
    }
    
}
