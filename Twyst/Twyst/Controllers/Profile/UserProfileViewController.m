//
//  UserProfileViewController.m
//  Twyst
//
//  Created by Niklas Ahola on 4/17/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <MessageUI/MessageUI.h>

#import "UIImage+Device.h"
#import "UIImageView+WebCache.h"
#import "NSString+Extension.h"

#import "TTwystOwnerManager.h"
#import "TSavedTwystManager.h"

#import "PhotoHelper.h"
#import "UserWebService.h"
#import "FriendManageService.h"
#import "FlipframeFileService.h"
#import "AzureBlobStorageService.h"

#import "ExtraTagButton.h"
#import "ProfileFeedCell.h"
#import "ProfileEmptyCell.h"
#import "WrongMessageView.h"

#import "SettingViewController.h"
#import "TwystPreviewController.h"
#import "UserProfileViewController.h"
#import "InvitePeopleViewController.h"

typedef enum {
    CameraTypeAvatar = 10,
    CameraTypeCover,
} CameraType;

@interface UserProfileViewController () <UIImagePickerControllerDelegate, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate> {
    CameraType _cameraType;
    
    UserWebService *_webService;
    FriendManageService *_friendService;
    FlipframeFileService *_fileService;
    
    UITapGestureRecognizer *_tapGestureAvatar;
    
    BOOL _isLoading;
    NSArray *_dataSource;
    
    //
    CGRect _frameSetting;
    CGRect _frameInvite;
    CGRect _frameCover;
}

@property (nonatomic, strong) UIButton *btnSetting;
@property (nonatomic, strong) UIButton *btnInvite;
@property (nonatomic, strong) UIButton *btnCover;

@end

@implementation UserProfileViewController

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    self.user = [Global getOCUser];
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self initView];
    [self addTapGestures];
    [self loadCoverPicture];
    [self loadProfilePicture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [_friendService readAllFriendBadge];
    
    [self actionLoadUserInfo];
    [self actionLoadTwysts];
}

#pragma mark - override methods
- (void)initMembers {
    DeviceType type = [Global deviceType];
    switch (type) {
        case DeviceTypePhone6:
            self.headerHeight = 129.0;
            self.avatarImageSize = 81;
            self.avatarImageCompressedSize = 44;
            self.avatarOffsetY = 52;
            self.avatarOffsetX = 10;
            self.nameOffsetX = 15;
            self.realNameOffsetY = 57;
            self.userNameOffsetY = 81;
            self.realNameFontSize = 18.6;
            self.userNameFontSize = 13;
            self.bioOffsetY = 105;
            self.bioFontSize = 15;
            
            _frameSetting = CGRectMake(180, 3, 40, 40);
            _frameInvite = CGRectMake(219.5, 3, 40, 40);
            _frameCover = CGRectMake(265.5, 3, 100, 40);
            break;
            
        case DeviceTypePhone6Plus:
            self.headerHeight = 142.0;
            self.avatarImageSize = 90;
            self.avatarImageCompressedSize = 50;
            self.avatarOffsetY = 59;
            self.avatarOffsetX = 11;
            self.nameOffsetX = 17;
            self.realNameOffsetY = 64;
            self.userNameOffsetY = 91;
            self.realNameFontSize = 20.8;
            self.userNameFontSize = 14;
            self.bioOffsetY = 117;
            self.bioFontSize = 16.4;
            
            _frameSetting = CGRectMake(201, 6, 40, 40);
            _frameInvite = CGRectMake(245, 6, 40, 40);
            _frameCover = CGRectMake(298, 6, 100, 40);
            break;
            
        default:
            self.headerHeight = 110.0;
            self.avatarImageSize = 70;
            self.avatarImageCompressedSize = 40;
            self.avatarOffsetY = 45.5;
            self.avatarOffsetX = 8;
            self.nameOffsetX = 13;
            self.realNameOffsetY = 48.5;
            self.userNameOffsetY = 69;
            self.realNameFontSize = 16.6;
            self.userNameFontSize = 12.6;
            self.bioOffsetY = 90;
            self.bioFontSize = 13.4;
            
            _frameSetting = CGRectMake(150.5, 0, 40, 40);
            _frameInvite = CGRectMake(184.5, 0, 40, 40);
            _frameCover = CGRectMake(219, 0, 100, 40);
            break;
    }
    
    // change subheader height according bio
    CGSize bioSize = [self.user.Bio stringSizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:self.bioFontSize] lineSpace:4 constrainedToWidth:SCREEN_WIDTH - self.nameOffsetX * 2];
    if (bioSize.height > 0) {
        self.subHeaderHeight = self.bioOffsetY + bioSize.height + self.bioFontSize;
    }
    else {
        self.subHeaderHeight = self.bioOffsetY;
    }
    
    self.barIsCollapsed = false;
    self.barAnimationComplete = false;
    
    _webService = [UserWebService sharedInstance];
    _friendService = [FriendManageService sharedInstance];
    _fileService = [FlipframeFileService sharedInstance];
}

