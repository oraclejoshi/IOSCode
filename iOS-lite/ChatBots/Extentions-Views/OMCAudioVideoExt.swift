//
//  OMCVideoExt.swift
//  ChatBots
//
//  Created by Jay Vachhani on 11/5/17.
//  Copyright © 2017 Oracle. All rights reserved.
//

import Foundation
import AVFoundation
import AVKit

extension OMCChatBubbleView {
    
    func setupMedia(url: String, isLocal:Bool) {
        
        var _url:URL?
        if( isLocal == true ){
            _url = NSURL.fileURL(withPath: url)
        }
        else{
            _url = URL.init(string: url)
        }
        
        avPlayer = AVPlayer(url: _url!)
        let avpController:AVPlayerViewController = AVPlayerViewController.init()
        avpController.player = avPlayer
        self.chatVC?.addChildViewController(avpController);
        avpController.view.frame = self.bounds;
        self.addSubview(avpController.view)
        self.bringSubview(toFront: avpController.view)
    }
    
    func setupVideo(url:String, isLocal:Bool) -> Void {
        setupMedia(url: url, isLocal:isLocal)
    }
    
    func setupAudio(url:String, isLocal:Bool) -> Void {
        setupMedia(url: url, isLocal: isLocal)
    }
    
    func play() -> Void {
        avPlayer?.play()
    }
    
    func pause() -> Void {
        avPlayer?.pause()
    }
}
