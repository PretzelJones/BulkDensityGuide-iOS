//
//  FavoritesViewController.swift
//  Bulk Density Guide
//
//  Created by Sean Patterson on 5/8/20.
//  Copyright © 2020 Bosson Design. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    @IBAction func shareNavButton(_ sender: UIBarButtonItem) {
        let shareItems: [Any] = sharedData
        let activityVC = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityVC.popoverPresentationController?.barButtonItem = sender
        self.present(activityVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        convertArray()
    }
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    
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
            let deleteAction = UIContextualAction(style: .destructive, title: "Remove") { (_, _, completionHandler) in
                sharedData.remove(at: indexPath.row)
                saveArray()
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
                completionHandler(true)
            }
            if #available(iOS 13.0, *) {
                deleteAction.image = UIImage(systemName: "trash")
            } else {
                // Fallback to default action
            }
            deleteAction.backgroundColor = .systemRed
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            return configuration
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let copyAction = UIContextualAction(style: .normal, title: "Copy") { (_, _, completionHandler) in
            
            let cell = tableView.cellForRow(at: indexPath)
            UIPasteboard.general.string = cell?.textLabel?.text
            
            completionHandler(true)
        }
        let shareAction = UIContextualAction(style: .normal, title: "Share") { (_, _, completionHandler) in
            var data: String
            //UIPasteboard.general.string = cell?.textLabel?.text
            data = sharedData[indexPath.row]
            
            let shareItems: [Any] = [data]
            let activityVC = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
            self.present(activityVC, animated: true, completion: nil)
        }
        if #available(iOS 13.0, *) {
            copyAction.image = UIImage(systemName: "doc.on.clipboard")
            shareAction.image = UIImage(systemName: "square.and.arrow.up")
        } else {
            // fall back to default action
        }
        copyAction.backgroundColor = .systemBlue
        shareAction.backgroundColor = .systemYellow
        let configuration = UISwipeActionsConfiguration(actions: [copyAction, shareAction])
        return configuration
    }
    
}

