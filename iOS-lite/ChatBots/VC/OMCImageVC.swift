//
//  OMCImageVC.swift
//  ChatBots
//
//  Created by Jay Vachhani on 11/1/17.
//  Copyright © 2017 Oracle. All rights reserved.
//

import UIKit

class OMCImageVC: UIViewController {

    open var url:String?
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var navBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let swipe = UISwipeGestureRecognizer(target: self, action:#selector(self.respondToSwipeGesture(gesture:)))
        self.view.addGestureRecognizer(swipe)
    }
    
    override func viewWillAppear(_ animated: Bool) {
      
        super.viewWillAppear(animated)
        setImageView()
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if gesture is UISwipeGestureRecognizer {
            dismissVC(gesture)
        }
    }

    @IBAction func dismissVC(_ sender: Any) {
        self.dismiss(animated: true) {
        }
    }

    func setImageView() -> Void {
        
        let data:Data? = OMCCardsCollectionView.init().fileData(url)
        if( data != nil ){
            self.imgView?.image = UIImage.init(data: data!)
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
