//
//  InfoViewController.swift
//  Bulk Density Guide
//
//  Created by Sean Patterson on 5/23/20.
//  Copyright © 2020 Bosson Design. All rights reserved.
//

import UIKit
import MessageUI

class InfoViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    let aboutData: [String] = [
        "About the Guide",
        "Hapman.com",
        "Contact Hapman",
        "Find a Rep",
        "About Hapman",
        "Share the App",
        "Provide Feedback",]
    
    let images = [
        UIImage(named: "about"),
        UIImage(named: "home"),
        UIImage(named: "phone"),
        UIImage(named: "map_pin"),
        UIImage(named: "people"),
        UIImage(named: "share"),
        UIImage(named: "feedback")
    ]
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.alwaysBounceVertical = false
        
    }
    
}

extension InfoViewController: UITableViewDataSource, UITableViewDelegate {
    
    func open(scheme: String) {
        if let url = URL(string: scheme) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:],
                                          completionHandler: {
                                            (success) in
                                            print("Open \(scheme): \(success)")
                })
            } else {
                let success = UIApplication.shared.openURL(url)
                print("Open \(scheme): \(success)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            performSegue(withIdentifier: "aboutSegue", sender: self)
        } else if indexPath.row == 1 {
            open(scheme: "http://www.hapman.com")
        } else if indexPath.row == 2 {
            open(scheme: "http://www.hapman.com/contact-us")
        } else if indexPath.row == 3 {
            open(scheme: "http://www.hapman.com/find-a-rep")
        } else if indexPath.row == 4 {
            open(scheme: "http://www.hapman.com/the-hapman-difference")
        } else if indexPath.row == 5 {
            
            let shareItem : NSURL = NSURL(string: "https://apps.apple.com/us/app/spooky-halloween-sounds/id1437079754")!
            
            let activityViewController : UIActivityViewController = UIActivityViewController(
                activityItems: [shareItem], applicationActivities: nil)
            
            if let popoverController = activityViewController.popoverPresentationController { //added to account for different handling in iPad OS
                popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 1, y: UIScreen.main.bounds.height / 1, width: 0, height: 0)
                popoverController.sourceView = self.view
                popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            }
            self.present(activityViewController, animated: true, completion: nil)
            print("Share the App")
            
        } else if indexPath.row == 6 {
            sendEmail()
            print("Provide Feedback")
        }
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["sean@bosson.design"])
            mail.setSubject("Bulk Density Guide Feedback")
            
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return aboutData.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = self.aboutData[indexPath.row]
        cell.imageView?.image = self.images[indexPath.row]
        
        return cell
    }
    
}
