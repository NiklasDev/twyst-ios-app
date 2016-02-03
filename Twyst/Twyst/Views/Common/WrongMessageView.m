//
//  WrongMessageView.m
//  Twyst
//
//  Created by Niklas Ahola on 3/21/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "WrongMessageView.h"
#import "UIImage+Device.h"
#import "NSString+Extension.h"

@interface WrongMessageView()   {
    CGFloat _messageHeight;
    CGFloat _fontSize;
    
    CGRect _frameStart;
    CGRect _frameEnd;
    
    UIView *_viewContainer;
    UILabel *_labelMessage;
    UIImageView *_imageMessage;
    UIImageView *_imageCheck;
    
    BOOL _isShowed;
    
}
@end

@implementation WrongMessageView

- (id) init
{
    switch ([Global deviceType]) {
        case DeviceTypePhone6:
            _messageHeight = 42;
            _fontSize = 14;
            break;
        case DeviceTypePhone6Plus:
            _messageHeight = 46;
            _fontSize = 15.3;
            break;
        default:
            _messageHeight = 36;
            _fontSize = 12.24;
            break;
    }
    
    CGRect frame = [UIScreen mainScreen].bounds;
    _frameStart = CGRectMake(0, - UI_STATUS_BAR_HEIGHT - UI_TOP_BAR_HEIGHT, frame.size.width, _messageHeight);
    _frameEnd = CGRectMake(0, 0, frame.size.width, _messageHeight);
    
    self = [super initWithFrame:CGRectMake(0, UI_STATUS_BAR_HEIGHT + UI_TOP_BAR_HEIGHT, frame.size.width, _messageHeight)];
    if (self) {
        // Initialization code
        [self initView];
        _isShowed = NO;
    }
    return self;
}

- (void)initView {
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = YES;
    
    _viewContainer = [[UIView alloc] initWithFrame:_frameStart];
    [self addSubview:_viewContainer];
    
    CGRect frame = (CGRect){0, 0, SCREEN_WIDTH, _messageHeight};
    _labelMessage = [[UILabel alloc] initWithFrame:frame];
    _labelMessage.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:_fontSize];
    _labelMessage.textColor = [UIColor whiteColor];
    _labelMessage.textAlignment = NSTextAlignmentCenter;
    _labelMessage.backgroundColor = [UIColor clearColor];
    _labelMessage.numberOfLines = 1;
    [_viewContainer addSubview:_labelMessage];
    
    UIImage *check = [UIImage imageNamedForDevice:@"wrong-icon-check"];
    frame = (CGRect){0, 0, check.size.width, _messageHeight};
    _imageCheck = [[UIImageView alloc] initWithFrame:frame];
    _imageCheck.image = check;
    _imageCheck.contentMode = UIViewContentModeCenter;
    [_viewContainer addSubview:_imageCheck];
    
    _imageMessage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, _messageHeight)];
    _imageMessage.userInteractionEnabled = NO;
    [_viewContainer addSubview:_imageMessage];
}

