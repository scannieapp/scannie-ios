//
//  MainTabBarController.swift
//  Scannie
//
//  Created by André Sousa on 26/02/2019.
//  Copyright © 2019 Alves. All rights reserved.
//

import UIKit
import WeScan
import SVProgressHUD
import Blockstack
import CryptoSwift

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
        addButtonFrame.origin.y = -addButtonFrame.height/2 - (UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0) + Dimensions.shadowPadding
        addButtonFrame.origin.x = view.bounds.width/2 - addButtonFrame.size.width/2
        addButton.frame = addButtonFrame
        
        tabBar.addSubview(addButton)
        
        addButton.setImage(addButtonImage, for: .normal)
        addButton.addTarget(self, action: #selector(scan(sender:)), for: .touchUpInside)
        
        view.layoutIfNeeded()
    }
    
    func setupUnderlineView() {

        var animate = false
        if underlineView == nil {
            underlineView = UIView()
            underlineView.backgroundColor = UIColor(red: 80/255, green: 227/255, blue: 194/255, alpha: 1)
            tabBar.addSubview(underlineView)
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
                    self.underlineView.frame = CGRect(x: originX, y: -3, width: Dimensions.underlineViewWidth, height: 3)
            }, completion: nil )
        } else {
            underlineView.frame = CGRect(x: originX, y: -3, width: Dimensions.underlineViewWidth, height: 3)
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
        
        var documentImage : UIImage!
        if results.enhancedImage != nil {
            documentImage = results.enhancedImage!
        } else {
            documentImage = results.scannedImage
        }
        
        let documentPDFData = PDFUtils.createPDFDataFromImage(image: documentImage)
        let thumbnail = documentImage.jpegData(compressionQuality: 0.1)
        
        if documentPDFData == nil || thumbnail == nil {
            
            DispatchQueue.main.async {
                let msg = "Unable to convert image."
                let alert = UIAlertController(title: "Error",
                                              message: msg,
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            return
        }
        
        let alert = UIAlertController(title: "Filename", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter filename"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0]
            let bytes = (documentPDFData! as Data).bytes
            let thumbnailBytes = thumbnail!.bytes
            self.uploadFile(filename: textField.text!, bytes: bytes, thumbnailBytes: thumbnailBytes)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func uploadFile(filename: String, bytes: [UInt8], thumbnailBytes: [UInt8]) {
        
        let uuid = UUID().uuidString
        let path = "\(uuid).pdf"
        
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.clear)
        SVProgressHUD.show()
        
        Blockstack.shared.getFile(at: "documents.json", decrypt: true, completion: { (response, error) in
            
            var documentsArray : Array<NSDictionary> = []
            
            if response != nil {
                
                print("get file response \(String(describing: response))")
                
                if let decryptedResponse = response as? DecryptedValue {
                    let responseString = decryptedResponse.plainText
                    
                    if let parsedDocuments = responseString!.parseJSONString as? Array<Any> {
                        documentsArray = parsedDocuments as! Array<NSDictionary>
                    }
                }
                
            } else if error != nil {
                
                print("get file error \(String(describing: error))")
                
                DispatchQueue.main.async {
                    let msg = error!.localizedDescription
                    let alert = UIAlertController(title: "Error",
                                                  message: msg,
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    SVProgressHUD.dismiss()
                }
                return
            }
            
            Blockstack.shared.putFile(to: "compressed_thumbnails/\(path)", bytes: thumbnailBytes, encrypt: true, completion: { (file, error) in
                
                Blockstack.shared.putFile(to: "documents/\(path)", bytes: bytes, encrypt: true, completion: { (file, error) in
                    let newDocument = [
                        "path": "documents/\(path)",
                        "uploadedAt": Date().millisecondsSince1970,
                        "uuid": uuid,
                        "compressedPath": "compressed_thumbnails/\(path)",
                        "filename": filename
                        ] as NSDictionary
                    
                    documentsArray.append(newDocument)
                    
                    Blockstack.shared.putFile(to: "documents.json", text: self.json(from: documentsArray)!, encrypt: true, completion: { (file, error) in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                            SVProgressHUD.dismiss()
                            print("Uploaded file")
                        })
                    })
                })
            })
        })

    }
    
    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        // The user tapped 'Cancel' on the scanner
        // You are responsible for dismissing the ImageScannerController
        scanner.dismiss(animated: true)
    }
    
    func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
}


