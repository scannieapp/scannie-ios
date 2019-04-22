//
//  MainController.swift
//  hello-blocstack-ios
//
//  Created by André Sousa on 21/02/2019.
//  Copyright © 2019 Andre. All rights reserved.
//

import UIKit
import Blockstack
import SVProgressHUD

class MainController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    var searchController                : UISearchController!
    var sortButton                      : UIButton!
    @IBOutlet weak var collectionView   : UICollectionView!
    private let refreshControl          = UIRefreshControl()
    var emptyResultsController          : EmptyResultsController!
    var documents                       : [Document] = []
    var filteredDocuments               : [Document] = []

    let reuseIdentifier = "listCellId"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSearchBar()
        setNavigationBar()
        setSortButton(image: nil)
        
        collectionView?.refreshControl = self.refreshControl
        refreshControl.addTarget(self, action: #selector(refreshDocuments(_:)), for: .valueChanged)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.refreshDocuments(_:)),
            name: NSNotification.Name(rawValue: "uploadedFile"),
            object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width, height: 80)
        
        collectionView.setCollectionViewLayout(layout, animated: false)
        
        self.refreshControl.beginRefreshing()
        self.fetchDocuments()
    }
    
    func setNavigationBar() {
        
        if UIScreen.main.bounds.size.height > 568 {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.largeTitleDisplayMode = .always
        }
        navigationController?.navigationBar.topItem?.title = "Your Documents"
        navigationController?.navigationBar.largeTitleTextAttributes =
            [NSAttributedString.Key.foregroundColor : UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1),
                NSAttributedString.Key.font: UIFont(name: "ArialBold", size: 22) ??
                UIFont.boldSystemFont(ofSize: 22)]
        navigationController?.navigationBar.barTintColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isOpaque = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func setSearchBar() {
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func setSortButton(image: UIImage?) {
        
        if self.sortButton == nil {
            self.sortButton = UIButton()
            self.sortButton.addTarget(self, action: #selector(sortDocuments), for: .touchUpInside)
        }
        
        var sortImage = image
        if image == nil {
            sortImage = UIImage(named: "sort-date.png")
        }
        self.sortButton.setImage(sortImage, for: .normal)
        self.sortButton.frame = CGRect(x: 0, y: 0, width: sortImage!.size.width, height: sortImage!.size.height)
        let rightNavBarButton = UIBarButtonItem(customView:self.sortButton)
        navigationItem.rightBarButtonItem = rightNavBarButton
    }
    
    @objc func refreshDocuments(_ sender: Any) {
        fetchDocuments()
    }
    
    func fetchDocuments() {
        
        self.refreshControl.endRefreshing()
        SVProgressHUD.show()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        Blockstack.shared.getFile(at: "documents.json", decrypt: true) { (response, error) in
            if let decryptedResponse = response as? DecryptedValue {
                let responseString = decryptedResponse.plainText
                
                self.documents = []
                self.filteredDocuments = []
                
                if let parsedDocuments = responseString!.parseJSONString as? Array<Any> {
                    for parsedDocument in parsedDocuments {
                        if let document = parsedDocument as? Dictionary<String, Any> {
                            self.documents.append(
                                Document.init( filename: document["filename"] as? String,
                                            uploadedAt: document["uploadedAt"] as? Double,
                                            path: document["path"] as? String,
                                            compressedPath: document["compressedPath"] as? String,
                                            uuid: document["uuid"] as? String)
                            )
                        }
                    }
                }
                
                self.documents = self.documents.sorted { $0.uploadedAt!.millisecondsSince1970 > $1.uploadedAt!.millisecondsSince1970 }
                self.filteredDocuments = self.documents
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    SVProgressHUD.dismiss()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    if self.filteredDocuments.count == 0 {
                        self.showEmptyResults()
                    } else {
                        self.hideEmptyResults()
                    }
                    self.collectionView?.reloadData()
                })
                
            } else if error != nil {
                print("error  fetching documents \(String(describing: error?.localizedDescription))")
                // Could not fetch documents.json file
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.refreshControl.endRefreshing()
                    SVProgressHUD.dismiss()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    let msg = error!.localizedDescription
                    let alert = UIAlertController(title: "Error",
                                                  message: msg,
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                })
                
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.refreshControl.endRefreshing()
                    SVProgressHUD.dismiss()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.showEmptyResults()
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
    
    @objc func sortDocuments() {
        
        let alert = UIAlertController(title: "",
                                      message: "Sort Documents",
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Chronologically", style: UIAlertAction.Style.default, handler: { _ in
            self.filteredDocuments = self.filteredDocuments.sorted { $0.uploadedAt!.millisecondsSince1970 > $1.uploadedAt!.millisecondsSince1970 }
            self.documents = self.documents.sorted { $0.uploadedAt!.millisecondsSince1970 > $1.uploadedAt!.millisecondsSince1970 }
            self.collectionView.reloadData()
            self.setSortButton(image: UIImage(named: "sort-date"))
        }))
        alert.addAction(UIAlertAction(title: "Alphabetically", style: UIAlertAction.Style.default, handler: { _ in
            self.filteredDocuments = self.filteredDocuments.sorted { $0.filename! < $1.filename! }
            self.documents = self.documents.sorted { $0.filename! < $1.filename! }
            self.collectionView.reloadData()
            self.setSortButton(image: UIImage(named: "sort-name"))
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDocument" {
            let documentController = segue.destination as! DocumentController
            documentController.document = sender as? Document
            documentController.documentsArray = documents
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }

        DispatchQueue.main.async {
            self.filteredDocuments = []
            if text == "" {
                self.filteredDocuments = self.documents
            } else {
                self.filteredDocuments = self.documents.filter { $0.filename!.lowercased().contains(text.lowercased()) }
            }
            if self.filteredDocuments.count == 0 {
                self.showEmptyResults()
            } else {
                self.hideEmptyResults()
            }
            self.collectionView?.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchController.dismiss(animated: true, completion: nil)
    }
}

extension MainController : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredDocuments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DocumentListCell

        let document = filteredDocuments[indexPath.row]
        cell.document = document
        
        cell.fileNameLabel.text = document.filename
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        cell.fileDateLabel.text = dateFormatter.string(from: document.uploadedAt!)
        
        cell.setThumbnailImage(document: document)
        
        return cell
    }
}

extension MainController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let document = self.filteredDocuments[indexPath.row]
        performSegue(withIdentifier: "showDocument", sender: document)
    }
}
