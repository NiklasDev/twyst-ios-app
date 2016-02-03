//
//  InvitePeopleViewController.m
//  Twyst
//
//  Created by Niklas Ahola on 8/13/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <MessageUI/MessageUI.h>

#import "UIImage+Device.h"

#import "AppDelegate.h"
#import "UserWebService.h"
#import "FriendManageService.h"
#import "ContactManageService.h"
#import "FlurryTrackingService.h"

#import "InviteCell.h"
#import "WrongMessageView.h"
#import "CircleProcessingView.h"
#import "EGORefreshTableHeaderView.h"

#import "InvitePeopleViewController.h"
#import "FriendProfileViewController.h"

#define DEF_MAX_INVITE_CONNECTS     6
#define DEF_CONNECT_REPLENISH       1800 //30 minutes

@interface InvitePeopleViewController () <EGORefreshTableHeaderDelegate, UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate> {
    
    NSMutableArray *_contacts;
    
    FriendManageService *_friendService;
    ContactManageService *_contactService;
    
    long _selectedFriendId;
    
    NSTimer *_connectsTimer;
    NSTimeInterval _newConnectTime;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
}

@property (weak, nonatomic) IBOutlet UIView *loadingContainer;
@property (weak, nonatomic) IBOutlet UIView *rightContainer;
@property (weak, nonatomic) IBOutlet UILabel *labelCount;
@property (weak, nonatomic) IBOutlet UILabel *labelTimer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headerView;

@end

@implementation InvitePeopleViewController

- (id)init {
    NSString *nibName = [FlipframeUtils nibNameForDevice:@"InvitePeopleViewController"];
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
        _contacts = [[NSMutableArray alloc] init];
        
        _friendService = [FriendManageService sharedInstance];
        _contactService = [ContactManageService sharedInstance];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.labelCount.layer.cornerRadius = self.labelCount.frame.size.height / 2;
    self.labelCount.layer.masksToBounds = YES;
    self.labelTimer.layer.cornerRadius = self.labelTimer.frame.size.height / 2;
    self.labelTimer.layer.masksToBounds = YES;
    
    // add refresh header view
    [self addEOGRefreshTableHeader];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onContactDidLoadNotification:)
                                                 name:kContactDidLoadNotification
                                               object:nil];
    
    self.loadingContainer.hidden = _contactService.isContactLoaded;
    
    
    //
    _newConnectTime = [self loadNewConnectTime];
    
    [self showInviteConnects];
    
    [self startTimer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadFriends];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kContactDidLoadNotification
                                                  object: nil];
    
    [self saveNewConnectTime:_newConnectTime];
    [self invalidateTimer];
}

#pragma mark - internal methods
- (void)addEOGRefreshTableHeader {
    if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
	}
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
}

#pragma mark - notification handler
- (void)onContactDidLoadNotification:(NSNotification *)notification {
    [self loadFriends];
}

#pragma mark - load friends methods
- (void)loadFriends {
    if (_contactService.isContactLoaded) {
        self.rightContainer.hidden = YES;
        self.loadingContainer.hidden = YES;
        [CircleProcessingView showInView:self.view];
        NSString *phoneCodes = [_contactService generatePhoneNumberString];
        [[UserWebService sharedInstance] searchFriendByPhoneCode:phoneCodes completion:^(NSArray *friends) {
            [self doneLoadingTableViewData];
            
            if (friends) {
                [self prepareDataSource:friends completion:^{
                    self.rightContainer.hidden = NO;
                    [CircleProcessingView hide];
                    [self.tableView reloadData];
                }];
            }
            else {
                [CircleProcessingView hide];
                [WrongMessageView showMessage:WrongMessageTypeNoInternetConnection inView:self.view];
            }
        }];
    }
}

