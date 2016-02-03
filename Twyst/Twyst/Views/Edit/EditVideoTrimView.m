//
//  EditVideoTrimView.m
//  Twyst
//
//  Created by Niklas Ahola on 4/23/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"

#import "EditVideoTrimView.h"

#pragma mark - Edit View Trim Cell

@interface EditViewTrimCell:UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageCover;
@property (nonatomic, strong) UIView *viewImageOverlay;
@property (nonatomic, strong) UIImageView *imageRuler;
@property (nonatomic, strong) UILabel *labelRuler1;
@property (nonatomic, strong) UILabel *labelRuler2;
@property (nonatomic, assign) NSInteger index;

@end

@implementation EditViewTrimCell

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGRect frameCover = CGRectMake(0, 0, frame.size.width, frame.size.width);
        self.imageCover = [[UIImageView alloc] initWithFrame:frameCover];
//        self.imageCover.backgroundColor = [UIColor blackColor];
        self.imageCover.contentMode = UIViewContentModeScaleAspectFill;
        self.imageCover.clipsToBounds = YES;
        [self.contentView addSubview:self.imageCover];
        
        self.viewImageOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
        self.viewImageOverlay.backgroundColor = ColorRGBA(0, 0, 0, 0.8);
        [self.contentView addSubview:self.viewImageOverlay];
        
        CGRect frameRuler = CGRectMake(0, frame.size.height - 15, frame.size.width, 15);
        self.imageRuler = [[UIImageView alloc] initWithFrame:frameRuler];
        [self.contentView addSubview:self.imageRuler];
        
        CGRect frameLabel = CGRectMake(0, [self labelRulerOffsetY], frame.size.width, 20);
        self.labelRuler1 = [[UILabel alloc] initWithFrame:frameLabel];
        self.labelRuler1.backgroundColor = [UIColor clearColor];
        self.labelRuler1.textColor = Color(39, 33, 58);
        self.labelRuler1.textAlignment = NSTextAlignmentCenter;
        self.labelRuler1.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
        [self.contentView addSubview:self.labelRuler1];
        
        self.labelRuler2 = [[UILabel alloc] initWithFrame:frameLabel];
        self.labelRuler2.backgroundColor = [UIColor clearColor];
        self.labelRuler2.textColor = Color(39, 33, 58);
        self.labelRuler2.textAlignment = NSTextAlignmentCenter;
        self.labelRuler2.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
        [self.contentView addSubview:self.labelRuler2];
    }
    return self;
}

- (CGFloat)labelRulerOffsetY {
    switch ([Global deviceType]) {
        case DeviceTypePhone4:
            return 67;
            break;
        case DeviceTypePhone5:
            return 75;
            break;
        case DeviceTypePhone6:
            return 81;
            break;
        case DeviceTypePhone6Plus:
            return 90;
            break;
        default:
            return 75;
            break;
    }
}

- (void)drawRuler:(NSInteger)index {
    self.index = index;
    CGFloat seconds = 1.2 * index;
    
    NSString *imageName = @"ic-edit-ruler-start";
    if (index) {
        index = index % 5;
        imageName = [NSString stringWithFormat:@"ic-edit-ruler-%ld", (long)index];
    }
    self.imageRuler.image = [UIImage imageNamedForDevice:imageName];
    
    CGFloat interval = self.bounds.size.width / 6;
    CGPoint center = self.labelRuler1.center;
    switch (index) {
        case 0:
            self.labelRuler2.hidden = NO;
            self.labelRuler1.text = [self timeStringFromSeconds:seconds];
            self.labelRuler2.text = [self timeStringFromSeconds:seconds + 1];
            self.labelRuler1.center = CGPointMake(0, center.y);
            self.labelRuler2.center = CGPointMake(interval * 5, center.y);
            break;
        case 4:
            self.labelRuler2.hidden = NO;
            self.labelRuler1.text = [self timeStringFromSeconds:seconds];
            self.labelRuler2.text = [self timeStringFromSeconds:seconds + 1];
            self.labelRuler1.center = CGPointMake(interval, center.y);
            self.labelRuler2.center = CGPointMake(interval * 6, center.y);
            break;
        case 1:
        case 2:
            self.labelRuler2.hidden = YES;
            self.labelRuler1.text = [self timeStringFromSeconds:seconds + 1];
            self.labelRuler1.center = CGPointMake(interval * (5 - index), center.y);
            break;
        case 3:
            self.labelRuler2.hidden = YES;
            self.labelRuler1.text = [self timeStringFromSeconds:seconds];
            self.labelRuler1.center = CGPointMake(interval * (5 - index), center.y);
            break;
        default:
            break;
    }
}

