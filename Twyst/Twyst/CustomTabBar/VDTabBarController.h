//
// Copyright 2010-2011 Vincent Demay
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//


#import <UIKit/UIKit.h>

#import "VDButton.h"
#import "BounceButton.h"

@protocol VDTabBarDelegate <NSObject>

- (void)didSelectTab:(UIViewController *)selectedViewController tabIndex:(NSInteger)tabIndex;

@end

@interface VDTabBarController : UITabBarController {
	NSMutableArray *_overbuttons;
	NSMutableArray *tabImages;
    NSMutableArray *tabselImages;
	
	UIColor* _from;
	UIColor* _to;
	VDTabBarStyle _style;

    UIImageView *_imageNewTwyst;
    UILabel *_labelNotBadge;
    UILabel *_labelFriendBadge;
    BounceButton *_btnCamera;
    
    CGFloat _badgeFontSize;
    CGRect _frameNotBadge;
    CGRect _frameFriendBadge;
}

@property (nonatomic, assign) id <VDTabBarDelegate> vdTabBarDelegate;

- (void) selectTab:(NSInteger)tabID;

- (void) setNewTwystBadge:(BOOL)isShow;
- (void) setNotificationBadge:(NSInteger)badge;
- (void) setFriendBadge:(NSInteger)badge;

@end
