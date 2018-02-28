//
//  OMCPhoneExt.swift
//  ChatBots
//
//  Created by Jay Vachhani on 11/4/17.
//  Copyright © 2017 Oracle. All rights reserved.
//

import Foundation

extension OMCChatVC {
    
    func phoneTo(number:String) -> Bool {
        
        var tel = "telprompt://\(number)"
        var telURL = URL(string:tel)!

        if( UIApplication.shared.canOpenURL(telURL) ){
            UIApplication.shared.open(telURL, options: [:], completionHandler: { (isSuccess) in
            })
        }else {
            
            tel = "tel://\(number))"
            telURL = URL(string:tel)!
            if( UIApplication.shared.canOpenURL(telURL) ){
                UIApplication.shared.open(telURL, options: [:], completionHandler: { (isSuccess) in
                })
            }else{
                print("unable to open url for call");
                return false
            }
        }
        
        return true
    }
}
