//
//  OMCBtnAttachmentExt.swift
//  ChatBots
//
//  Created by Jay Vachhani on 11/6/17.
//  Copyright © 2017 Oracle. All rights reserved.
//

import Foundation

extension OMCChatBubbleView {
    
    func addBtnAttachment( attachment:OMCBotAttachment ) {
        
        var startY:CGFloat = 0.0;
        if lblHeight != nil {
            startY = lblHeight! < 25 ? 25 : lblHeight!
        }
        startY = startY + padding;
        
        btnAttachment = UIButton.init(frame: CGRect(x: padding, y: startY, width: self.frame.width - (2*padding) , height: self.frame.height - (4*padding)))
        btnAttachment?.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        btnAttachment?.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center;
        btnAttachment?.contentVerticalAlignment = UIControlContentVerticalAlignment.center;
        btnAttachment?.imageRect(forContentRect: backgroundRect(forBounds: (btnAttachment?.bounds)!))
        if( (btnAttachment?.frame.origin.y)! <= startY ){
            btnAttachment?.frame.origin.y = startY;
        }
        
        btnAttachment?.addTarget(self, action: #selector(self.attachmentTapped(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(btnAttachment!)

        if attachment.type?.caseInsensitiveCompare("image") == ComparisonResult.orderedSame {
            self.addSubview(btnAttachment!)
            btnAttachment?.tag = OMCAttachmentType.imageAttchment.rawValue;
            renderImage(attachment: attachment)
        }
        else if attachment.type?.caseInsensitiveCompare("audio") == ComparisonResult.orderedSame {
            btnAttachment?.tag = OMCAttachmentType.audioAttachment.rawValue
            setupAudioBtn(attachment: attachment, frame: (btnAttachment?.frame)! )
        }
        else if attachment.type?.caseInsensitiveCompare("video") == ComparisonResult.orderedSame {
            btnAttachment?.tag = OMCAttachmentType.videoAttachment.rawValue
            setupVideoBtn(attachment: attachment, frame: (btnAttachment?.frame)!)
        }
        else{
            btnAttachment?.tag = -1
        }
        
        viewHeight = btnAttachment!.frame.maxY + padding/2
        viewWidth = btnAttachment!.frame.width + btnAttachment!.frame.minX + padding
    }
    
    func renderImage ( attachment:OMCBotAttachment ){
        
        btnAttachment?.frame.size = CGSize(width: (btnAttachment?.bounds.width)!, height: 200.0)
        currAttachmentImgUrl = attachment.url
        let data:Data? = OMCCardsCollectionView.init().fileData(attachment.url)
        if( data != nil ){
            btnAttachment?.setImage(UIImage.init(data: data!), for: UIControlState.normal);
        }
        else{
            OMCCardsCollectionView.init().setBackgroundImageIn(btnAttachment, imgUrl: attachment.url)
        }
    }
    
    func setupAudioBtn( attachment:OMCBotAttachment, frame:CGRect ){
        
       // btnAttachment?.frame.size = CGSize(width: (btnAttachment?.bounds.width)!, height: 150.0)
        self.frame = frame
        if( UserDefaults.standard.object(forKey: attachment.url!) != nil ){
            let path:String? = OMCFileManager.filePath(UserDefaults.standard.object(forKey: attachment.url!) as! String)
            if( path != nil ){
                setupAudio(url: path!, isLocal: true)
            }
            else {
                print("Unable to load audio from local cache.")
            }
        }
        else{
            DispatchQueue.global().async {
                if let audioData = try? Data.init(contentsOf: URL.init(string: attachment.url!)!, options: Data.ReadingOptions.alwaysMapped) {
                    let ext = String.init(format: ".@",attachment.url!.components(separatedBy: ".").last!);
                    let fname:String = OMCFileManager.storeFileData(audioData, withExt: ext)!
                    UserDefaults.standard.set(fname, forKey: attachment.url!)
                    UserDefaults.standard.synchronize()
                } else {
                    print("Unable to load audio from server.")
                }
            }
            setupAudio(url: attachment.url!, isLocal: false)
        }
    }
    
    func setupVideoBtn( attachment:OMCBotAttachment, frame:CGRect ){
        
        btnAttachment?.isHidden = true;
        self.frame = frame
      //  btnAttachment?.frame.size = CGSize(width: (btnAttachment?.bounds.width)!, height: 200.0)

        if( UserDefaults.standard.object(forKey: attachment.url!) != nil ){
            let path:String? = OMCFileManager.filePath(UserDefaults.standard.object(forKey: attachment.url!) as! String)
            if( path != nil ){
                setupVideo(url: path!, isLocal: true)
            }
            else {
                print("Unable to load video from local cache.")
            }
        }
        else{
            DispatchQueue.global().async {
                if let videoData = try? Data.init(contentsOf: URL.init(string: attachment.url!)!, options: Data.ReadingOptions.alwaysMapped) {
                    let ext = String.init(format: ".@",attachment.url!.components(separatedBy: ".").last!);
                    let fname:String = OMCFileManager.storeFileData(videoData, withExt: ext)!
                    UserDefaults.standard.set(fname, forKey: attachment.url!)
                    UserDefaults.standard.synchronize()
                } else {
                    print("Unable to load video from server.")
                }
            }
            setupVideo(url: attachment.url!, isLocal: false)
        }
    }
    
    func attachmentTapped(sender:Any) {
        
        let btn:UIButton = sender as! UIButton
        if btn.tag == OMCAttachmentType.imageAttchment.rawValue {
            chatVC?.gotoFullImageView( url: currAttachmentImgUrl )
        }
    }
    
    func backgroundRect(forBounds bounds: CGRect) -> CGRect {
        let leftMargin:CGFloat = 10
        let rightMargin:CGFloat = 10
        let topMargin:CGFloat = 10
        let bottomMargin:CGFloat = 10
        return CGRect(x: leftMargin, y: topMargin, width: bounds.size.width-leftMargin-rightMargin, height: bounds.size.height-topMargin-bottomMargin)
    }
}
