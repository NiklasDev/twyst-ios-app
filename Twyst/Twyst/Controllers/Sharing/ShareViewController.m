//
//  ShareViewController.m
//  Twyst
//
//  Created by Niklas Ahola on 8/14/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UIView+Animation.h"
#import "UIImage+Device.h"
#import "UIImageView+WebCache.h"

#import "TStillframeRegular.h"
#import "TSavedTwystManager.h"

#import "ZipService.h"
#import "UserWebService.h"
#import "FriendManageService.h"
#import "FlipframeFileService.h"
#import "LibraryTwystService.h"
#import "IANoticeManageService.h"
#import "FlurryTrackingService.h"
#import "AzureBlobStorageService.h"
#import "LibraryFlipframeServices.h"

#import "Twyst.h"
#import "AppDelegate.h"

#import "YLProgressBar.h"
#import "CustomSearchBar.h"
#import "ShareFriendCell.h"
#import "WrongMessageView.h"
#import "FFullTutorialView.h"

#import "ShareViewController.h"

@interface ShareViewController () <AzureStorageServiceDelegate, SearchBarDelegate, UITableViewDataSource, UITableViewDelegate> {
    
    NSString *_searchKey;
    CustomSearchBar *_searchBar;
    
    BOOL _isAllFriends;
    NSMutableArray *_shareFriends;
    
    FriendManageService *_friendService;
    FlipframeFileService *_fileService;
    AzureBlobStorageService *_storageService;
    
    NSArray *_arrFriends;
    NSMutableArray *_filterFrineds;
    
    NSInteger _frameTime;
    FlipframePhotoModel *_flipframePhotoModel;
    FlipframeVideoModel *_flipframeVideoModel;
    FFlipframeSavedLibrary *_flipframeLibrary;
    
    NSInteger _dataSourceType;
    NSArray *_dataSource;
    
    BOOL _allowReplies;
    BOOL _allowPass;
    BOOL _isSendButtonPresent;
    BOOL _shouldShowClear;
    
    NSInteger _stepSharing;
    
    UIButton *_buttonClear;
}

@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnHome;
@property (weak, nonatomic) IBOutlet UIView *rightButtonContainer;

@property (weak, nonatomic) IBOutlet UIView *sendBtnContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnReplies;
@property (weak, nonatomic) IBOutlet UIButton *btnPass;
@property (weak, nonatomic) IBOutlet UIImageView *imageDArrow;

@property (weak, nonatomic) IBOutlet UIView *searchBarContainer;
@property (weak, nonatomic) IBOutlet UIView *searchResultContainer;
@property (weak, nonatomic) IBOutlet UITableView *tableViewSearch;
@property (weak, nonatomic) IBOutlet UITableView *tableViewFriends;

@property (weak, nonatomic) IBOutlet UIView *viewSending;
@property (weak, nonatomic) IBOutlet YLProgressBar *progressSend;

@end

@implementation ShareViewController

