//
//  WDActivityIndicator.m
//  Weddine
//
//  Created by Guilherme Moura on 24/02/2013.
//  Copyright (c) 2013 Reefactor, Inc. All rights reserved.
//

#import "WDActivityIndicator.h"

#define DEF_ACTIVITY_SIZE       21

@interface WDActivityIndicator ()

@property (nonatomic) BOOL animating;
@property (nonatomic) CGFloat angle;
@property (strong, nonatomic) UIImageView *activityImageView;

@end

@implementation WDActivityIndicator

- (id)init {
	return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    CGFloat size = 21;
    CGRect actualFrame = {{frame.origin.x + (frame.size.width - size) / 2, frame.origin.y + (frame.size.height - size) / 2}, {size, size}};
	self = [super initWithFrame:actualFrame];
	if (self) {
		[self setupView];
	}
	
	return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    CGRect frame = self.frame;
    CGRect actualFrame = {{frame.origin.x + (frame.size.width - DEF_ACTIVITY_SIZE) / 2, frame.origin.y + (frame.size.height - DEF_ACTIVITY_SIZE) / 2}, {DEF_ACTIVITY_SIZE, DEF_ACTIVITY_SIZE}};
    self.frame = actualFrame;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self setupView];
	}
	
	return self;
}

- (void)startAnimating {
	self.animating = YES;
	self.hidden = NO;
}

- (void)stopAnimating {
	self.animating = NO;
	
	self.hidden = self.hidesWhenStopped;
	
	// reset to default position
	self.angle = 0.0f;
	CGAffineTransform transform = CGAffineTransformMakeRotation(0.0f);
	self.activityImageView.transform = transform;
}

- (void)setIndicatorStyle:(WDActivityIndicatorStyle)indicatorStyle {
	_indicatorStyle = indicatorStyle;
	
	NSMutableString *imageName = [NSMutableString stringWithString:@"WDActivityIndicator.bundle/"];
	
    if (indicatorStyle == WDActivityIndicatorStyleGradientPurple) {
        [imageName appendString:@"activity_gradient_purple"];
    }
    else if (indicatorStyle == WDActivityIndicatorStylePretzel) {
        [imageName appendString:@"activity_gradient_pretzel"];
    }
    else if (indicatorStyle == WDActivityIndicatorStylePretzelGrey) {
        [imageName appendString:@"activity_gradient_pretzel_grey"];
    }
    else {
        switch (indicatorStyle) {
            case WDActivityIndicatorStyleGradient:
                [imageName appendString:@"activity_gradient"];
                break;
                
            case WDActivityIndicatorStyleSegment:
                [imageName appendString:@"activity_segment"];
                break;
                
            case WDActivityIndicatorStyleSegmentLarge:
                [imageName appendString:@"activity_segment_full"];
                break;
                
            default:
                break;
        }
        
        // Set the style conforming native UIActivityIndicatorView constants.
        switch (self.nativeIndicatorStyle) {
            case UIActivityIndicatorViewStyleGray:
                [imageName appendString:@"_gray"];
                break;
                
            case UIActivityIndicatorViewStyleWhite:
                [imageName appendString:@"_white"];
                break;
                
            case UIActivityIndicatorViewStyleWhiteLarge:
                // TODO: Create large white images
                [imageName appendString:@"_white"];
                break;
                
            default:
                break;
        }
    }
    
	UIImage *indicatorImage = [UIImage imageNamed:imageName];
	
	if (!self.activityImageView) {
		self.activityImageView = [[UIImageView alloc] initWithImage:indicatorImage];
        self.activityImageView.contentMode = UIViewContentModeCenter;
	}
	
	[self.activityImageView setImage:indicatorImage];
}

- (void)setNativeIndicatorStyle:(UIActivityIndicatorViewStyle)nativeIndicatorStyle {
	_nativeIndicatorStyle = nativeIndicatorStyle;
	
	[self setIndicatorStyle:self.indicatorStyle];
}

#pragma mark - Private Methods

- (void)setupView {
	// Default Value is to start animated and to hide when stopped
	self.animating = YES;
	self.hidesWhenStopped = YES;
	self.nativeIndicatorStyle = UIActivityIndicatorViewStyleGray;
	
	// Configure the parent view
	[self setBackgroundColor:[UIColor clearColor]];
	
	[self setIndicatorStyle:WDActivityIndicatorStyleGradient];
	
	self.angle = 0.0f;
	
	NSTimer *timer = [NSTimer timerWithTimeInterval:0.02 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
		
	[self addSubview:self.activityImageView];
}

- (void)handleTimer:(NSTimer *)timer {
	if (self.animating)
		self.angle += 0.13f;
	
	if (self.angle > 6.283)
		self.angle = 0.0f;

	CGAffineTransform transform = CGAffineTransformMakeRotation(self.angle);
	self.activityImageView.transform = transform;
}

@end
