//
//  DateMilliseconds.swift
//  Scannie
//
//  Created by Andre Sousa on 04/03/2019.
//  Copyright © 2019 Alves. All rights reserved.
//

import Foundation

extension Date {
    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}
