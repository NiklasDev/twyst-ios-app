//
//  UpdateVersionView.m
//  Twyst
//
//  Created by Niklas Ahola on 1/8/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UpdateVersionView.h"

@interface UpdateVersionView() {
    
}

@property (nonatomic, retain) IBOutlet UILabel *labelHelp;

@end

@implementation UpdateVersionView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initView];
}

- (void)initView {
    CGRect bounds = [UIScreen mainScreen].bounds;
    self.frame = bounds;
    
    NSString *message = self.labelHelp.text;
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:message];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:4.0f];
    [style setAlignment:NSTextAlignmentCenter];
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, message.length)];
    self.labelHelp.attributedText = attrString;
    
    self.alpha = 0;
}

- (void)showInView:(UIView*)parent {
    [parent addSubview:self];
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.alpha = 1.0f;
                     }];
}

- (IBAction)handleBtnUpdateTouch:(id)sender {
    NSURL *url = [NSURL URLWithString:APP_STORE_LINK];
    [[UIApplication sharedApplication] openURL:url];
}

@end
