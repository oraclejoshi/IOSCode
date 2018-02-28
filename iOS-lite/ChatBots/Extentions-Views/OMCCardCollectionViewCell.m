//
//  OMCCardCollectionViewCell.m
//  ChatBots
//
//  Created by Jay Vachhani on 10/30/17.
//  Copyright © 2017 Oracle. All rights reserved.
//

#import "OMCCardCollectionViewCell.h"

#define cardXpadding 5
#define cardYpadding 7
#define actionBtnPadding 10

@implementation OMCCardCollectionViewCell
{
    CGFloat cardImgY;
    CGFloat actionBtnHeight;
    
    CGFloat cvHeight;
    CGFloat cvWidth;
    
    CGFloat elementWidth;
}

@synthesize lbl, btnCenter, btnAction1, btnAction2, btnAction3, btnAction4;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    cvWidth = UIScreen.mainScreen.bounds.size.width/1.5;
    cvHeight = self.contentView.bounds.size.height;

    elementWidth = cvWidth - ( 5*cardXpadding );
    self.contentView.frame = CGRectMake(0, 0, elementWidth+(2*cardXpadding), cvHeight);
    self.view.frame = self.contentView.bounds;
    
//    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self.lbl.frame = CGRectMake(cardXpadding, cardXpadding, elementWidth , self.lbl.bounds.size.height);
    self.desc.frame = CGRectMake(cardXpadding, self.lbl.bounds.size.height+cardYpadding, elementWidth, self.desc.bounds.size.height);
    
    cardImgY = self.desc.frame.origin.y+self.desc.bounds.size.height+cardYpadding;
    actionBtnHeight = self.btnAction1.bounds.size.height;
}

- (CGRect) frameOfActionBtnIndex:(int) index {

   return CGRectMake(cardXpadding, cvHeight-(actionBtnHeight*index)-(cardYpadding*index)-actionBtnPadding, elementWidth, actionBtnHeight);
}

-(void) adjustFrames:(NSInteger) totalActions {
    
    self.btnCenter.frame = CGRectMake(cardXpadding, cardImgY, elementWidth, cvHeight-cardImgY-(actionBtnHeight*totalActions)-((1+totalActions)*cardYpadding)-actionBtnPadding);

    switch ( totalActions ) {
        case 1:
            self.btnAction1.frame = [self frameOfActionBtnIndex:1];
            self.btnAction1.hidden = NO;
            break;
        case 2:
            self.btnAction2.frame = [self frameOfActionBtnIndex:1];
            self.btnAction2.hidden = NO;

            self.btnAction1.frame = [self frameOfActionBtnIndex:2];
            self.btnAction1.hidden = NO;
            break;
        case 3:
            self.btnAction3.frame = [self frameOfActionBtnIndex:1];
            self.btnAction3.hidden = NO;

            self.btnAction2.frame = [self frameOfActionBtnIndex:2];
            self.btnAction2.hidden = NO;

            self.btnAction1.frame = [self frameOfActionBtnIndex:3];
            self.btnAction1.hidden = NO;
            break;
        case 4:
            self.btnAction4.frame = [self frameOfActionBtnIndex:1];
            self.btnAction4.hidden = NO;

            self.btnAction3.frame = [self frameOfActionBtnIndex:2];
            self.btnAction3.hidden = NO;

            self.btnAction2.frame = [self frameOfActionBtnIndex:3];
            self.btnAction2.hidden = NO;

            self.btnAction1.frame = [self frameOfActionBtnIndex:4];
            self.btnAction1.hidden = NO;
            break;
        default:
            break;
    }
}

-(void) layoutIfNeeded {
    self.contentView.layer.cornerRadius = 10;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self setHighlighted:NO];
    
    self.btnCenter.imageView.image = nil;
}

@end
