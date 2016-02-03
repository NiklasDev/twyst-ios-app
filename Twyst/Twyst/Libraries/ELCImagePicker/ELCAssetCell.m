//
//  AssetCell.m
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAssetCell.h"
#import "ELCAsset.h"
#import "UIImage+Device.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/UTCoreTypes.h>

@interface ELCAssetCell () {
    CGFloat _cellWidth;
    CGFloat _startX;
}

@property (nonatomic, strong) NSArray *rowAssets;
@property (nonatomic, strong) NSMutableArray *imageViewArray;
@property (nonatomic, strong) NSMutableArray *overlayViewArray;

@end

@implementation ELCAssetCell

//Using auto synthesizers

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	if (self) {
        [self initMembers];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped:)];
        [self addGestureRecognizer:tapRecognizer];
        
        NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:3];
        self.imageViewArray = mutableArray;
        
        NSMutableArray *overlayArray = [[NSMutableArray alloc] initWithCapacity:3];
        self.overlayViewArray = overlayArray;
	}
	return self;
}

- (void)setAssets:(NSArray *)assets selectedAssets:(NSArray *)selectedArray mediaTypes:(NSArray*)mediaTypes {
    self.rowAssets = assets;
	for (UIImageView *view in _imageViewArray) {
        [view removeFromSuperview];
	}
    for (UIImageView *view in _overlayViewArray) {
        [view removeFromSuperview];
	}
    
    //set up a pointer here so we don't keep calling [UIImage imageNamed:] if creating overlays
    for (int i = 0; i < [_rowAssets count]; ++i) {

        ELCAsset *asset = [_rowAssets objectAtIndex:i];

        BOOL isVideo = NO;
        if([mediaTypes containsObject:(NSString*)kUTTypeMovie]) {
            isVideo = YES;
        }
        
        UIImageView *imageView = nil;
        if (i < [_imageViewArray count]) {
            imageView = [_imageViewArray objectAtIndex:i];
        } else {
            imageView = [[UIImageView alloc] init];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            [_imageViewArray addObject:imageView];
        }
        
        [self thumbnailForAsset:asset.asset
                   maxPixelSize:400
                        isVideo:isVideo
                     completion:^(UIImage *image) {
                         NSLog(@"image size = (%.0f, %.0f)", image.size.width, image.size.height);
                         imageView.image = image;
                     }];
        
        UIImageView *overlayView = nil;
        if (i < [_overlayViewArray count]) {
            overlayView = [_overlayViewArray objectAtIndex:i];
        } else {
            overlayView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _cellWidth, _cellWidth)];
            [_overlayViewArray addObject:overlayView];
        }
        if (asset.selected) {
            overlayView.hidden = NO;
            NSInteger index = [selectedArray indexOfObject:asset];
            UIImage *overlayBgImage = [UIImage imageNamedForDevice:@"ic-camera-upload-overlay"];
            UIImage *overlayImage = [FlipframeUtils generateSelectionOverlayWithIndex:overlayBgImage withIndex:index];
            overlayView.image = overlayImage;
        }
        else {
            overlayView.hidden = YES;
        }
    }
}

- (void)cellTapped:(UITapGestureRecognizer *)tapRecognizer {
    CGPoint point = [tapRecognizer locationInView:self];
    
	CGRect frame = CGRectMake(_startX, 0, _cellWidth, _cellWidth);
	
	for (int i = 0; i < [_rowAssets count]; ++i) {
        if (CGRectContainsPoint(frame, point)) {
            ELCAsset *asset = [_rowAssets objectAtIndex:i];
            asset.selected = !asset.selected;
            UIImageView *overlayView = [_overlayViewArray objectAtIndex:i];
            overlayView.hidden = !asset.selected;
            break;
        }
        frame.origin.x = frame.origin.x + frame.size.width;
    }
}

