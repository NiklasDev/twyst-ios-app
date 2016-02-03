//
//  EditThemeView.m
//  Twyst
//
//  Created by Niklas Ahola on 4/17/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "FlipframePhotoModel.h"

#import "EditThemeView.h"
#import "FFullTutorialView.h"
#import "UIPlaceHolderTextView.h"

@interface EditThemeView() <UITextViewDelegate> {
    UIView *_parent;
    FlipframePhotoModel *_flipframeModel;
    NSArray *_arrayThemes;
    NSArray *_arrayColors;
    NSMutableArray *_arrayFrames;
    CGFloat _fontSize;
    UIColor *_blueTextColor;
}

@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;
@property (weak, nonatomic) IBOutlet UIButton *btnOk;
@property (weak, nonatomic) IBOutlet UILabel *labelCharactorCount;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *txtTheme;
@property (weak, nonatomic) IBOutlet UIView *tutorialContainer;

@end

@implementation EditThemeView

- (id)initWithParent:(UIView*)parent {
    NSString *nibName = [FlipframeUtils nibNameForDevice:@"EditThemeView"];
    NSArray *subViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    self = [subViews firstObject];
    _parent = parent;
    [self initMembers];
    [self initView];
    return self;
}

- (void)initView {
    CGRect bounds = [UIScreen mainScreen].bounds;
    [self setFrame:bounds];
    
    _blueTextColor = [UIColor colorWithRed:58/256.0f green:50/256.0f blue:88/256.0f alpha:1];
    
    self.txtTheme.placeholder = @"Describe your Twyst";
    self.txtTheme.placeholderColor = _blueTextColor;
    self.txtTheme.text = _flipframeModel.twystTheme;
    
    self.btnDone.hidden = !IsNSStringValid(_flipframeModel.twystTheme);
    self.btnOk.hidden = YES;
    self.labelCharactorCount.alpha = 0;
    
    for (NSInteger i = 0; i < 8; i++) {
        NSValue *value = [_arrayFrames objectAtIndex:i];
        CGRect frame = [value CGRectValue];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = frame;
        [button setTitle:[_arrayThemes objectAtIndex:i] forState:UIControlStateNormal];
        button.backgroundColor = [_arrayColors objectAtIndex:i];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:_fontSize];
        button.tag = i;
        button.layer.cornerRadius = 3;
        button.layer.masksToBounds = YES;
        [button addTarget:self action:@selector(handleBtnThemeTouch:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
}

- (void)initMembers {
    _flipframeModel = [Global getCurrentFlipframePhotoModel];
    _arrayThemes = @[@"Food Fight",
                     @"Work Life",
                     @"Sunday Funday",
                     @"Throwback Thursday",
                     @"From Where I Stand",
                     @"Face Off",
                     @"Selfie Twyst",
                     @"My First Twyst"];
    
    _arrayColors = @[Color(39, 33, 58),
                     Color(251, 146, 52),
                     Color(0, 183, 170),
                     Color(255, 96, 92),
                     Color(39, 33, 58),
                     Color(251, 146, 52),
                     Color(0, 183, 170),
                     Color(255, 96, 92)];
    
    _arrayFrames = [NSMutableArray new];
    switch ([Global deviceType]) {
        case DeviceTypePhone4:
        {
            _fontSize = 14;
            CGRect frames[8] = {
                CGRectMake(10, 345.5, 93, 35),
                CGRectMake(108, 345.5, 80, 35),
                CGRectMake(193, 345.5, 117, 35),
                CGRectMake(10, 389, 156, 35),
                CGRectMake(171, 389, 139, 35),
                CGRectMake(10, 434.5, 72, 35),
                CGRectMake(87, 434.5, 103, 35),
                CGRectMake(195, 434.5, 116, 35),
            };
            for (NSInteger i = 0; i < 8; i++) {
                CGRect frame = frames[i];
                NSValue *value = [NSValue valueWithCGRect:frame];
                [_arrayFrames addObject:value];
            }
        }
            break;
        case DeviceTypePhone5:
        {
            _fontSize = 14;
            CGRect frames[8] = {
                CGRectMake(10, 429, 93, 35),
                CGRectMake(108, 429, 80, 35),
                CGRectMake(193, 429, 117, 35),
                CGRectMake(10, 473.5, 156, 35),
                CGRectMake(171, 473.5, 139, 35),
                CGRectMake(10, 519, 72, 35),
                CGRectMake(87, 519, 103, 35),
                CGRectMake(195, 519, 116, 35),
            };
            for (NSInteger i = 0; i < 8; i++) {
                CGRect frame = frames[i];
                NSValue *value = [NSValue valueWithCGRect:frame];
                [_arrayFrames addObject:value];
            }
        }
            break;
        case DeviceTypePhone6:
        {
            _fontSize = 15.4;
            CGRect frames[8] = {
                CGRectMake(12.5, 524, 106.5, 35),
                CGRectMake(131, 524, 95, 35),
                CGRectMake(237.5, 524, 125, 35),
                CGRectMake(12.5, 568.5, 167, 35),
                CGRectMake(191.5, 568.5, 167, 35),
                CGRectMake(12.5, 614, 85, 35),
                CGRectMake(109.5, 614, 110, 35),
                CGRectMake(231.5, 614, 131, 35),
            };
            for (NSInteger i = 0; i < 8; i++) {
                CGRect frame = frames[i];
                NSValue *value = [NSValue valueWithCGRect:frame];
                [_arrayFrames addObject:value];
            }
        }
            break;
        case DeviceTypePhone6Plus:
        {
            _fontSize = 16.8;
            CGRect frames[8] = {
                CGRectMake(13.7, 578.3, 118, 39),
                CGRectMake(144.7, 578.3, 105.3, 39),
                CGRectMake(262, 578.3, 138.3, 39),
                CGRectMake(13.7, 627.3, 184.7, 39),
                CGRectMake(211.3, 627.3, 184.7, 39),
                CGRectMake(13.7, 677.7, 94, 39),
                CGRectMake(121, 677.7, 121.7, 39),
                CGRectMake(255.3, 677.7, 145, 39),
            };
            for (NSInteger i = 0; i < 8; i++) {
                CGRect frame = frames[i];
                NSValue *value = [NSValue valueWithCGRect:frame];
                [_arrayFrames addObject:value];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)show {
    self.alpha = 0.0f;
    [_parent addSubview:self];
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.alpha = 1.0f;
                     }];
}

- (void)hide:(BOOL)isConfirm {
    if ([self.delegate respondsToSelector:@selector(editThemeViewWillDisapper:isConfirm:)]) {
        [self.delegate editThemeViewWillDisapper:self isConfirm:isConfirm];
    }
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.alpha = 0.0f;
                     } completion:^(BOOL finished) {
                         if ([self.delegate respondsToSelector:@selector(editThemeViewDidDisapper: isConfirm:)]) {
                             [self.delegate editThemeViewDidDisapper:self isConfirm:isConfirm];
                         }
                         [self removeFromSuperview];
                     }];
}

- (void)updateCharactorCounter {
    NSInteger restChaCount = DEF_CAPTION_MAX_CHARACTOR - self.txtTheme.text.length;
    self.labelCharactorCount.text = [NSString stringWithFormat:@"%ld", (long)restChaCount];
    if (restChaCount <= 10) {
        self.labelCharactorCount.textColor = [UIColor redColor];
    }
    else {
        self.labelCharactorCount.textColor = _blueTextColor;
    }
}

- (IBAction)handleBtnCloseTouch:(id)sender {
    [self hide:NO];
}

- (IBAction)handleBtnDoneTouch:(id)sender {
    _flipframeModel.twystTheme = self.txtTheme.text;
    [self hide:YES];
}

- (IBAction)handleBtnOkTouch:(id)sender {
    [self.txtTheme resignFirstResponder];
}

- (void)handleBtnThemeTouch:(UIButton*)sender {
    NSString *theme = [_arrayThemes objectAtIndex:sender.tag];
    self.txtTheme.text = theme;
    self.btnDone.hidden = NO;
}

- (IBAction)handleBtnBackgroundTouch:(id)sender {
    if (![self.txtTheme isFirstResponder]) {
        [self.txtTheme becomeFirstResponder];
    }
}

#pragma mark - text view delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    [self updateCharactorCounter];
    
    self.btnOk.hidden = NO;
    self.btnDone.hidden = YES;
    [self showCancel:NO];
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (self.txtTheme.text.length >= DEF_CAPTION_MAX_CHARACTOR) {
        NSString * subString = [self.txtTheme.text substringToIndex:DEF_CAPTION_MAX_CHARACTOR];
        self.txtTheme.text = subString;
    }
    [self updateCharactorCounter];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        return NO;
    }
    else {
        return YES;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.btnOk.hidden = YES;
    self.btnDone.hidden = !IsNSStringValid(self.txtTheme.text);
    [self showCancel:YES];
}

- (void)showCancel:(BOOL)show {
    [UIView animateWithDuration:0.3f
                     animations:^{
                         self.btnClose.alpha = show ? 1.0f : 0.0f;
                         self.labelCharactorCount.alpha = show ? 0.0f : 1.0f;
                     }];
}

@end
