//
//  LibraryPreviewController.m
//  Twyst
//
//  Created by Niklas Ahola on 8/27/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "FriendManageService.h"
#import "LibraryFlipframeServices.h"

#import "TwystPreviewView.h"

#import "ShareViewController.h"
#import "ShareEmptyViewController.h"
#import "LibraryPreviewController.h"

@interface LibraryPreviewController() <UIActionSheetDelegate> {
    TwystPreviewView *_twystPreview;
}

@property (weak, nonatomic) IBOutlet UIView *previewContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnPass;

@end

@implementation LibraryPreviewController

- (id)init
{
    NSString *nibName = [FlipframeUtils nibNameForDevice:@"LibraryPreviewController"];
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_twystPreview play];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_twystPreview pause];
}

#pragma mark - internal actions
- (void)initView {
    // disable pass if no friends or saved photo or no caption
    if ([[FriendManageService sharedInstance] getFriendsCount] == 0
        || !IsNSStringValid(self.flipframeLibrary.caption)) {
        self.btnPass.enabled = NO;
    }
    
    //add stringg preview
    [self addTwystPreviewView];
}

- (void)addTwystPreviewView {
    _twystPreview = [[TwystPreviewView alloc] initWithFrame:self.view.bounds];
    [_twystPreview setDataSourceWithFlipframeLibrary:self.flipframeLibrary];
    [self.previewContainer addSubview:_twystPreview];
    [_twystPreview setSelectedImageIndex:0];
}

- (void)actionClosePreview {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionShare {
    UIViewController *viewController = nil;
    if ([[FriendManageService sharedInstance] getFriendsCount]) {
        viewController = [[ShareViewController alloc] initWithFlipframeLibrary:self.flipframeLibrary];
    }
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)actionDelete {
    FFlipframeSaved *flipframeSaved = self.flipframeLibrary.flipframeSaved;
    [[LibraryFlipframeServices sharedInstance] deleteFlipframeSaved:flipframeSaved];
    [self actionClosePreview];
}

#pragma mark - handle button methods
- (IBAction)handleBtnCloseTouch:(id)sender {
    [self actionClosePreview];
}

- (IBAction)handleBtnPassTouch:(id)sender {
    [self actionShare];
}

- (IBAction)handleBtnDeleteTouch:(id)sender {
    
    [_twystPreview pause];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Delete", nil];
    actionSheet.tag = SlideUpTypeDeleteTwyst;
    [actionSheet showInView:self.view];
}

#pragma mark - action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == SlideUpTypeDeleteTwyst) {
        if (buttonIndex == 0) {
            [self actionDelete];
        }
        else {
            [_twystPreview play];
        }
    }
}

#pragma mark - status bar hidden
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

@end