- (void)initView {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUsernameDidChange:)
                                                 name:kUsernameDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleFullnameDidChange:)
                                                 name:kFullnameDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleBioDidChange:)
                                                 name:kBioDidChangeNotification
                                               object:nil];
}

- (UIView*) createSubHeaderView {
    UIView* view = [UIView new];
    view.backgroundColor = [UIColor whiteColor];
    
    NSMutableDictionary* views = [NSMutableDictionary new];
    views[@"super"] = self.view;
    
    UILabel* realNameLabel = [UILabel new];
    realNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    realNameLabel.text = [NSString stringWithFormat:@"%@ %@", self.user.FirstName, self.user.LastName];
    realNameLabel.textColor = Color(49, 47, 60);
    [realNameLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:self.realNameFontSize]];
    views[@"realNameLabel"] = realNameLabel;
    [view addSubview:realNameLabel];
    self.labelRealname = realNameLabel;
    
    UILabel* userNameLabel = [UILabel new];
    userNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    userNameLabel.text = self.user.UserName;
    userNameLabel.textColor = Color(74, 71, 90);
    [userNameLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:self.userNameFontSize]];
    views[@"userNameLabel"] = userNameLabel;
    [view addSubview:userNameLabel];
    self.labelUsername = userNameLabel;
    
    UILabel* bioLabel = [UILabel new];
    bioLabel.translatesAutoresizingMaskIntoConstraints = NO;
    if (IsNSStringValid(self.user.Bio)) {
        bioLabel.attributedText = [NSString formattedString:@[self.user.Bio] fonts:@[[UIFont fontWithName:@"HelveticaNeue" size:self.bioFontSize]] colors:nil lineSpace:4];
    }
    bioLabel.textColor = Color(49, 47, 60);
    bioLabel.numberOfLines = 0;
    views[@"bioLabel"] = bioLabel;
    [view addSubview:bioLabel];
    self.labelBio = bioLabel;
    
    self.btnSetting = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnSetting.frame = _frameSetting;
    [self.btnSetting setImage:[UIImage imageNamedForDevice:@"btn-profile-setting-on"] forState:UIControlStateNormal];
    [self.btnSetting setImage:[UIImage imageNamedForDevice:@"btn-profile-setting-hl"] forState:UIControlStateHighlighted];
    [self.btnSetting addTarget:self action:@selector(handlebtnSettingTouch:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.btnSetting];
    
    self.btnInvite = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnInvite.frame = _frameInvite;
    [self.btnInvite setImage:[UIImage imageNamedForDevice:@"btn-profile-invite-on"] forState:UIControlStateNormal];
    [self.btnInvite setImage:[UIImage imageNamedForDevice:@"btn-profile-invite-hl"] forState:UIControlStateHighlighted];
    [self.btnInvite addTarget:self action:@selector(handlebtnInviteTouch:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.btnInvite];
    
    self.btnCover = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnCover.frame = _frameCover;
    [self.btnCover setImage:[UIImage imageNamedForDevice:@"btn-profile-cover-on"] forState:UIControlStateNormal];
    [self.btnCover setImage:[UIImage imageNamedForDevice:@"btn-profile-cover-hl"] forState:UIControlStateHighlighted];
    [self.btnCover addTarget:self action:@selector(handlebtnCoverTouch:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.btnCover];
    
    NSArray* constraints;
    NSString* format;
    
    format = [NSString stringWithFormat:@"|-%.0f-[realNameLabel]", self.nameOffsetX - 2];
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views];
    [view addConstraints:constraints];
    
    format = [NSString stringWithFormat:@"V:|-%.0f-[realNameLabel]", self.realNameOffsetY];
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views];
    [view addConstraints:constraints];
    
    format = [NSString stringWithFormat:@"|-%.0f-[userNameLabel]", self.nameOffsetX];
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views];
    [view addConstraints:constraints];
    
    format = [NSString stringWithFormat:@"V:|-%.0f-[userNameLabel]", self.userNameOffsetY];
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views];
    [view addConstraints:constraints];
    
    format = [NSString stringWithFormat:@"|-%.0f-[bioLabel]-%.0f-|", self.nameOffsetX, self.nameOffsetX];
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views];
    [view addConstraints:constraints];
    
    format = [NSString stringWithFormat:@"V:|-%.0f-[bioLabel]", self.bioOffsetY];
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views];
    [view addConstraints:constraints];
    
    return view;
}

