//
//  OMCCardCollectionViewCell.h
//  ChatBots
//
//  Created by Jay Vachhani on 10/30/17.
//  Copyright © 2017 Oracle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMCCardCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *view;
@property (weak,nonatomic) IBOutlet UILabel* lbl;
@property (weak,nonatomic) IBOutlet UILabel* desc;
@property (weak,nonatomic) IBOutlet UIButton* btnCenter;

@property (weak,nonatomic) IBOutlet UIButton* btnAction1;
@property (weak,nonatomic) IBOutlet UIButton* btnAction2;
@property (weak,nonatomic) IBOutlet UIButton* btnAction3;
@property (weak,nonatomic) IBOutlet UIButton* btnAction4;

-(void) adjustFrames:(NSInteger) totalActions;

@end
