//
//  CustomTabBar.swift
//  Scannie
//
//  Created by Andre Sousa on 17/03/2019.
//  Copyright © 2019 Alves. All rights reserved.
//

import UIKit

class CustomTabBar: UITabBar {
    
    struct Dimensions {
        static let shadowPadding            : CGFloat = 5
        static let extraTabBarItemPadding   : CGFloat = 25
        static let underlineViewWidth       : CGFloat = 54
        static let underlineViewPadding     : CGFloat = 45
    }
    
    var addButton : UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let addButtonImage = UIImage(named: "add-icon")!
        addButton = UIButton(frame: CGRect(x: 0, y: 0, width: addButtonImage.size.width, height: addButtonImage.size.height))
        self.addSubview(addButton)
        
        addButton.setImage(addButtonImage, for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var addButtonFrame = addButton.frame
        addButtonFrame.origin.y = -addButtonFrame.height/2 + Dimensions.shadowPadding
        addButtonFrame.origin.x = self.bounds.width/2 - addButtonFrame.size.width/2
        addButton.frame = addButtonFrame
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let pointForTargetView: CGPoint = addButton.convert(point, from: self)
        if addButton.bounds.contains(pointForTargetView) {
            return addButton
        }
        return super.hitTest(point, with: event)
    }
}
