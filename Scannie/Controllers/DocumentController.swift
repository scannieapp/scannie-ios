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
    var documentsArray                  : [Document]!
    var pdfData                         : NSData!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = document.filename
        navigationItem.largeTitleDisplayMode = .never
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
                            self.pdfView.autoScales = true
                            self.pdfParentView.addSubview(self.pdfView)
                        }
                        self.pdfView.document = PDFDocument(data: self.pdfData as Data)
                        self.pdfView.maxScaleFactor = 4.0
                        self.pdfView.minScaleFactor = self.pdfView.scaleFactorForSizeToFit
                        self.pdfView.zoomOut(nil)
                        self.pdfView.zoomOut(nil)
                        self.pdfView.zoomOut(nil)
                    })
                }
            }
        })
    }
    
    @IBAction func share() {
        if pdfData != nil {
            let activityVC = UIActivityViewController(activityItems: [document.filename!, pdfData], applicationActivities: nil)
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
        
        let alert = UIAlertController(title: "Delete document",
                                      message: "Are you sure you want to delete this document?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { _ in

            SVProgressHUD.show()
            
            print("path \(self.document.path!)")
            
            var newDocuments = self.documentsArray!
            let indexOfObject = self.documentsArray.index{$0 === self.document}
            newDocuments.remove(at: indexOfObject!)

            var documentsArrayDictionary : Array<NSDictionary> = []
            for document in newDocuments {
                documentsArrayDictionary.append(document.nsDictionary)
            }

            Blockstack.shared.putFile(to: "documents.json", text: self.json(from: documentsArrayDictionary)!, encrypt: true, completion: { (file, error) in
                
                if self.document.compressedPath != nil {
                    Blockstack.shared.putFile(to: self.document.compressedPath!, bytes: [], encrypt: true, completion: { (file, error) in })
                }
                
                if self.document.path != nil {
                    Blockstack.shared.putFile(to: self.document.path!, bytes: [], encrypt: true, completion: { (file, error) in })
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    SVProgressHUD.dismiss()
                    self.navigationController?.popViewController(animated: true)
                    print("Deleted file")
                })
            })
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
}
