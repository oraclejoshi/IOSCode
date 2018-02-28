//
//  OMCWebVC.swift
//  ChatBots
//
//  Created by Jay Vachhani on 11/1/17.
//  Copyright © 2017 Oracle. All rights reserved.
//

import UIKit
import WebKit

class OMCWebVC: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    open var urlString:String?
    
    private var request: NSMutableURLRequest? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)

        
        var url: NSURL? = NSURL(string: urlString!)
        if url == nil {
            let escapedString: String = (urlString?.removingPercentEncoding)!
            self.urlString = escapedString
            url = NSURL(string: escapedString)
        }

        request = NSMutableURLRequest(url: url! as URL)
        self.webView?.loadRequest(request! as URLRequest);
    }

    @IBAction func hideTapped(_ sender: Any) {
        self.dismiss(animated: true) {
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
