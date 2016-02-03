//
//  PhotoImportCircleProgress.m
//  Twyst
//
//  Created by Niklas Ahola on 8/21/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "PhotoImportCircleProgress.h"
#import "KAProgressLabel.h"

@interface PhotoImportCircleProgress() {
    int _startFps;
    void (^_completion)(void);
}
@end

@implementation PhotoImportCircleProgress

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void) startAutoWithCompletion:(void (^)(void)) completion    {
    float speed = 2;
    [self.circleProgressView setProgress:0];
    [self.circleProgressView setProgress:1
                                  timing:TPPropertyAnimationTimingEaseOut
                                duration:speed
                                   delay:0];
    self.circleProgressView.progressLabelVCBlock = ^(KAProgressLabel *label, CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progress == 1)  {
                if (completion) {
                    completion();
                }
            }
        });
    };
}

- (void) startVideoAutoWithCompletion:(NSTimeInterval)duration completion:(void (^)(void)) completion    {
    float speed = duration;
    self.lbText.text = @"Cropping video";
    self.lbProgress.text = @"";
    [self.circleProgressView setProgress:0];
    [self.circleProgressView setProgress:1
                                  timing:TPPropertyAnimationTimingEaseOut
                                duration:speed
                                   delay:0];
    self.circleProgressView.progressLabelVCBlock = ^(KAProgressLabel *label, CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progress == 1)  {
                if (completion) {
                    completion();
                }
            }
        });
    };
}

- (void) startWithImportService:(PhotoRegularService*) regularService Completion:(void (^)(void)) completion    {
    _startFps = 0;
    _completion = completion;
    regularService.processDelegate = self;
    
    self.lbText.text = @"Fetching Photos";
    [self.circleProgressView setProgress:0];
    self.circleProgressView.progressLabelVCBlock = ^(KAProgressLabel *label, CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    };
}

- (void) photoImportCompleteSingleFPS:(NSInteger)currectFps withTotal:(NSInteger) totalFps {
    float progress = (float) (currectFps - _startFps) / (float) (totalFps - _startFps);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.circleProgressView setProgress:progress
                                      timing:TPPropertyAnimationTimingEaseOut
                                    duration:0.2
                                       delay:0];
        NSString *mess = [NSString stringWithFormat:@"%ld of %ld", (long)currectFps , (long)totalFps];
        self.lbProgress.text = mess;
    });
}

- (void) photoImportCompleteAllImages {
    [self.circleProgressView setProgress:1];
    if (_completion)    {
        _completion();
    }
}

static PhotoImportCircleProgress* _instance;
+ (void) startAutoWithParent:(UIView*)parent withComplete:(void (^)(void)) completion   {
    @synchronized(self)  {
        if (_instance == nil)
        {
            CGRect frame = [UIScreen mainScreen].bounds;
            _instance = [[PhotoImportCircleProgress alloc] initWithFrame:frame];
        }
        if (_instance.superview)    {
            [_instance removeFromSuperview];
        }
        [parent addSubview:_instance];
        [_instance startAutoWithCompletion:^{
            [_instance removeFromSuperview];
            if (completion)
                completion();
        }];
    }
}

+ (void) startVideoAutoWithParent:(UIView*)parent duration:(NSTimeInterval)duration withComplete:(void (^)(void)) completion   {
    @synchronized(self)  {
        if (_instance == nil)
        {
            CGRect frame = [UIScreen mainScreen].bounds;
            _instance = [[PhotoImportCircleProgress alloc] initWithFrame:frame];
        }
        if (_instance.superview)    {
            [_instance removeFromSuperview];
        }
        [parent addSubview:_instance];
        
        [_instance startVideoAutoWithCompletion:duration completion:^{
            [_instance removeFromSuperview];
            if (completion)
                completion();
        }];
    }
}

+(void) startWithParent:(UIView*) parent withImportService:(PhotoRegularService*) regularService Completion:(void (^)(void)) completion  {
    @synchronized(self)  {
        if (_instance == nil)
        {
            CGRect frame = [UIScreen mainScreen].bounds;
            _instance = [[PhotoImportCircleProgress alloc] initWithFrame:frame];
        }
        if (_instance.superview)    {
            [_instance removeFromSuperview];
        }
        [parent addSubview:_instance];
        [_instance startWithImportService:regularService Completion:^{
            
            regularService.processDelegate = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                [_instance removeFromSuperview];
            });
            
            completion();
        }];
    }
}

+ (void) removeInstance {
    @synchronized(self) {
        [_instance removeFromSuperview];
    }
}

@end
