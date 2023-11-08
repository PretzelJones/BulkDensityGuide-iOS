//
//  ViewController.swift
//  Bulk Density Guide
//
//  Created by Sean Patterson on 2/25/19.
//  Copyright © 2019 Bosson Design. All rights reserved.
//

import UIKit
import SwiftSoup
import SwiftUI

var sharedData = [String]()

func convertArray() { //fix duplicates by converting to set then back
    sharedData = Array(Set(sharedData))
    sharedData.sort()
}

struct Keys {
    
    static let arrayKey = "arrayKey"
}

let defaults = UserDefaults.standard

func saveArray() {
    
    defaults.set(sharedData, forKey: Keys.arrayKey)
}

func retrieveArray() {
    
    sharedData = defaults.array(forKey: Keys.arrayKey) as? [String] ?? []
}

class ViewController: UIViewController {
    
    private let menuView = UIView()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    /*
    var materialData: [String] {
        return MaterialDataProvider.materialData
    }
    */
    
    var materialData = [Material]() //working code for fetching and parsing
    var searchMaterial = [Material]()
    var searching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchMaterials() // Start fetching materials when the view loads
        showSearchBar() //custom searchbar
        hideKeyboardWhenTappedAround() //hides keyboard as user taps anywhere else on screen
        retrieveArray() //retrieves saved array data from userDefaults
        addNavBarImage() //Hapman logo at center of navbar

    }
    
    func fetchMaterials() {
        let urlString = "https://hapman.com/resources-knowledge/tools/bulk-density-guide/"  // Replace with your actual URL
        let materialDataService = MaterialDataService()
        
        materialDataService.fetchMaterialData(from: urlString) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    // Data was fetched, you can now parse and use it
                    self?.handleFetchedData(data)
                case .failure(let error):
                    // Handle any errors here
                    self?.handleError(error)
                }
            }
        }
    }
    
    // This function will handle the data after it has been fetched
    private func handleFetchedData(_ data: Data) {
        if let htmlString = String(data: data, encoding: .utf8) {
            do {
                let doc = try SwiftSoup.parse(htmlString)
                // Use the table ID to select the correct table rows
                let rows = try doc.select("#table_1 tbody tr")

                var newMaterials = [Material]() // Temporary array to hold parsed materials

                for row in rows {
                    // The second cell (index 1) is the material name
                    let materialName = try row.select("td").get(1).text()
                    // The third cell (index 2) is the density in lb/ft3
                    let densityLbFt3String = try row.select("td").get(2).text()
                    // The fourth cell (index 3) is the density in g/cm3
                    let densityGmCm3String = try row.select("td").get(3).text()
                    
                    if let densityLbFt3 = Double(densityLbFt3String),
                       let densityGmCm3 = Double(densityGmCm3String) {
                        let newMaterial = Material(name: materialName, densityLbFt3: densityLbFt3, densityGmCm3: densityGmCm3)
                        newMaterials.append(newMaterial)
                    } else {
                        print("Error parsing density values for \(materialName)")
                    }
                }

                DispatchQueue.main.async { [weak self] in
                    // Update the materialData stored property with the new materials
                    self?.materialData = newMaterials
                    self?.tableView.reloadData()
                }
            
            } catch Exception.Error(let type, let message) {
                print("Error of type \(type) with message: \(message)")
            } catch {
                print("error: \(error)")
            }
        }
    }


    // This function will handle errors that may occur during data fetching
    private func handleError(_ error: Error) {
        // Error handling logic would go here
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

extension ViewController: UIContextMenuInteractionDelegate {
    
    @available(iOS 13.0, *)
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            
            let copy = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.clipboard")) { action in
            }
            let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { action in
            }
            let save = UIAction(title: "Save", image: UIImage(systemName: "pin")) { action in
            }
            return UIMenu(title: "", children: [save, copy, share])
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            
            let copy = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.clipboard")) { action in
                let cell = tableView.cellForRow(at: indexPath)
                UIPasteboard.general.string = cell?.textLabel?.text
            }
            let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { action in
                var data: String
                if self.searching {
                    let material = self.searchMaterial[indexPath.row]
                    data = "\(material.name)\n\(material.densityLbFt3) lb/ft³, \(material.densityGmCm3) g/cm³"
                } else {
                    let material = self.materialData[indexPath.row]
                    data = "\(material.name)\n\(material.densityLbFt3) lb/ft³, \(material.densityGmCm3) g/cm³"
                }
                let shareItems: [Any] = [data]
                let activityVC = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
                
                if let popoverController = activityVC.popoverPresentationController, let cell = tableView.cellForRow(at: indexPath) {
                    popoverController.sourceView = cell
                    popoverController.sourceRect = cell.bounds
                }
                
                DispatchQueue.main.async {
                    self.present(activityVC, animated: true, completion: nil)
                }
            }
            let save = UIAction(title: "Save", image: UIImage(systemName: "pin")) { action in
                var data: String
                if self.searching {
                    let material = self.searchMaterial[indexPath.row]
                    data = "\(material.name)\n\(material.densityLbFt3) lb/ft³, \(material.densityGmCm3) g/cm³"
                } else {
                    let material = self.materialData[indexPath.row]
                    data = "\(material.name)\n\(material.densityLbFt3) lb/ft³, \(material.densityGmCm3) g/cm³"
                }
                sharedData.append(data)
                saveArray()
            }
            return UIMenu(title: "", children: [save, copy, share])
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        print(self.materialData[indexPath.row], "selected!")
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let copyAction = UIContextualAction(style: .normal, title: "Copy") { (_, _, completionHandler) in
            
            let cell = tableView.cellForRow(at: indexPath)
            UIPasteboard.general.string = cell?.textLabel?.text
            
            completionHandler(true)
        }
        
        let shareAction = UIContextualAction(style: .normal, title: "Share") { (_, _, completionHandler) in
            var data: String
            if self.searching {
                let material = self.searchMaterial[indexPath.row]
                data = "\(material.name)\n\(material.densityLbFt3) lb/ft³, \(material.densityGmCm3) g/cm³"
            } else {
                let material = self.materialData[indexPath.row]
                data = "\(material.name)\n\(material.densityLbFt3) lb/ft³, \(material.densityGmCm3) g/cm³"
            }
            let shareItems: [Any] = [data]
            let activityVC = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
            
            if let popoverController = activityVC.popoverPresentationController, let cell = tableView.cellForRow(at: indexPath) {
                popoverController.sourceView = cell
                popoverController.sourceRect = cell.bounds
            }
            
            DispatchQueue.main.async {
                self.present(activityVC, animated: true, completion: nil)
            }
        }

        shareAction.backgroundColor = .systemYellow
        copyAction.backgroundColor = .systemBlue
        let configuration = UISwipeActionsConfiguration(actions: [copyAction, shareAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        
        let favoriteAction = UIContextualAction(style: .normal, title: "Save") { (_, _, completionHandler) in
            var data: String
            if self.searching {
                let material = self.searchMaterial[indexPath.row]
                data = "\(material.name)\n\(material.densityLbFt3) lb/ft³, \(material.densityGmCm3) g/cm³"
            } else {
                let material = self.materialData[indexPath.row]
                data = "\(material.name)\n\(material.densityLbFt3) lb/ft³, \(material.densityGmCm3) g/cm³"
            }
            // Append the string representation to the sharedData
            sharedData.append(data)
            saveArray()
            completionHandler(true)
        }
        favoriteAction.backgroundColor = .systemOrange
        let configuration = UISwipeActionsConfiguration(actions: [favoriteAction])
        return configuration
    }
    
    //extension ViewController: UITableViewDataSource { //if needed to seperate delegate and datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searching {
            return searchMaterial.count
        } else {
            return materialData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.numberOfLines = 0 // Allows label to have multiple lines
        
        let material: Material
        if searching {
            material = searchMaterial[indexPath.row]
        } else {
            material = materialData[indexPath.row]
        }
        
        // Set the material name on the first line and densities on the second line
        cell.textLabel?.text = "\(material.name)\n\(material.densityLbFt3) lb/ft³, \(material.densityGmCm3) g/cm³"
        
        return cell
    }

}

extension ViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchBar.setShowsCancelButton(true, animated: true)
        
        if searchText.isEmpty {
            searching = false
            searchMaterial.removeAll()
        } else {
            searching = true
            // Filter the materialData array by the material name
            searchMaterial = materialData.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.setShowsCancelButton(false, animated: true)
        searching = false
        searchBar.text = ""
        tableView.reloadData()
    }
    
    func showSearchBar() { //enables auto hiding of searchBar - not working
        
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.returnKeyType = UIReturnKeyType.search
        searchController.searchBar.placeholder = "Search material"
    }
}

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        
        view.endEditing(true)
        
        if let nav = self.navigationController {
            nav.view.endEditing(true)
        }
    }
}