#pragma mark - internal methods
- (void)addTapGestures {
    _tapGestureAvatar = [UITapGestureRecognizer new];
    [_tapGestureAvatar addTarget:self action:@selector(handleTapAvatar:)];
    self.imageAvatar.userInteractionEnabled = YES;
    [self.imageAvatar addGestureRecognizer:_tapGestureAvatar];
}

- (void)removeTapGestures {
    [self.imageAvatar removeGestureRecognizer:_tapGestureAvatar];
}

- (void)actionGotoSetting {
    SettingViewController *viewController = [[SettingViewController alloc] init];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:viewController];
    navVC.navigationBarHidden = YES;
    [self presentViewController:navVC animated:YES completion:nil];
}

#pragma mark - handle button methods
- (void)handlebtnSettingTouch:(id)sender {
    [self actionGotoSetting];
}

- (void)handlebtnInviteTouch:(id)sender {
    InvitePeopleViewController *viewController = [[InvitePeopleViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)handlebtnCoverTouch:(id)sender {
    _cameraType = CameraTypeCover;
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:@"Camera roll", @"Take a Photo", nil];
    actionSheet.tag = 300;
    [actionSheet showInView:self.view];
}

- (void)handleTapAvatar:(UITapGestureRecognizer*)sender {
    _cameraType = CameraTypeAvatar;
    OCUser *user = [Global getOCUser];
    UIActionSheet * actionSheet = nil;
    if (IsNSStringValid(user.ProfilePicName)) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:@"Remove Photo"
                                         otherButtonTitles:@"Camera roll", @"Take a Photo", nil];
        actionSheet.tag = 100;
    }
    else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:@"Camera roll", @"Take a Photo", nil];
        actionSheet.tag = 200;
    }
    [actionSheet showInView:self.view];
}

- (void)handleUsernameDidChange:(NSNotification*)notification {
    self.user = [Global getOCUser];
    self.labelTitleUsername.text = self.user.UserName;
    self.labelUsername.text = self.user.UserName;
}

- (void)handleFullnameDidChange:(NSNotification*)notification {
    self.user = [Global getOCUser];
    NSString *fullname = [NSString stringWithFormat:@"%@ %@", self.user.FirstName, self.user.LastName];
    self.labelTitleRealname.text = fullname;
    self.labelRealname.text = fullname;
}

- (void)handleBioDidChange:(NSNotification*)notification {
    self.user = [Global getOCUser];
    [self refreshTableHeaderView];
    [self loadCoverPicture];
    [self loadProfilePicture];
}

#pragma mark - reload content
- (void)actionLoadTwysts {
    if (self.currentTab == ProfileTabCreated) {
        if (self.arrayCreatedTwysts.count) {
            _dataSource = self.arrayCreatedTwysts;
            [self.tableView reloadData];
        }
        else {
            [self actionLoadCreatedTwysts];
        }
    }
    else if (self.currentTab == ProfileTabLiked) {
        if (self.arrayLikedTwysts.count) {
            _dataSource = self.arrayLikedTwysts;
            [self.tableView reloadData];
        }
        else {
            [self actionLoadLikedTwysts];
        }
    }
}

- (void)actionLoadMoreTwysts {
    if (!_isLoading) {
        if (self.currentTab == ProfileTabCreated) {
            [self actionLoadCreatedTwysts];
        }
        else if (self.currentTab == ProfileTabLiked) {
            [self actionLoadLikedTwysts];
        }
    }
}

