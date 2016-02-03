//
//  TwystNoticeView.m
//  Twyst
//
//  Created by Niklas Ahola on 9/23/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"
#import "UIImageView+WebCache.h"
#import "NSString+Extension.h"

#import "TTwystOwner.h"
#import "UserWebService.h"
#import "TTwystOwnerManager.h"

#import "TwystNoticeCell.h"
#import "TwystNoticeView.h"

@interface TwystNoticeView() <TwystNoticeCellDelegate> {
    CGRect _frameClose;
    
    NSTimer *_timerNotice;
    BOOL _isNoticeRequest;
    
    NSArray *_noticeColors;
    
    NSInteger _maximumCount;
    NSMutableArray *_arrayNotices;
    
    long _latestId;
    BOOL _isFirstAppear;
}

@property (strong, nonatomic) TTwystOwner *owner;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UIImageView *imageCreator;
@property (weak, nonatomic) IBOutlet UILabel *labelRealname;
@property (weak, nonatomic) IBOutlet UILabel *labelUsername;
@property (weak, nonatomic) IBOutlet UIView *bottomContainer;
@property (weak, nonatomic) IBOutlet UIView *noticeContainer;

@end

@implementation TwystNoticeView

- (id)initWithTwyst:(TSavedTwyst *)twyst {
    NSString *nibName = ([Global deviceType] == DeviceTypePhone4) ? @"TwystNoticeView-3.5inch" : [FlipframeUtils nibNameForDevice:@"TwystNoticeView"];
    NSArray *subViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    self = [subViews firstObject];
    self.twyst = twyst;
    [self initMembers];
    [self initView];
    return self;
}

- (void)initMembers {
    //hide view as default
    self.alpha = 0.0f;
    
    _frameClose = _btnClose.frame;
    
    _arrayNotices = [[NSMutableArray alloc] init];
    
    _noticeColors = @[Color(1, 162, 152),
                      Color(233, 98, 24),
                      Color(222, 20, 73),
                      Color(70, 57, 105),
                      Color(54, 54, 54)];
    
    _isFirstAppear = YES;
    
    _latestId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notice_latest_id"] longValue];
    
    switch ([Global deviceType]) {
        case DeviceTypePhone4:
            _maximumCount = 7;
            break;
        case DeviceTypePhone5:
            _maximumCount = 9;
            break;
        case DeviceTypePhone6:
            _maximumCount = 11;
            break;
        case DeviceTypePhone6Plus:
            _maximumCount = 12;
            break;
        default:
            break;
    }
}

- (void)initView {
    // set gaussian blur image
//    [self addGaussianBlurImage];
    self.backgroundColor = ColorRGBA(8, 8, 8, 0.9);
    
    // set creator profile picture
    _imageCreator.layer.cornerRadius = _imageCreator.frame.size.width / 2;
    _imageCreator.layer.masksToBounds = YES;
    
    long ownerId = [_twyst.ownerId longValue];
    _owner = [[TTwystOwnerManager sharedInstance] getOwnerWithUserId:ownerId];
    UIImage *placeholder = [UIImage imageNamedContentFile:@"ic-profile-avatar"];
    [_imageCreator setImageWithURL:ProfileURL(_owner.profilePicName) placeholderImage:placeholder];
    
    // set name
    _labelRealname.text = [NSString stringWithFormat:@"%@ %@", _owner.firstName, _owner.lastName];
}

- (void) dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

- (void)addGaussianBlurImage {
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:.6f];
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = self.bounds;
        [self insertSubview:blurEffectView atIndex:0];
    }
    else {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:.9f];
    }
}

- (void)addNoticeCells:(NSArray*)notices {
    NSInteger count = notices.count;
    for (NSInteger i = 0; i < count; i++) {
        NSDictionary *notice = [notices objectAtIndex:i];
        NSString *username = [notice objectForKey:@"username"];
        NSString *action = [notice objectForKey:@"action"];
        
        if (_arrayNotices.count >= _maximumCount) {
            TwystNoticeCell *cell = (TwystNoticeCell*)[_arrayNotices firstObject];
            [cell releaseNoticeCell];
        }
        
        NSInteger preColor = arc4random() % _noticeColors.count;
        if (_arrayNotices.count > 0) {
            TwystNoticeCell *cell = (TwystNoticeCell*)[_arrayNotices lastObject];
            preColor = cell.colorIndex;
        }
        
        TwystNoticeCell *cell = [[TwystNoticeCell alloc] initWithUsername:username action:action color:Color(1, 162, 152)];
        cell.delegate = self;
        cell.colorIndex = [self getNoticeColorIndex:preColor];
        [cell setNoticeColor:[_noticeColors objectAtIndex:cell.colorIndex]];
        [_noticeContainer addSubview:cell];
        
        cell.frame = CGRectMake(0, _noticeContainer.frame.size.height + cell.frame.size.height * i, cell.frame.size.width, cell.frame.size.height);
        [_arrayNotices addObject:cell];
    }
    
    for (UIView *view in _arrayNotices) {
        [UIView animateWithDuration:0.4f
                         animations:^{
                             CGRect frame = view.frame;
                             frame.origin.y -= frame.size.height * count;
                             view.frame = frame;
                         }];
    }
}

