//
//  TwystFramesViewController.m
//  Twyst
//
//  Created by Niklas Ahola on 3/3/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"
#import "UIImageView+WebCache.h"
#import "NSString+Extension.h"

#import "TStillframeRegular.h"

#import "UserWebService.h"
#import "FlipframeFileService.h"

#import "WrongMessageView.h"
#import "CircleProcessingView.h"

#import "TwystFramesViewController.h"
#import "FriendProfileViewController.h"

typedef enum {
    FrameSortTypeNewest = 100,
    FrameSortTypeOldest,
    FrameSortTypeMe,
    FrameSortTypeFriends,
} FrameSortType;

#pragma mark - Stringg Frame Cell

@protocol TwystFrameCellDelegate <NSObject>

- (void)twystFrameCellDidLongPress:(NSInteger)index;
- (void)twystFrameCellDidTap:(NSInteger)index;

@end

@interface TwystFrameCell : UICollectionViewCell {
    UITapGestureRecognizer *_tapGesture;
    UILongPressGestureRecognizer *_longPressGesture;
}

@property (nonatomic, strong) UIImageView *viewFrame;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) id <TwystFrameCellDelegate> delegate;

- (void)reloadImage:(NSString *)thumbPath isMovie:(BOOL)isMovie;

@end

@implementation TwystFrameCell

- (id) initWithFrame:(CGRect)frame  {
    self = [super initWithFrame:frame];
    if (self) {
        self.viewFrame = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.viewFrame.backgroundColor = [UIColor blackColor];
        self.viewFrame.contentMode = UIViewContentModeScaleAspectFill;
        self.viewFrame.clipsToBounds = YES;
        self.viewFrame.userInteractionEnabled = YES;
        [self.contentView addSubview:self.viewFrame];
        
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        [self.viewFrame addGestureRecognizer:_longPressGesture];
        
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [self.viewFrame addGestureRecognizer:_tapGesture];
    }
    return self;
}

- (void) reloadImage:(NSString *)path isMovie:(BOOL)isMovie {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *fullPath = [[FlipframeFileService sharedInstance] generateFullDocPath:path];
        if (isMovie) {
            self.viewFrame.image = [FlipframeUtils generateThumbImageFromVideo:[NSURL fileURLWithPath:fullPath] coverFrame:0.0];
        }
        else {
            @autoreleasepool {
                NSData * fileData = [NSData dataWithContentsOfFile:fullPath];
                self.viewFrame.image = [UIImage imageWithData:fileData];
            }
        }
    });
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(twystFrameCellDidLongPress:)]) {
            [self.delegate twystFrameCellDidLongPress:self.index];
        }
    }
}

- (void)handleTapGesture:(UITapGestureRecognizer*)sender {
    if ([self.delegate respondsToSelector:@selector(twystFrameCellDidTap:)]) {
        [self.delegate twystFrameCellDidTap:self.index];
    }
}

- (void)dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
    [self.viewFrame removeGestureRecognizer:_longPressGesture];
}

@end


@interface TwystFramesViewController() <TwystFrameCellDelegate, UIActionSheetDelegate, UICollectionViewDataSource, UICollectionViewDelegate> {
    
    NSString *_cellIdentifier;
    FrameSortType _sortType;
    
    NSArray *_arrayFrames;
    NSMutableArray *_dataSource;
    
    NSInteger _currentIndex;
}

@property (nonatomic, retain) TSavedTwyst *savedTwyst;
@property (nonatomic, retain) NSMutableArray *reportedReplies;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *btnNewest;
@property (weak, nonatomic) IBOutlet UIButton *btnOldest;
@property (weak, nonatomic) IBOutlet UIButton *btnMe;
@property (weak, nonatomic) IBOutlet UIButton *btnFriends;
@property (weak, nonatomic) IBOutlet UIView *noFramesContainer;

@end

@implementation TwystFramesViewController

