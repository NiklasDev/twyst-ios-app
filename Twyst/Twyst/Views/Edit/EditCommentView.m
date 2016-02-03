//
//  EditCommentView.m
//  Twyst
//
//  Created by Niklas Ahola on 12/29/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "NSString+Extension.h"

#import "EditCommentView.h"

@interface EditCommentView() <UITextFieldDelegate> {
    CGRect _frameStart;
    UILabel *_labelComment;
    UITextField *_txtComment;
}

@end

@implementation EditCommentView
- (id)initWithFrame:(CGRect)frame {
    CGFloat height = [FlipframeUtils editCommentHeight];
    _frameStart = CGRectMake(0, (frame.size.height - height) / 2, frame.size.width, height);
    self = [super initWithFrame:_frameStart];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    self.backgroundColor = ColorRGBA(0, 0, 0, 0.8);
    self.userInteractionEnabled = NO;
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:[FlipframeUtils editCommentFontSize]];
    CGRect frame = CGRectMake(10, 0, self.bounds.size.width - 20, self.bounds.size.height);
    _labelComment = [[UILabel alloc] initWithFrame:frame];
    _labelComment.backgroundColor = [UIColor clearColor];
    _labelComment.textColor = [UIColor whiteColor];
    _labelComment.textAlignment = NSTextAlignmentCenter;
    _labelComment.font = font;
    [self addSubview:_labelComment];
    
    _txtComment = [[UITextField alloc] initWithFrame:frame];
    _txtComment.backgroundColor = [UIColor clearColor];
    _txtComment.borderStyle = UITextBorderStyleNone;
    _txtComment.textColor = [UIColor whiteColor];
    _txtComment.font = font;
    _txtComment.returnKeyType = UIReturnKeyDone;
    _txtComment.delegate = self;
    _txtComment.keyboardAppearance = UIKeyboardAppearanceLight;
    [_txtComment addTarget:self action:@selector(onDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self addSubview:_txtComment];
}

#pragma mark - public methods
- (BOOL)containsPoint:(CGPoint)pt {
    if (self.hidden == NO) {
        CGRect frame = self.frame;
        return CGRectContainsPoint(frame, pt);
    }
    return NO;
}

- (void)moveComment:(CGPoint)pt {
    CGRect frame = self.frame;
    frame.origin.y = MIN(MAX(_topBarHeight, pt.y - frame.size.height / 2), SCREEN_HEIGHT - _bottomBarHeight - frame.size.height);
    self.frame = frame;
}

- (void)setFirstResponder {
    self.hidden = NO;
    [_txtComment becomeFirstResponder];
}

- (void)resignFirstResponder {
    [_txtComment resignFirstResponder];
}

- (void)setComment:(NSString*)comment frame:(CGRect)frame {
    [_txtComment resignFirstResponder];
    
    if (IsNSStringValid(comment)) {
        _labelComment.text = comment;
        self.frame = frame;
        self.hidden = NO;
    }
    else {
        _labelComment.text = @"";
        _txtComment.text = @"";
        self.frame = _frameStart;
        self.hidden = YES;
    }
}

- (NSString*)getComment {
    return _labelComment.text;
}

#pragma mark - text field delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (IsNSStringValid(_labelComment.text)) {
        _txtComment.text = _labelComment.text;
        _labelComment.text = @"";
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@""]) {
        return YES;
    }
    
    NSString *newString = [NSString stringWithFormat:@"%@%@", textField.text, string];
    CGSize size = [newString sizeWithAttributes:@{NSFontAttributeName:textField.font}];
    if (size.width > self.bounds.size.width - 20) {
        return NO;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (IsNSStringValid(_txtComment.text)) {
        _labelComment.text = _txtComment.text;
        _txtComment.text = @"";
    }
    else {
        self.hidden = YES;
    }
}

- (void)onDidEndOnExit:(UITextField*)sender {
}

@end
