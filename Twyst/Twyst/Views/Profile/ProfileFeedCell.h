//
//  ProfileFeedCell.h
//  Twyst
//
//  Created by Wang Fang on 3/20/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Twyst.h"

@interface ProfileFeedCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIView *content_;

@property (weak, nonatomic) IBOutlet UIView *leftContainer;
@property (weak, nonatomic) IBOutlet UIView *rightContainer;

+ (CGFloat)heightForCell;
+ (NSString*)reuseIdentifier;
+ (NSString*)nibName;

- (id)initWithTarget:(id)target selector:(SEL)selector;
- (void)configureCell:(Twyst*)leftTwyst leftIndex:(NSInteger)leftIndex rightTwyst:(Twyst*)rightTwyst rightIndex:(NSInteger)rightIndex;

@end
