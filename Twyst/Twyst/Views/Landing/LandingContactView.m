//
//  LandingContactView.m
//  Twyst
//
//  Created by Niklas Ahola on 7/27/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "AppDelegate.h"

#import "UserWebService.h"
#import "ValidationService.h"

#import "ContactCell.h"
#import "LandingContactView.h"
#import "ContactManageService.h"
#import "WrongMessageView.h"
#import <MessageUI/MessageUI.h>
#import "LandingTopBarView.h"
#import "NMTransitionManager+Headers.h"

@interface LandingContactView() <UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate> {
    
    NSMutableArray *_friends;
    NSDictionary *_friendSelected;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation LandingContactView

+ (NSMutableArray *)alreadySentRequests {
    static NSMutableArray *alreadySentRequests;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        alreadySentRequests = [[NSMutableArray alloc] init];
    });
    
    return alreadySentRequests;
}

+ (LandingContactView*)contactViewWithParent:(LandingPageViewController *)parent {
    NSString *nibName = [FlipframeUtils nibNameForDevice:@"LandingContactView"];
    NSArray *subViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    LandingContactView *contactView = [subViews firstObject];
    contactView.parentViewController = parent;
    return contactView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.tableView.alpha = 0;
    _friends = [[NSMutableArray alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadFriends];
    });
}

#pragma mark - load friends methods
- (void)loadFriends {
    ContactManageService *contactService = [ContactManageService sharedInstance];
    if (contactService.isContactLoaded) {
        [self showProcessingView:YES];
        NSString *phoneCodes = [contactService generatePhoneNumberString];
        [[UserWebService sharedInstance] searchFriendByPhoneCode:phoneCodes completion:^(NSArray *friends) {
            [self showProcessingView:NO];

            if (friends) {
                [_friends removeAllObjects];
                [_friends addObjectsFromArray:friends];
                [self.tableView reloadData];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:0.3 animations:^{
                        self.tableView.alpha = 1.0;
                    }];
                });
                
            }
            else {
                [WrongMessageView showMessage:WrongMessageTypeNoInternetConnection inView:self];
            }
        }];
    }
}

#pragma mark - table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_friends count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ContactCell heightForCell];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactCell * cell = [tableView dequeueReusableCellWithIdentifier:[ContactCell reuseIdentifier]];
    if (cell == nil) {
        cell = [[ContactCell alloc] init];
    }
    
    NSDictionary *friendDic = [_friends objectAtIndex:indexPath.row];
    BOOL alreadySentRequest = NO;
    for (NSNumber *Id in [LandingContactView alreadySentRequests]) {
        if ([friendDic[@"Id"] isEqual:Id]) {
            alreadySentRequest = YES;
            break;
        }
    }
    
    [cell configureFriendMessageCell:friendDic alreadySentRequest:alreadySentRequest];
    
    return cell;
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _friendSelected = [_friends objectAtIndex:indexPath.row];
    [self sendInviteCodeRequest:_friendSelected];
}

#pragma mark - send message

- (void)sendInviteCodeRequest:(NSDictionary *)friendDic {
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *_controller = [[MFMessageComposeViewController alloc] init];
        _controller.messageComposeDelegate = self;
        NSString *bodyText = [NSString stringWithFormat:@"Hey, do you have an invite code for Twyst? I want in ;)"];
        _controller.body = bodyText;
        _controller.recipients = @[friendDic[@"Phonenumber"]];
        [self.parentViewController presentViewController:_controller animated:YES completion:nil];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Send SMS"
                                                        message:@"You can not send SMS on this device."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark - MFMessageComposeViewController Delegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    BOOL isSent = NO;
    switch (result) {
        case MessageComposeResultCancelled:
            NSLog(@"Cancelled");
            break;
        case MessageComposeResultFailed:
            NSLog(@"Failed");
            break;
        case MessageComposeResultSent:
            isSent = YES;
            break;
        default:
            break;
    }
    
    if (isSent) {
        [[LandingContactView alreadySentRequests] addObject:_friendSelected[@"Id"]];
        [self.tableView reloadData];
    }
    
    // Remove the message view
    @autoreleasepool {
        [controller dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma mark -
- (void)dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

#pragma mark - Animation

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

@end