- (id)initWithSavedStringg:(TSavedTwyst*)savedTwyst {
    NSString *nibName = [FlipframeUtils nibNameForDevice:@"TwystFramesViewController"];
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
        _cellIdentifier = @"StringgFramesCellIdentifier";
        
        _savedTwyst = savedTwyst;
        self.reportedReplies = [NSMutableArray arrayWithArray:[Global getInstance].reportedReplies];
        NSSet *setStillframes = savedTwyst.listStillframeRegular;
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
        _arrayFrames = [setStillframes sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
        _dataSource = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

#pragma mark - internal methods
- (void)initView {
    [self.collectionView registerClass:[TwystFrameCell class] forCellWithReuseIdentifier:_cellIdentifier];
    
    [self handleBtnNewestTouch:nil];
    if ([self allFramesReported]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)filterDataSource {
    NSInteger totalFrames = [_arrayFrames count];
    [_dataSource removeAllObjects];
    switch (_sortType) {
        case FrameSortTypeOldest:
            [_dataSource addObjectsFromArray:_arrayFrames];
            break;
        case FrameSortTypeNewest:
        {
            for (NSInteger i = totalFrames - 1; i >= 0; i--) {
                [_dataSource addObject:[_arrayFrames objectAtIndex:i]];
            }
        }
            break;
        case FrameSortTypeMe:
        {
            long userId = [Global getOCUser].Id;
            for (TStillframeRegular *stillframeRegular in _arrayFrames) {
                if ([stillframeRegular.userId longValue] == userId) {
                    [_dataSource addObject:stillframeRegular];
                }
            }
        }
            break;
        case FrameSortTypeFriends:
        {
            long userId = [Global getOCUser].Id;
            for (TStillframeRegular *stillframeRegular in _arrayFrames) {
                if ([stillframeRegular.userId longValue] != userId) {
                    [_dataSource addObject:stillframeRegular];
                }
            }
        }
            break;
        default:
            break;
    }
    [self actionReloadContentView];
}

- (void)actionReloadContentView {
    if (_dataSource.count) {
        self.noFramesContainer.hidden = YES;
    }
    else {
        self.noFramesContainer.hidden = NO;
    }
    [self.collectionView reloadData];
}

- (CGRect)selectedCellFrame:(NSIndexPath*)indexPath {
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    CGRect frame = [self.view convertRect:cell.frame fromView:self.collectionView];
    return frame;
}

- (BOOL)allFramesReported {
    if (![_dataSource count]) return NO;
    
    BOOL allFramesReported = YES;
    for (int i = 0; i < _dataSource.count; i++) {
        TStillframeRegular *stillframeRegular = [_dataSource objectAtIndex:i];
        NSArray *paths = [stillframeRegular.path componentsSeparatedByString:@"/"];
        NSString *replyName = [paths objectAtIndex:2];
        if (![self.reportedReplies containsObject:replyName]) {
            allFramesReported = NO;
            break;
        }
    }
    return allFramesReported;
}

- (void)actionReportFrame {
    [CircleProcessingView showInView:self.view];
    [self actionGetReplyId:^(long replyId) {
        if (replyId > 0) {
            [[UserWebService sharedInstance] reportRely:replyId completion:^(BOOL isSuccess) {
                [CircleProcessingView hide];
                if (isSuccess) {
                    [self actionHandleReportSuccess];
                }
                else {
                    [WrongMessageView showMessage:WrongMessageTypeNoInternetConnection inView:self.view arrayOffsetY:@[@0, @0, @0]];
                }
            }];
        }
        else {
            [CircleProcessingView hide];
            [WrongMessageView showAlert:WrongMessageTypeSomethingWentWrong target:nil];
        }
    }];
}

- (void)actionGetReplyId:(void(^)(long))completion {
    TStillframeRegular *stillframeRegular = [_dataSource objectAtIndex:_currentIndex];
    NSArray *paths = [stillframeRegular.path componentsSeparatedByString:@"/"];
    NSString *replyFileName = [paths objectAtIndex:2];
    long twystId = [self.savedTwyst.twystId longValue];
    [[UserWebService sharedInstance] getTwystReplies:twystId completion:^(NSArray *replies) {
        if (replies) {
            long replyId = 0;
            for (NSDictionary *reply in replies) {
                NSString *imageName = [reply objectForKey:@"ImageName"];
                NSRange range = [imageName rangeOfString:replyFileName];
                if (range.length > 0) {
                    replyId = [[reply objectForKey:@"Id"] longValue];
                    break;
                }
            }
            completion(replyId);
        }
        else {
            completion(0);
        }
    }];
}

- (void)actionHandleReportSuccess {
    TStillframeRegular *stillframeRegular = [_dataSource objectAtIndex:_currentIndex];
    NSArray *paths = [stillframeRegular.path componentsSeparatedByString:@"/"];
    NSString *replyFileName = [paths objectAtIndex:2];
    [self.reportedReplies addObject:replyFileName];
    [[Global getInstance].reportedReplies addObject:replyFileName];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTwystFrameReportNotification object:nil];
    
    if ([self allFramesReported]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.collectionView reloadData];
    }
}

- (void)actionGotoFriendProfile:(OCUser*)user {
    if (user.Id != [Global getOCUser].Id) {
        FriendProfileViewController *viewController = [[FriendProfileViewController alloc] init];
        viewController.user = user;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

#pragma mark - handle button methods
- (IBAction)handleBtnCloseTouch:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)handleBtnNewestTouch:(id)sender {
    if (_sortType != FrameSortTypeNewest) {
        _btnNewest.selected = YES;
        _btnOldest.selected = NO;
        _btnMe.selected = NO;
        _btnFriends.selected = NO;
        _sortType = FrameSortTypeNewest;
        [self filterDataSource];
    }
}

- (IBAction)handleBtnOldestTouch:(id)sender {
    if (_sortType != FrameSortTypeOldest) {
        _btnNewest.selected = NO;
        _btnOldest.selected = YES;
        _btnMe.selected = NO;
        _btnFriends.selected = NO;
        _sortType = FrameSortTypeOldest;
        [self filterDataSource];
    }
}

- (IBAction)handleBtnMeTouch:(id)sender {
    if (_sortType != FrameSortTypeMe) {
        _btnNewest.selected = NO;
        _btnOldest.selected = NO;
        _btnMe.selected = YES;
        _btnFriends.selected = NO;
        _sortType = FrameSortTypeMe;
        [self filterDataSource];
    }
}

- (IBAction)handleBtnFriendsTouch:(id)sender {
    if (_sortType != FrameSortTypeFriends) {
        _btnNewest.selected = NO;
        _btnOldest.selected = NO;
        _btnMe.selected = NO;
        _btnFriends.selected = YES;
        _sortType = FrameSortTypeFriends;
        [self filterDataSource];
    }
}

#pragma mark - collection view delegate
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_dataSource count];
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TwystFrameCell * cell = (TwystFrameCell *)[collectionView dequeueReusableCellWithReuseIdentifier:_cellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    cell.index = indexPath.row;
    
    TStillframeRegular *frame = [_dataSource objectAtIndex:indexPath.row];
    NSArray *paths = [frame.path componentsSeparatedByString:@"/"];
    NSString *replyName = [paths objectAtIndex:2];
    if ([self.reportedReplies containsObject:replyName]) {
        cell.viewFrame.image = [UIImage imageNamedForDevice:@"ic-frame-reported-small"];
    }
    else {
        [cell reloadImage:frame.path isMovie:[frame.isMovie boolValue]];
    }
    return cell;
}

#pragma mark - twyst frame cell delegate
- (void)twystFrameCellDidLongPress:(NSInteger)index {
    _currentIndex = index;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Report"
                                                    otherButtonTitles:nil];
    actionSheet.tag = SlideUpTypeReportFrame;
    [actionSheet showInView:self.view];
}

- (void)twystFrameCellDidTap:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(twystFrameDidSelect:)]) {
        TStillframeRegular *stillframe = [_dataSource objectAtIndex:index];
        NSInteger order = [_arrayFrames indexOfObject:stillframe];
        [self.delegate twystFrameDidSelect:order];
    }
    [self handleBtnCloseTouch:nil];
}

#pragma mark - action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == SlideUpTypeReportFrame) {
        if (buttonIndex == 0) {
            [self actionReportFrame];
        }
    }
}

#pragma mark - status bar hidden
- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

@end