- (void)updateOverlay:(CGFloat)trimStart trimEnd:(CGFloat)trimEnd duration:(CGFloat)duration {
    
    CGFloat seconds = 1.2 * self.index;
    if (seconds > duration) {
        self.viewImageOverlay.hidden = YES ;
        return;
    }
    
    if (seconds < trimStart) {
        CGFloat x = self.bounds.size.width * (trimStart - seconds) / 1.2;
        CGRect frame = self.viewImageOverlay.frame;
        self.viewImageOverlay.frame = CGRectMake(0, frame.origin.y, x, frame.size.height);
        self.viewImageOverlay.hidden = NO;
        return;
    }
    
    seconds += 1.2;
    if (seconds > trimEnd) {
        CGFloat x =  MIN(self.bounds.size.width * (seconds - trimEnd) / 1.2, self.bounds.size.width);
        CGRect frame = self.viewImageOverlay.frame;
        self.viewImageOverlay.frame = CGRectMake(self.bounds.size.width - x, frame.origin.y, x, frame.size.height);
        self.viewImageOverlay.hidden = NO;
        return;
    }
    
    self.viewImageOverlay.hidden = YES;
}

- (NSString*)timeStringFromSeconds:(CGFloat)seconds {
    if (seconds < 60) {
        return [NSString stringWithFormat:@":%02.0f", seconds];
    }
    else {
        NSInteger min = (NSInteger)(seconds / 60);
        seconds -= 60.0f * min;
        return [NSString stringWithFormat:@"%ld:%02.0f", (long)min, seconds];
    }
}

@end

#pragma mark - Edit Video Trim View

typedef enum {
    TouchTypeNone = 100,
    TouchTypeLeft,
    TouchTypeRight,
} TouchType;

@interface EditVideoTrimView() <UICollectionViewDataSource, UICollectionViewDelegate> {
    FlipframeVideoModel *_flipframeModel;
    AVAssetImageGenerator *_imageGenerator;
    
    TouchType _touchType;
    CGFloat _touchX;
    
    CGFloat _trimWidth;
    CGFloat _trimOffsetX;
    CGFloat _offsetY;
    CGFloat _barWidth;
    
    NSTimer *_timer;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *leftSelector;
@property (nonatomic, strong) UIView *rightSelector;
@property (nonatomic, strong) UIView *topEdgeLine;
@property (nonatomic, strong) UIView *bottomEdgeLine;
@property (nonatomic, strong) UIImageView *imageProgressBar;

@end

@implementation EditVideoTrimView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _flipframeModel = [Global getCurrentFlipframeVideoModel];
        
        _touchType = TouchTypeNone;
        
        AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:_flipframeModel.videoURL options:nil];
        _imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        _imageGenerator.appliesPreferredTrackTransform=TRUE;
        _imageGenerator.maximumSize = CGSizeMake(250, 250);
        
        [self initMembers];
        [self initView];
    }
    return self;
}

- (void)initMembers {
    switch ([Global deviceType]) {
        case DeviceTypePhone6:
            _trimOffsetX = 20;
            _offsetY = 13;
            break;
        case DeviceTypePhone6Plus:
            _trimOffsetX = 22;
            _offsetY = 15;
            break;
        default:
            _trimOffsetX = 22.5;
            _offsetY = 8;
            break;
    }
}

