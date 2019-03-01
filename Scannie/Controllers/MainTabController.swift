//
//  MainTabBarController.swift
//  Scannie
//
//  Created by André Sousa on 26/02/2019.
//  Copyright © 2019 Alves. All rights reserved.
//

import UIKit

class MainTabController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupMiddleButton()
    }
    
    func setupMiddleButton() {

        let addButtonImage = UIImage(named: "add-icon")!
        let addButton = UIButton(frame: CGRect(x: 0, y: 0, width: addButtonImage.size.width, height: addButtonImage.size.height))
        
        var addButtonFrame = addButton.frame
        addButtonFrame.origin.y = view.bounds.height - addButtonFrame.height
        addButtonFrame.origin.x = view.bounds.width/2 - addButtonFrame.size.width/2
        addButton.frame = addButtonFrame
        
        view.addSubview(addButton)
        
        addButton.setImage(addButtonImage, for: .normal)
        addButton.addTarget(self, action: #selector(scan(sender:)), for: .touchUpInside)
        
        view.layoutIfNeeded()
    }

    @objc private func scan(sender: UIButton) {

    }

}
