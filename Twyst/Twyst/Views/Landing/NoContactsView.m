//
//  NoContactsView.m
//  Twyst
//
//  Created by Niklas Ahola on 7/27/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "AppDelegate.h"

#import "UserWebService.h"
#import "ValidationService.h"

#import "SignupView.h"
#import "NoContactsView.h"

#import "NMTransitionManager+Headers.h"
#import "LandingTopBarView.h"

@interface NoContactsView() {
    
}
@property (weak, nonatomic) IBOutlet UIImageView *logoView;
@property (weak, nonatomic) IBOutlet UILabel *hintTitle;
@property (weak, nonatomic) IBOutlet UILabel *hintTitle2;
@property (weak, nonatomic) IBOutlet UILabel *hintText1;
@property (weak, nonatomic) IBOutlet UILabel *hintText2;
@property (weak, nonatomic) IBOutlet UILabel *hintText3;
@property (weak, nonatomic) IBOutlet UILabel *hintText4;
@property (weak, nonatomic) IBOutlet UIButton *btnContinue;

@end

@implementation NoContactsView

+ (NoContactsView*)noContactsViewWithParent:(LandingPageViewController *)parent {
    NSString *nibName = ([Global deviceType] == DeviceTypePhone4) ? @"NoContactsView-3.5inch" : [FlipframeUtils nibNameForDevice:@"NoContactsView"];
    NSArray *subViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    NoContactsView *noContactView = [subViews firstObject];
    noContactView.parentViewController = parent;
    return noContactView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

#pragma mark - internal methods
- (BOOL)actionCheckValidation {
    return YES;
}

#pragma mark - handle button methods
- (IBAction)handleBtnContinueTouch:(id)sender {
    SignupView *signupView = [SignupView signupViewWithParent:self.parentViewController];
    [self.parentViewController pushView:signupView animated:YES];
}

#pragma mark -
- (void)dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

#pragma - Transition

- (void)customizeTopBar:(LandingTopBarView *)topBar {
    topBar.hidden = YES;

    dispatch_async(dispatch_get_main_queue(), ^{
        topBar.hidden = NO;

        NMEntranceTransitionAnimation *animation = [NMEntranceTransitionAnimation animationWithContainerView:self];
        NMEntranceElementTop *barEntrance = [NMEntranceElementTop animationWithContainerView:self elementView:topBar];
        barEntrance.delay = 0.0;
        [animation addEntranceElement:barEntrance];
        [[NMTransitionManager sharedInstance] beginAnimation:animation];
    });
}

- (NMTransitionAnimation *)generateIntroAnimation:(id)sender {
    NMEntranceTransitionAnimation *animation = [NMEntranceTransitionAnimation animationWithContainerView:self];
    
    NMEntranceElementTop *logoAnim = [NMEntranceElementTop animationWithContainerView:self elementView:self.logoView];
    NMEntranceElementBottom *btnContinueAnim = [NMEntranceElementBottom animationWithContainerView:self elementView:self.btnContinue];
    
    NMEntranceElementLeft *hintTitleAnim = [NMEntranceElementLeft animationWithContainerView:self elementView:self.hintTitle];
    NMEntranceElementLeft *hintTitle2Anim = [NMEntranceElementLeft animationWithContainerView:self elementView:self.hintTitle2];
    NMEntranceElementLeft *hintLabel1Anim = [NMEntranceElementLeft animationWithContainerView:self elementView:self.hintText1];
    NMEntranceElementLeft *hintLabel2Anim = [NMEntranceElementLeft animationWithContainerView:self elementView:self.hintText2];
    NMEntranceElementLeft *hintLabel3Anim = [NMEntranceElementLeft animationWithContainerView:self elementView:self.hintText3];
    NMEntranceElementLeft *hintLabel4Anim = [NMEntranceElementLeft animationWithContainerView:self elementView:self.hintText4];

    logoAnim.fadeIn = YES;
    
    CGFloat delay = 0.0;
    hintTitleAnim.delay = delay;
    hintTitle2Anim.delay = delay;
    delay += 0.1;
    hintLabel1Anim.delay = delay;
    delay += 0.1;
    hintLabel2Anim.delay = delay;
    delay += 0.1;
    hintLabel3Anim.delay = delay;
    delay += 0.1;
    hintLabel4Anim.delay = delay;
    delay += 0.1;
    logoAnim.delay = delay;
    
    [animation addEntranceElements:@[logoAnim, btnContinueAnim, hintTitleAnim, hintTitle2Anim, hintLabel1Anim, hintLabel2Anim, hintLabel3Anim, hintLabel4Anim]];
    
    return animation;
}

@end
