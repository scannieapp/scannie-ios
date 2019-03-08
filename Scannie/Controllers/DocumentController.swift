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
    var pdfData                         : NSData!

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
                    self.pdfData = NSData(bytes: decryptedImage, length: decryptedImage.count)
                    DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                        SVProgressHUD.dismiss()
                        
                        if self.pdfView == nil {
                            self.pdfView = PDFView(frame: self.pdfParentView.frame)
                            self.pdfParentView.addSubview(self.pdfView)
                        }
                        self.pdfView.document = PDFDocument(data: self.pdfData as Data)
                    })
                }
            }
        })
    }
    
    @IBAction func share() {
        if pdfData != nil {
            let activityVC = UIActivityViewController(activityItems: [document.name!, pdfData], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view
            
            self.present(activityVC, animated: true, completion: nil)
        } else {
            let msg = "No file loaded yet."
            let alert = UIAlertController(title: "Error",
                                          message: msg,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func delete() {
        
    }
    
}
