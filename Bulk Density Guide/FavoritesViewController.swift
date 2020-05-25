//
//  FavoritesViewController.swift
//  Bulk Density Guide
//
//  Created by Sean Patterson on 5/8/20.
//  Copyright © 2020 Bosson Design. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController {
    
    private let menuView = UIView()
    @IBOutlet var tableView: UITableView!
    
    @IBAction func shareNavButton(_ sender: UIBarButtonItem) {
        let shareItems: [Any] = sharedData
        if shareItems.isEmpty {
            let alert = UIAlertController(title: "Nothing to share", message: "Add items from the guide to your favorites list to share in other apps", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.performSegue(withIdentifier: "returnSegue", sender: self) //returns user to the main VC via segue returnSegue via yellow square to target VC
            }))
            //alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil)) // just dismisses the alert
            self.present(alert, animated: true)
        } else {
            let activityVC = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
            activityVC.popoverPresentationController?.barButtonItem = sender
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNavBarImage()
        convertArray()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        menuView.center = view.center
    }
    
    
    func addNavBarImage() {
        
        let navController = navigationController!
        
        let image = UIImage(named: "hapman_title_logo")
        let imageView = UIImageView(image: image)
        
        let bannerWidth = navController.navigationBar.frame.size.width
        let bannerHeight = navController.navigationBar.frame.size.height
        
        let bannerX = bannerWidth / 2 - image!.size.width / 2
        let bannerY = bannerHeight / 2 - image!.size.height / 2
        
        imageView.frame = CGRect(x: bannerX, y: bannerY, width: bannerWidth, height: bannerHeight)
        imageView.contentMode = .top
        
        navigationItem.titleView = imageView
        
    }
}

extension FavoritesViewController: UIContextMenuInteractionDelegate {
    
    @available(iOS 13.0, *)
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            let copy = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.clipboard")) { action in
            }
            let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { action in
            }
            let remove = UIAction(title: "Remove", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
            }
            return UIMenu(title: "", children: [copy, share, remove])
        }
    }
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        //let item = sharedData[indexPath.row]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            
            let copy = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.clipboard")) { action in
                let cell = tableView.cellForRow(at: indexPath)
                UIPasteboard.general.string = cell?.textLabel?.text
            }
            let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { action in
                var data: String
                data = sharedData[indexPath.row]
                let shareItems: [Any] = [data]
                let activityVC = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
                
                if let popoverController = activityVC.popoverPresentationController { //added to account for different handling in iPad OS
                    popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 1, y: UIScreen.main.bounds.height / 1, width: 0, height: 0)
                    popoverController.sourceView = self.view
                    popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
                }
                self.present(activityVC, animated: true, completion: nil)
            }
            let remove = UIAction(title: "Remove", image: UIImage(systemName: "trash")) { action in
                sharedData.remove(at: indexPath.row)
                saveArray()
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
            }
            
            
            return UIMenu(title: "", children: [copy, share, remove])
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sharedData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = sharedData[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {
            let deleteAction = UIContextualAction(style: .destructive, title: "Remove") { (action, view, completion) in
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Remove", style: .default) { (action) in
                    
                    sharedData.remove(at: indexPath.row)
                    saveArray()
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    tableView.endUpdates()
                    completion(true)
                })
                alert.addAction(UIAlertAction(title: "Cancel", style: .default) { (action) in
                    completion(false)
                })
                
                alert.popoverPresentationController?.sourceView = view
                alert.popoverPresentationController?.sourceRect = view.bounds
                
                self.present(alert, animated: true, completion: nil)
            }
            //            if #available(iOS 13.0, *) { // used to account for system SF icons not available in > iOS 13
            //                deleteAction.image = UIImage(systemName: "trash.fill")
            //            } else {
            //                // Fallback to default action
            //            }
            deleteAction.backgroundColor = .systemRed
            return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let copyAction = UIContextualAction(style: .normal, title: "Copy") { (_, _, completionHandler) in
            
            let cell = tableView.cellForRow(at: indexPath)
            UIPasteboard.general.string = cell?.textLabel?.text
            
            completionHandler(true)
        }
        
        let shareAction = UIContextualAction(style: .normal, title: "Share") { (_, _, completionHandler) in
            var data: String
            data = sharedData[indexPath.row]
            let shareItems: [Any] = [data]
            let activityVC = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
            
            if let popoverController = activityVC.popoverPresentationController { //added to account for different handling in iPad OS
                popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 1, y: UIScreen.main.bounds.height / 1, width: 0, height: 0)
                popoverController.sourceView = self.view
                popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            }
            self.present(activityVC, animated: true, completion: nil)
        }
        //        if #available(iOS 13.0, *) { // used to account for system SF icons not available in > iOS 13
        //            copyAction.image = UIImage(systemName: "doc.on.clipboard.fill")
        //            shareAction.image = UIImage(systemName: "square.and.arrow.up.fill")
        //        } else {
        //            // fall back to default action
        //        }
        copyAction.backgroundColor = .systemBlue
        shareAction.backgroundColor = .systemYellow
        let configuration = UISwipeActionsConfiguration(actions: [copyAction, shareAction])
        return configuration
    }
}
