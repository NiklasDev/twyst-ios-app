//
//  EditVideoCoverView.m
//  Twyst
//
//  Created by Niklas Ahola on 5/7/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "EditVideoCoverView.h"

#pragma mark - Edit View Cover Cell

@interface EditViewCoverCell:UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageCover;

@end

@implementation EditViewCoverCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGRect frameCover = CGRectMake(0, 0, frame.size.width, frame.size.width);
        self.imageCover = [[UIImageView alloc] initWithFrame:frameCover];
        self.imageCover.backgroundColor = [UIColor blackColor];
        self.imageCover.contentMode = UIViewContentModeScaleAspectFill;
        self.imageCover.clipsToBounds = YES;
        [self.contentView addSubview:self.imageCover];
    }
    return self;
}

@end

#pragma mark - Edit Video Cover View

@interface EditVideoCoverView() <UICollectionViewDataSource, UICollectionViewDelegate> {
    FlipframeVideoModel *_flipframeModel;
    AVAssetImageGenerator *_imageGenerator;
    
    CGFloat _cellWidth;
    CGFloat _cellCount;
    CGFloat _coverWidth;
    CGRect _frameCollectionView;
    NSTimeInterval _timeStamp;
    
    BOOL _isOnCover;
    NSTimer *_timer;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIImageView *imageCover;


@end

@implementation EditVideoCoverView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _flipframeModel = [Global getCurrentFlipframeVideoModel];
        
        AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:_flipframeModel.videoURL options:nil];
        _imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        _imageGenerator.appliesPreferredTrackTransform=TRUE;
        _imageGenerator.maximumSize = CGSizeMake(250, 250);
        _imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
        _imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
        
        [self initMembers];
        [self initView];
    }
    return self;
}

- (void)initMembers {
    switch ([Global deviceType]) {
        case DeviceTypePhone6:
            _cellWidth = 49;
            _cellCount = 7;
            _coverWidth = 65;
            _frameCollectionView = CGRectMake((SCREEN_WIDTH - _cellWidth * _cellCount) / 2, 39, _cellWidth * _cellCount, _cellWidth);
            break;
        case DeviceTypePhone6Plus:
            _cellWidth = 54;
            _cellCount = 7;
            _coverWidth = 72;
            _frameCollectionView = CGRectMake((SCREEN_WIDTH - _cellWidth * _cellCount) / 2, 43, _cellWidth * _cellCount, _cellWidth);
            break;
        default:
            _cellWidth = 49;
            _cellCount = 6;
            _coverWidth = 60;
            _frameCollectionView = CGRectMake((SCREEN_WIDTH - _cellWidth * _cellCount) / 2, 28, _cellWidth * _cellCount, _cellWidth);
            break;
    }
}

- (void)initView {
    self.backgroundColor = [UIColor clearColor];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(_cellWidth, _cellWidth);
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:_frameCollectionView collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.clipsToBounds = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.userInteractionEnabled = NO;
    [self addSubview:self.collectionView];
    [self.collectionView registerClass:[EditViewCoverCell class] forCellWithReuseIdentifier:@"EditViewCoverCell"];
    
    CGFloat imageCoverY = _frameCollectionView.origin.y + (_frameCollectionView.size.height - _coverWidth) / 2;
    self.imageCover = [[UIImageView alloc] initWithFrame:CGRectMake(_frameCollectionView.origin.x, imageCoverY, _coverWidth, _coverWidth)];
    self.imageCover.layer.borderColor = Color(0, 185, 172).CGColor;
    self.imageCover.layer.borderWidth = 2.0f;
    self.imageCover.layer.cornerRadius = 2.0f;
    self.imageCover.layer.masksToBounds = YES;
    self.imageCover.contentMode = UIViewContentModeScaleAspectFill;
    self.imageCover.clipsToBounds = YES;
    [self addSubview:self.imageCover];
}

