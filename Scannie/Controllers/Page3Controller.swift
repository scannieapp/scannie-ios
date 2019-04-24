//
//  Page3Controller.swift
//  Scannie
//
//  Created by André Sousa on 24/04/2019.
//  Copyright © 2019 Alves. All rights reserved.
//

import UIKit
import Blockstack

class Page3Controller: UIViewController {
    
    @IBOutlet weak var topConstraint    : NSLayoutConstraint!
    @IBOutlet var signInButton          : UIButton!
    @IBOutlet var descriptionLabel      : UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        if(UIScreen.main.bounds.size.height < 667) {
            topConstraint.constant = 20
        }
        signInButton.layer.cornerRadius = 8
        signInButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        signInButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        signInButton.layer.shadowOpacity = 0.3
        signInButton.layer.shadowRadius = 0.0
        signInButton.layer.masksToBounds = false
        
        descriptionLabel.isUserInteractionEnabled = true
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapLocation(_:)))
        tap.delegate = self as? UIGestureRecognizerDelegate
        descriptionLabel.addGestureRecognizer(tap)
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
    
    @objc func tapLocation(_ sender: UITapGestureRecognizer) {
        
        let text = descriptionLabel.attributedText?.string
        let blockStackString = "Blockstack’s"
        let blockStackRange = (text! as NSString).range(of: blockStackString)

        if sender.didTapAttributedTextInLabel(label: descriptionLabel, inRange: blockStackRange) {
            UIApplication.shared.open(URL(string: "https://blockstack.org")!, options: [:], completionHandler: nil)
        }
    }

}

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {

        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y);
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
    
}

