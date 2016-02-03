//
//  HomeTwystCell.h
//  Twyst
//
//  Created by Niklas Ahola on 8/13/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeTwystCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIView *content_;
@property (weak, nonatomic) IBOutlet UIImageView *imageAvatar;
@property (weak, nonatomic) IBOutlet UIImageView *imageThumb;
@property (weak, nonatomic) IBOutlet UILabel *labelTheme;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelTime;
@property (weak, nonatomic) IBOutlet UIImageView *imagePassArrow;

@property (nonatomic, assign) long twystId;

+ (CGFloat)heightForCell:(Twyst*)twyst;
+ (CGFloat)heightForSavedCell:(FFlipframeSavedLibrary*)twyst;
+ (NSString *)reuseIdentifier;
+ (NSString *)nibName;

- (void)configureCell:(Twyst*)twyst;
- (void)configureSavedCell:(FFlipframeSavedLibrary*)twyst;
- (void)updateCell:(Twyst*)twyst;

@end
