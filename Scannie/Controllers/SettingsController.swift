//
//  SettingsController.swift
//  Scannie
//
//  Created by Andre Sousa on 09/03/2019.
//  Copyright © 2019 Alves. All rights reserved.
//

import UIKit
import Blockstack

class SettingsController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!

    let reuseIdentifier = "settingsCellId"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension SettingsController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "Logout"
        } else {
            cell.textLabel?.text = "Know more about Blockstack"
        }
        
        return cell
    }
}

extension SettingsController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            Blockstack.shared.signUserOut()
            AppDelegate.shared.rootViewController.switchToAuthScreen()
        } else {
            UIApplication.shared.open(URL(string: "https://blockstack.org")!)
        }
    }
}