- (void)actionLoadCreatedTwysts {
    if (self.isAllLoaded == NO) {
        
        _isLoading = YES;
        [self.tableView reloadData];
        
        [[UserWebService sharedInstance] getFriendProfile:self.user.Id start:self.loadStartIndex completion:^(NSDictionary *friendInfo) {
            
            _isLoading = NO;
            if ([friendInfo isKindOfClass:[NSDictionary class]]) {
                NSArray *friendTwysts = [friendInfo objectForKey:@"stringgs"];
                if (friendTwysts) {
                    NSMutableArray *twysts = [NSMutableArray new];
                    for (NSDictionary *twystDic in friendTwysts) {
                        Twyst *twyst = [Twyst createNewTwystWithDictionary:twystDic];
                        [twysts addObject:twyst];
                    }
                    [self.arrayCreatedTwysts addObjectsFromArray:twysts];
                    self.loadStartIndex = self.arrayCreatedTwysts.count;
                    if (friendTwysts.count < DEF_HOME_FEED_BUNCH) {
                        self.isAllLoaded = YES;
                    }
                    _dataSource = self.arrayCreatedTwysts;
                }
            }
            else {
                [self actionShowWrongMessage:WrongMessageTypeNoInternetConnection];
            }
            [self.tableView reloadData];
        }];
    }
}

- (void)actionLoadLikedTwysts {
    if (self.isAllLoaded == NO) {
        
        _isLoading = YES;
        [self.tableView reloadData];
        
        [[UserWebService sharedInstance] getUserLikedTwysts:self.user.Id start:self.loadStartIndex completion:^(NSArray *likedTwysts) {
            
            _isLoading = NO;
            if (likedTwysts) {
                [self.arrayLikedTwysts addObjectsFromArray:likedTwysts];
                self.loadStartIndex = self.arrayLikedTwysts.count;
                if (likedTwysts.count < DEF_HOME_FEED_BUNCH) {
                    self.isAllLoaded = YES;
                }
                _dataSource = self.arrayLikedTwysts;
            }
            else {
                [self actionShowWrongMessage:WrongMessageTypeNoInternetConnection];
            }
            [self.tableView reloadData];
        }];
    }
}

