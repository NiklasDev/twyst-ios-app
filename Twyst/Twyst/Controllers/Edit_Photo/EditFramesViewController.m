//
//  EditDeleteFramesViewController.m
//  Twyst
//
//  Created by Niklas Ahola on 8/19/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"
#import "WrongMessageView.h"
#import "EditFramesViewController.h"

#pragma mark - EditFrameCell
@interface EditFrameCell : UICollectionViewCell {
    FlipframePhotoModel *_flipframeModel;
}

@property (nonatomic, retain) UIImageView * viewFrame;
@property (nonatomic, retain) UIImageView * viewSaved;
@property (nonatomic, retain) UIImageView * viewSelected;

- (void) setFrameModel:(FlipframePhotoModel *)frameModel;
- (void) reloadImage:(NSInteger)index selectedStatus:(BOOL)status;
- (void) setStatusSelected:(BOOL)selected;

@end

@implementation EditFrameCell

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGRect frameView = CGRectMake(0, 0, frame.size.width, frame.size.height);
        self.viewFrame = [[UIImageView alloc] initWithFrame:frameView];
        self.viewFrame.backgroundColor = [UIColor blackColor];
        [self.contentView addSubview:self.viewFrame];
        
        self.viewSaved = [[UIImageView alloc] initWithFrame:frameView];
        self.viewSaved.image = [UIImage imageNamedForDevice:@"ic-edit-photo-saved-frame"];
        [self.contentView addSubview:self.viewSaved];
        
        self.viewSelected = [[UIImageView alloc] initWithFrame:frameView];
        self.viewSelected.image = [UIImage imageNamedForDevice:@"ic-edit-photo-selected-frame"];
        [self.contentView addSubview:self.viewSelected];
        [self.contentView setClipsToBounds:YES];
        self.backgroundColor = [UIColor redColor];
    }
    return self;
}

- (void) setFrameModel:(FlipframePhotoModel *)frameModel {
    _flipframeModel = frameModel;
}

- (void) reloadImage:(NSInteger)index selectedStatus:(BOOL)status {
    self.viewFrame.image = nil;
    [self performSelector:@selector(loadImage:) withObject:[NSNumber numberWithInteger:index]];
    self.viewSelected.hidden = !status;
    self.viewSaved.hidden = [_flipframeModel canSaveFrameAtIndex:index];
}

- (void) loadImage:(NSNumber *)index{
    self.viewFrame.image = [_flipframeModel serviceGetThumbImageAtIndex:[index integerValue]];
}

- (void) setStatusSelected:(BOOL)selected {
    self.viewSelected.hidden = !selected;
}

@end

#pragma mark - EditDeleteFramesViewController
@interface EditFramesViewController () <UICollectionViewDataSource, UICollectionViewDelegate> {
    BOOL _isSelectEnable;
    NSString *_cellIdentifier;
    FlipframePhotoModel *_flipframeModel;
    NSMutableArray *_selectedIndexes;
    EditPhotoViewController * _parentVC;
    
    //Single Frame View
    CGRect _framePreviewStart;
    NSInteger _currentIndex;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *btnSelect;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UIButton *btnTrash;

@property (weak, nonatomic) IBOutlet UIView *singleFrameContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnSignleSave;
@property (weak, nonatomic) IBOutlet UIButton *btnSignleTrash;
@property (weak, nonatomic) IBOutlet UIImageView *imagePreview;

@end

@implementation EditFramesViewController

- (id) initWithInputService:(FlipframePhotoModel *)flipframeModel parent:(EditPhotoViewController *)parent {
    NSString *nibName = [FlipframeUtils nibNameForDevice:@"EditFramesViewController"];
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
        _isSelectEnable = NO;
        _cellIdentifier = @"EditFramesCollectionViewCell";
        _flipframeModel = flipframeModel;
        _parentVC = parent;
        
        [self deselectAll];
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
    
    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView registerClass:[EditFrameCell class] forCellWithReuseIdentifier:_cellIdentifier];
}

- (BOOL) isAllSelected {
    for (NSNumber *index in _selectedIndexes) {
        if ([index boolValue] == NO) {
            return NO;
        }
    }
    return YES;
}

- (void)deselectAll {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_selectedIndexes) {
            [_selectedIndexes removeAllObjects];
        }
        else {
            _selectedIndexes = [NSMutableArray new];
        }
        
        NSInteger totalFrames = [_flipframeModel totalFrames];
        for (NSInteger i = 0; i < totalFrames; i++) {
            [_selectedIndexes addObject:[NSNumber numberWithBool:NO]];
        }
        
        [self.collectionView reloadData];
    });
}

#pragma mark - show / hide preview
- (void) showPreview:(NSIndexPath*)indexPath {
    _currentIndex = indexPath.row;
    
    [self actionLoadFrame];
    
    _framePreviewStart = [self selectedCellFrame:indexPath];
    
    self.imagePreview.hidden = NO;
    self.imagePreview.frame = _framePreviewStart;
    
    [UIView animateWithDuration:0.25f
                     animations:^{
                         self.singleFrameContainer.alpha = 1.0f;
                         self.imagePreview.frame = self.view.bounds;
                     }
                     completion:^(BOOL finished) {
                         [self setNeedsStatusBarAppearanceUpdate];
                     }];
}

- (void) hidePreview {
    [self.collectionView reloadData];
    
    self.imagePreview.frame = self.view.bounds;
    
    [UIView animateWithDuration:0.25f
                     animations:^{
                         self.singleFrameContainer.alpha = 0.0f;
                         self.imagePreview.frame = _framePreviewStart;
                     }
                     completion:^(BOOL finished) {
                         self.imagePreview.hidden = YES;
                         [self setNeedsStatusBarAppearanceUpdate];
                     }];
}

