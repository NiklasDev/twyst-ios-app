//
//  ProfileActivityView.m
//  Twyst
//
//  Created by Niklas Ahola on 7/27/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "ProfileActivityView.h"

@interface ProfileActivityView() {
    
}

@end

@implementation ProfileActivityView

+ (CGFloat)heightForView {
    switch ([Global deviceType]) {
        case DeviceTypePhone6:
            return 50;
            break;
        case DeviceTypePhone6Plus:
            return 55;
            break;
        default:
            return 43;
            break;
    }
}

- (id)init {
    NSString *nibName = [FlipframeUtils nibNameForDevice:@"ProfileActivityView"];
    NSArray *subViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    self = [subViews firstObject];
    return self;
}

- (void)setActivities:(OCUser*)user relation:(UserRelationType)relation {
    self.labelTwysts.text = [FlipframeUtils countString:user.TwystCreated];
    self.labelLikes.text = [FlipframeUtils countString:user.LikeCount];
    self.labelFollowers.text = [FlipframeUtils countString:user.Followers];
    self.labelFollowing.text = [FlipframeUtils countString:user.Following];
    
    if (relation == UserRelationTypeSelf) {
        self.userInteractionEnabled = YES;
    }
    else if (user.PrivateProfile && relation != UserRelationTypeFriend) {
        self.userInteractionEnabled = NO;
    }
    else {
        self.userInteractionEnabled = YES;
    }
}

- (IBAction)handleBtnActivityTouch:(UIButton*)sender {
    NSInteger index = sender.tag;
    if ([self.delegate respondsToSelector:@selector(profileActivity:itemTouch:)]) {
        [self.delegate profileActivity:self itemTouch:index];
    }
    
    if (index < 2) {
        CGFloat offsetX = (index == 0) ? self.labelTwysts.frame.origin.x : self.labelLikes.frame.origin.x;
        CGRect frame = self.viewUnderline.frame;
        frame.origin.x = offsetX - 2;
        [UIView animateWithDuration:0.2f
                         animations:^{
                             self.viewUnderline.frame = frame;
                         }];
    }
    
}


@end