#pragma mark - table view methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = _dataSource.count;
    if (count == 0) {
        return 1;
    }
    else {
        if (self.isAllLoaded) {
            return count / 2 + count % 2;
        }
        else {
            return count / 2 + count % 2 + 1;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger count = _dataSource.count;
    if (count == 0) {
        return [ProfileEmptyCell heightForCell:self.headerHeight + self.subHeaderHeight + [ProfileActivityView heightForView]];
    }
    else {
        if (indexPath.row == (count + 1) / 2) {
            return 44;
        }
        else {
            return [ProfileFeedCell heightForCell];
        }
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger count = _dataSource.count;
    if (count == 0) {
        ProfileEmptyCell *cell = [tableView dequeueReusableCellWithIdentifier:[ProfileEmptyCell reuseIdentifier]];
        if (cell == nil) {
            cell = [[ProfileEmptyCell alloc] init];
        }
        
        if (_isLoading) {
            [cell showProfileLoading:self.headerHeight + self.subHeaderHeight + [ProfileActivityView heightForView]];
        }
        else {
            if (self.user.PrivateProfile) {
                [cell showFriendPrivate:self.headerHeight + self.subHeaderHeight + [ProfileActivityView heightForView]];
            }
            else {
                [cell showFriendNoPosts:self.headerHeight + self.subHeaderHeight + [ProfileActivityView heightForView]];
            }
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else {
        UITableViewCell *cell = nil;
        if (indexPath.row >= (count + 1) / 2) {
            cell = [self tableView:tableView loadingCellForRowAtIndexPath:indexPath];
        }
        else {
            ProfileFeedCell *feedCell = [tableView dequeueReusableCellWithIdentifier:[ProfileFeedCell reuseIdentifier]];
            if (feedCell == nil) {
                feedCell = [[ProfileFeedCell alloc] initWithTarget:self selector:@selector(handleFeedCellTouch:)];
            }
            
            NSInteger leftIndex = indexPath.row * 2;
            Twyst *leftTwyst = (leftIndex < _dataSource.count) ? [_dataSource objectAtIndex:leftIndex] : nil;
            
            NSInteger rightIndex = indexPath.row * 2 + 1;
            Twyst *rightTwyst = (rightIndex < _dataSource.count) ? [_dataSource objectAtIndex:rightIndex] : nil;
            
            [feedCell configureCell:leftTwyst leftIndex:leftIndex rightTwyst:rightTwyst rightIndex:rightIndex];
            cell = feedCell;
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView loadingCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TwystLoadingCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TwystLoadingCell"];
        cell.backgroundColor = [UIColor clearColor];
        
        WDActivityIndicator *indicator = [[WDActivityIndicator alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
        indicator.indicatorStyle = WDActivityIndicatorStyleGradientPurple;
        [indicator startAnimating];
        [cell addSubview:indicator];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void)handleFeedCellTouch:(ExtraTagButton*)sender {
    NSInteger index = sender.extraTag;
    [self actionSelectTwyst:index];
}

#pragma mark - show stringg preview
- (void)actionSelectTwyst:(NSInteger)index {
    Twyst *twyst = [_dataSource objectAtIndex:index];
    [self actionGotoPreview:twyst];
}

- (void)actionGotoPreview:(Twyst*)twyst {
    TwystPreviewController *viewController = [[TwystPreviewController alloc] init];
    viewController.twyst = twyst;
    viewController.isFriendTwyst = YES;
    [self showPreviewController:viewController];
}

- (void)showPreviewController:(PreviewBaseViewController*)viewController {
    UINavigationController * navVC = [[UINavigationController alloc] initWithRootViewController:viewController];
    navVC.navigationBarHidden = YES;
    [self.navigationController presentViewController:navVC animated:YES completion:nil];
}

#pragma mark - profile action sheet delegate
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 100) {
        switch (buttonIndex) {
            case 0:
                [self onRemovePhoto];
                break;
            case 1:
                [self onSelectPhoto];
                break;
            case 2:
                [self onTakePhoto];
                break;
            default:
                break;
        }
    }
    else if (actionSheet.tag == 200 || actionSheet.tag == 300) {
        switch (buttonIndex) {
            case 0:
                [self onSelectPhoto];
                break;
            case 1:
                [self onTakePhoto];
                break;
            default:
                break;
        }
    }
}

#pragma mark - load user info
- (void)actionLoadUserInfo {
    [self.activityView setActivities:self.user relation:UserRelationTypeSelf];
    [_webService getOCUser:self.user.Id completion:^(OCUser *user) {
        if (user) {
            self.user = user;
            [self.activityView setActivities:self.user relation:UserRelationTypeSelf];
        }
    }];
}

#pragma mark - profile photo manage methods
- (void)onRemovePhoto {
    OCUser *curUser = [Global getOCUser];
    curUser.ProfilePicName = @"";
    
    UIImage *placeholder = [UIImage imageNamedContentFile:@"ic-profile-avatar"];
    self.imageAvatar.image = placeholder;
    
    // update profile to server
    [_webService updateProfile:curUser completion:^(NSInteger statusCode) {
        if (statusCode == 0) {
            // remove original photo from local
            [Global saveOCUser];
        }
        else {
            [Global recoverOCUser];
            [WrongMessageView showAlert:WrongMessageTypeUploadProfileImageFailed target:nil];
            [self loadProfilePicture];
        }
    }];
}

- (void)onTakePhoto {
    UIImagePickerController* controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [controller setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Camera" message:@"Camera Not Available for This Device" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
    }
    controller.allowsEditing = YES;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)onSelectPhoto {
    UIImagePickerController* controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        controller.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    controller.allowsEditing = YES;
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - image picker controller delegate
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info {
    UIImage *selectedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    if (_cameraType == CameraTypeAvatar) {
        [self uploadProfilePicture:selectedImage];
    }
    else if (_cameraType == CameraTypeCover) {
        [self uploadCoverPicture:selectedImage];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - update profile picture
- (void)uploadProfilePicture:(UIImage *)selectedImage {
    UIImage *largeImage = [PhotoHelper cropSquareImage:selectedImage size:DEF_PROFILE_LARGE_SIZE];
    UIImage *image = [PhotoHelper cropSquareImage:selectedImage size:DEF_PROFILE_SIZE];
    self.imageAvatar.image = [PhotoHelper cropCircleImage:image size:self.imageAvatar.frame.size];
    
    AzureBlobStorageService *azureService = [AzureBlobStorageService sharedInstance];
    
    OCUser *curUser = [Global getOCUser];
    NSString *fileName = [_fileService generateProfilePhotoName:curUser.Id];
    NSString *largeFileName = [_fileService generateLargeProfilePhotoName:fileName];
    
    [azureService uploadProfilePhoto:image withFileName:fileName withCompletion:^(BOOL isSuccess) {
        if (isSuccess) {
            [azureService uploadProfilePhoto:largeImage withFileName:largeFileName withCompletion:^(BOOL isSuccess) {
                if (isSuccess) {
                    //update record to server
                    NSString *fileNameBody = [fileName stringByDeletingPathExtension];
                    [_webService uploadProfilePic:fileNameBody completion:^(OCUser *user) {
                        if (user) {
                            OCUser *curUser = [Global getOCUser];
                            curUser.ProfilePicName = fileName;
                            [Global saveOCUser];
                            
                            TTwystOwner *tOwner = [[TTwystOwnerManager sharedInstance] getOwnerWithUserId:user.Id];
                            if (tOwner) {
                                tOwner.profilePicName = fileName;
                                [[TTwystOwnerManager sharedInstance] saveObject:tOwner];
                            }
                        }
                        else {
                            [self actionUpdateProfileFailed];
                        }
                    }];
                }
                else {
                    [self actionUpdateProfileFailed];
                }
            }];
        }
        else {
            [self actionUpdateProfileFailed];
        }
    }];
}

- (void)actionUpdateProfileFailed {
    [self loadProfilePicture];
    [WrongMessageView showAlert:WrongMessageTypeUploadProfileImageFailed target:nil];
}

- (void)loadProfilePicture {
    OCUser *user = [Global getOCUser];
    UIImage *placeholder = [UIImage imageNamedContentFile:@"ic-profile-avatar"];
    __weak typeof(self) weakSelf = self;
    [self.imageAvatar setImageWithURL:ProfileURL(user.ProfilePicName) placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if (image) {
            weakSelf.imageAvatar.image = [PhotoHelper cropCircleImage:image size:weakSelf.imageAvatar.frame.size];
        }
    }];
}

- (void)uploadCoverPicture:(UIImage*)selectedImage {
    UIImage *coverImage = [PhotoHelper cropCoverImage:selectedImage];
    self.imageCover.image = coverImage;
    
    AzureBlobStorageService *azureService = [AzureBlobStorageService sharedInstance];
    
    OCUser *curUser = [Global getOCUser];
    NSString *fileName = [_fileService generateProfilePhotoName:curUser.Id];
    
    __weak typeof(self) weakSelf = self;
    [azureService uploadProfilePhoto:coverImage withFileName:fileName withCompletion:^(BOOL isSuccess) {
        if (isSuccess) {
            curUser.CoverPhoto = fileName;
            [_webService updateProfile:curUser completion:^(NSInteger statusCode) {
                if (statusCode == 0) {
                    [Global saveOCUser];
                    [weakSelf setOriginCoverImage:coverImage];
                }
                else {
                    [Global recoverOCUser];
                    [weakSelf loadCoverPicture];
                    [WrongMessageView showAlert:WrongMessageTypeUploadCoverImageFailed target:nil];
                }
            }];
        }
        else {
            [weakSelf loadCoverPicture];
            [WrongMessageView showAlert:WrongMessageTypeUploadCoverImageFailed target:nil];
        }
    }];
}

- (void)loadCoverPicture {
    OCUser *user = [Global getOCUser];
    UIImage *placeholder = [UIImage imageNamedForDevice:@"ic-friend-profile-default-cover"];
    [self setOriginCoverImage:placeholder];
    
    if (IsNSStringValid(user.CoverPhoto)) {
        __weak typeof(self) weakSelf = self;
        [self.imageCover setImageWithURL:ProfileURL(user.CoverPhoto) placeholderImage:placeholder options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (image) {
                [weakSelf setOriginCoverImage:image];
            }
        }];
    }
    else {
        self.imageCover.image = placeholder;
    }
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
    [self profileDidScroll:scrollView];
    
    CGFloat bottomInset = scrollView.contentInset.bottom;
    CGFloat bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height - bottomInset;
    if ((NSInteger)bottomEdge == (NSInteger)scrollView.contentSize.height) {
        NSLog(@"--- scroll view reaches to the bottom ---");
        if (self.loadStartIndex) {
            [self actionLoadMoreTwysts];
        }
    }
}

#pragma mark - status bar hidden
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    [self removeTapGestures];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kUsernameDidChangeNotification
                                                  object:nil];
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

@end