- (NSString*) messageText:(WrongMessageType)type {
    NSString *message = nil;
    switch (type) {
        case WrongMessageTypeInvalidCrediential:
            message = @"Your username or password is incorrect.";
            break;
        case WrongMessageTypeInvalidEmailFormat:
            message = @"Please enter a valid email address.";
            break;
        case WrongMessageTypeInvalidFirstName:
        case WrongMessageTypeInvalidLastName:
            message = @"Please enter a valid first and last name";
            break;
        case WrongMessageTypeInvalidPasswordFormat:
            message = @"Your password should be 6 or more characters.";
            break;
        case WrongMessageTypeUsernameLength:
            message = @"Your username should be more than 4 characters.";
            break;
        case WrongMessageTypeUsernameOverLength:
            message = @"Your username should be less than 20 characters.";
            break;
        case WrongMessageTypeUsernameInvalidFormat:
            message = @"Please enter a valid username.";
            break;
        case WrongMessageTypeInvalidPhoneNumber:
            message = @"Invalid phone number.";
            break;
        case WrongMessageTypeVerificationCodeSent:
            message = @"Verification code sent.";
            break;
        case WrongMessageTypeInvalidVerificationCode:
            message = @"Invalid verification code.";
            break;
        case WrongMessageTypeErrorExistingEmail:
            message = @"This email already exists.";
            break;
        case WrongMessageTypeErrorExistingUsername:
            message = @"This username already exists.";
            break;
        case WrongMessageTypeInvalidInviteCode:
            message = @"This code doesn't exist or it has already been redeemed.";
            break;
            
        case WrongMessageTypeIncorrectOldPassword:
            message = @"Your old password does not match.";
            break;
        case WrongMessageTypeDoesNotMatchPassword:
            message = @"Your password does not match.";
            break;
        case WrongMessageTypeItsTheSameAsTheOldPassword:
            message = @"Please create a new password different from the temporary one we sent you.";
            break;
        case WrongMessageTypeUploadProfileImageFailed:
            message = @"Your picture was not uploaded successfully.";
            break;
        case WrongMessageTypeUploadCoverImageFailed:
            message = @"Your picture was not uploaded successfully.";
            break;
        case WrongMessageTypeErrorEmailNotOnFile:
            message = @"Invalid email address. Please try again.";
            break;
        case WrongMessageTypeNewPasswordRequestSent:
            message = @"Request Sent";
            break;
            
        case WrongMessageTypeProfileChangesSaved:
            message = @"Changes Saved";
            break;
            
        case WrongMessageTypeDeleteFrames:
            message = @"Deleted!";
            break;
        case WrongMessageTypeSuccessSaveLibrary:
            message = @"Saved!";
            break;
        case WrongMessageTypeTwystSaveLibrary:
            message = @"Saved!";
            break;
        case WrongMessageTypeNeedOnePhoto:
            message = @"You need at least one photo.";
            break;
        case WrongMessageTypeTwystDeleted:
            message = @"This content has been removed";
            break;
            
        case WrongMessageTypeInvalidComment:
            message = @"Please enter a comment.";
            break;
        case WrongMessageTypeReportConfirmation:
            message = @"Reported Successfully!";
            break;
            
        case WrongMessageTypeSuccessLeaveTwyst:
            message = @"You have been removed from this twyst.";
            break;
        case WrongMessageTypeTwystOverMaxFrames:
            message = @"Max: 15 photos";
            break;
            
        case WrongMessageTypeCreateSuccessfully:
            message = @"Created Successfully";
            break;
        case WrongMessageTypeReplySuccessfully:
            message = @"Reply added";
            break;
        case WrongMessageTypePassSuccessfully:
            message = @"Passed Successfully";
            break;
            
        case WrongMessageTypeRepliesOff:
            message = @"Replies Off";
            break;
        case WrongMessageTypeRepliesOn:
            message = @"Replies On";
            break;
        case WrongMessageTypePassOff:
            message = @"Pass Off";
            break;
        case WrongMessageTypePassOn:
            message = @"Pass On";
            break;
            
        case WrongMessageTypeSomethingWentWrong:
            message = @"Something went wrong.";
            break;
            
        case WrongMessageTypeNoInternetConnection:
            message = @"";
            break;
        default:
            break;
    }
    return message;
}

- (BOOL)hasCheckmark:(WrongMessageType)type {
    if (type == WrongMessageTypeProfileChangesSaved ||
        type == WrongMessageTypeNewPasswordRequestSent ||
        type == WrongMessageTypeReplySuccessfully ||
        type == WrongMessageTypeCreateSuccessfully ||
        type == WrongMessageTypePassSuccessfully) {
        return YES;
    }
    else {
        return NO;
    }
}

- (UIColor*) messageColor:(WrongMessageType)type {
    UIColor *messageColor = ColorRGBA(0, 185, 172, 0.95);
//    switch (type) {
//        case WrongMessageTypeDeleteFrames:
//        case WrongMessageTypeReportConfirmation:
//        case WrongMessageTypeSuccessSaveLibrary:
//        case WrongMessageTypeTwystSaveLibrary:
//        case WrongMessageTypeSuccessLeaveTwyst:
//            backgroundColor = Color(40, 35, 55);
//            break;
//            
//        default:
//            break;
//    }
    return messageColor;
}

