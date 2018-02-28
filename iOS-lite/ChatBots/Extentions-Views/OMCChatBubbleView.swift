//
//  OMCChatBubbleView.swift
//  ChatBots
//
//  Created by Jay Vachhani on 11/13/16.
//  Copyright © 2016 Oracle. All rights reserved.
//

import UIKit
import MapKit
import AVKit

struct ScreenSize
{
    static let SCREEN_WIDTH = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

enum OMCChatBubbleType: Int{
    case mineBubble = 0
    case opponentBubble = 1
    case systemBubble = 2
}

enum OMCAttachmentType: NSInteger{
    case imageAttchment = 0
    case audioAttachment = 1
    case videoAttachment = 2
}

class OMCChatBubbleView: UIView {
    
    weak var chatVC:OMCChatVC?
    
    var isCMM:Bool?
    var viewHeight:CGFloat?
    var viewWidth:CGFloat?
    var lblHeight:CGFloat?
    let padding: CGFloat = 10.0
    var existingTblsHeight: CGFloat = 0.0

    var tblData:NSArray?
    var globalTblData:NSArray?
    
    var isCard:Bool?
    var cardHeight:CGFloat?
    var cardWidth:CGFloat?
    
    var imageViewBG: UIImageView?
    var labelChatText: UILabel?
    var listView: UITableView?
    var globalListView: UITableView?
    var mapView: MKMapView?
    var avPlayer:AVPlayer?
    var btnAttachment:UIButton?
    var currAttachmentImgUrl:String?
    
    func heightFor(constraintedWidth width: CGFloat, font: UIFont, txt:String) -> CGFloat {
        let label =  UILabel(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.text = txt
        return label.sizeThatFits(label.frame.size).height
    }
    
    init( data: OMCChatMessage, startY: CGFloat, choices:NSArray?, chatVC:OMCChatVC ){
        
        super.init(frame: OMCChatBubbleView.framePrimary(data.type, startY:startY))
        
        viewHeight = 0.0
        viewWidth = 0.0
        //let _map:NSDictionary? = nil;
        self.backgroundColor = UIColor.clear
        
        self.chatVC = chatVC
        
        if data.botMsg != nil {
            
            // V1.1 only
            isCMM = true
            if( data.botMsg?.type == "text" && data.botMsg?.text != nil ){
                lblHeight = heightFor(constraintedWidth: (self.frame.width - 2 * padding), font: UIFont.systemFont(ofSize: 12), txt: (data.botMsg?.text)!);
                addTxtLabel(text: data.botMsg?.text, type: OMCChatBubbleType.opponentBubble )
                viewHeight = labelChatText!.frame.maxY + padding/2
                viewWidth = labelChatText!.frame.width + labelChatText!.frame.minX + padding
            }
            
            if( data.botMsg?.type == "card"
                || data.botMsg?.type == "cards"
                || data.botMsg?.cards != nil ) {
                isCard = true
                addCarousle(cards:data.botMsg?.cards);
            }
            else if( data.botMsg?.type == "actions" || data.botMsg?.actions != nil ) {
                self.tblData = data.botMsg?.actions;
                addTableView()
            }
            else if ( data.botMsg?.type == "attachment" || data.botMsg?.attachment != nil ){
              
                if ( data.botMsg?.attachment?.type == "image" ){
                    addBtnAttachment(attachment: (data.botMsg?.attachment)!)
                }
                else{
                    viewWidth = (self.frame.width - 2 * padding)
                    viewHeight = 200.0
                    self.frame = CGRect( x: self.frame.minX, y: self.frame.minY, width: viewWidth!, height: viewHeight! )
                    setupVideoBtn(attachment:(data.botMsg?.attachment!)!, frame: self.frame)
                }
            }
            else{
                // New type not supported yet
            }
            
            if data.botMsg?.globalActions != nil {
                self.globalTblData = data.botMsg?.globalActions;
                addGlobalTableView()
            }
        }
        else {
            
            isCMM = false
            if data.text != nil {
                lblHeight = heightFor(constraintedWidth: (self.frame.width - 2 * padding), font: UIFont.systemFont(ofSize: 12), txt: (data.text)!);
                addTxtLabel(text: data.text, type: data.type )
            }
            
            viewHeight = labelChatText!.frame.maxY + padding/2
            viewWidth = labelChatText!.frame.width + labelChatText!.frame.minX + padding

            if ( choices != nil ) {
                self.tblData = choices;
                addTableView()
            }
            else if( data.map == true ){
                setupMapView(_map: nil);
            }
        }

        if isCard == true {
            viewWidth = cardWidth! + padding/2;
        }
        self.frame = CGRect( x: self.frame.minX, y: self.frame.minY, width: viewWidth!, height: viewHeight! )
        
        // Adding the resizable bubble like shape
        let bubbleImageFileName = data.type == .mineBubble ? "chatBubbleMine" : "chatBubbleOpp"
        imageViewBG = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height))
        if data.type == .mineBubble {
            imageViewBG?.image = UIImage(named: bubbleImageFileName)?.resizableImage(withCapInsets: UIEdgeInsetsMake(14, 14, 17, 28))
        } else {
            imageViewBG?.image = UIImage(named: bubbleImageFileName)?.resizableImage(withCapInsets: UIEdgeInsetsMake(14, 22, 17, 20))
        }
        self.addSubview(imageViewBG!)
        self.sendSubview(toBack: imageViewBG!)
        
