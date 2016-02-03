//
//  PhotoCompileCircleProgress.m
//  Twyst
//
//  Created by Niklas Ahola on 4/10/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "PhotoCompileCircleProgress.h"
#import "KAProgressLabel.h"

@interface PhotoCompileCircleProgress() {
    int _startFps;
    void (^_completion)(void);
}
@end

@implementation PhotoCompileCircleProgress

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (self.lbText)    {
            NSLog(@"cool");
        }   else    {
            NSLog(@"nil nil");
        }
        self.lbText.text = @"Compiling photos";
    }
    return self;
}

- (void) startAutoWithCompletion:(void (^)(void)) completion    {
    float speed = 1;
    if ([Global deviceType] > DeviceTypePhone4) {
        speed /= 6.0;
    }
    FlipframePhotoModel *flipframeModel = [Global getCurrentFlipframePhotoModel];
    NSInteger total = flipframeModel.totalFrames;
    NSLog(@"speed: %f", speed);
    [self.circleProgressView setProgress:0];
    [self.circleProgressView setProgress:1
                              timing:TPPropertyAnimationTimingEaseOut
                            duration:speed * total
                               delay:0];
    
    __weak typeof(self) weakSelf = self;
    self.circleProgressView.progressLabelVCBlock = ^(KAProgressLabel *label, CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            float current = (progress * total);
            int intCur = (int) current;
            if (current - intCur > 0) {
                intCur ++;
            }
            NSString *mess = [NSString stringWithFormat:@"%d of %ld", intCur , (long)total];
            weakSelf.lbProgress.text = mess;
            if (progress == 1)  {
                if (completion) {
                    completion();
                }
            }
        });
    };
}

- (void) startWithPhotoModel:(FlipframePhotoModel*)flipframeModel Completion:(void (^)(void)) completion    {
    _startFps = 0;
    _completion = completion;
    flipframeModel.processDelegate = self;
    [self.circleProgressView setProgress:0];
    self.circleProgressView.progressLabelVCBlock = ^(KAProgressLabel *label, CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    };
}

- (void) photoCompileCompleteSingleFPS:(NSInteger)currectFps withTotal:(NSInteger)totalFps {
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

- (void) photoCompileCompleteAllImages {
    [self.circleProgressView setProgress:1];
    if (_completion)    {
        double delayInSeconds = 0.2f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            _completion();
        });
    }
}

static PhotoCompileCircleProgress* _instance;
+ (void) startAutoWithParent:(UIView *)parent withComplete:(void (^)(void))completion  {
    @synchronized(self)  {
        if (_instance == nil)
        {
            CGRect frame = [UIScreen mainScreen].bounds;
            _instance = [[PhotoCompileCircleProgress alloc] initWithFrame:frame];
        }
        if (_instance.superview)    {
            [_instance removeFromSuperview];
        }
        [parent addSubview:_instance];
        [_instance startAutoWithCompletion:^{
            [_instance removeFromSuperview];
            if (completion) {
                completion();
            }
        }];
    }
}

+ (void) startWithParent:(UIView *)parent withPhotoModel:(FlipframePhotoModel *)photoModel Completion:(void (^)(void))completion {
    @synchronized(self)  {
        if (_instance == nil)
        {
            CGRect frame = [UIScreen mainScreen].bounds;
            _instance = [[PhotoCompileCircleProgress alloc] initWithFrame:frame];
        }
        if (_instance.superview)    {
            [_instance removeFromSuperview];
        }
        [parent addSubview:_instance];
        [_instance startWithPhotoModel:photoModel Completion:^{
            
            photoModel.processDelegate = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                [_instance removeFromSuperview];
            });
            
            completion();
        }];
    }
}

@end
