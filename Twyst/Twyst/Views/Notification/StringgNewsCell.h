//
//  TwystNewsCell.h
//  Twyst
//
//  Created by Niklas Ahola on 8/13/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTwystNews;

@interface StringgNewsCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIView *content_;
@property (weak, nonatomic) IBOutlet UIImageView *imageAvatar;
@property (weak, nonatomic) IBOutlet UIImageView *imageThumb;
@property (weak, nonatomic) IBOutlet UILabel *labelDesc;
@property (weak, nonatomic) IBOutlet UIImageView *imageSeparator;

+ (CGFloat)heightForCell:(TTwystNews*)news;
+ (NSString *)reuseIdentifier;
+ (NSString *)nibName;

- (void)configureCell:(TTwystNews*)news;

@end