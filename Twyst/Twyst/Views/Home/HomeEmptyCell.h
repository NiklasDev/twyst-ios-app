//
//  HomeEmptyCell.h
//  Twyst
//
//  Created by Niklas Ahola on 2/19/15.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BounceButton.h"

@interface HomeEmptyCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIView *content_;

@property (weak, nonatomic) IBOutlet UIView *viewEmptyHome;
@property (weak, nonatomic) IBOutlet UIView *viewEmptyDirect;
@property (weak, nonatomic) IBOutlet UIView *viewEmptySaved;

@property (weak, nonatomic) IBOutlet BounceButton *btnHomeCreate;
@property (weak, nonatomic) IBOutlet BounceButton *btnDirectInvite;
@property (weak, nonatomic) IBOutlet BounceButton *btnSavedCreate;

+ (CGFloat)heightForCell;
+ (NSString *)reuseIdentifier;
+ (NSString *)nibName;

- (void)showEmptyHome:(id)target selector:(SEL)selector;
- (void)showEmptyDirect:(id)target selector:(SEL)selector;
- (void)showEmptySaved:(id)target selector:(SEL)selector;

@end
