//
//  CameraDeleteFramesViewController.m
//  Twyst
//
//  Created by Niklas Ahola on 8/8/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"
#import "CameraDeleteFramesViewController.h"

#pragma mark - CameraDeleteFrameCell
@interface CameraDeleteFrameCell : UICollectionViewCell

@property (nonatomic, retain) UIImageView *viewFrame;
@property (nonatomic, retain) UIImageView *viewMask;

- (void) reloadImage:(NSString *)thumbPath;
- (void) setStatusSelected:(BOOL)selected;

@end

@implementation CameraDeleteFrameCell

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGRect frameView = CGRectMake(0, 0, frame.size.width, frame.size.height);
        self.viewFrame = [[UIImageView alloc] initWithFrame:frameView];
        self.viewFrame.backgroundColor = [UIColor blackColor];
        [self.contentView addSubview:self.viewFrame];
        
        self.viewMask = [[UIImageView alloc] initWithFrame:frameView];
        self.viewMask.image = [UIImage imageNamedForDevice:@"ic-camera-delete-select"];
        [self.contentView addSubview:self.viewMask];
        
        [self.contentView setClipsToBounds:YES];
    }
    return self;
}

- (void) reloadImage:(NSString *)thumbPath {
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            NSData * fileData = [NSData dataWithContentsOfFile:thumbPath];
            self.viewFrame.image = [UIImage imageWithData:fileData];
        }
    });
}

- (void) setStatusSelected:(BOOL)selected {
    self.viewMask.hidden = !selected;
}

@end

#pragma mark - CameraDeleteFramesViewController
@interface CameraDeleteFramesViewController () <UICollectionViewDataSource, UICollectionViewDelegate> {
    NSString *_cellIdentifier;
    PhotoRegularService *_inputService;
    NSMutableArray *_selectedIndexes;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;

@end

@implementation CameraDeleteFramesViewController

- (id) initWithInputService:(PhotoRegularService *)inputService {
    self = [self init];
    if (self) {
        // Custom initialization
        _cellIdentifier = @"DeleteFramesCollectionViewCell";
        _inputService = inputService;
        
        NSInteger totalImages = [inputService totalImages];
        _selectedIndexes = [[NSMutableArray alloc] initWithCapacity:totalImages];
        for (NSInteger i = 0; i < totalImages; i++) {
            [_selectedIndexes addObject:[NSNumber numberWithBool:NO]];
        }
    }
    return self;
}

- (id) init {
    NSString *nibName = [FlipframeUtils nibNameForDevice:@"CameraDeleteFramesViewController"];
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
        
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
    [self.collectionView registerClass:[CameraDeleteFrameCell class] forCellWithReuseIdentifier:_cellIdentifier];
}

#pragma mark - handle button methods
- (IBAction)handleBtnCloseTouch:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)handleBtnDeleteTouch:(id)sender {
    [_inputService deleteFrames:_selectedIndexes];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - collection view delegate
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_inputService totalImages];
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CameraDeleteFrameCell * cell = (CameraDeleteFrameCell *)[collectionView dequeueReusableCellWithReuseIdentifier:_cellIdentifier forIndexPath:indexPath];
    
    NSString * thumbPath = [_inputService.arrThumbPaths objectAtIndex:indexPath.row];
    [cell reloadImage:thumbPath];
    
    BOOL selectedStatus = [[_selectedIndexes objectAtIndex:indexPath.row] boolValue];
    [cell setStatusSelected:selectedStatus];
    
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    BOOL selectedStatus = [[_selectedIndexes objectAtIndex:indexPath.row] boolValue];
    selectedStatus = !selectedStatus;
    [_selectedIndexes replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:selectedStatus]];
    
    CameraDeleteFrameCell * cell = (CameraDeleteFrameCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell setStatusSelected:selectedStatus];
    
    [self reloadDeleteButtonStatus];
}

#pragma mark - reload delete button status
- (void) reloadDeleteButtonStatus {
    for (NSNumber * selectedStatus in _selectedIndexes) {
        if ([selectedStatus boolValue] == YES) {
            [self.btnDelete setEnabled:YES];
            return;
        }
    }
    [self.btnDelete setEnabled:NO];
}

#pragma mark - status bar hidden
- (BOOL)prefersStatusBarHidden {
    return NO;
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
