//
//  MainController.swift
//  hello-blocstack-ios
//
//  Created by André Sousa on 21/02/2019.
//  Copyright © 2019 Andre. All rights reserved.
//

import UIKit
import Blockstack

class MainController: UIViewController {
    
    lazy var searchBar                  : UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width-70, height: 46))
    @IBOutlet weak var collectionView   : UICollectionView!
    private let refreshControl          = UIRefreshControl()
    var emptyResultsController          : EmptyResultsController!
    var documents                       : [Document] = []
    
    let reuseIdentifier = "listCellId"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setNavigationBar()
        setSearchBar()
        
        if #available(iOS 10.0, *) {
            collectionView?.refreshControl = self.refreshControl
        } else {
            self.collectionView?.addSubview(self.refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshDocuments(_:)), for: .valueChanged)
        
        self.collectionView?.setContentOffset(CGPoint(x: 0, y: -80.0), animated: true)
        self.refreshControl.beginRefreshing()
        
        self.fetchDocuments()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width, height: 80)
        
        collectionView.setCollectionViewLayout(layout, animated: false)
    }
    
    func setNavigationBar() {
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isOpaque = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func setSearchBar() {
        
        for view in searchBar.subviews {
            for subview in view.subviews {
                if subview.isKind(of: UITextField.self) {
                    let textField: UITextField = subview as! UITextField
                    textField.backgroundColor = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 0.12)
                }
            }
        }

        searchBar.placeholder = "Search"
        let leftNavBarButton = UIBarButtonItem(customView:searchBar)
        navigationItem.leftBarButtonItem = leftNavBarButton
    }
    
    @objc func refreshDocuments(_ sender: Any) {
        fetchDocuments()
    }
    
    func fetchDocuments() {
        
        Blockstack.shared.getFile(at: "documents.json", decrypt: true) { (response, error) in
            if let decryptedResponse = response as? DecryptedValue {
                let responseString = decryptedResponse.plainText
                
                self.documents = []
                
                if let parsedDocuments = responseString!.parseJSONString as? Array<Any> {
                    for parsedDocument in parsedDocuments {
                        if let document = parsedDocument as? Dictionary<String, Any> {
                            self.documents.append(
                                Document.init( name: document["name"] as? String,
                                            uploadedAt: document["uploadedAt"] as? Double,
                                            path: document["path"] as? String,
                                            compressedPath: document["compressedPath"] as? String)
                            )
                        }
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    if self.documents.count == 0 {
                        self.showEmptyResults()
                    } else {
                        self.hideEmptyResults()
                    }
                    self.collectionView?.reloadData()
                    self.refreshControl.endRefreshing()
                })
            } else {
                // Could not fetch documents.json file
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.refreshControl.endRefreshing()
                    let msg = error!.localizedDescription
                    let alert = UIAlertController(title: "Error",
                                                  message: msg,
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                })
            }
        }
    }
    
    func showEmptyResults() {
        if emptyResultsController == nil {
            emptyResultsController = storyboard?.instantiateViewController(withIdentifier: "emptyResultsVC") as? EmptyResultsController
            emptyResultsController.view.frame = collectionView.frame
            addChild(emptyResultsController)
            collectionView.addSubview(emptyResultsController.view)
        }
        collectionView.bringSubviewToFront(emptyResultsController.view)
    }
    
    func hideEmptyResults() {
        if emptyResultsController != nil {
            emptyResultsController.view.removeFromSuperview()
            emptyResultsController.removeFromParent()
            emptyResultsController = nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDocument" {
            let documentController = segue.destination as! DocumentController
            documentController.document = sender as? Document
        }
    }
    
}

extension MainController : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return documents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DocumentListCell

        let document = documents[indexPath.row]
        cell.document = document
        
        cell.fileNameLabel.text = document.name
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        cell.fileDateLabel.text = dateFormatter.string(from: document.uploadedAt!)
        
        cell.setThumbnailImage(document: document)
        
        return cell
    }
}

extension MainController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let document = self.documents[indexPath.row]
        performSegue(withIdentifier: "showDocument", sender: document)
    }
}
