//
//  OMCBotAction.swift
//  ChatBots
//
//  Created by Jay Vachhani on 10/27/17.
//  Copyright © 2017 Oracle. All rights reserved.
//

import Foundation

class OMCBotAction: NSObject {
    
    var type: String?
    var lbl: String?
    var postback: NSDictionary?
    var imageUrl: String?
    var phoneNumber: String?
    var url: String?
    
    /*
     * Quick init for postback type action.
     */
    init( lbl: String?, postback: NSDictionary? ) {
        
        self.type = "postback"
        self.postback = postback
        self.lbl = lbl
        self.imageUrl = nil
        self.phoneNumber = nil
        self.url = nil
    }
    
    /*
     * Generic init for all types.
     */
    init( anAction:NSDictionary? ) {
        
        self.type = anAction?.object(forKey: "type") as? String
        self.postback = anAction?.object(forKey: "postback") as? NSDictionary
        self.lbl = anAction?.object(forKey: "label") as? String
        self.imageUrl = anAction?.object(forKey: "imageUrl") as? String
        self.phoneNumber = anAction?.object(forKey: "phoneNumber") as? String
        self.url = anAction?.object(forKey: "url") as? String
    }
}