- (void)generateImage:(CGFloat)seconds completion:(void(^)(UIImage*))completion {
    CMTime thumbTime = CMTimeMakeWithSeconds(seconds, 600);
    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        if (result != AVAssetImageGeneratorSucceeded) {
            NSLog(@"couldn't generate thumbnail, error:%@", error);
        }
        UIImage *imageThumb=[UIImage imageWithCGImage:im];
        completion(imageThumb);
    };
    [_imageGenerator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
}

#pragma mark - public methods
- (void)startNewSession {
    if (_flipframeModel.coverFrame < _flipframeModel.playStartTime || _flipframeModel.coverFrame > _flipframeModel.playEndTime) {
        [self updateCoverFrame:_flipframeModel.playStartTime];
    }
    else {
        [self updateCoverFrame:_flipframeModel.coverFrame];
    }
    
    [self updateCoverImage];
    self.imageCover.center = [self getPointFromMoment:_flipframeModel.coverFrame];
    
    _timeStamp = (_flipframeModel.playEndTime - _flipframeModel.playStartTime) / (_cellCount - 1);
    [self.collectionView reloadData];
}

#pragma mark - internal actions
- (void)updateCoverFrame:(CGFloat)moment {
    _flipframeModel.coverFrame = moment;
    if ([self.delegate respondsToSelector:@selector(coverFrameDidChange)]) {
        [self.delegate coverFrameDidChange];
    }
}

- (void)updateCoverImage {
    [self generateImage:_flipframeModel.coverFrame completion:^(UIImage *imageThumb) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageCover.image = imageThumb;
        });
    }];
}

- (CGPoint)getPointFromMoment:(CGFloat)moment {
    CGFloat delta = moment - _flipframeModel.playStartTime;
    CGFloat deltaX = (_frameCollectionView.size.width - _coverWidth) * delta / (_flipframeModel.playEndTime - _flipframeModel.playStartTime);
    CGPoint center = CGPointMake(_frameCollectionView.origin.x + _coverWidth / 2 + deltaX, self.imageCover.center.y);
    return center;
}

- (CGFloat)getMomentFromPoint:(CGPoint)point {
    CGFloat deltaX = point.x - _frameCollectionView.origin.x - _coverWidth / 2;
    CGFloat delta = (_flipframeModel.playEndTime - _flipframeModel.playStartTime) * deltaX / (_frameCollectionView.size.width - _coverWidth);
    return _flipframeModel.playStartTime + delta;
}

#pragma mark - touch methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
//    if (CGRectContainsPoint(self.imageCover.frame, p)) {
        _isOnCover = YES;
        [self startTimer];
    [self moveImageCover:p];
//    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_isOnCover) {
        UITouch *touch = [touches anyObject];
        CGPoint p = [touch locationInView:self];
        [self moveImageCover:p];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_isOnCover) {
        _isOnCover = NO;
        [self onTimer:nil];
        [self stopTimer];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_isOnCover) {
        _isOnCover = NO;
        [self onTimer:nil];
        [self stopTimer];
    }
}

- (void)moveImageCover:(CGPoint)pt {
    if (pt.x > _frameCollectionView.origin.x + _frameCollectionView.size.width - _coverWidth / 2) {
        pt.x = _frameCollectionView.origin.x + _frameCollectionView.size.width - _coverWidth / 2;
    }
    else if (pt.x < _frameCollectionView.origin.x + _coverWidth / 2) {
        pt.x = _frameCollectionView.origin.x + _coverWidth / 2;
    }
    pt.y = self.imageCover.center.y;
    self.imageCover.center = pt;
}

#pragma mark - timer methods
- (void)startTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                              target:self
                                            selector:@selector(onTimer:)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)stopTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)onTimer:(NSTimer*)sender {
    CGPoint center = self.imageCover.center;
    [self updateCoverFrame:[self getMomentFromPoint:center]];
    [self updateCoverImage];
}

#pragma mark - collection view delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _cellCount;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EditViewCoverCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EditViewCoverCell" forIndexPath:indexPath];
    cell.imageCover.image = nil;
    CGFloat seconds = _timeStamp * indexPath.row + _flipframeModel.playStartTime;
    [self generateImage:seconds completion:^(UIImage *imageThumb) {
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.imageCover.image = imageThumb;
        });
    }];
    return cell;
}

@end
