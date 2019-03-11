//
//  Document.swift
//  Scannie
//
//  Created by Andre Sousa on 06/03/2019.
//  Copyright © 2019 Alves. All rights reserved.
//

import UIKit

class Document {

    var filename        : String?
    var uploadedAt      : Date?
    var path            : String?
    var compressedPath  : String?
    var uuid            : String?
    
    init(filename: String?, uploadedAt: Double? = nil, path: String?, compressedPath: String?, uuid: String?) {
        if let filename = filename {
            self.filename = filename
        }
        if let uploadedAt = uploadedAt {
            let date = Date(timeIntervalSince1970: TimeInterval(uploadedAt) / 1000)
            self.uploadedAt = date
        }
        if let path = path {
            self.path = path
        }
        if let compressedPath = compressedPath {
            self.compressedPath = compressedPath
        }
        if let uuid = uuid {
            self.uuid = uuid
        }
    }
    
    var dictionary: [String: Any] {
        return ["filename": filename!,
                "uploadedAt": uploadedAt!.millisecondsSince1970,
                "path": path!,
                "compressedPath": compressedPath!,
                "uuid": uuid!]
    }
    var nsDictionary: NSDictionary {
        return dictionary as NSDictionary
    }

}
