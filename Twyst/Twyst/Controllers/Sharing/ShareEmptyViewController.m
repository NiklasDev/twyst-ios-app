//
//  ShareEmptyViewController.m
//  Twyst
//
//  Created by Niklas Ahola on 2/27/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"

#import "AppDelegate.h"

#import "LibraryTwystService.h"

#import "WrongMessageView.h"

#import "ShareEmptyViewController.h"
#import "FindPeopleViewController.h"

@interface ShareEmptyViewController () {
    NSInteger _dataSourceType;
    FlipframePhotoModel *_flipframePhotoModel;
    FlipframeVideoModel *_flipframeVideoModel;
}

@property (nonatomic, weak) IBOutlet UIImageView *imageBg;

@end

@implementation ShareEmptyViewController

- (id)init {
    NSString *nibName = [FlipframeUtils nibNameForDevice:@"ShareEmptyViewController"];
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (id)initWithFlipframePhotoModel:(FlipframePhotoModel *)flipframePhotoModel {
    self = [self init];
    if (self) {
        _flipframePhotoModel = flipframePhotoModel;
        _dataSourceType = 1;
    }
    return [self init];
}

- (id)initWithFlipframeVideoModel:(FlipframeVideoModel *)flipframeVideoModel {
    self = [self init];
    if (self) {
        _flipframeVideoModel = flipframeVideoModel;
        _dataSourceType = 2;
    }
    return [self init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.imageBg.image = [UIImage imageNamedForAllDevices:@"ic-share-empty"];
}

#pragma mark - internal methods
- (void)actionSaveTwystToLibrary {
    id retVal = nil;
    if (_dataSourceType == 1) {
        retVal = [[LibraryTwystService sharedInstance] confirmLibraryTwystWithPhotoModel:_flipframePhotoModel];
    }
    else {
        retVal = [[LibraryTwystService sharedInstance] confirmLibraryTwystWithVideoModel:_flipframeVideoModel];
    }
    
    if (retVal) {
        [WrongMessageView showMessage:WrongMessageTypeTwystSaveLibrary inView:[[AppDelegate sharedInstance] window]];
    }
    else {
        [WrongMessageView showAlert:WrongMessageTypeSomethingWentWrong target:nil];
    }
}

- (void) actionCloseScreen {
    AppDelegate *delegate = [AppDelegate sharedInstance];
    [delegate backToHomeScreen];
}

#pragma mark - handle button methods
- (IBAction)handleBtnSaveTouch:(id)sender {
    [self actionSaveTwystToLibrary];
    [self actionCloseScreen];
}

- (IBAction)handleBtnInviteTouch:(id)sender {
    FindPeopleViewController *viewController = [[FindPeopleViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
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
