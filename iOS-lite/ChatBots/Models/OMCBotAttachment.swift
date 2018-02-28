//
//  OMCBotAttachment.swift
//  ChatBots
//
//  Created by Jay Vachhani on 11/6/17.
//  Copyright © 2017 Oracle. All rights reserved.
//

import Foundation


class OMCBotAttachment: NSObject {
    
    public private(set) var type: String?
    public private(set) var url: String?
    
    init(type: String?, url:String?) {
        
        self.type = type;
        self.url = url;
    }
    
    init( anAttachment:NSDictionary? ) {
        
        self.type = anAttachment?.object(forKey: "type") as? String
        self.url = anAttachment?.object(forKey: "url") as? String
    }
}
