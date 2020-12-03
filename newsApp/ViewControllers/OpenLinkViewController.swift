//
//  OpenLinkViewController.swift
//  newsApp
//
//  Created by Anna Kulaieva on 02.12.2020.
//

import Foundation
import UIKit
import WebKit

class OpenLinkViewController: UIViewController {
    @IBOutlet weak var newsLinkWebView: WKWebView!
    var urlToOpen: String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        guard let url = URL(string: urlToOpen) else {
            HelperMethods.showFailureAlert(title: "Warning", message: "No valid url provided", controller: self)
            newsLinkWebView.isHidden = true
            return
        }
        newsLinkWebView.load(URLRequest(url: url))
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
