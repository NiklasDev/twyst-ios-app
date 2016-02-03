//
//  ProfileDownloadProgressView.m
//  Twyst
//
//  Created by Niklas Ahola on 4/10/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "ProfileDownloadProgressView.h"

@interface ProfileDownloadProgressView() <ProfileDownloadProcessDelegate> {
    void (^_completion)(void);
}

@end

@implementation ProfileDownloadProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        float bgS = 80;
        float bgX = (self.bounds.size.width - bgS ) / 2;
        float bgY = (self.bounds.size.height - bgS) / 2;
        CGRect frameBg = CGRectMake(bgX, bgY, bgS, bgS);
        self.bgImageView = [[UIImageView alloc] initWithFrame:frameBg];
        self.bgImageView.image = [UIImage imageNamed:@"ic-edit-photo-finalizing-popup-bg"];
        [self addSubview:self.bgImageView];
        
        float circleS = 54;
        float circleX = (bgS - circleS ) / 2;
        CGRect frameCircle = CGRectMake(circleX, circleX, circleS, circleS);
        self.circleProgressView = [[KAProgressLabel alloc] initWithFrame:frameCircle];
        self.circleProgressView.backgroundColor = [UIColor clearColor];
        [self.circleProgressView setBorderWidth:8];
        
        UIColor *trackColor = [UIColor colorWithRed:12.0/255.0 green:12.0/255.0 blue:12.0/255.0 alpha:1];
        [self.circleProgressView setColorTable: @{
                                              NSStringFromProgressLabelColorTableKey(ProgressLabelFillColor):[UIColor clearColor],
                                              NSStringFromProgressLabelColorTableKey(ProgressLabelTrackColor):trackColor,
                                              NSStringFromProgressLabelColorTableKey(ProgressLabelProgressColor):[UIColor whiteColor]
                                              }];
        [self.bgImageView addSubview:self.circleProgressView];
        
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void) startWithParent:(FullProfileImageView*)parent Completion:(void (^)(void)) completion {
    _completion = completion;
    parent.processDelegate = self;
    [self.circleProgressView setProgress:0];
    self.circleProgressView.progressLabelVCBlock = ^(KAProgressLabel *label, CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    };
}

- (void) profileDownloadProgress:(NSInteger)received withTotal:(NSInteger) expected {
    float progress = (float)received / (float)expected;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.circleProgressView setProgress:progress
                                      timing:TPPropertyAnimationTimingEaseOut
                                    duration:0.2
                                       delay:0];
    });
}

- (void) profileDownloadDidComplete {
    [self.circleProgressView setProgress:1];
    if (_completion)    {
        _completion();
    }
}

- (void)profileDownloadDidFail {
    [self.circleProgressView setProgress:1];
    if (_completion) {
        _completion();
    }
}

static ProfileDownloadProgressView* _instance;
+(void) startWithParent:(FullProfileImageView*)parent Completion:(void (^)(void)) completion  {
    @synchronized(self)  {
        if (_instance == nil)
        {
            CGRect frame = [UIScreen mainScreen].bounds;
            _instance = [[ProfileDownloadProgressView alloc] initWithFrame:frame];
        }
        if (_instance.superview)    {
            [_instance removeFromSuperview];
        }
        [parent addSubview:_instance];
        [_instance startWithParent:parent Completion:^{
            
            parent.processDelegate = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                [_instance removeFromSuperview];
            });
            
            completion();
        }];
    }
}

@end
