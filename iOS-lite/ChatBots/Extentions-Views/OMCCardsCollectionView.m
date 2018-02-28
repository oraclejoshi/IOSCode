//
//  OMCCardsCollectionView.m
//  ChatBots
//
//  Created by Jay Vachhani on 11/1/17.
//  Copyright © 2017 Oracle. All rights reserved.
//

#import "OMCCardsCollectionView.h"
#import "OMCCardCollectionViewCell.h"
#import "OMCFileManager.h"
#import "ChatBots_lite-Swift.h"

@interface UIButton (CardIndexCategory)
@property (nonatomic, strong) NSNumber* cardIndex;
@property (nonatomic, strong) NSString* imgUrl;
@end

@implementation UIButton (CardIndexCategory)
- (NSNumber*)cardIndex{
    return objc_getAssociatedObject(self, @selector(cardIndex));
}

- (void)setCardIndex:(NSNumber*)cardIndex{
    objc_setAssociatedObject(self, @selector(cardIndex), [cardIndex copy], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSString*)imgUrl{
    return objc_getAssociatedObject(self, @selector(imgUrl));
}

- (void)setImgUrl:(NSString*)imgUrl{
    objc_setAssociatedObject(self, @selector(imgUrl), [imgUrl copy], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end

@implementation OMCCardsCollectionView

@synthesize allCards;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


static NSString * const reuseIdentifier = @"CardsCell";

-(instancetype) initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView=[[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:layout];
        [_collectionView setDataSource:self];
        [_collectionView setDelegate:self];
        
        UINib *nib = [UINib nibWithNibName:@"OMCCardCollectionViewCell" bundle:nil];
        [_collectionView registerNib:nib forCellWithReuseIdentifier:reuseIdentifier];
        
        //    [_collectionView registerClass:[OMCCardCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
        [_collectionView setBackgroundColor:[UIColor clearColor]];
        
        [self addSubview:_collectionView];
    }
    
    return self;
}

#pragma mark - CollectionView methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return allCards.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake(UIScreen.mainScreen.bounds.size.width/1.5, (CGRectGetHeight(collectionView.frame)));
}

- (NSString *) filePath:(NSString *) url{
    
    if ( [[NSUserDefaults standardUserDefaults] objectForKey:url] ) {
        return [OMCFileManager filePath:[[NSUserDefaults standardUserDefaults] objectForKey:url]];
    }
    
    return nil;
}

- (NSData *) fileData:(NSString *) url {
    
    if ( [[NSUserDefaults standardUserDefaults] objectForKey:url] ) {
        NSData* data = [OMCFileManager fileData:[[NSUserDefaults standardUserDefaults] objectForKey:url]];
        return data;
    }
    
    return nil;
}

- (void) setBackgroundImageInButton:(UIButton *) btn
                             imgUrl:(NSString *) imgUrl {
    
    if ( imgUrl == nil || btn == nil ) {
        return;
    }
    
    [btn setImgUrl:imgUrl];

    if ( [[NSUserDefaults standardUserDefaults] objectForKey:imgUrl] ) {
        NSData* imgData = [OMCFileManager fileData:[[NSUserDefaults standardUserDefaults] objectForKey:imgUrl]];
        [btn setBackgroundImage:[UIImage imageWithData:imgData]
                                  forState:UIControlStateNormal];
    }
    else{
        
        dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_HIGH), ^{
            
            NSString* __url = [imgUrl copy];
            NSData* imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:__url]];
            if ( imgData && btn ) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [btn setBackgroundImage:[UIImage imageWithData:imgData]
                                              forState:UIControlStateNormal];
                });
            }
            
            if( imgData ){
                NSString* fName = [OMCFileManager storeFileData:imgData withExt:nil];
                if ( fName ) {
                    [[NSUserDefaults standardUserDefaults] setObject:fName
                                                              forKey:__url];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
        });
    }
}

- (void) configureCardImage:(OMCCardCollectionViewCell *) cell
                       card:(OMCBotCard *) aCard
                  indexPath:(NSIndexPath *) indexPath {
    
    if ( aCard.imageUrl != nil
        && ![aCard.imageUrl isEqualToString:@""]) {
        cell.btnCenter.tag = indexPath.row;
        cell.btnCenter.hidden = NO;
        
        if ( [[NSUserDefaults standardUserDefaults] objectForKey:aCard.imageUrl] ) {
            NSData* imgData = [OMCFileManager fileData:[[NSUserDefaults standardUserDefaults] objectForKey:aCard.imageUrl]];
            [cell.btnCenter setBackgroundImage:[UIImage imageWithData:imgData]
                                      forState:UIControlStateNormal];
        }
        else{
            
            [self setBackgroundImageInButton:cell.btnCenter
                                      imgUrl:aCard.imageUrl];
        }
        
        [cell.btnCenter addTarget:self
                           action:@selector(btnCenterTapped:)
                 forControlEvents:UIControlEventTouchUpInside];
    }
    else{
        cell.btnCenter.hidden = YES;
    }
}

- (void) configureActionButtons:(OMCCardCollectionViewCell *) cell
                           card:(OMCBotCard *) aCard
                      indexPath:(NSIndexPath *) indexPath {
    
    cell.btnAction1.hidden = YES;
    cell.btnAction2.hidden = YES;
    cell.btnAction3.hidden = YES;
    cell.btnAction4.hidden = YES;
    cell.btnAction1.tag = indexPath.row;
    cell.btnAction2.tag = indexPath.row;
    cell.btnAction3.tag = indexPath.row;
    cell.btnAction4.tag = indexPath.row;

    // Set center image, if found.
   [self configureCardImage:cell
                       card:aCard
                  indexPath:indexPath];
    
    [cell adjustFrames:aCard.actions.count];
    for ( int index=0; index<aCard.actions.count; index++ ) {
        
        OMCBotAction* btnAction = [[OMCBotAction alloc] initWithAnAction:aCard.actions[index]];
        UIButton* btn = [cell valueForKey:[NSString stringWithFormat:@"btnAction%d",index+1]];
        btn.tag = indexPath.row;
        btn.cardIndex = [NSNumber numberWithInt:index];
        [btn setTitle:btnAction.lbl forState:UIControlStateNormal];
        [btn addTarget:self
                action:@selector(btnActionTapped:)
      forControlEvents:UIControlEventTouchUpInside];
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    OMCCardCollectionViewCell* cell = (OMCCardCollectionViewCell *) [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    OMCBotCard* aCard = allCards[indexPath.row];
    cell.lbl.text = [NSString stringWithFormat:@"%@", aCard.title];
    cell.desc.text = [NSString stringWithFormat:@"%@", aCard.desc];
    
    [self configureActionButtons:cell
                            card:aCard
                       indexPath:indexPath];
    
    [collectionView flashScrollIndicators];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    OMCCardCollectionViewCell *disCell = (OMCCardCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    if( disCell == nil ){
        disCell = (OMCCardCollectionViewCell *) cell;
    }
    
    disCell = nil;
}

#pragma mark - Action Buttons

-(void) btnCenterTapped:(id) sender {
}

-(void) btnActionTapped:(id) sender {
    
    UIButton* btn = (UIButton *) sender;
    OMCBotCard* aCard = allCards[btn.tag];
    OMCBotAction* btnAction = [[OMCBotAction alloc] initWithAnAction:aCard.actions[btn.cardIndex.intValue]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"choiceSelectedOrChatEntered"
                                                        object:btnAction];
}

@end