- (id)init {
    NSString *nibName = [FlipframeUtils nibNameForDevice:@"ShareViewController"];
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
        _friendService = [FriendManageService sharedInstance];
        _fileService = [FlipframeFileService sharedInstance];
        _storageService = [AzureBlobStorageService sharedInstance];
        
        _isAllFriends = NO;
        _allowReplies = YES;
        _allowPass = YES;
        _isSendButtonPresent = NO;
        
        _searchKey = nil;
        _shareFriends = [[NSMutableArray alloc] init];
        _filterFrineds = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithFlipframePhotoModel:(FlipframePhotoModel*)flipframeModel {
    self = [self init];
    if (self) {
        _flipframePhotoModel = flipframeModel;
        _dataSourceType = 1;
        _dataSource = flipframeModel.inputService.arrFullImagePaths;
        _frameTime = _flipframePhotoModel.frameTime;
    }
    return self;
}

- (id)initWithFlipframeVideoModel:(FlipframeVideoModel *)flipframeVideoModel {
    self = [self init];
    if (self) {
        _flipframeVideoModel = flipframeVideoModel;
        _dataSourceType = 2;
        _frameTime = _flipframeVideoModel.frameTime;
    }
    return self;
}

- (id)initWithFlipframeLibrary:(FFlipframeSavedLibrary*)flipframeLibrary {
    self = [self init];
    if (self) {
        _flipframeLibrary = flipframeLibrary;
        _dataSourceType = 3;
        _frameTime = flipframeLibrary.frameTime;
        FFlipframeSaved *flipframeSaved = [_flipframeLibrary flipframeSaved];
        if (_flipframeLibrary.isMovie) {
            
        }
        else {
            NSSet *setStillframes = flipframeSaved.libraryTwyst.listStillframeRegular;
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
            _dataSource = [setStillframes sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (_dataSourceType == 3) {
        _btnHome.hidden = YES;
    }
    else {
        _btnBack.hidden = YES;
    }
    
    [self actionGetAllFriends];
    
    // add search bar
    [self addSearchBar];
}

- (void)actionGetAllFriends {
    _arrFriends = [_friendService friends];
    [self.tableViewFriends reloadData];
}

- (void)filterDataSource {
    [_filterFrineds removeAllObjects];
    
    if (_searchKey == nil) {
        [_filterFrineds addObjectsFromArray:_arrFriends];
    }
    else if ([_searchKey isEqualToString:@""]) {
        // none
    }
    else {
        for (NSDictionary *friendDic in _arrFriends) {
            NSString *userName = [[friendDic objectForKey:@"OCUser1_friendid"] objectForKey:@"UserName"];
            if ([FlipframeUtils isSubstring:_searchKey of:[userName lowercaseString]]) {
                [_filterFrineds addObject:friendDic];
            }
        }
    }
    
    [self.tableViewSearch reloadData];
}

- (void) actionCloseShareScreen:(BOOL)isShared {
    if (_dataSourceType == 1 || _dataSourceType == 2) {
        [[AppDelegate sharedInstance] backToHomeScreen];
    }
    else if (_dataSourceType == 3) {
        if (isShared) {
            FFlipframeSaved *flipframeSaved = _flipframeLibrary.flipframeSaved;
            [[LibraryFlipframeServices sharedInstance] deleteFlipframeSaved:flipframeSaved];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - data source methods
- (NSString*)getTwystTheme {
    NSString *theme = nil;
    switch (_dataSourceType) {
        case 1:
            theme = _flipframePhotoModel.twystTheme;
            break;
        case 2:
            theme = _flipframeVideoModel.twystTheme;
            break;
        case 3:
            theme = _flipframeLibrary.caption;
            break;
        default:
            break;
    }
    return theme;
}

- (NSInteger)totalFrames {
    if (_dataSourceType == 2 || (_dataSourceType == 3 && _flipframeLibrary.isMovie)) {
        return 1;
    }
    else {
        return [_dataSource count];
    }
}

- (UIImage*)getImageAtIndex:(NSInteger)index {
    UIImage *image = nil;
    switch (_dataSourceType) {
        case 1:
            image = [_flipframePhotoModel serviceGetFinalImageAtIndex:index];
            break;
        case 3:
        {
            if (_flipframeLibrary.isMovie) {
                
            }
            else {
                TStillframeRegular *stillframeRegular = [_dataSource objectAtIndex:index];
                NSString *fullPath = [_fileService generateFullDocPath:stillframeRegular.path];
                image = [UIImage imageWithContentsOfFile:fullPath];
            }
        }
            break;
        default:
            break;
    }
    return image;
}

- (UIImage*)getThumbImage {
    if (_dataSourceType == 2) {
        NSURL *videoUrl = [NSURL fileURLWithPath:_flipframeVideoModel.finalPath];
        return [FlipframeUtils generateThumbImageFromVideo:videoUrl coverFrame:_flipframeVideoModel.coverFrame ];
    }
    else if (_dataSourceType == 3 && _flipframeLibrary.isMovie == YES) {
        return _flipframeLibrary.imageThumb;
    }
    else {
        return [self getImageAtIndex:0];
    }
}

- (NSString*)getVideoPath {
    NSString *videoPath = nil;
    if (_dataSourceType == 2) {
        videoPath = _flipframeVideoModel.finalPath;
    }
    else if (_dataSourceType == 3 && _flipframeLibrary.isMovie) {
        videoPath = [[FlipframeFileService sharedInstance] generateFullDocPath:_flipframeLibrary.videoPath];
    }
    return videoPath;
}

- (BOOL)zipFiles:(NSString*)zipFilePath {
    BOOL result = NO;
    switch (_dataSourceType) {
        case 1:
            result = [[ZipService sharedInstance] zipFilesWithFlipframeModel:_flipframePhotoModel withOutput:zipFilePath];
            break;
        case 3:
            result = [[ZipService sharedInstance] zipFilesWithFlipframeLibrary:_flipframeLibrary withOutput:zipFilePath];
            break;
        default:
            break;
    }
    return result;
}

- (void)actionSaveTwyst:(Twyst*)twyst fileName:(NSString*)fileName {
    
    void(^completion)() = ^void() {
        [self actionTwystDidSaveProc:twyst];
        [WrongMessageView showMessage:WrongMessageTypeCreateSuccessfully inView:[[AppDelegate sharedInstance] window]];
    };
    
    if (_dataSourceType == 2 ||
        (_dataSourceType == 3 && _flipframeLibrary.isMovie)) {
        if ([Global deviceType] == DeviceTypePhone4) {
            [self saveVideoTwystProc_iPhone4:twyst
                                    fileName:fileName
                                  completion:^{
                                      completion();
                                  }];
        }
        else {
            [self saveVideoTwystProc:twyst
                            fileName:fileName
                          completion:^{
                              completion();
                          }];
        }
    }
    else {
        if ([Global deviceType] == DeviceTypePhone4) {
            [self savePhotoTwystProc_iPhone4:twyst
                               fileName:fileName
                             completion:^{
                                 completion();
                             }];
        }
        else {
            [self savePhotoTwystProc:twyst
                       fileName:fileName
                     completion:^{
                         completion();
                     }];
        }
    }
}

- (void)actionTwystDidSaveProc:(Twyst*)twyst {
    [Global postTwystDidCreateNotification:twyst];
    [[IANoticeManageService sharedInstance] checkIANManually:nil];
    [self actionCloseShareScreen:YES];
}

- (void)actionSaveTwystToLibrary {
    id retVal = nil;
    if (_dataSourceType == 2) {
        retVal = [[LibraryTwystService sharedInstance] confirmLibraryTwystWithVideoModel:_flipframeVideoModel];
    }
    else {
        retVal = [[LibraryTwystService sharedInstance] confirmLibraryTwystWithPhotoModel:_flipframePhotoModel];
    }
    
    if (retVal) {
        [Global postLibraryItemDidSaveNotification];
        [WrongMessageView showMessage:WrongMessageTypeTwystSaveLibrary inView:[[AppDelegate sharedInstance] window]];
    }
    else {
        [WrongMessageView showAlert:WrongMessageTypeSomethingWentWrong target:nil];
    }
}

- (void)savePhotoTwystProc:(Twyst*)twyst fileName:(NSString*)fileName completion:(void(^)())completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSInteger totalFrames = [self totalFrames];
        NSNumber *userId = [NSNumber numberWithLong:[Global getOCUser].Id];
        NSMutableArray *arrFrames = [[NSMutableArray alloc] init];
        
        NSString *folderPath = [_fileService generateSavedTwystFolderPath:twyst.Id];
        folderPath = [folderPath stringByAppendingPathComponent:fileName];
        NSString *fullPath = [_fileService generateFullDocPath:folderPath];
        [FlipframeUtils checkAndCreateDirectory:fullPath];
        
        for (NSInteger i = 0; i < totalFrames; i++) {
            NSString *filePath = [NSString stringWithFormat:@"%@/%ld.jpg", folderPath, (long)i];
            NSString *fullPath = [_fileService generateFullDocPath:filePath];
            @autoreleasepool {
                UIImage *image = [self getImageAtIndex:i];
                [_fileService saveImageToPath:image path:fullPath];
                NSDictionary *frame = [NSDictionary dictionaryWithObjectsAndKeys:filePath, @"path",
                                       userId, @"userId",
                                       [NSNumber numberWithBool:NO], @"isMovie",
                                       [NSNumber numberWithInteger:0], @"replyIndex",
                                       [NSNumber numberWithInteger:_frameTime], @"frameTime",
                                       nil];
                [arrFrames addObject:frame];
            }
        }
        
        //save to core data
        [[TSavedTwystManager sharedInstance] confirmSavedTwyst:twyst arrFrames:arrFrames];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    });
}

- (void)savePhotoTwystProc_iPhone4:(Twyst*)twyst fileName:(NSString*)fileName completion:(void(^)())completion {
    NSInteger totalFrames = [self totalFrames];
    NSNumber *userId = [NSNumber numberWithLong:[Global getOCUser].Id];
    NSMutableArray *arrFrames = [[NSMutableArray alloc] init];
    
    NSString *folderPath = [_fileService generateSavedTwystFolderPath:twyst.Id];
    folderPath = [folderPath stringByAppendingPathComponent:fileName];
    NSString *fullPath = [_fileService generateFullDocPath:folderPath];
    [FlipframeUtils checkAndCreateDirectory:fullPath];
    
    for (NSInteger i = 0; i < totalFrames; i++) {
        NSString *filePath = [NSString stringWithFormat:@"%@/%ld.jpg", folderPath, (long)i];
        NSString *fullPath = [_fileService generateFullDocPath:filePath];
        @autoreleasepool {
            UIImage *image = [self getImageAtIndex:i];
            [_fileService saveImageToPath:image path:fullPath];
            NSDictionary *frame = [NSDictionary dictionaryWithObjectsAndKeys:filePath, @"path",
                                   userId, @"userId",
                                   [NSNumber numberWithBool:NO], @"isMovie",
                                   [NSNumber numberWithInteger:0], @"replyIndex",
                                   [NSNumber numberWithInteger:_frameTime], @"frameTime",
                                   nil];
            [arrFrames addObject:frame];
        }
    }
    
    //save to core data
    [[TSavedTwystManager sharedInstance] confirmSavedTwyst:twyst arrFrames:arrFrames];
    completion();
}

- (void)saveVideoTwystProc:(Twyst*)twyst fileName:(NSString*)fileName completion:(void(^)())completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSNumber *userId = [NSNumber numberWithLong:[Global getOCUser].Id];
        NSMutableArray *arrFrames = [[NSMutableArray alloc] init];
        
        NSString *folderPath = [_fileService generateSavedTwystFolderPath:twyst.Id];
        folderPath = [folderPath stringByAppendingPathComponent:fileName];
        [FlipframeUtils checkAndCreateDirectory:[_fileService generateFullDocPath:folderPath]];
        
        NSString *filePath = [NSString stringWithFormat:@"%@/movie.mp4", folderPath];
        NSString *fullPath = [_fileService generateFullDocPath:filePath];

        NSString *srcPath = [self getVideoPath];
        if ([_fileService copyFileToPath:srcPath toPath:fullPath]) {
            NSDictionary *frame = [NSDictionary dictionaryWithObjectsAndKeys:filePath, @"path",
                                   userId, @"userId",
                                   [NSNumber numberWithBool:YES], @"isMovie",
                                   [NSNumber numberWithInteger:0], @"replyIndex",
                                   [NSNumber numberWithInteger:_frameTime], @"frameTime",
                                   nil];
            [arrFrames addObject:frame];
            
            //save to core data
            [[TSavedTwystManager sharedInstance] confirmSavedTwyst:twyst arrFrames:arrFrames];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    });
}

- (void)saveVideoTwystProc_iPhone4:(Twyst*)twyst fileName:(NSString*)fileName completion:(void(^)())completion {
    NSNumber *userId = [NSNumber numberWithLong:[Global getOCUser].Id];
    NSMutableArray *arrFrames = [[NSMutableArray alloc] init];
    
    NSString *folderPath = [_fileService generateSavedTwystFolderPath:twyst.Id];
    folderPath = [folderPath stringByAppendingPathComponent:fileName];
    [FlipframeUtils checkAndCreateDirectory:[_fileService generateFullDocPath:folderPath]];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/movie.mp4", folderPath];
    NSString *fullPath = [_fileService generateFullDocPath:filePath];
    
    NSString *srcPath = [self getVideoPath];
    if ([_fileService copyFileToPath:srcPath toPath:fullPath]) {
        NSDictionary *frame = [NSDictionary dictionaryWithObjectsAndKeys:filePath, @"path",
                               userId, @"userId",
                               [NSNumber numberWithBool:YES], @"isMovie",
                               [NSNumber numberWithInteger:0], @"replyIndex",
                               [NSNumber numberWithInteger:_frameTime], @"frameTime",
                               nil];
        [arrFrames addObject:frame];
        
        //save to core data
        [[TSavedTwystManager sharedInstance] confirmSavedTwyst:twyst arrFrames:arrFrames];
    }
    completion();
}

- (void)showShareOptionMessage:(WrongMessageType)type {
    [WrongMessageView showMessage:type inView:self.view];
}

#pragma mark - handle button methods
- (IBAction)handleBtnHomeTouch:(id)sender {
    [self actionSaveTwystToLibrary];
    [self actionCloseShareScreen:NO];
}

- (IBAction)handleBtnBackTouch:(id)sender {
    [self actionCloseShareScreen:NO];
}

- (IBAction)handleBtnSearchTouch:(id)sender {
    [self showSearchBar];
}

- (IBAction)handleBtnRepliesTouch:(id)sender {
    _btnReplies.selected = !_btnReplies.selected;
    _allowReplies = _btnReplies.selected;
    WrongMessageType type = _allowReplies ? WrongMessageTypeRepliesOn : WrongMessageTypeRepliesOff;
    [self showShareOptionMessage:type];
}

- (IBAction)handleBtnPassTouch:(id)sender {
    _btnPass.selected = !_btnPass.selected;
    _allowPass = _btnPass.selected;
    WrongMessageType type = _allowPass ? WrongMessageTypePassOn : WrongMessageTypePassOff;
    [self showShareOptionMessage:type];
}

- (IBAction)handleBtnSendTouch:(id)sender {
    if (_isAllFriends) {
        [self actionSelectAllFriends];
    }
    
    if (_dataSourceType == 2 || (_dataSourceType == 3 && _flipframeLibrary.isMovie)) {
        [self shareVideoToFriends];
    }
    else {
        [self sharePhotosToFriends];
    }
}

#pragma mark - share twyst methods
- (void) actionSelectAllFriends {
    for (NSDictionary *friendDic in _arrFriends) {
        NSString *friendId = [[[friendDic objectForKey:@"OCUser1_friendid"] objectForKey:@"Id"] stringValue];
        if (![_shareFriends containsObject:friendId]) {
            [_shareFriends addObject:friendId];
        }
    }
}

- (NSString*) friendslist {
    NSMutableString *friends = nil;
    for (NSString *friendId in _shareFriends) {
        if (friends) {
            [friends appendFormat:@"|%@", friendId];
        }
        else {
            friends = [NSMutableString stringWithString:friendId];
        }
    }
    return friends;
}

- (NSString*)visibility {
    if (_isAllFriends) {
        return @"open";
    }
    else {
        return @"private";
    }
}

- (void)sharePhotosToFriends {
    NSString *caption = [self getTwystTheme];
    NSString *allowReplies = _allowReplies ? @"yes" : @"no";
    NSString *allowPass = _allowPass ? @"true" : @"false";
    
    [self showSendingView];
    
    // step 1 : create twyst id from app server
    _stepSharing = 1;
    [self.progressSend setProgress:0.1 animated:YES];
    [[UserWebService sharedInstance] createTwyst:caption allowReplies:allowReplies allowPass:allowPass visibility:[self visibility] completion:^(BOOL isSuccess1, Twyst *twyst1) {
        if (isSuccess1) {
            NSLog(@"++++++ Send Twyst STEP 1 : create twyst id = %ld", twyst1.Id);
            [self.progressSend setProgress:0.2 animated:YES];
            
            // step 2 : zip photos
            _stepSharing = 2;
            NSString *zipFilePath = [_fileService generateTwystZipFilePath:twyst1.Id];
            if ([self zipFiles:zipFilePath]) {
                NSLog(@"++++++ Send Twyst STEP 2 : zip files success");
                
                // step 3 : upload thumb image to cloud
                _stepSharing = 3;
                UIImage *thumb = [self getThumbImage];
                _storageService.delegate = self;
                [_storageService uploadTwystThumbnail:thumb withTwystId:twyst1.Id withCompletion:^(BOOL isSuccess2) {
                    if (isSuccess2) {
                        NSLog(@"++++++ Send Twyst STEP 3 : upload twyst thumbnail to cloud server success");
                        
                        // step 4 : upload zip file to cloud storage
                        _stepSharing = 4;
                        [_storageService uploadTwyst:zipFilePath withTwystId:twyst1.Id withCompletion:^(BOOL isSuccess3, NSString* fileName) {
                            _storageService.delegate = nil;
                            if (isSuccess3) {
                                NSLog(@"++++++ Send Twyst STEP 4 : upload twyst to cloud server success");
                                
                                // step 5 : share twyst to friends
                                _stepSharing = 5;
                                NSString *friends = [self friendslist];
                                NSString *fileNameBody = [fileName stringByDeletingPathExtension];
                                NSInteger imageCount = [self totalFrames];
                                [[UserWebService sharedInstance] shareTwyst:twyst1.Id filename:fileNameBody imageCount:imageCount isMovie:@"false" frameTime:_frameTime friends:friends completion:^(ResponseType response, Twyst *twyst2) {
                                    if (response == Response_Success) {
                                        NSLog(@"++++++ Send Twyst STEP 5 : share twyst success");
                                        [self.progressSend setProgress:1.0f animated:NO];
                                        
                                        OCUser *user = [Global getOCUser];
                                        NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:user.UserName, @"username", [NSString stringWithFormat:@"%ld", twyst2.Id], @"stringgId", nil];
                                        [FlurryTrackingService logEvent:FlurryCustomEventCreateTwyst param:param];
                                        
                                        twyst2.isMyFeed = YES;
                                        [self actionSaveTwyst:twyst2 fileName:fileNameBody];
                                    }
                                    else {
                                        NSLog(@"++++++ Send Twyst STEP 5 : share twyst failed");
                                        [self handleShareTwystFailed:twyst1.Id];
                                    }
                                }];
                            }
                            else {
                                NSLog(@"++++++ Send Twyst STEP 4 : upload twyst to cloud server failed");
                                [self handleShareTwystFailed:twyst1.Id];
                            }
                        }];
                    }
                    else {
                        NSLog(@"++++++ Send Twyst STEP 3 : upload thumb failed");
                        [self handleShareTwystFailed:twyst1.Id];
                    }
                }];
            }
            else {
                NSLog(@"++++++ Send Twyst STEP 2 : zip files failed");
                [self handleShareTwystFailed:twyst1.Id];
            }
        }
        else {
            NSLog(@"++++++ Send Twyst STEP 1 : create twyst id failed");
            [self handleShareTwystFailed:-1];
        }
    }];
}

- (void)shareVideoToFriends {
    NSString *caption = [self getTwystTheme];
    NSString *allowReplies = _allowReplies ? @"yes" : @"no";
    NSString *allowPass = _allowPass ? @"true" : @"false";
    
    [self showSendingView];
    
    // step 1 : create twyst id from app server
    _stepSharing = 1;
    [self.progressSend setProgress:0.1 animated:YES];
    [[UserWebService sharedInstance] createTwyst:caption allowReplies:allowReplies allowPass:allowPass visibility:[self visibility] completion:^(BOOL isSuccess1, Twyst *twyst1) {
        if (isSuccess1) {
            NSLog(@"++++++ Send Twyst STEP 1 : create twyst id = %ld", twyst1.Id);
            
            // step 2 : upload thumb image to cloud
            _stepSharing = 2;
            UIImage *thumb = [self getThumbImage];
            _storageService.delegate = self;
            [_storageService uploadTwystThumbnail:thumb withTwystId:twyst1.Id withCompletion:^(BOOL isSuccess2) {
                if (isSuccess2) {
                    NSLog(@"++++++ Send Twyst STEP 2 : upload twyst thumbnail to cloud server success");
                    
                    // step 4 : upload video file to cloud storage
                    _stepSharing = 3;
                    NSString *videoPath = [self getVideoPath];
                    [_storageService uploadTwystVideo:videoPath withTwystId:twyst1.Id withCompletion:^(BOOL isSuccess3, NSString* fileName) {
                        _storageService.delegate = nil;
                        if (isSuccess3) {
                            NSLog(@"++++++ Send Twyst STEP 3 : upload twyst to cloud server success");
                            
                            // step 5 : share twyst to friends
                            _stepSharing = 4;
                            NSString *friends = [self friendslist];
                            NSString *fileNameBody = [fileName stringByDeletingPathExtension];
                            NSInteger imageCount = [self totalFrames];
                            [[UserWebService sharedInstance] shareTwyst:twyst1.Id filename:fileNameBody imageCount:imageCount isMovie:@"true" frameTime:_frameTime friends:friends completion:^(ResponseType response, Twyst *twyst2) {
                                if (response == Response_Success) {
                                    NSLog(@"++++++ Send Twyst STEP 4 : share twyst success");
                                    [self.progressSend setProgress:1.0f animated:NO];
                                    
                                    OCUser *user = [Global getOCUser];
                                    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:user.UserName, @"username", [NSString stringWithFormat:@"%ld", twyst2.Id], @"stringgId", nil];
                                    [FlurryTrackingService logEvent:FlurryCustomEventCreateTwyst param:param];
                                    
                                    twyst2.isMyFeed = YES;
                                    [self actionSaveTwyst:twyst2 fileName:fileNameBody];
                                }
                                else {
                                    NSLog(@"++++++ Send Twyst STEP 4 : share twyst failed");
                                    [self handleShareTwystFailed:twyst1.Id];
                                }
                            }];
                        }
                        else {
                            NSLog(@"++++++ Send Twyst STEP 3 : upload twyst to cloud server failed");
                            [self handleShareTwystFailed:twyst1.Id];
                        }
                    }];
                }
                else {
                    NSLog(@"++++++ Send Twyst STEP 2 : upload thumb failed");
                    [self handleShareTwystFailed:twyst1.Id];
                }
            }];
        }
        else {
            NSLog(@"++++++ Send Twyst STEP 1 : create twyst id failed");
            [self handleShareTwystFailed:-1];
        }
    }];
}

