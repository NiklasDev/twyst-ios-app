//
//  CircleProgressView.m
//  Twyst
//
//  Created by Niklas Ahola on 4/10/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "CircleProgressView.h"
@interface CircleProgressView() {
    
}
@end

@implementation CircleProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        float bgS = 150;
        float bgX = (self.bounds.size.width - bgS ) / 2;
        float bgY = 118;
        CGRect frameBg = CGRectMake(bgX, bgY, bgS, bgS);
        self.bgImageView = [[UIImageView alloc] initWithFrame:frameBg];
        self.bgImageView.image = [UIImage imageNamed:@"ic-edit-photo-finalizing-popup-bg"];
        [self addSubview:self.bgImageView];
        
        float circleS = 54;
        float circleX = (bgS - circleS ) / 2;
        float circleY = 24;
        CGRect frameCircle = CGRectMake(circleX, circleY, circleS, circleS);
        self.circleProgressView = [[KAProgressLabel alloc] initWithFrame:frameCircle];
        self.circleProgressView.backgroundColor = [UIColor clearColor];
        [self.circleProgressView setBorderWidth:10];
        
        UIColor *trackColor = [UIColor colorWithRed:12.0/255.0 green:12.0/255.0 blue:12.0/255.0 alpha:1];
        [self.circleProgressView setColorTable: @{
                                              NSStringFromProgressLabelColorTableKey(ProgressLabelFillColor):[UIColor clearColor],
                                              NSStringFromProgressLabelColorTableKey(ProgressLabelTrackColor):trackColor,
                                              NSStringFromProgressLabelColorTableKey(ProgressLabelProgressColor):[UIColor whiteColor]
                                              }];
        [self.bgImageView addSubview:self.circleProgressView];
        
        //label text
        self.lbText = [[UILabel alloc] initWithFrame:CGRectMake(0, 93, frameBg.size.width, 15)];
        self.lbText.textColor = [UIColor whiteColor];
        self.lbText.font = [UIFont boldSystemFontOfSize:14];
        self.lbText.textAlignment = NSTextAlignmentCenter;
        self.lbText.backgroundColor = [UIColor clearColor];
        [self.bgImageView addSubview:self.lbText];
        
        //label progress
        self.lbProgress = [[UILabel alloc] initWithFrame:CGRectMake(0, 116, frameBg.size.width, 15)];
        self.lbProgress.textColor = [UIColor whiteColor];
        self.lbProgress.font = [UIFont boldSystemFontOfSize:14];
        self.lbProgress.textAlignment = NSTextAlignmentCenter;
        self.lbProgress.backgroundColor = [UIColor clearColor];
        [self.bgImageView addSubview:self.lbProgress];
        
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
