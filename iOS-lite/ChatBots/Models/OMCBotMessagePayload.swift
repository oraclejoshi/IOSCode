//
//  OMCBotMessagePayload.swift
//  ChatBots
//
//  Created by Jay Vachhani on 11/2/17.
//  Copyright © 2017 Oracle. All rights reserved.
//

import UIKit

class OMCBotMessagePayload: NSObject {
    
    public private(set) var type: String?
    public private(set) var text: String?
    public private(set) var actions: NSArray?
    public private(set) var cards: NSArray?
    public private(set) var globalActions: NSArray?
    public private(set) var originalMsgPayload: NSDictionary?
    public private(set) var attachment: OMCBotAttachment?

    init(text: String?, actions: NSArray?,cards: NSArray? , globalActions:NSArray?, type:String?) {
        
        self.actions = actions;
        self.type = type;
        self.globalActions = globalActions;
        self.cards = cards;
        self.text = text;
    }
    
    init( aMessage:NSDictionary? ) {
        
        self.text = aMessage?.object(forKey: "text") as? String
        self.type = aMessage?.object(forKey: "type") as? String
        self.actions = aMessage?.object(forKey: "actions") as? NSArray
        self.globalActions = aMessage?.object(forKey: "globalActions") as? NSArray
        self.cards = aMessage?.object(forKey: "cards") as? NSArray
        
        if( aMessage?.object(forKey: "attachment") != nil ){
            self.attachment = OMCBotAttachment.init(anAttachment: aMessage?.object(forKey: "attachment") as? NSDictionary )
        }
        
        self.originalMsgPayload = aMessage;
    }
}