- (void)initView {
    self.backgroundColor = [UIColor clearColor];
    
    _trimWidth = self.bounds.size.width - _trimOffsetX * 2;
    CGFloat cellWidth = _trimWidth / 5;
    
    CGRect frame = CGRectMake(_trimOffsetX, _offsetY, self.bounds.size.width - _trimOffsetX * 2, self.bounds.size.height - _offsetY);
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(cellWidth, frame.size.height);
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.clipsToBounds = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.alwaysBounceHorizontal = NO;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.collectionView];
    [self.collectionView registerClass:[EditViewTrimCell class] forCellWithReuseIdentifier:@"EditViewTrimCell"];
    
    //left selector
    frame = CGRectMake(0, _offsetY, _trimOffsetX + 10, cellWidth);
    self.leftSelector = [[UIView alloc] initWithFrame:frame];
    self.leftSelector.backgroundColor = [UIColor clearColor];
    [self addSubview:self.leftSelector];
    
    UIImageView *imageLeftSelector = [[UIImageView alloc] initWithImage:[UIImage imageNamedForDevice:@"ic-edit-video-trim-left-selector"]];
    imageLeftSelector.translatesAutoresizingMaskIntoConstraints = NO;
    imageLeftSelector.contentMode = UIViewContentModeScaleAspectFill;
    [self.leftSelector addSubview:imageLeftSelector];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:imageLeftSelector attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.leftSelector attribute:NSLayoutAttributeTop multiplier:1.0f constant:0];
    [self.leftSelector addConstraint: constraint];
    constraint = [NSLayoutConstraint constraintWithItem:imageLeftSelector attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.leftSelector attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0];
    [self.leftSelector addConstraint: constraint];
    constraint = [NSLayoutConstraint constraintWithItem:imageLeftSelector attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.leftSelector attribute:NSLayoutAttributeRight multiplier:1.0f constant:-10];
    [self.leftSelector addConstraint: constraint];
    
    //right selector
    CGFloat startX = _trimOffsetX + _trimWidth * (_flipframeModel.playEndTime - _flipframeModel.playStartTime) / 6 - 10;
    frame = CGRectMake(startX, _offsetY, self.bounds.size.width - startX, cellWidth);
    self.rightSelector = [[UIView alloc] initWithFrame:frame];
    self.rightSelector.backgroundColor = [UIColor clearColor];
    [self addSubview:self.rightSelector];
    
    UIImageView *imageRightSelector = [[UIImageView alloc] initWithImage:[UIImage imageNamedForDevice:@"ic-edit-video-trim-right-selector"]];
    imageRightSelector.translatesAutoresizingMaskIntoConstraints = NO;
    imageRightSelector.contentMode = UIViewContentModeScaleAspectFill;
    [self.rightSelector addSubview:imageRightSelector];
    constraint = [NSLayoutConstraint constraintWithItem:imageRightSelector attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.rightSelector attribute:NSLayoutAttributeTop multiplier:1.0f constant:0];
    [self.rightSelector addConstraint: constraint];
    constraint = [NSLayoutConstraint constraintWithItem:imageRightSelector attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.rightSelector attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0];
    [self.rightSelector addConstraint: constraint];
    constraint = [NSLayoutConstraint constraintWithItem:imageRightSelector attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.rightSelector attribute:NSLayoutAttributeLeft multiplier:1.0f constant:10];
    [self.rightSelector addConstraint: constraint];
    
    //top edge line
    frame = CGRectMake(self.leftSelector.frame.origin.x + self.leftSelector.frame.size.width - 15,
                       _offsetY -  0.5,
                       self.rightSelector.frame.origin.x - self.leftSelector.frame.origin.x - self.leftSelector.frame.size.width + 30,
                       0.5);
    self.topEdgeLine = [[UIView alloc] initWithFrame:frame];
    self.topEdgeLine.backgroundColor = Color(39, 33, 58);
    [self addSubview:self.topEdgeLine];
    
    //bottom edge line
    frame.origin.y = _offsetY + cellWidth;
    self.bottomEdgeLine = [[UIView alloc] initWithFrame:frame];
    self.bottomEdgeLine.backgroundColor = Color(39, 33, 58);
    [self addSubview:self.bottomEdgeLine];
    
    //progress bar
    UIImage *image = [UIImage imageNamedForDevice:@"ic-edit-video-trim-progress-bar"];
    _barWidth = image.size.width;
    frame = CGRectMake(_trimOffsetX, _offsetY - (image.size.height - cellWidth) / 2, image.size.width, image.size.height);
    self.imageProgressBar = [[UIImageView alloc] initWithFrame:frame];
    self.imageProgressBar.image = image;
    [self addSubview:self.imageProgressBar];
}