- (void)layoutSubviews {
	CGRect frame = CGRectMake(_startX, 0, _cellWidth, _cellWidth);
	
	for (int i = 0; i < [_rowAssets count]; ++i) {
		UIImageView *imageView = [_imageViewArray objectAtIndex:i];
		[imageView setFrame:frame];
		[self addSubview:imageView];
        
        UIImageView *overlayView = [_overlayViewArray objectAtIndex:i];
        [overlayView setFrame:frame];
        [self addSubview:overlayView];
		
		frame.origin.x = frame.origin.x + frame.size.width;
	}
}

- (void)initMembers {
    DeviceType type = [Global deviceType];
    switch (type) {
        case DeviceTypePhone6:
            _cellWidth = 125;
            _startX = 0;
            break;
        case DeviceTypePhone6Plus:
            _cellWidth = 138;
            _startX = 0;
            break;
        default:
            _cellWidth = 107;
            _startX = 0;
            break;
    }
}

static size_t getAssetBytesCallback(void *info, void *buffer, off_t position, size_t count) {
    ALAssetRepresentation *rep = (__bridge id)info;
    
    NSError *error = nil;
    size_t countRead = [rep getBytes:(uint8_t *)buffer fromOffset:position length:count error:&error];
    
    if (countRead == 0 && error) {
        // We have no way of passing this info back to the caller, so we log it, at least.
        NSLog(@"thumbnailForAsset:maxPixelSize: got an error reading an asset: %@", error);
    }
    
    return countRead;
}

static void releaseAssetCallback(void *info) {
    // The info here is an ALAssetRepresentation which we CFRetain in thumbnailForAsset:maxPixelSize:.
    // This release balances that retain.
    CFRelease(info);
}

- (void)thumbnailForAsset:(ALAsset *)asset maxPixelSize:(NSInteger)size isVideo:(BOOL)isVideo completion:(void(^)(UIImage*))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImage *toRetun = isVideo ? [self videoThumbnailForAsset:asset maxPixelSize:size] : [self thumbnailForAsset:asset maxPixelSize:size];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(toRetun);
        });
    });
}

- (UIImage *)thumbnailForAsset:(ALAsset *)asset maxPixelSize:(NSInteger)size {
    NSParameterAssert(asset != nil);
    NSParameterAssert(size > 0);
    
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    
    CGDataProviderDirectCallbacks callbacks = {
        .version = 0,
        .getBytePointer = NULL,
        .releaseBytePointer = NULL,
        .getBytesAtPosition = getAssetBytesCallback,
        .releaseInfo = releaseAssetCallback,
    };
    
    CGDataProviderRef provider = CGDataProviderCreateDirect((void *)CFBridgingRetain(rep), [rep size], &callbacks);
    CGImageSourceRef source = CGImageSourceCreateWithDataProvider(provider, NULL);
    
    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef) @{
                                                                                                      (NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                                                                                      (NSString *)kCGImageSourceThumbnailMaxPixelSize : [NSNumber numberWithInteger:size],
                                                                                                      (NSString *)kCGImageSourceCreateThumbnailWithTransform : @YES,
                                                                                                      });
    CFRelease(source);
    CFRelease(provider);
    
    if (!imageRef) {
        return nil;
    }
    
    UIImage *toReturn = [UIImage imageWithCGImage:imageRef];
    
    CFRelease(imageRef);
    
    return toReturn;
}

- (UIImage*)videoThumbnailForAsset:(ALAsset*)asset maxPixelSize:(NSInteger)size {
    NSParameterAssert(asset != nil);
    NSParameterAssert(size > 0);
    
    NSURL *url = [asset.defaultRepresentation url];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:[AVAsset assetWithURL:url]];
    imageGenerator.appliesPreferredTrackTransform = YES;
    imageGenerator.maximumSize = CGSizeMake(size, size);
    CMTime time = CMTimeMake(1, 60);
    CGImageRef imgRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:nil];
    UIImage *toReturn = [[UIImage alloc] initWithCGImage:imgRef];
    return toReturn;
}

@end