- (CGRect)selectedCellFrame:(NSIndexPath*)indexPath {
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    CGRect frame = [self.view convertRect:cell.frame fromView:self.collectionView];
    return frame;
}

- (void)actionLoadNextFrame {
    NSInteger totalFrames = [_flipframeModel totalFrames];
    if (totalFrames > 1) {
        _currentIndex ++;
        if (_currentIndex == totalFrames) {
            _currentIndex = 0;
        }
        [self actionLoadFrame];
    }
}

- (void)actionLoadFrame {
    self.imagePreview.image = [_flipframeModel serviceGetFullImageAtIndex:_currentIndex];
    
    if ([Global getConfig].isSaveVideo) {
        self.btnSignleSave.selected = ![_flipframeModel canSaveFrameAtIndex:_currentIndex];
        self.btnSignleSave.enabled = YES;
    } else {
        self.btnSignleSave.selected = NO;
        self.btnSignleSave.enabled = NO;
    }
    
    NSInteger totalFrames = [_flipframeModel totalFrames];
    self.btnSignleTrash.enabled = (totalFrames > 1);
}

#pragma mark - handle button methods
- (IBAction)handleBtnCloseTouch:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)handleBtnSelectTouch:(id)sender {
    _isSelectEnable = !_isSelectEnable;
    NSString *buttonTitle = _isSelectEnable ? @"Cancel" : @"Select";
    [self.btnSelect setTitle:buttonTitle forState:UIControlStateNormal];
    if (_isSelectEnable == NO) {
        [self deselectAll];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadActionButtonStatus];
    });
}

- (IBAction)handleBtnSaveTouch:(id)sender {
    [_flipframeModel saveFrames:_selectedIndexes];
    [WrongMessageView showMessage:WrongMessageTypeSuccessSaveLibrary inView:self.view];
    [self deselectAll];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadActionButtonStatus];
    });
}

- (IBAction)handleBtnTrashTouch:(id)sender {
    if ([self isAllSelected]) {
        [WrongMessageView showAlert:WrongMessageTypeNeedOnePhoto target:nil];
    }
    else {
        [_flipframeModel deleteFrames:_selectedIndexes];
        [_parentVC actionFrameDeleted];
        [WrongMessageView showMessage:WrongMessageTypeDeleteFrames inView:self.view];
        [self deselectAll];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadActionButtonStatus];
        });
    }
}

- (IBAction)handleBtnSingleBackTouch:(id)sender {
    [WrongMessageView hide];
    [self deselectAll];
    [self hidePreview];
}

- (IBAction)handleBtnSignleSaveTouch:(id)sender {
    [_flipframeModel saveSingleFrameAtIndex:_currentIndex];
    [_flipframeModel notifySavedImage:_currentIndex];
    [WrongMessageView showMessage:WrongMessageTypeSuccessSaveLibrary inView:self.view arrayOffsetY:@[@0, @0, @0]];
    [self actionLoadFrame];
}

- (IBAction)handleBtnSingleTrashTouch:(id)sender {
    if ([_flipframeModel totalFrames] == 1) {
        [WrongMessageView showAlert:WrongMessageTypeNeedOnePhoto target:nil];
    }
    else {
        [_flipframeModel removeCurrentImage:_currentIndex];
        if (_currentIndex >= [_flipframeModel totalFrames]) {
            _currentIndex = 0;
        }
        [self actionLoadFrame];
    }
}

- (IBAction)handleTapPreview:(id)sender {
    [self actionLoadNextFrame];
}

#pragma mark - collection view delegate
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_flipframeModel totalFrames];
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EditFrameCell * cell = (EditFrameCell *)[collectionView dequeueReusableCellWithReuseIdentifier:_cellIdentifier forIndexPath:indexPath];
    [cell setFrameModel:_flipframeModel];
    BOOL selectedStatus = [[_selectedIndexes objectAtIndex:indexPath.row] boolValue];
    [cell reloadImage:indexPath.row selectedStatus:selectedStatus];
    
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_isSelectEnable) {
        BOOL selectedStatus = [[_selectedIndexes objectAtIndex:indexPath.row] boolValue];
        selectedStatus = !selectedStatus;
        [_selectedIndexes replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:selectedStatus]];
        
        EditFrameCell * cell = (EditFrameCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [cell setStatusSelected:selectedStatus];
        
        [self reloadActionButtonStatus];
    }
    else {
        [self showPreview:indexPath];
    }
}

#pragma mark - reload delete button status
- (void) reloadActionButtonStatus {
    if (!_isSelectEnable) {
        self.btnSave.enabled = NO;
        self.btnTrash.enabled = NO;
    }
    else {
        self.btnSave.enabled = NO;
        self.btnTrash.enabled = NO;
        
        NSInteger totalFrames = [_flipframeModel totalFrames];
        BOOL isSaveAllowed = [Global getConfig].isSaveVideo;
        for (int i = 0; i < totalFrames; i++) {
            NSNumber * selectedStatus = _selectedIndexes[i];
            if ([selectedStatus boolValue] == YES) {
                BOOL canSaveFrame = [_flipframeModel canSaveFrameAtIndex:i];

                if (isSaveAllowed && canSaveFrame) {
                    [self.btnSave setEnabled:YES];
                }

                [self.btnTrash setEnabled:(totalFrames > 1)];
            }
        }
    }
}

#pragma mark - status bar hidden
- (BOOL)prefersStatusBarHidden {
    if (self.imagePreview.hidden) {
        return NO;
    }
    else {
        return YES;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
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