// Handle share twyst failure
- (void)handleShareTwystFailed:(long)twystId {
    [self handleShareTwystFailed:twystId messageType:WrongMessageTypeNoInternetConnection];
}

- (void)handleShareTwystFailed:(long)twystId messageType:(WrongMessageType)messageType {
    if (twystId >= 0) {
        [[UserWebService sharedInstance] deleteUserTwyst:twystId completion:^(ResponseType response){}];
    }
    
    [self hideSendingView];
    
    if (messageType == WrongMessageTypeNoInternetConnection) {
        [WrongMessageView showMessage:messageType inView:self.view];
    }
    else {
        [WrongMessageView showAlert:messageType target:nil];
    }
}

#pragma mark - show / hide search bar
- (void)addSearchBar {
    _searchBar = [[CustomSearchBar alloc] initWithTarget:self];
    [self.searchBarContainer addSubview:_searchBar];
}

- (void)showSearchBar {
    self.searchResultContainer.hidden = NO;
    
    CGFloat width = SCREEN_WIDTH;
    CGRect frame = CGRectMake(width / 2, 0, width / 2, UI_TOP_BAR_HEIGHT);
    _searchBar.frame = frame;
    _searchBarContainer.alpha = 1.0f;
    frame = CGRectMake(0, 0, width, UI_TOP_BAR_HEIGHT);
    
    [_searchBar focusFriendSearchBar];
    [UIView animateWithDuration:0.2f
                     animations:^{
                         _searchBar.frame = frame;
                     }];
}

