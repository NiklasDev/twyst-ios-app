//
//  NoFriendsView.m
//  Twyst
//
//  Created by Niklas Ahola on 7/31/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"

#import "AppDelegate.h"

#import "UserWebService.h"
#import "ValidationService.h"

#import "NoFriendsView.h"
#import "LandingContactView.h"
#import "LandingTopBarView.h"

#import "NMTransitionManager+Headers.h"

@interface NoFriendsView() {
}

@property (weak, nonatomic) IBOutlet UIImageView *logoView;
@property (weak, nonatomic) IBOutlet UILabel *hintTitle;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel1;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel2;
@property (weak, nonatomic) IBOutlet BounceButton *btnInvite;


@end

@implementation NoFriendsView

+ (NoFriendsView*)noFriendsViewWithParent:(LandingPageViewController *)parent {
    NSString *nibName = ([Global deviceType] == DeviceTypePhone4) ? @"NoFriendsView-3.5inch" : [FlipframeUtils nibNameForDevice:@"NoFriendsView"];
    NSArray *subViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    NoFriendsView *noFriendsView = [subViews firstObject];
    noFriendsView.parentViewController = parent;
    return noFriendsView;
}

- (void)customizeTopBar:(LandingTopBarView*)topBar {
    CGRect frameSkip = CGRectZero;
    CGFloat skipFontSize = 0;
    switch ([Global deviceType]) {
        case DeviceTypePhone6:
            frameSkip = CGRectMake(7, 22, 48, 40);
            skipFontSize = 17;
            break;
        case DeviceTypePhone6Plus:
            frameSkip = CGRectMake(9, 26, 48, 40);
            skipFontSize = 18.8;
            break;
        default:
            frameSkip = CGRectMake(6, 22, 48, 40);
            skipFontSize = 16;
            break;
    }
    
    UIButton *btnSkip = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSkip.frame = frameSkip;
    [btnSkip setTitle:@"Skip" forState:UIControlStateNormal];
    [btnSkip setTitleColor:Color(58, 50, 88) forState:UIControlStateNormal];
    [btnSkip setTitleColor:Color(91, 87, 111) forState:UIControlStateHighlighted];
    [btnSkip setTitleColor:ColorRGBA(58, 50, 88, 0.2) forState:UIControlStateDisabled];
    btnSkip.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:skipFontSize];
    [btnSkip addTarget:self action:@selector(handleBtnSkipTouch:) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:btnSkip];
}

#pragma mark - internal methods
- (void)actionGotoContacts {
    
}

- (void)actionStartApp {
    NMColorBurstTransition *transition = [[NMColorBurstTransition alloc] initWithContainerFrom:self.topBarView.superview
                                                                                     burstView:self.topBarView.btnBack
                                                                                   containerTo:nil
                                                                                    burstColor:[UIColor whiteColor]];
    [transition setTransitionBlock:^(void(^completion)(void)) {
        [[AppDelegate sharedInstance] startApp];
        completion();
    }];
    [[NMTransitionManager sharedInstance] beginTransition:transition];
}

#pragma mark - handle button methods
- (IBAction)handleBtnInviteTouch:(id)sender {
    [self actionGotoContacts];
}

- (void)handleBtnSkipTouch:(id)sender {
    [self actionStartApp];
}

#pragma mark -
- (void)dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

#pragma mark - Animations

- (NMTransitionAnimation *)generateIntroAnimation:(id)sender {
    NMEntranceTransitionAnimation *animation = [NMEntranceTransitionAnimation animationWithContainerView:self];
    
    NMEntranceElementTop *logoAnim = [NMEntranceElementTop animationWithContainerView:self elementView:self.logoView];
    NMEntranceElementLeft *hintTitleAnim = [NMEntranceElementLeft animationWithContainerView:self elementView:self.hintTitle];
    NMEntranceElementLeft *hintLabel1Anim = [NMEntranceElementLeft animationWithContainerView:self elementView:self.hintLabel1];
    NMEntranceElementLeft *hintLabel2Anim = [NMEntranceElementLeft animationWithContainerView:self elementView:self.hintLabel2];

    NMEntranceElementBottom *btnInviteAnim = [NMEntranceElementBottom animationWithContainerView:self elementView:self.btnInvite];
    
    CGFloat delay = 0.0;
    hintTitleAnim.delay = delay;
    delay += 0.1;
    hintLabel1Anim.delay = delay;
    delay += 0.1;
    hintLabel2Anim.delay = delay;
    logoAnim.delay = delay;
    
    [animation addEntranceElements:@[logoAnim, hintTitleAnim, hintLabel1Anim, hintLabel2Anim, btnInviteAnim]];
    
    return animation;
}

@end