- (void) showMessage:(WrongMessageType)type inView:(UIView*) view arrayOffsetY:(NSArray*)arrayOffsetY    {
    if (self.superview) {
        [self removeFromSuperview];
    }
    
    CGRect frame = self.frame;
    frame.origin.y = [self getOffsetY:arrayOffsetY];
    self.frame = frame;
    [view addSubview:self];
    
    NSString *message = [self messageText:type];
    UIColor *backgroundColor = [self messageColor:type];
    _viewContainer.backgroundColor = backgroundColor;
    _labelMessage.text = message;
    
    // draw check mark
    if ([self hasCheckmark:type]) {
        _imageCheck.hidden = NO;
        CGSize size = [message stringSizeWithFont:_labelMessage.font constrainedToWidth:CGFLOAT_MAX];
        _imageCheck.center = (CGPoint){(SCREEN_WIDTH - size.width - _imageCheck.frame.size.width - 10) / 2, _imageCheck.center.y};
    }
    else {
        _imageCheck.hidden = YES;
    }
    
    if (type == WrongMessageTypeNoInternetConnection) {
        _imageMessage.image = [UIImage imageNamedForDevice:@"wrong-error-no-network"];
    }
    else {
        _imageMessage.image = nil;
    }
    
    if (_isShowed) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(hide)
                                                   object:nil];
    }
    
    _viewContainer.frame = _frameStart;
    _viewContainer.alpha = 1;
    _isShowed = YES;
    [UIView animateWithDuration:0.5 animations:^{
        _viewContainer.frame = _frameEnd;
        [self performSelector:@selector(hide) withObject:nil afterDelay:2.0f];
    }];
}

- (CGFloat)getOffsetY:(NSArray*)arrayOffsetY {
    CGFloat offsetY = 0;
    if (arrayOffsetY) {
        switch ([Global deviceType]) {
            case DeviceTypePhone4:
            case DeviceTypePhone5:
                offsetY = [[arrayOffsetY objectAtIndex:0] floatValue];
                break;
            case DeviceTypePhone6:
                offsetY = [[arrayOffsetY objectAtIndex:1] floatValue];
                break;
            case DeviceTypePhone6Plus:
                offsetY = [[arrayOffsetY objectAtIndex:2] floatValue];
                break;
            default:
                break;
        }
    }
    else {
        offsetY = UI_NEW_TOP_BAR_HEIGHT;
    }
    return offsetY;
}

- (void) showAlert:(WrongMessageType)type target:(id)target {
    NSString *message = [self messageText:type];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:message
                                                   delegate:target
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    alert.tag = type;
    [alert show];
}

- (void) hide   {
    if (_isShowed)  {
        [UIView animateWithDuration:0.5 animations:^{
            _viewContainer.frame = _frameEnd;
            _viewContainer.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            _isShowed = NO;
        }];
    }
}

- (BOOL) checkIfShowed  {
    return _isShowed;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event   {
    [super touchesBegan:touches withEvent:event];
    [self hide];
}

#pragma static function
static WrongMessageView* _instance;
+ (WrongMessageView*) getInstance   {
    @synchronized(self)  {
        if (_instance == nil)
        {
            _instance = [[WrongMessageView alloc] init];
        }
        return _instance;
    }
}

+ (void) showMessage:(WrongMessageType)type inView:(UIView*)view {
    [[self getInstance] showMessage:type inView:view arrayOffsetY:nil];
}

+ (void) showMessage:(WrongMessageType)type inView:(UIView*)view arrayOffsetY:(NSArray*)arrayOffsetY    {
    [[self getInstance] showMessage:type inView:view arrayOffsetY:arrayOffsetY];
}

+ (void) showAlert:(WrongMessageType)type target:(id)target {
    [[self getInstance] showAlert:type target:target];
}

+ (void) forceHide  {
    [[self getInstance] removeFromSuperview];
}

+ (void) hide   {
    [[self getInstance] hide];
}

+ (BOOL) checkIfShowed  {
    return [[self getInstance] checkIfShowed];
}

@end
