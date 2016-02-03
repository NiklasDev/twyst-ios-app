//
//  CameraAutoTopView.m
//  Twyst
//
//  Created by Niklas Ahola on 4/6/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"

#import "CameraAutoTopView.h"

@interface CameraAutoTopView() {
    UIImage *_imBoxBg;
    UIImage *_imBoxRed;
    UIImage *_imBoxGreen;
    
    int _totalCells;
    NSMutableArray *_arrCells;
    NSMutableArray *_arrLabels;
}

@end

@implementation CameraAutoTopView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        //init images
        _imBoxBg = [UIImage imageNamedContentFile:@"ic-camera-clock-ready"];
        _imBoxGreen = [UIImage imageNamedContentFile:@"ic-camera-clock-taken"];
        _imBoxRed = [UIImage imageNamedContentFile:@"ic-camera-clock-progress"];
        
        //init image views
        _totalCells = 4;
        _arrCells = [[NSMutableArray alloc] initWithCapacity:_totalCells];
        _arrLabels = [[NSMutableArray alloc] initWithCapacity:_totalCells];
        
        float cellW = 48;
        float cellH = cellW;
        float cellY = (self.bounds.size.height - cellH ) / 2;
        float cellPX = (self.bounds.size.width - cellW * 4) / 2;
        for (int i=0; i<_totalCells; i++)   {
            CGRect frameImageView = CGRectMake(i * cellW + cellPX, cellY, cellW, cellH);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:frameImageView];
            imageView.image = _imBoxBg;
            [self addSubview:imageView];
            
            CGRect frameLable = frameImageView;
            frameLable.origin.y -= 2;
            UILabel *lbNum = [[UILabel alloc] initWithFrame:frameLable];
            lbNum.backgroundColor = [UIColor clearColor];
            lbNum.textColor = [UIColor whiteColor];
            lbNum.textAlignment = NSTextAlignmentCenter;
            CGFloat fontSize = 26;
            lbNum.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:fontSize];
            [self addSubview:lbNum];
            
            [_arrCells addObject:imageView];
            [_arrLabels addObject:lbNum];
        }
    }
    return self;
}

- (void) resetAll   {
    [self resetAll:NO];
}

- (void) resetAll:(BOOL)animate {
    for (int i=0; i<_arrCells.count; i++)   {
        UIImageView *imageView = [_arrCells objectAtIndex:i];
        UILabel *label = [_arrLabels objectAtIndex:i];
        label.text = @"";
        
        int maxPhotos = (int) [Global getConfig].selfieStripSize;
        if (i < maxPhotos) {
            imageView.alpha = 1;
            if (animate) {
                imageView.transform = CGAffineTransformMakeScale(0, 0);
                [UIView animateWithDuration:0.2f
                                      delay:0.4 + 0.1 * i
                                    options:UIViewAnimationOptionCurveEaseIn
                                 animations:^{
                                     imageView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                                 } completion:^(BOOL finished) {
                                     
                                 }];
            }
            label.alpha = 1;
        }
        else {
            imageView.alpha = 0;
            label.alpha = 0;
        }
        
        if (i == 0) {
            imageView.image = [UIImage imageNamedContentFile:@"ic-camera-clock"];
        }   else    {
            imageView.image = _imBoxBg;
        }
    }
}

- (void) updateCell:(int) index withCountDown:(int) countDown withMaxPhotos:(int) maxPhotos   {
    int count = (int)_arrCells.count;
    if (index == count)   {
        [self resetAll];
        if (maxPhotos > count)  {
            int startInx = maxPhotos % count;
            if (startInx >0)    {
                for (int i=startInx; i<count; i++)  {
                    UIImageView *imageView = [_arrCells objectAtIndex:i];
                    UILabel *label = [_arrLabels objectAtIndex:i];
                    imageView.alpha = 0;
                    label.alpha = 0;
                }
            }
        }
    }
    if (index >= count)   {
        index = index % count;
    }
    
    UIImageView *imageView = [_arrCells objectAtIndex:index];
    UILabel *label = [_arrLabels objectAtIndex:index];
    
    UIImage *image  = nil;
    NSString *strNum = @"";
    if (countDown >= 1) {
        image = _imBoxRed; 
        strNum = [NSString stringWithFormat:@"%d", countDown];
    } else if (countDown == 0)  { //=0
        image = _imBoxGreen;
    }   else    { // == -1
        image = _imBoxBg;
    }
    imageView.image = image;
    label.text = strNum;
}

- (void) prepareNewSection  {
    [self resetAll:YES];
}

- (void) tutorialCountDown  {
    UIImageView *imageView = [_arrCells firstObject];
    UILabel *label = [_arrLabels firstObject];
    imageView.image = _imBoxRed;
    label.text = [NSString stringWithFormat:@"%d", 3];
}

- (void) tutorialPicTaken   {
    UIImageView *imageView = [_arrCells firstObject];
    UILabel *label = [_arrLabels firstObject];
    imageView.image = _imBoxGreen;
    label.text = @"";
}

- (void) tutorialChangeFace {
    UIImageView *imageView = [_arrCells objectAtIndex:1];
    UILabel *label = [_arrLabels objectAtIndex:1];
    imageView.image = _imBoxRed;
    label.text = [NSString stringWithFormat:@"%d", 3];
}

@end
