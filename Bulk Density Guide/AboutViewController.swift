//
//  AboutViewController.swift
//  Bulk Density Guide
//
//  Created by Sean Patterson on 5/22/20.
//  Copyright © 2020 Bosson Design. All rights reserved.
//

import UIKit
import MessageUI

class AboutViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var siteButton: UIButton!
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var repButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var feedbackButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func tapSiteButton(_ sender: UIButton) {
        UIApplication.shared.openURL(URL(string: "http://www.hapman.com")!)
    }
    
    @IBAction func tapContactButton(_ sender: UIButton) {
        UIApplication.shared.openURL(URL(string: "http://www.hapman.com/contact-us")!)
    }
    
    @IBAction func tapRepButton(_ sender: UIButton) {
        UIApplication.shared.openURL(URL(string: "http://www.hapman.com/find-a-rep")!)
    }
    @IBAction func tapAboutButton(_ sender: UIButton) {
        UIApplication.shared.openURL(URL(string: "http://www.hapman.com/the-hapman-difference")!)
    }
    @IBAction func tapShareButton(_ sender: UIButton) {
        
        let shareItem : NSURL = NSURL(string: "https://apps.apple.com/us/app/spooky-halloween-sounds/id1437079754")!
        // If you want to put an image
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [shareItem], applicationActivities: nil)
        
        // This lines is for the popover you need to show in iPad
        activityViewController.popoverPresentationController?.sourceView = (sender )
        
        // This line remove the arrow of the popover to show in iPad
        if let popoverController = activityViewController.popoverPresentationController { //added to account for different handling in iPad OS
            popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 1, y: UIScreen.main.bounds.height / 1, width: 0, height: 0)
            popoverController.sourceView = self.view
            popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func tapFeedbackButton(_ sender: UIButton) {
        sendEmail()
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
    
    
}