- (void)hideSearchBar {
    self.searchResultContainer.hidden = YES;
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         _searchBarContainer.alpha = 0.0f;
                     }];
}

#pragma mark show / hide sending view
- (void)showSendingView {
    [self initReplyView];
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.viewSending.alpha = 1.0f;
                     }];
}

- (void)hideSendingView {
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.viewSending.alpha = 0.0f;
                     }];
}

- (void)initReplyView {
    self.progressSend.trackTintColor           = [UIColor colorWithRed:194/255.0f green:194/255.0f blue:194/255.0f alpha:1.0f];
    self.progressSend.progressTintColor        = [UIColor colorWithRed:49/255.0f green:204/255.0f blue:206/255.0f alpha:1.0f];
    self.progressSend.indicatorTextDisplayMode = YLProgressBarIndicatorTextDisplayModeNone;
    self.progressSend.behavior                 = YLProgressBarBehaviorNonStripe;
    [self.progressSend setProgress:0 animated:NO];
}

#pragma mark - send button show / hide
- (void) reloadSendButtonStatus {
    if (_isAllFriends || [_shareFriends count]) {
        [self showSendButton];
    }
    else {
        [self hideSendButton];
    }
}

- (void) showSendButton {
    if (!_isSendButtonPresent) {
        
        // init share options as default
        _allowPass = _isAllFriends;
        _allowReplies = YES;
        _btnPass.selected = _allowPass;
        _btnReplies.selected = _allowReplies;
        
        CGFloat width = self.view.bounds.size.width;
        CGFloat height = self.view.bounds.size.height;
        CGFloat buttonHeight = _sendBtnContainer.frame.size.height;
        
        CGRect destBtnFrame = CGRectMake(0, height - buttonHeight, width, buttonHeight);
        
        CGFloat tableViewHeight = height - UI_NEW_TOP_BAR_HEIGHT - buttonHeight;
        CGRect frameTableView = CGRectMake(0, UI_NEW_TOP_BAR_HEIGHT, width, tableViewHeight);
        
        [UIView animateWithDuration:0.2f animations:^{
            _sendBtnContainer.frame = destBtnFrame;
            _tableViewFriends.frame = frameTableView;
        } completion:^(BOOL finished) {
            _isSendButtonPresent = YES;
            [_imageDArrow startPulseAnimation:0.02 duration:0.4];
        }];
    }
}

