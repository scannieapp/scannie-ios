//
//  MainTabBarController.swift
//  Scannie
//
//  Created by André Sousa on 26/02/2019.
//  Copyright © 2019 Alves. All rights reserved.
//

import UIKit
import WeScan

class MainTabController: UITabBarController {
    
    struct Dimensions {
        static let shadowPadding            : CGFloat = 5
        static let extraTabBarItemPadding   : CGFloat = 25
        static let underlineViewWidth       : CGFloat = 54
        static let underlineViewPadding     : CGFloat = 45
    }
    
    var tabIndex        = 0
    var underlineView   : UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setTabBarItemsSpacing()
        removeTopBorder()
        setupMiddleButton()
    }
    
    override func viewDidLayoutSubviews() {
        setupUnderlineView()
    }
    
    func setTabBarItemsSpacing() {
        
        tabBar.itemPositioning = .centered
        tabBar.itemSpacing = tabBar.frame.size.width/3 + Dimensions.extraTabBarItemPadding
    }
    
    func removeTopBorder() {
        
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
    }
    
    func setupMiddleButton() {

        let addButtonImage = UIImage(named: "add-icon")!
        let addButton = UIButton(frame: CGRect(x: 0, y: 0, width: addButtonImage.size.width, height: addButtonImage.size.height))
        
        var addButtonFrame = addButton.frame
        addButtonFrame.origin.y = view.bounds.height - addButtonFrame.height - (UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0) - Dimensions.shadowPadding
        addButtonFrame.origin.x = view.bounds.width/2 - addButtonFrame.size.width/2
        addButton.frame = addButtonFrame
        
        view.addSubview(addButton)
        
        addButton.setImage(addButtonImage, for: .normal)
        addButton.addTarget(self, action: #selector(scan(sender:)), for: .touchUpInside)
        
        view.layoutIfNeeded()
    }
    
    func setupUnderlineView() {

        var animate = false
        if underlineView == nil {
            underlineView = UIView()
            underlineView.backgroundColor = UIColor(red: 80/255, green: 227/255, blue: 194/255, alpha: 1)
            view.addSubview(underlineView)
        } else {
            animate = true
        }
        
        var originX = tabBar.frame.size.width/3 - Dimensions.extraTabBarItemPadding - Dimensions.underlineViewWidth
        if tabIndex == 1 {
            originX = (tabBar.frame.size.width/3*2) + Dimensions.extraTabBarItemPadding
        }

        if animate {
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping:0.6, initialSpringVelocity: 0.4, options: UIView.AnimationOptions.curveEaseIn, animations:
                {
                    self.underlineView.frame = CGRect(x: originX, y: self.view.frame.size.height - 3 - self.tabBar.frame.size.height, width: Dimensions.underlineViewWidth, height: 3)
            }, completion: nil )
        } else {
            underlineView.frame = CGRect(x: originX, y: view.frame.size.height - 3 - tabBar.frame.size.height, width: Dimensions.underlineViewWidth, height: 3)
        }
        
        view.layoutIfNeeded()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {

        if item == (self.tabBar.items)![0] {
            tabIndex = 0
        } else {
            tabIndex = 1
        }
        setupUnderlineView()
    }

    @objc private func scan(sender: UIButton) {
        
        let scannerViewController = ImageScannerController()
        scannerViewController.imageScannerDelegate = self
        present(scannerViewController, animated: true)
    }
}

extension MainTabController : ImageScannerControllerDelegate {
    
    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        // You are responsible for carefully handling the error
        print(error)
    }
    
    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        // The user successfully scanned an image, which is available in the ImageScannerResults
        // You are responsible for dismissing the ImageScannerController
        scanner.dismiss(animated: true)
    }
    
    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        // The user tapped 'Cancel' on the scanner
        // You are responsible for dismissing the ImageScannerController
        scanner.dismiss(animated: true)
    }
}

