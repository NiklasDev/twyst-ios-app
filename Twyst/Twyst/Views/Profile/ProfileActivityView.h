//
//  ProfileActivityView.h
//  Twyst
//
//  Created by Niklas Ahola on 7/27/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

@class ProfileActivityView;

@protocol ProfileActivityDelegate <NSObject>

@optional
- (void)profileActivity:(ProfileActivityView*)activityView itemTouch:(NSInteger)index;

@end

@interface ProfileActivityView : UIView

@property (nonatomic, assign) id<ProfileActivityDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *labelTwysts;
@property (weak, nonatomic) IBOutlet UILabel *labelLikes;
@property (weak, nonatomic) IBOutlet UILabel *labelFollowers;
@property (weak, nonatomic) IBOutlet UILabel *labelFollowing;
@property (weak, nonatomic) IBOutlet UIView *viewUnderline;

+ (CGFloat)heightForView;
- (void)setActivities:(OCUser*)user relation:(UserRelationType)relation;

@end