        // Create a frame with background bubble
        let repositionXFactor:CGFloat = data.type == .mineBubble ? 0.0 : -7.0
        let bgImageNewX = imageViewBG!.frame.minX + repositionXFactor
        let bgImageNewWidth =  imageViewBG!.frame.width + CGFloat(9.0)
        let bgImageNewHeight =  imageViewBG!.frame.height + CGFloat(5.0)
        imageViewBG?.frame = CGRect(x: bgImageNewX, y: 0.0, width: bgImageNewWidth, height: bgImageNewHeight)
        
        var newStartX:CGFloat = 0.0
        if data.type == .mineBubble{
            let extraWidthToConsider = imageViewBG!.frame.width
            newStartX = ScreenSize.SCREEN_WIDTH - extraWidthToConsider
        } else {
            newStartX = -imageViewBG!.frame.minX + 3.0
        }
        
        self.frame = CGRect(x: newStartX, y: self.frame.minY, width: self.frame.width, height: self.frame.height)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("coder: Not Implemented")
    }
    
    public class func framePrimary(_ type:OMCChatBubbleType, startY: CGFloat) -> CGRect{
        let paddingFactor: CGFloat = 0.02
        let sidePadding = ScreenSize.SCREEN_WIDTH * paddingFactor
        let maxWidth = ScreenSize.SCREEN_WIDTH * 0.75
        
        let startX: CGFloat = type == .mineBubble ? ScreenSize.SCREEN_WIDTH * (CGFloat(1.0) - paddingFactor) - maxWidth : sidePadding
        return CGRect(x: startX, y: startY, width: maxWidth, height: 7)
    }
    
    func cardsAndHeight(cards:NSArray?) -> (NSArray?, CGFloat?) {
        
        var _cards:NSMutableSet? = NSMutableSet.init(capacity: (cards?.count)!)
        var _height:CGFloat = padding+60;
        let cardWithImageHeight:CGFloat = 350;
        var imgUrlPresent:Bool = false;
        for aCard in cards! {
            let _aCard:NSDictionary? = aCard as? NSDictionary
            let __aCard:OMCBotCard = OMCBotCard.init(aCard: _aCard)
            if( __aCard.imageUrl != nil ){
                imgUrlPresent = true;
            }
            _cards?.add(__aCard);
        }

        if imgUrlPresent {
            _height = cardWithImageHeight;
        }
        
        return (_cards?.allObjects as NSArray?, _height);
    }
    