- (void) hideSendButton {
    if (_isSendButtonPresent) {
        CGFloat width = self.view.bounds.size.width;
        CGFloat height = self.view.bounds.size.height;
        CGFloat buttonHeight = _sendBtnContainer.frame.size.height;
        
        CGRect destBtnFrame = CGRectMake(0, height, width, buttonHeight);
        
        CGFloat tableViewHeight = height - UI_NEW_TOP_BAR_HEIGHT;
        CGRect frameTableView = CGRectMake(0, UI_NEW_TOP_BAR_HEIGHT, width, tableViewHeight);
        
        [UIView animateWithDuration:0.2f animations:^{
            _sendBtnContainer.frame = destBtnFrame;
            _tableViewFriends.frame = frameTableView;
        } completion:^(BOOL finished) {
            _isSendButtonPresent = NO;
            [_imageDArrow stopPulseAnimation];
        }];
    }
}

- (void)showClearButtonAnimation {
    if (_buttonClear) {
        [_buttonClear bounceAnimation:0.3];
    }
}

#pragma mark - table view delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([tableView isEqual:_tableViewFriends]) {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:_tableViewFriends]) {
        if (section == 1) {
            switch ([Global deviceType]) {
                case DeviceTypePhone6Plus:
                    return 34;
                    break;
                default:
                    return 30;
                    break;
            }
        }
    }
    return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:_tableViewFriends] && section == 1) {
        UIView *headerView = nil;
        switch ([Global deviceType]) {
            case DeviceTypePhone6Plus:
                headerView = [self tableView:tableView iPhone6PlusViewForHeaderInSection:section];
                break;
            default:
                headerView = [self tableView:tableView defaultViewForHeaderInSection:section];
                break;
        }
        return headerView;
    }
    else {
        return nil;
    }
}

