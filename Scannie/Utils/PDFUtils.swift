//
//  PDFUtils.swift
//  Scannie
//
//  Created by Andre Sousa on 08/03/2019.
//  Copyright © 2019 Alves. All rights reserved.
//

import UIKit

struct PDFUtils {

    static func createPDFDataFromImage(image: UIImage) -> NSMutableData? {
        
        let pdfData = NSMutableData()
        let imgView = UIImageView.init(image: image)
        let imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        UIGraphicsBeginPDFContextToData(pdfData, imageRect, nil)
        UIGraphicsBeginPDFPage()
        let context = UIGraphicsGetCurrentContext()
        imgView.layer.render(in: context!)
        UIGraphicsEndPDFContext()
        
//        //try saving in doc dir to confirm:
//        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
//        let path = dir?.appendingPathComponent("file.pdf")
//        
//        do {
//            try pdfData.write(to: path!, options: NSData.WritingOptions.atomic)
//        } catch {
//            print("error catched")
//            return nil
//        }
        
        return pdfData
    }
}
