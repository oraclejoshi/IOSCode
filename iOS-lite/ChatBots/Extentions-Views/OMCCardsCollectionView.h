//
//  OMCCardsCollectionView.h
//  ChatBots
//
//  Created by Jay Vachhani on 11/1/17.
//  Copyright © 2017 Oracle. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OMCBotCard;

@interface OMCCardsCollectionView : UIView <UICollectionViewDataSource, UICollectionViewDelegate> {
    UICollectionView* _collectionView;
}

@property(nonatomic, copy) NSArray<OMCBotCard*>* allCards;

- (void) setBackgroundImageInButton:(UIButton *) btn
                             imgUrl:(NSString *) imgUrl;

- (NSData *) fileData:(NSString *) url;

- (NSString *) filePath:(NSString *) url;

@end