- (UIView*)tableView:(UITableView *)tableView defaultViewForHeaderInSection:(NSInteger)section {
    CGRect frameHeader = CGRectMake(0, 0, SCREEN_WIDTH, 30);
    UIView *headerView = [[UIView alloc] initWithFrame:frameHeader];
    headerView.backgroundColor = Color(242, 242, 242);
    
    CGRect frameLabel = CGRectMake(13, 8, 200, 20);
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:frameLabel];
    labelTitle.textColor = Color(116, 117, 132);
    labelTitle.font = [UIFont fontWithName:@"Seravek" size:12];
    [headerView addSubview:labelTitle];
    labelTitle.text = @"DIRECT";
    
    if (_shareFriends.count) {
        CGFloat width = ([Global deviceType] == DeviceTypePhone6) ? 60 : 54;
        CGRect frameClear = CGRectMake(SCREEN_WIDTH - width, 8, width, 20);
        UIButton *buttonClear = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonClear.frame = frameClear;
        [buttonClear setTitleColor:Color(116, 117, 132) forState:UIControlStateNormal];
        [buttonClear setTitleColor:Color(97, 97, 110) forState:UIControlStateHighlighted];
        buttonClear.titleLabel.font = [UIFont fontWithName:@"Seravek" size:12];
        [buttonClear setTitle:@"Clear" forState:UIControlStateNormal];
        [buttonClear addTarget:self action:@selector(handleBtnClearTouch:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:buttonClear];
        _buttonClear = buttonClear;
        if (_shouldShowClear) {
            _buttonClear.transform = CGAffineTransformMakeScale(0, 0);
            [self performSelector:@selector(showClearButtonAnimation) withObject:nil afterDelay:0.2f];
        }
    }
    else {
        _buttonClear = nil;
    }
    
    return headerView;
}

