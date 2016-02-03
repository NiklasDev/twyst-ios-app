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

#import "UIImage+Device.h"
#import "UITabBar+NewSize.h"
#import "NSString+Extension.h"

#import "VDTabBarController.h"

#import "UITabBarController+FadeHeader.h"

#define DEF_TAB_COUNT   5

@interface VDTabBarController (Private) <UITabBarControllerDelegate>
-(void) computePosition;
-(void) addCustomElements;
-(void) selectTab:(NSInteger)tabID;

@property (nonatomic, weak) id<UITabBarControllerDelegate> externalDelegate;

@end

//////////////////////////////////////////////////////////////////////////////////////////////

@implementation VDTabBarController

- (id)init {
    self = [super init];
    if (self) {
        self.delegate = self;
        [self initMembers];
    }
    return self;
}

- (void)initMembers {
    DeviceType type = [Global deviceType];
    switch (type) {
        case DeviceTypePhone6:
            _badgeFontSize = 17.0f;
            _frameNotBadge = CGRectMake(91.5, 10.5, 33, 27);
            _frameFriendBadge = CGRectMake(326, 10.5, 33, 27);
            break;
        case DeviceTypePhone6Plus:
            _badgeFontSize = 18.6f;
            _frameNotBadge = CGRectMake(100, 12, 37, 30);
            _frameFriendBadge = CGRectMake(359, 12, 37, 30);
            break;
        default:
            _badgeFontSize = 17.0f;
            _frameNotBadge = CGRectMake(78, 10, 33, 27);
            _frameFriendBadge = CGRectMake(273.5, 10, 33, 27);
            break;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamedForDevice:@"tab_bar_background"];
    UIImageView *backTabBar = [[UIImageView alloc] initWithImage:image];
    [backTabBar setFrame:self.tabBar.bounds];
    [self.tabBar addSubview:backTabBar];
    [backTabBar release];
    
    [self.tabBarController.tabBar sizeThatFits:CGSizeMake(self.tabBar.frame.size.width, UI_TAB_BAR_HEIGHT)];
    
    [[UITabBar appearance] setBackgroundImage:[[UIImage alloc] init]];
    [[UITabBar appearance] setShadowImage:[UIImage imageNamedContentFile:@"tab_bar_shadow"]];
}

- (void)addNotifications {
    // add new twyst badge
    CGRect frame = CGRectMake(0, 0, SCREEN_WIDTH / DEF_TAB_COUNT, UI_TAB_BAR_HEIGHT);
    _imageNewTwyst = [[UIImageView alloc] initWithFrame:frame];
    _imageNewTwyst.image = [UIImage imageNamedForDevice:@"tab_bar_new_twyst"];
    _imageNewTwyst.hidden = YES;
    [self.tabBar addSubview:_imageNewTwyst];
    
    // add notification badge
    _labelNotBadge = [[UILabel alloc] initWithFrame:_frameNotBadge];
    _labelNotBadge.backgroundColor = Color(61, 52, 91);
    _labelNotBadge.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:_badgeFontSize];
    _labelNotBadge.textAlignment = NSTextAlignmentCenter;
    _labelNotBadge.textColor = [UIColor whiteColor];
    _labelNotBadge.layer.cornerRadius = _frameNotBadge.size.height / 2;
    _labelNotBadge.layer.masksToBounds = YES;
    _labelNotBadge.hidden = YES;
    [self.tabBar addSubview:_labelNotBadge];
    
    // add friend badge
    _labelFriendBadge = [[UILabel alloc] initWithFrame:_frameFriendBadge];
    _labelFriendBadge.backgroundColor = Color(61, 52, 91);
    _labelFriendBadge.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:_badgeFontSize];
    _labelFriendBadge.textAlignment = NSTextAlignmentCenter;
    _labelFriendBadge.textColor = [UIColor whiteColor];
    _labelFriendBadge.layer.cornerRadius = _frameFriendBadge.size.height / 2;
    _labelFriendBadge.layer.masksToBounds = YES;
    _labelFriendBadge.hidden = YES;
    [self.tabBar addSubview:_labelFriendBadge];
}

- (void)loadView {
    [super loadView];
    
	_overbuttons = [[NSMutableArray alloc] initWithCapacity:self.tabBar.items.count];
	tabImages = [[NSMutableArray alloc] init];
    tabselImages = [[NSMutableArray alloc] init];
    
    [tabselImages addObject:@"tab_bar_item_home"];
	[tabselImages addObject:@"tab_bar_item_notification"];
    [tabselImages addObject:@"tab_bar_item_friend"];
    [tabselImages addObject:@"tab_bar_item_profile"];
}

