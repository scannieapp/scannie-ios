//
//  DocumentController.swift
//  Scannie
//
//  Created by Andre Sousa on 08/03/2019.
//  Copyright © 2019 Alves. All rights reserved.
//

import UIKit
import Blockstack
import PDFKit
import SVProgressHUD

class DocumentController: UIViewController {
    
    @IBOutlet weak var pdfParentView    : UIView!
    var pdfView                         : PDFView!
    var document                        : Document!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = document.name
        getFile()
    }
    
    func getFile() {
        
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.clear)
        SVProgressHUD.show()

        Blockstack.shared.getFile(at: document.path!, decrypt: true, completion: { (imageData, error) in
            if let decryptedResponse = imageData as? DecryptedValue {
                if let decryptedImage = decryptedResponse.bytes {
                    let data = NSData(bytes: decryptedImage, length: decryptedImage.count)
                    DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                        SVProgressHUD.dismiss()
                        
                        if self.pdfView == nil {
                            self.pdfView = PDFView(frame: self.pdfParentView.frame)
                            self.pdfParentView.addSubview(self.pdfView)
                        }
                        self.pdfView.document = PDFDocument(data: data as Data)
                    })
                }
            }
        })
    }
    
}