- (UIView*)tableView:(UITableView *)tableView iPhone6PlusViewForHeaderInSection:(NSInteger)section {
    CGRect frameHeader = CGRectMake(0, 0, SCREEN_WIDTH, 34);
    UIView *headerView = [[UIView alloc] initWithFrame:frameHeader];
    headerView.backgroundColor = Color(242, 242, 242);
    
    CGRect frameLabel = CGRectMake(13, 11, 200, 20);
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:frameLabel];
    labelTitle.textColor = Color(116, 117, 132);
    labelTitle.font = [UIFont fontWithName:@"Seravek" size:13];
    [headerView addSubview:labelTitle];
    labelTitle.text = @"DIRECT";
    
    if (_shareFriends.count) {
        CGRect frameClear = CGRectMake(SCREEN_WIDTH - 68, 11, 68, 20);
        UIButton *buttonClear = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonClear.frame = frameClear;
        [buttonClear setTitleColor:Color(116, 117, 132) forState:UIControlStateNormal];
        [buttonClear setTitleColor:Color(97, 97, 110) forState:UIControlStateHighlighted];
        buttonClear.titleLabel.font = [UIFont fontWithName:@"Seravek" size:13];
        [buttonClear setTitle:@"Clear" forState:UIControlStateNormal];
        [buttonClear addTarget:self action:@selector(handleBtnClearTouch:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:buttonClear];
        _buttonClear = buttonClear;
        if (_shouldShowClear) {
            _buttonClear.transform = CGAffineTransformMakeScale(0, 0);
            [self performSelector:@selector(showClearButtonAnimation) withObject:nil afterDelay:0.2f];
        }
    }
    else {
        _buttonClear = nil;
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ShareFriendCell heightForCell];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:_tableViewFriends]) {
        if (section == 0) {
            return 1;
        }
        else {
            return [_arrFriends count];
        }
    }
    else if ([tableView isEqual:_tableViewSearch]) {
        return [_filterFrineds count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_tableViewFriends]) {
        if (indexPath.section == 0) {
            return [self tableView:tableView allFriendsCellForRowAtIndex:indexPath.row];
        }
        else {
            return [self tableView:tableView friendCellForRowAtIndex:indexPath.row];
        }
    }
    else if ([tableView isEqual:_tableViewSearch]) {
        return [self tableView:tableView searchCellForRowAtIndex:indexPath.row];
    }
    return nil;
}

