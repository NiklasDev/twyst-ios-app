//
//  EditFilterViewCell.m
//  Twyst
//
//  Created by Niklas Ahola on 7/4/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"
#import "EditFilterViewCell.h"

@interface EditFilterViewCell() {
    CGRect _frameImage;
    
    NSString *_bundleImage;
    NSString *_bundleSelectedImage;
    
    UIImageView *_imageView;
    
    BOOL _isSelected;
}
@end


@implementation EditFilterViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initMembers];
        
        _imageView = [[UIImageView alloc] initWithFrame:_frameImage];
        [self addSubview:_imageView];
    }
    return self;
}

- (void)initMembers {
    DeviceType type = [Global deviceType];
    switch (type) {
        case DeviceTypePhone4:
            _frameImage = CGRectMake(5.5, 11.5, 63.5, 87.5);
            break;
        case DeviceTypePhone5:
            _frameImage = CGRectMake(5.5, 15, 63.5, 87.5);
            break;
        case DeviceTypePhone6:
            _frameImage = CGRectMake(6, 13.5, 74, 102);
            break;
        case DeviceTypePhone6Plus:
            _frameImage = CGRectMake(7, 16, 82, 113);
            break;
        default:
            break;
    }
}

- (void) updateState:(BOOL) isSelected withBundleImage:(NSString*) bundleImage selectedBundleImage:(NSString*)selectedBundleImage {
    _bundleImage = bundleImage;
    _bundleSelectedImage = selectedBundleImage;
    
    _isSelected = isSelected;
    [self refreshImageState];
}

- (void) refreshImageState  {
    if (_isSelected) {
        _imageView.image = [UIImage imageNamedForDevice:_bundleSelectedImage];
    }
    else {
        _imageView.image = [UIImage imageNamedForDevice:_bundleImage];
    }
}

- (void) cellSelected:(BOOL)selected {
    _isSelected = selected;
    if (_isSelected) {
        _imageView.image = [UIImage imageNamedForDevice:_bundleSelectedImage];
    }
    else {
        _imageView.image = [UIImage imageNamedForDevice:_bundleImage];
    }
}

@end
