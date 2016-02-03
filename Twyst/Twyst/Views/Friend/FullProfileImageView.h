//
//  FullProfileImageView.h
//  Twyst
//
//  Created by Niklas Ahola on 1/8/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProfileDownloadProcessDelegate <NSObject>

- (void) profileDownloadProgress:(NSInteger)received withTotal:(NSInteger)expected;
- (void) profileDownloadDidComplete;
- (void) profileDownloadDidFail;

@end

@interface FullProfileImageView : UIView

@property (nonatomic, retain) NSString *profileName;
@property (nonatomic, assign) id <ProfileDownloadProcessDelegate> processDelegate;

- (id)initWithProfileName:(NSString*)profileName;
- (void)showInView:(UIView*)parent;

@end

