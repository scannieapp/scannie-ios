//
//  DocumentListCell.swift
//  Scannie
//
//  Created by Andre Sousa on 06/03/2019.
//  Copyright © 2019 Alves. All rights reserved.
//

import UIKit
import Blockstack

class DocumentListCell: UICollectionViewCell {
    
    @IBOutlet weak var fileNameLabel : UILabel!
    @IBOutlet weak var fileDateLabel : UILabel!
    @IBOutlet weak var fileImageView : UIImageView!
    var document : Document!
    
    func setThumbnailImage(document: Document) {
        
        Blockstack.shared.getFile(at: document.compressedPath!, decrypt: true, completion: { (imageData, error) in
            if (document.compressedPath == self.document.compressedPath) {
                if let decryptedResponse = imageData as? DecryptedValue {
                    if let decryptedImage = decryptedResponse.bytes {
                        let imageData = NSData(bytes: decryptedImage, length: decryptedImage.count)
                        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                            let image = UIImage(data: imageData as Data)
                            self.fileImageView.image = image
                        })
                    }
                }
            }
        })
    }
}