- (NSInteger)getNoticeColorIndex:(NSInteger)preColor {
    NSInteger colorIndex = arc4random() % _noticeColors.count;
    while (colorIndex == preColor) {
        colorIndex = arc4random() % _noticeColors.count;
    }
    return colorIndex;
}

#pragma mark - twyst notice cell delegate
- (void)twystNoticeCellDidDisappear:(TwystNoticeCell *)sender {
    [_arrayNotices removeObject:sender];
    [sender releaseNoticeCell];
}

#pragma mark - public methods
- (void)show {
    self.alpha = 0;
    _btnClose.frame = CGRectMake(_frameClose.origin.x, -_frameClose.size.height, _frameClose.size.width, _frameClose.size.height);
    _bottomContainer.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, _bottomContainer.frame.size.height);
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.alpha = 1.0f;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2f
                                          animations:^{
                                              _btnClose.frame = _frameClose;
                                              _bottomContainer.frame = CGRectMake(0, SCREEN_HEIGHT - _bottomContainer.frame.size.height, SCREEN_WIDTH, _bottomContainer.frame.size.height);
                                          } completion:^(BOOL finished) {
                                              [self startNoticeTimer];
                                              if (_isFirstAppear) {
                                                  _isFirstAppear = NO;
                                                  
                                                  [self addNoticeCells:@[@{@"username":_owner.userName, @"action":@"start"}]];
                                              }
                                          }];
                     }];
}

- (void)hide:(void(^)(void))completion {
    [self stopNoticeTimer];
    [UIView animateWithDuration:0.2f
                     animations:^{
                         _btnClose.frame = CGRectMake(_frameClose.origin.x, -_frameClose.size.height, _frameClose.size.width, _frameClose.size.height);
                         _bottomContainer.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, _bottomContainer.frame.size.height);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2f
                                          animations:^{
                                              self.alpha = 0.0f;
                                          } completion:^(BOOL finished) {
                                              for (TwystNoticeCell *cell in _arrayNotices) {
                                                  [cell releaseNoticeCell];
                                              }
                                              completion();
                                          }];
                     }];
}

- (void)releaseNoticeView {
    [self stopNoticeTimer];
    for (TwystNoticeCell *cell in _arrayNotices) {
        [cell releaseNoticeCell];
    }
}

#pragma mark - button handler
- (IBAction)handleBtnMoreTouch:(id)sender {
    [self.delegate twystNoticeViewMoreDidClick];
}

- (IBAction)handleBtnCloseTouch:(id)sender {
    [self hide:^{
        [self.delegate twystNoticeViewDidClose];
    }];
}

#pragma mark - handle timer methods
- (void)startNoticeTimer {
    if (_timerNotice == nil) {
        _timerNotice = [NSTimer scheduledTimerWithTimeInterval:3.0f
                                                           target:self
                                                         selector:@selector(onNoticeTimer:)
                                                         userInfo:nil
                                                          repeats:YES];
    }
}

- (void)stopNoticeTimer {
    if (_timerNotice) {
        [_timerNotice invalidate];
        _timerNotice = nil;
    }
}

- (void)onNoticeTimer:(id)sender {
    if (_isNoticeRequest == NO) {
        _isNoticeRequest = YES;
        long twystId = [_twyst.twystId longValue];
        [[UserWebService sharedInstance] getTwystActivity:twystId completion:^(NSArray *actions) {
            _isNoticeRequest = NO;
            NSInteger count = actions.count;
            if (count > 0) {
                NSMutableArray *notices = [[NSMutableArray alloc] init];
                for (NSInteger i = count - 1; i >= 0; i--) {
                    NSDictionary *dic = [actions objectAtIndex:i];
                    long noticeId = [[dic objectForKey:@"Id"] longValue];
                    if (noticeId > _latestId) {
                        NSString *action = [dic objectForKey:@"NewsType"];
                        if (![action isEqualToString:@"unlike"]) {
                            NSString *username = [[dic objectForKey:@"OCUser"] objectForKey:@"UserName"];
                            [notices addObject:@{@"username":username, @"action":action}];
                            _latestId = noticeId;
                        }
                    }
                }
                
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLong:_latestId] forKey:@"notice_latest_id"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self addNoticeCells:notices];
            }
        }];
        
    }
}

@end
