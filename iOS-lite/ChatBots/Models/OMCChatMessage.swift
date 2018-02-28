//
//  OMCChatMessage.swift
//  ChatBots
//
//  Created by Jay Vachhani on 11/13/16.
//  Copyright © 2016 Oracle. All rights reserved.
//

import UIKit

class OMCChatMessage: NSObject {
    
    var text: String?
    var image: UIImage?
    var videoUrl: String?
    var date: Date?
    var botMsg: OMCBotMessagePayload?
    var type: OMCChatBubbleType
    var map:Bool?
    
    init( text: String?, type:OMCChatBubbleType = .mineBubble ) {
        self.text = text
        self.type = type
        self.botMsg = nil;
    }
    
    init( map: Bool, type:OMCChatBubbleType = .mineBubble ) {
        self.map = map
        self.text = "Select Location:"
        self.type = type
        self.botMsg = nil;
    }
    
    init( video: String?, type:OMCChatBubbleType = .opponentBubble ) {
        self.videoUrl = video
        self.text = ""
        self.type = type
        self.botMsg = nil;
    }
    
    init( text:String? ) {
        self.botMsg = nil;
        self.text = text;
        self.type = .mineBubble;
    }
    
    init( botMsg:OMCBotMessagePayload? ) {
        self.botMsg = botMsg;
        self.text = nil;
        self.type = .opponentBubble;
    }
}