- (void)generateImage:(CGFloat)seconds completion:(void(^)(UIImage*))completion {
    if (seconds < _flipframeModel.duration) {
        CMTime thumbTime = CMTimeMakeWithSeconds(seconds, 30);
        AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
            if (result != AVAssetImageGeneratorSucceeded) {
                NSLog(@"couldn't generate thumbnail, error:%@", error);
            }
            UIImage *imageThumb=[UIImage imageWithCGImage:im];
            completion(imageThumb);
        };
        [_imageGenerator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
    }
    else {
        completion(nil);
    }
}

- (void)updateTrimSelector {
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (CGRectContainsPoint(self.leftSelector.frame, point)) {
        _touchType = TouchTypeLeft;
        _touchX = point.x;
        return;
    }
    
    if (CGRectContainsPoint(self.rightSelector.frame, point)) {
        _touchType = TouchTypeRight;
        _touchX = point.x;
        return;
    }
    
    _touchType = TouchTypeNone;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (_touchType == TouchTypeLeft) {
        CGFloat deltaX = point.x - _touchX;
        if (self.leftSelector.frame.origin.x + self.leftSelector.frame.size.width + deltaX - 10 < _trimOffsetX) {
            deltaX = _trimOffsetX - self.leftSelector.frame.origin.x - self.leftSelector.frame.size.width + 10;
            point.x = deltaX + _touchX;
        }
        
        CGFloat deltaTime = 6 * deltaX / _trimWidth;
        
        if (_flipframeModel.playStartTime + deltaTime < 0) {
            deltaTime = - _flipframeModel.playStartTime;
            deltaX = deltaTime * _trimWidth / 6;
            point.x = deltaX + _touchX;
        }
        
        if (_flipframeModel.playStartTime + deltaTime > _flipframeModel.playEndTime - DEF_VIDEO_MIN_LEN) {
            deltaTime = _flipframeModel.playEndTime - DEF_VIDEO_MIN_LEN - _flipframeModel.playStartTime;
            deltaX = deltaTime * _trimWidth / 6;
            point.x = deltaX + _touchX;
        }
        
        _flipframeModel.playStartTime += deltaTime;

        CGRect frame = self.leftSelector.frame;
        frame.size.width += deltaX;
        self.leftSelector.frame = frame;
        
        _touchX = point.x;
        
        [self updateEdgeLines];
        [self updateThumbnails];
    }
    else if (_touchType == TouchTypeRight) {
        CGFloat deltaX = point.x - _touchX;
        if (self.rightSelector.frame.origin.x + deltaX + 10 > _trimOffsetX + _trimWidth) {
            deltaX = _trimOffsetX + _trimWidth - self.rightSelector.frame.origin.x - 10;
            point.x = deltaX + _touchX;
        }
        
        CGFloat deltaTime = 6 * deltaX / _trimWidth;
        
        if (_flipframeModel.playEndTime + deltaTime > _flipframeModel.duration) {
            deltaTime = _flipframeModel.duration - _flipframeModel.playEndTime;
            deltaX = deltaTime * _trimWidth / 6;
            point.x = deltaX + _touchX;
        }
        
        if (_flipframeModel.playEndTime + deltaTime < _flipframeModel.playStartTime + DEF_VIDEO_MIN_LEN) {
            deltaTime = _flipframeModel.playStartTime + DEF_VIDEO_MIN_LEN - _flipframeModel.playEndTime;
            deltaX = deltaTime * _trimWidth / 6;
            point.x = deltaX + _touchX;
        }
        
        _flipframeModel.playEndTime += deltaTime;
        
        CGRect frame = self.rightSelector.frame;
        frame.size.width -= deltaX;
        frame.origin.x += deltaX;
        self.rightSelector.frame = frame;
        
        _touchX = point.x;
        
        [self updateEdgeLines];
        [self updateThumbnails];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"-- touches ended --");
    _touchType = TouchTypeNone;
}