- (void)prepareDataSource:(NSArray*)friends completion:(void(^)())completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray *friendCodes = [NSMutableArray new];
        for (NSDictionary *friend in friends) {
            NSString *friendPhoneNumber = [friend objectForKey:@"Phonenumber"];
            [friendCodes addObject:friendPhoneNumber];
        }
        
        [_contacts removeAllObjects];
        NSArray *allKeys = [_contactService.contacts allKeys];
        for (NSString *phoneNumber in allKeys) {
            if (![friendCodes containsObject:phoneNumber]) {
                Contact *object = [_contactService.contacts objectForKey:phoneNumber];
                [_contacts addObject:object];
            }
        }
        
        //sort array
        NSArray *tempArray = [_contacts sortedArrayUsingComparator:^NSComparisonResult(Contact *obj1, Contact *obj2) {
            NSComparisonResult resut = [(NSString *)[obj1 fullName]
                                        compare:(NSString *)[obj2 fullName]
                                        options:NSCaseInsensitiveSearch];
            return resut;
        }];
        [_contacts removeAllObjects];
        [_contacts addObjectsFromArray:tempArray];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    });
}

- (void)actionSendRequest {
    NSString *friendId = [NSString stringWithFormat:@"%ld", _selectedFriendId];
    self.rightContainer.hidden = YES;
    [CircleProcessingView showInView:self.view];
    [_friendService requesetFriend:friendId
                       completion:^(BOOL isSuccess) {
                           self.rightContainer.hidden = NO;
                           [CircleProcessingView hide];
                           if (isSuccess) {
                               [self.tableView reloadData];
                           }
                           else {
                               [WrongMessageView showMessage:WrongMessageTypeNoInternetConnection inView:self.view];
                           }
                       }];
}

- (void)actionUnfriend {
    NSString *requestId = [_friendService friendshipId:_selectedFriendId];
    self.rightContainer.hidden = YES;
    [CircleProcessingView showInView:self.view];
    [_friendService removeFriend:requestId
                     completion:^(BOOL isSuccess) {
                         self.rightContainer.hidden = NO;
                         [CircleProcessingView hide];
                         if (isSuccess) {
                             [self.tableView reloadData];
                         }
                         else {
                             [WrongMessageView showMessage:WrongMessageTypeNoInternetConnection inView:self.view];
                         }
                     }];
}

#pragma mark - handle button methods
- (IBAction)handleBtnCloseTouch:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)handleBtnTimerTouch:(id)sender {
    if ([self getInviteConnects] < DEF_MAX_INVITE_CONNECTS) {
        self.labelCount.hidden = !self.labelCount.hidden;
        self.labelTimer.hidden = !self.labelTimer.hidden;
    }
}

#pragma mark - table view delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_contacts count];
}

#pragma mark -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [InviteCell heightForCell];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:tableView contactCellForRowIndexPath:indexPath];
    return cell;
}

- (UITableViewCell*)tableView:(UITableView*)tableView contactCellForRowIndexPath:(NSIndexPath*)indexPath {
    InviteCell * cell = [tableView dequeueReusableCellWithIdentifier:[InviteCell reuseIdentifier]];
    if (cell == nil) {
        cell = [[InviteCell alloc] init];
    }
    
    Contact *contact = [_contacts objectAtIndex:indexPath.row];
    [cell configureInviteCell:contact];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self handleContactCellTouch:indexPath.row];
}