- (void)dealloc {
    [_overbuttons release];
    _overbuttons = nil;
    
	[tabImages release];
    tabImages = nil;
    
    [tabselImages release];
    tabselImages = nil;
    
	[_from release];
	_from = nil;
    
	[_to release];
	_to = nil;
    
    [super dealloc];
}

#pragma mark -

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark public
- (void)setNewTwystBadge:(BOOL)isShow {
    _imageNewTwyst.hidden = !isShow;
}

- (void) setNotificationBadge:(NSInteger)badge {
    if (badge == 0) {
        _labelNotBadge.hidden = YES;
        return;
    }
    
    _labelNotBadge.hidden = NO;
    NSString *badgeString = badge > 99 ? @"99" : [NSString stringWithFormat:@"%ld", (long)badge];
    _labelNotBadge.text = badgeString;
}

- (void) setFriendBadge:(NSInteger)badge {
    if (badge == 0) {
        _labelFriendBadge.hidden = YES;
        return;
    }
    
    _labelFriendBadge.hidden = NO;
    NSString *badgeString = badge > 99 ? @"99" : [NSString stringWithFormat:@"%ld", (long)badge];
    _labelFriendBadge.text = badgeString;
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark private
-(void)addCustomElements
{
    CGFloat itemWidth = self.tabBar.frame.size.width / DEF_TAB_COUNT;

    for (UIView* button in _overbuttons)
        [button removeFromSuperview];
    [_overbuttons removeAllObjects];
    
    int i = 0;
    for (i = 0; i < self.tabBar.items.count; i++) {
        // Initialise our two images
        UIImage *btnImage_sel = [UIImage imageNamedForDevice:[tabselImages objectAtIndex:i]];
        ((UITabBarItem*)[self.tabBar.items objectAtIndex:i]).image = nil;

        VDButton* current = [VDButton buttonWithType:UIButtonTypeCustom]; //Setup the button
        [current setBackgroundImage:btnImage_sel forState:UIControlStateSelected];
        [current setTag:i];

        CGRect frame = CGRectZero;
        if (i < 2) {
            frame = CGRectMake(itemWidth * i, 0, itemWidth, UI_TAB_BAR_HEIGHT);
        }
        else {
            frame = CGRectMake(itemWidth * (i + 1), 0, itemWidth, UI_TAB_BAR_HEIGHT);
        }
        current.frame = frame;
        
        if ((self.tabBar.selectedItem == nil && i==0) || [self.tabBar.items objectAtIndex:i] == self.tabBar.selectedItem) {
            [current setSelected:YES];
        }

        [self.tabBar addSubview:current];
        [current addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_overbuttons addObject:current];
    }
    
    // Add camera tab manually
    if (_btnCamera) {
        [_btnCamera removeFromSuperview];
        _btnCamera = nil;
    }
    
    _btnCamera = [BounceButton buttonWithType:UIButtonTypeCustom];
    _btnCamera.frame = CGRectMake(itemWidth * 2, 0, itemWidth, UI_TAB_BAR_HEIGHT);
    [_btnCamera setImage:[UIImage imageNamedForDevice:@"tab_bar_item_camera"] forState:UIControlStateHighlighted];
    [_btnCamera addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _btnCamera.tag = i;
    [self.tabBar addSubview:_btnCamera];
    
    [self addNotifications];
}

- (void)buttonClicked:(id)sender {
	NSInteger tagNum = [sender tag];
	[self selectTab:tagNum];
}

- (void)onCamera {
    [[NSNotificationCenter defaultCenter] postNotificationName:kCameraTabDidSelectNotification object:nil];
}

- (void)selectTab:(NSInteger)tabID {
    if (tabID == 4) {
        [self onCamera];
        return;
    }
	for (int i=0; i<self.tabBar.items.count; i++) {
		UIButton* current = (UIButton*)[_overbuttons objectAtIndex:i];
		if (i == tabID) {
			[current setSelected:YES];
		} else {
			[current setSelected:NO];
		}
	}
	self.selectedIndex = tabID;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
	for (int i=0; i<self.tabBar.items.count; i++) {
		UIButton* current = (UIButton*)[_overbuttons objectAtIndex:i];
		if ([self.tabBar.items objectAtIndex:i] == item) {
			[current setSelected:YES];
		} else {
			[current setSelected:NO];
		}
	}
}

- (void)setViewControllers:(NSArray*)vcs
{
    [super setViewControllers:vcs];
    [self addCustomElements];
}

- (void)setSelectedIndex:(NSUInteger)idx
{
    [super setSelectedIndex:idx];
    if ([self.vdTabBarDelegate respondsToSelector:@selector(didSelectTab: tabIndex:)]) {
        [self.vdTabBarDelegate didSelectTab:[self.viewControllers objectAtIndex:idx] tabIndex:idx];
    }
}

@end
