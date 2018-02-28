//
//  ChatTableView.swift
//  ChatBots
//
//  Created by Jay Vachhani on 11/13/16.
//  Copyright © 2016 Oracle. All rights reserved.
//

import UIKit

extension OMCChatBubbleView : UITableViewDelegate, UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (tableView.tag == 1) {
        
            if self.tblData == nil {
                return 0;
            }
        
            return (self.tblData?.count)!;
        }
        
        if self.globalTblData == nil {
            return 0;
        }
        
        return (self.globalTblData?.count)!;
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 28
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "chatBotsCell")
        if (cell == nil) {
            cell = UITableViewCell(style:UITableViewCellStyle.default, reuseIdentifier:"chatBotsCell")
        }
        
        cell!.accessoryType = UITableViewCellAccessoryType.none
        cell?.selectionStyle = UITableViewCellSelectionStyle.blue
        cell?.textLabel?.textColor = #colorLiteral(red: 0, green: 0.5008062124, blue: 1, alpha: 1)
        cell?.textLabel?.textAlignment = NSTextAlignment.center
        cell!.textLabel!.font = UIFont.boldSystemFont(ofSize: 14);
        
        let _tblData:NSArray? = currentTableData(tag: tableView.tag);
        
        if self.isCMM! {
            let anAction:OMCBotAction = OMCBotAction(anAction: _tblData?.object(at: indexPath.row) as? NSDictionary)
            cell!.textLabel!.text = anAction.lbl;
        }
        else {
            cell!.textLabel!.text = _tblData?.object(at: indexPath.row) as? String;
        }
        
        cell?.textLabel?.numberOfLines = 0
    
        return cell!;
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let _tblData:NSArray? = currentTableData(tag: tableView.tag);

        if self.isCMM! {
            let anAction:OMCBotAction = OMCBotAction(anAction: _tblData?.object(at: indexPath.row) as? NSDictionary)
            NotificationCenter.default.post(name: Notification.Name(rawValue: kchoiceSelectedOrChatEntered), object: anAction )
        }
        else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: kchoiceSelectedOrChatEntered), object: _tblData?.object(at: indexPath.row) as? String )
        }

        tableView.isUserInteractionEnabled = false;
    }
    
    func currentTableData( tag:NSInteger ) -> NSArray? {
        
        if ( tag == 1 ) {
            return self.tblData;
        }
        
        return self.globalTblData;
    }
}
