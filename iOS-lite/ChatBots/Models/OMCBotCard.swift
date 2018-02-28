//
//  OMCBotCard.swift
//  ChatBots
//
//  Created by Jay Vachhani on 11/1/17.
//  Copyright © 2017 Oracle. All rights reserved.
//

import UIKit

@objc class OMCBotCard: NSObject {

    var title: String?
    var desc: String?
    var actions: NSArray?
    var cardAction: OMCBotAction?
    var imageUrl: String?
    var url:String?
    
    @objc
    init( aCard:NSDictionary? ) {
        
        self.title = aCard?.object(forKey: "title") as? String
        self.desc = aCard?.object(forKey: "description") as? String
        self.imageUrl = aCard?.object(forKey: "imageUrl") as? String
        self.url = aCard?.object(forKey:"url") as? String
        
        if ( aCard?.object(forKey: "cardAction") != nil ) {
            self.cardAction = OMCBotAction.init(anAction: aCard?.object(forKey: "cardAction") as? NSDictionary )
        }
        
        if ( aCard?.object(forKey: "actions") != nil ) {
            self.actions =  aCard?.object(forKey: "actions") as? NSArray;
        }
        
        if ( self.desc == nil ){
            self.desc = "";
        }
    }
}