- (void)updateThumbnails {
    NSArray *visibleCells = [self.collectionView visibleCells];
    for (EditViewTrimCell *cell in visibleCells) {
        [cell updateOverlay:_flipframeModel.playStartTime trimEnd:_flipframeModel.playEndTime duration:_flipframeModel.duration];
    }
    [self.delegate trimViewDidChange:self];
}

- (void)updateEdgeLines {
    self.topEdgeLine.frame = CGRectMake(self.leftSelector.frame.origin.x + self.leftSelector.frame.size.width - 15,
                                        self.topEdgeLine.frame.origin.y,
                                        self.rightSelector.frame.origin.x - self.leftSelector.frame.origin.x - self.leftSelector.frame.size.width + 30,
                                        self.topEdgeLine.frame.size.height);
    self.bottomEdgeLine.frame = CGRectMake(self.leftSelector.frame.origin.x + self.leftSelector.frame.size.width - 15,
                                        self.bottomEdgeLine.frame.origin.y,
                                        self.rightSelector.frame.origin.x - self.leftSelector.frame.origin.x - self.leftSelector.frame.size.width + 30,
                                        self.bottomEdgeLine.frame.size.height);
}

#pragma mark - collection view delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    CGFloat duration = _flipframeModel.isCapture ? MIN(DEF_VIDEO_MAX_LEN, _flipframeModel.duration) : _flipframeModel.duration;
    NSInteger cellCount = (NSInteger)(duration / 1.2);
    if (1.2 * cellCount < duration) {
        cellCount ++;
    }
    
    cellCount = MAX(5, cellCount);
    
    return cellCount;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EditViewTrimCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EditViewTrimCell" forIndexPath:indexPath];
    cell.imageCover.image = nil;
    CGFloat seconds = 1.2 * indexPath.row;
    [self generateImage:seconds completion:^(UIImage *imageThumb) {
        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"thumbnail size = (%.0f, %.0f)", imageThumb.size.width, imageThumb.size.height);
            cell.imageCover.image = imageThumb;
        });
    }];
    [cell drawRuler:indexPath.row];
    [cell updateOverlay:_flipframeModel.playStartTime trimEnd:_flipframeModel.playEndTime duration:_flipframeModel.duration];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat deltaTime = 1.2 * (scrollView.contentOffset.x + _leftSelector.frame.size.width - _trimOffsetX - 10) * 5 / _trimWidth;
    _flipframeModel.playEndTime = deltaTime + (_flipframeModel.playEndTime - _flipframeModel.playStartTime);
    _flipframeModel.playStartTime = deltaTime;
    [self updateThumbnails];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self showProgressBar:NO];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self showProgressBar:YES];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self showProgressBar:YES];
}

#pragma mark - timer methods
- (void)startTimer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.01f
                                                  target:self
                                                selector:@selector(onTimer:)
                                                userInfo:nil
                                                 repeats:YES];
    }
}

- (void)invalidateTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)onTimer:(id)sender {
    CGFloat minX = self.leftSelector.frame.size.width - 10 - _trimOffsetX;
    CGFloat deltaTime = [self.videoView currentPlaybackTime] - _flipframeModel.playStartTime;
    CGRect frame = self.imageProgressBar.frame;
    
    frame.origin.x = MAX(minX, minX + _trimOffsetX + (_trimWidth - _barWidth - 10) * deltaTime / 6);
    self.imageProgressBar.frame = frame;
}

- (void)showProgressBar:(BOOL)isShow {
    CGFloat alpha = isShow ? 1.0f : 0.0f;
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.imageProgressBar.alpha = alpha;
                     }];
}

@end