#pragma mark - handle cell action
- (void)handleContactCellTouch:(NSInteger)index {
    if ([self getInviteConnects] > 0) {
        Contact *contact = [_contacts objectAtIndex:index];
        if ([MFMessageComposeViewController canSendText])
        {
            self.rightContainer.hidden = YES;
            [CircleProcessingView showInView:self.view];
            [[UserWebService sharedInstance] inviteCodeRequestCodeWithcompletion:^(NSString *inviteCode) {
                self.rightContainer.hidden = YES;
                [CircleProcessingView showInView:self.view];
                
                if (inviteCode) {
                    MFMessageComposeViewController *_controller = [[MFMessageComposeViewController alloc] init];
                    _controller.messageComposeDelegate = self;
                    NSString *bodyText = [NSString stringWithFormat:@"You're in. Here's your personal invite code to unlock Twyst: %@.\nDownload the app %@", inviteCode, DOWNLOAD_LINK];
                    _controller.body = bodyText;
                    _controller.recipients = @[contact.phone];
                    [self presentViewController:_controller animated:YES completion:nil];
                }
                else {
                    [WrongMessageView showMessage:WrongMessageTypeNoInternetConnection inView:self.view];
                }
            }];
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
        OCUser *user = [Global getOCUser];
        NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:user.UserName, @"username", nil];
        [FlurryTrackingService logEvent:FlurryCustomEventInviteFriend param:param];
        [_contactService inviteContacts:controller.recipients];
        [self.tableView reloadData];
        
        [self decreaseInviteConnects];
        [self showInviteConnects];
    }
    
    // Remove the message view
    @autoreleasepool {
        [controller dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - connects timer
- (void)startTimer {
    if (_connectsTimer == nil) {
        _connectsTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                          target:self
                                                        selector:@selector(onConnectsTimer:)
                                                        userInfo:nil
                                                         repeats:YES];
    }
}

- (void)invalidateTimer {
    if (_connectsTimer) {
        [_connectsTimer invalidate];
        _connectsTimer = nil;
    }
}

- (void)onConnectsTimer:(NSTimer*)sender {
    NSTimeInterval curTime = [NSDate timeIntervalSinceReferenceDate];
    if (curTime < _newConnectTime) {
        [self showNewConnectTime:_newConnectTime - curTime];
    }
    else {
        [self increaseInviteConnects:1];
        [self showInviteConnects];
        self.labelTimer.hidden = YES;
        self.labelCount.hidden = NO;
    }
}

#pragma mark - invite connects management
- (NSString*)connectsKeyString {
    OCUser *user = [Global getOCUser];
    return [NSString stringWithFormat:@"InviteConnects-%ld", user.Id];
}

- (NSString*)newConnectTimeString {
    OCUser *user = [Global getOCUser];
    return [NSString stringWithFormat:@"NewConnectTime-%ld", user.Id];
}

- (NSInteger)getInviteConnects {
    NSString *keyString = [self connectsKeyString];
    NSUserDefaults *userDefault =[NSUserDefaults standardUserDefaults];
    if ([userDefault objectForKey:keyString] == nil) {
        [userDefault setInteger:6 forKey:keyString];
        [userDefault synchronize];
    }
    return [[NSUserDefaults standardUserDefaults] integerForKey:[self connectsKeyString]];
}

- (void)increaseInviteConnects:(NSInteger)newConnects {
    NSString *keyString = [self connectsKeyString];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger connects = [userDefaults integerForKey:keyString];
    if (connects < DEF_MAX_INVITE_CONNECTS) {
        connects = MIN(DEF_MAX_INVITE_CONNECTS, connects + newConnects);
        [userDefaults setInteger:connects forKey:keyString];
        [userDefaults synchronize];
        [self updateNewConnectTime];
    }
}

- (void)decreaseInviteConnects {
    NSString *keyString = [self connectsKeyString];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger connects = [userDefaults integerForKey:keyString];
    if (connects > 0) {
        connects --;
        [userDefaults setInteger:connects forKey:keyString];
        [userDefaults synchronize];
        [self updateNewConnectTime];
    }
}

- (NSTimeInterval)loadNewConnectTime {
    NSTimeInterval newConnectTime = [[NSUserDefaults standardUserDefaults] doubleForKey:[self newConnectTimeString]];
    NSTimeInterval curTime = [NSDate timeIntervalSinceReferenceDate];
    if (newConnectTime < curTime) {
        NSInteger connects = (int)(curTime - newConnectTime) / DEF_CONNECT_REPLENISH;
        [self increaseInviteConnects:connects + 1];
    }
    return newConnectTime;
}

- (void)saveNewConnectTime:(NSTimeInterval)time {
    [[NSUserDefaults standardUserDefaults] setDouble:time forKey:[self newConnectTimeString]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateNewConnectTime {
    NSTimeInterval curTime = [NSDate timeIntervalSinceReferenceDate];
    if (_newConnectTime < curTime) {
        _newConnectTime = curTime + DEF_CONNECT_REPLENISH;
        [self saveNewConnectTime:_newConnectTime];
    }
}

- (void)showNewConnectTime:(NSTimeInterval)delta {
    int minutes = (int)delta / 60;
    int seconds = (int)delta % 60;
    self.labelTimer.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
}

- (void)showInviteConnects {
    NSInteger connects = [self getInviteConnects];
    self.labelCount.text = [NSString stringWithFormat:@"%ld", (long)connects];
}

#pragma mark - Data Source Loading / Reloading Methods
- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
    
    [self.view endEditing:YES];
	
    [self loadFriends];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

#pragma mark - status bar hidden
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    [_contacts removeAllObjects];
    _contacts = nil;
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

@end