    func addCarousle(cards:NSArray?) {
        
        var startY:CGFloat = 0.0;
        if lblHeight != nil {
            startY = lblHeight! < 25 ? 25 : lblHeight!
        }
        startY = startY + padding/2;
        
        var _cards:NSArray?
        var _height:CGFloat?
        (_cards, _height) = cardsAndHeight(cards: cards);
        let cardsView:OMCCardsCollectionView?  = OMCCardsCollectionView.init(frame:  CGRect(x: 0, y: startY, width: ScreenSize.SCREEN_WIDTH-(4*padding), height: _height!))
        cardsView?.backgroundColor = UIColor.clear;
        cardsView?.allCards = _cards as! [OMCBotCard]
        self.addSubview(cardsView!);
        cardHeight = cardsView?.bounds.size.height;
        cardWidth = cardsView?.bounds.size.width;
        //self.bringSubview(toFront: cardsView!)
        
        if lblHeight != nil {
            viewHeight = viewHeight! + lblHeight!;
        }
        viewHeight = viewHeight! + cardHeight! + padding;
        viewWidth = cardWidth;
    }
    
    func addTableView() {
        
        let startX:CGFloat = 0.0
        var startY:CGFloat = 0.0
        
        if lblHeight != nil {
            startY = lblHeight! < 25 ? 25 : lblHeight!
        }
        
        listView = UITableView(frame: CGRect(x: CGFloat(startX), y: startY, width: self.frame.width , height: (CGFloat((self.tblData?.count)!*28)) ))
        listView?.tag = 1
        listView?.delegate = self
        listView?.dataSource = self
        listView?.isScrollEnabled = false
        listView?.separatorInset.left = 0
        self.addSubview(listView!)
        
        viewHeight = padding/2 + (CGFloat((self.tblData?.count)!*28))
        if lblHeight != nil {
            viewHeight = viewHeight! + lblHeight!;
        }

        viewWidth = listView!.frame.maxX;
    }
    
    func addGlobalTableView() {
        
        let startX:CGFloat = 0.0
        var startY:CGFloat = padding
        var globalTblWidth = self.frame.width;
        
        if lblHeight != nil {
            startY = lblHeight! < 25 ? 25 : lblHeight!
        }

        if listView != nil {
            startY = startY + padding/2 + (listView?.bounds.size.height)!;
        }
        
        if isCard == true {
            startY = startY + cardHeight! + padding;
            globalTblWidth = cardWidth!;
        }
        
        globalListView = UITableView(frame: CGRect(x: CGFloat(startX), y: startY, width: globalTblWidth , height: (CGFloat((self.globalTblData?.count)!*28)) ))
        globalListView?.tag = 2
        globalListView?.delegate = self
        globalListView?.dataSource = self
        globalListView?.isScrollEnabled = false
        globalListView?.separatorInset.left = 0
        self.addSubview(globalListView!)
        
        viewHeight = padding/2 + (CGFloat((self.globalTblData?.count)!*28))
        if listView != nil {
            viewHeight = viewHeight! + padding/2 + (listView?.bounds.size.height)!;
        }
        if lblHeight != nil {
            viewHeight = viewHeight! + lblHeight!;
        }
        if isCard == true {
            viewHeight = viewHeight! + cardHeight! + (padding*2);
        }

        viewWidth = globalListView!.frame.maxX;
    }
    
    func addTxtLabel(text:String?, type:OMCChatBubbleType) {
        
        let startX = padding
        let startY:CGFloat = 5.0
        
        labelChatText = UILabel(frame: CGRect(x: startX, y: startY, width: self.frame.width - 2 * padding , height: lblHeight!))
        labelChatText?.textAlignment = type == .mineBubble ? .right : .left
        labelChatText?.font = UIFont.systemFont(ofSize: 14)
        labelChatText?.numberOfLines = 0 // Making it multiline
        labelChatText?.text = text
        
        if type == .mineBubble {
            labelChatText?.textColor = UIColor.white
        }
        else{
            labelChatText?.textColor = UIColor.black
        }
        
        labelChatText?.sizeToFit()
        self.addSubview(labelChatText!)
    }
}