- (UITableViewCell*)tableView:(UITableView *)tableView allFriendsCellForRowAtIndex:(NSInteger)index {
    ShareFriendCell * cell = (ShareFriendCell *)[tableView dequeueReusableCellWithIdentifier:[ShareFriendCell reuseIdentifier]];
    if (cell == nil) {
        cell = [[ShareFriendCell alloc] init];
    }
    
    [cell configureAllFriendsCell:_isAllFriends];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (UITableViewCell*)tableView:(UITableView *)tableView friendCellForRowAtIndex:(NSInteger)index {
    ShareFriendCell * cell = (ShareFriendCell *)[tableView dequeueReusableCellWithIdentifier:[ShareFriendCell reuseIdentifier]];
    if (cell == nil) {
        cell = [[ShareFriendCell alloc] init];
    }
    
    NSDictionary *friendDic = [_arrFriends objectAtIndex:index];
    NSString *friendId = [[[friendDic objectForKey:@"OCUser1_friendid"] objectForKey:@"Id"] stringValue];
    BOOL selected = [_shareFriends containsObject:friendId];
    [cell configureFriendCellWithDictionary:friendDic
                             selectedStatus:selected];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (UITableViewCell*)tableView:(UITableView *)tableView searchCellForRowAtIndex:(NSInteger)index {
    ShareFriendCell * cell = (ShareFriendCell *)[tableView dequeueReusableCellWithIdentifier:[ShareFriendCell reuseIdentifier]];
    if (cell == nil) {
        cell = [[ShareFriendCell alloc] init];
    }
    
    NSDictionary *friendDic = [_filterFrineds objectAtIndex:index];
    NSString *friendId = [[[friendDic objectForKey:@"OCUser1_friendid"] objectForKey:@"Id"] stringValue];
    BOOL selected = _isAllFriends || [_shareFriends containsObject:friendId];
    [cell configureFriendCellWithDictionary:friendDic
                             selectedStatus:selected];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_tableViewFriends]) {
        if (indexPath.section == 0) {
            [self handleAllFriendsCellSelected:indexPath.row];
        }
        else {
            [self handleFriendCellSelected:indexPath.row];
        }
    }
    else if ([tableView isEqual:_tableViewSearch]) {
        [self handleSearchCellSelected:indexPath.row];
    }
}

- (void)handleAllFriendsCellSelected:(NSInteger)index {
    _shouldShowClear = NO;
    
    _isAllFriends = !_isAllFriends;
    [_shareFriends removeAllObjects];
    
    [self.tableViewFriends reloadData];
    [self reloadSendButtonStatus];
}

- (void)handleFriendCellSelected:(NSInteger)index {
    _isAllFriends = NO;
    
    _shouldShowClear = NO;
    NSDictionary *friendDic = [_arrFriends objectAtIndex:index];
    NSString *friendId = [[[friendDic objectForKey:@"OCUser1_friendid"] objectForKey:@"Id"] stringValue];
    if ([_shareFriends containsObject:friendId]) {
        [_shareFriends removeObject:friendId];
    }
    else {
        if (!_shareFriends.count) {
            _shouldShowClear = YES;
        }
        [_shareFriends addObject:friendId];
    }
    
    [self.tableViewFriends reloadData];
    [self reloadSendButtonStatus];
}

- (void)handleSearchCellSelected:(NSInteger)index {
    if (_isAllFriends) {
        _isAllFriends = NO;
        for (NSDictionary *friendDic in _arrFriends) {
            NSString *friendId = [[[friendDic objectForKey:@"OCUser1_friendid"] objectForKey:@"Id"] stringValue];
            if (![_shareFriends containsObject:friendId]) {
                [_shareFriends addObject:friendId];
            }
        }
    }
    
    NSDictionary *friendDic = [_filterFrineds objectAtIndex:index];
    NSString *friendId = [[[friendDic objectForKey:@"OCUser1_friendid"] objectForKey:@"Id"] stringValue];
    
    if ([_shareFriends containsObject:friendId]) {
        [_shareFriends removeObject:friendId];
    }
    else {
        [_shareFriends addObject:friendId];
    }
    
    [self.tableViewSearch reloadData];
}

- (void)handleBtnClearTouch:(id)sender {
    [_shareFriends removeAllObjects];
    _isAllFriends = NO;
    [self hideSendButton];
    [self.tableViewFriends reloadData];
}

#pragma mark - search bar delegate
- (void)searchBarDidStart {
    if (_searchKey == nil) {
        _searchKey= @"";
        [self filterDataSource];
    }
}

- (void)searchBarDidChanged:(NSString *)searchText {
    _searchKey = [searchText lowercaseString];
    [self filterDataSource];
}

- (void)searchBarDidClear {
    _searchKey = @"";
    [self filterDataSource];
}

- (void)searchBarDidCancel {
    _searchKey = nil;
    [self hideSearchBar];
    [self reloadSendButtonStatus];
    [self.tableViewFriends reloadData];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([_searchBar isSearchBarFirstResponder]) {
        [_searchBar resignFriendSearchBar];
    }
}

#pragma mark - azure storage service delegate
- (void)storageUploading:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    CGFloat progress = (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite;
    if (_dataSourceType == 2 || (_dataSourceType == 3 && _flipframeLibrary.isMovie)) {
        if (_stepSharing == 2) {
            progress = 0.1f + progress * 0.2;
        }
        else if (_stepSharing == 3) {
            progress = 0.3f + progress * 0.6;
        }
    }
    else {
        if (_stepSharing == 3) {
            progress = 0.2f + progress * 0.2;
        }
        else if (_stepSharing == 4) {
            progress = 0.4f + progress * 0.5;
        }
    }
    [self.progressSend setProgress:progress animated:YES];
}

#pragma mark - status bar hidden
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

@end
