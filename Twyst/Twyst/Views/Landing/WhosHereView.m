//
//  WhosHereView.m
//  Twyst
//
//  Created by Niklas Ahola on 7/27/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "AppDelegate.h"

#import "UserWebService.h"
#import "ValidationService.h"

#import "WhosHereView.h"
#import "NoContactsView.h"
#import "LandingContactView.h"
#import "ContactManageService.h"

#import "SubmitButton.h"

#import "NMTransitionManager+Headers.h"

@interface WhosHereView() {
    
}

@property (weak, nonatomic) IBOutlet SubmitButton *btnSearch;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *logoView;
@property (weak, nonatomic) IBOutlet UILabel *hintTitle;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel1;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel2;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel3;

@end

@implementation WhosHereView

+ (WhosHereView*)whosHereViewWithParent:(LandingPageViewController *)parent {
    NSString *nibName = ([Global deviceType] == DeviceTypePhone4) ? @"WhosHereView-3.5inch" : [FlipframeUtils nibNameForDevice:@"WhosHereView"];
    NSArray *subViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    WhosHereView *whosHereView = [subViews firstObject];
    whosHereView.parentViewController = parent;
    return whosHereView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

#pragma mark - internal methods
- (void)actionSearch {
    [self loadFriends:^(BOOL containsFriends) {
        if (containsFriends) {
            [self actionGotoContacts];
        } else {
            [self actionGotoNoContacts];
        }
    }];
}

- (void)loadFriends:(void(^)(BOOL containsFriends))completion {
    ContactManageService *contactService = [ContactManageService sharedInstance];
    
    [self showProcessingView:YES];
    [self.btnSearch startLoading];
    
    if (contactService.isContactLoaded) {
        NSString *phoneCodes = [contactService generatePhoneNumberString];
        [[UserWebService sharedInstance] searchFriendByPhoneCode:phoneCodes completion:^(NSArray *friends) {
            [self showProcessingView:NO];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 *NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self.btnSearch stopLoading];
            });
            
            completion([friends count] != 0);
        }];
    } else {
        [contactService startNewContactSession:^(BOOL accessGranted, BOOL userBannedAccess) {
            [self showProcessingView:NO];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 *NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self.btnSearch stopLoading];
            });
            
            if (accessGranted) {
                [self loadFriends:completion];
            } else if (userBannedAccess) {
                [contactService showAccessDeniedAlert];
            }
        }];
    }
}

- (void)actionGotoNoContacts {
    NoContactsView *noContactsView = [NoContactsView noContactsViewWithParent:self.parentViewController];
    [self.parentViewController pushAnimatedView:noContactsView
                                   slideEnabled:NO
                                      animation:[NMColorFadeInTransitionAnimation animationWithContainerView:self color:[UIColor whiteColor]]
                                         sender:nil];
}

- (void)actionGotoContacts {
    LandingContactView *contactsView = [LandingContactView contactViewWithParent:self.parentViewController];    
    [self.parentViewController pushAnimatedView:contactsView
                                   slideEnabled:NO
                                      animation:[NMColorFadeInTransitionAnimation animationWithContainerView:self color:[UIColor whiteColor]]
                                         sender:nil];
}

#pragma mark - handle button methods
- (IBAction)handleBtnSearchTouch:(id)sender {
    [self actionSearch];
}

- (IBAction)handleBtnCancelTouch:(id)sender {
    [self.parentViewController popView:YES];
}

#pragma mark -
- (void)dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

- (NMTransitionAnimation *)generateIntroAnimation:(id)sender {
    NMEntranceTransitionAnimation *animation = [NMEntranceTransitionAnimation animationWithContainerView:self];
    
    NMEntranceElementTop *logoAnim = [NMEntranceElementTop animationWithContainerView:self elementView:self.logoView];
    NMEntranceElementTop *headerAnim = [NMEntranceElementTop animationWithContainerView:self elementView:self.headerView];
    NMEntranceElementBottom *btnSearchAnim = [NMEntranceElementBottom animationWithContainerView:self elementView:self.btnSearch];

    NMEntranceElementLeft *hintTitleAnim = [NMEntranceElementLeft animationWithContainerView:self elementView:self.hintTitle];
    NMEntranceElementLeft *hintLabel1Anim = [NMEntranceElementLeft animationWithContainerView:self elementView:self.hintLabel1];
    NMEntranceElementLeft *hintLabel2Anim = [NMEntranceElementLeft animationWithContainerView:self elementView:self.hintLabel2];
    NMEntranceElementLeft *hintLabel3Anim = [NMEntranceElementLeft animationWithContainerView:self elementView:self.hintLabel3];
    
    logoAnim.fadeIn = YES;
    
    CGFloat delay = 0.0;
    hintTitleAnim.delay = delay;
    delay += 0.1;
    hintLabel1Anim.delay = delay;
    delay += 0.1;
    hintLabel2Anim.delay = delay;
    delay += 0.1;
    hintLabel3Anim.delay = delay;
    delay += 0.1;
    logoAnim.delay = delay;

    [animation addEntranceElements:@[logoAnim, headerAnim, btnSearchAnim, hintTitleAnim, hintLabel1Anim, hintLabel2Anim, hintLabel3Anim]];
    
    return animation;
}

@end
