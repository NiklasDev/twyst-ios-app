//
//  FriendSearchBar.m
//  Twyst
//
//  Created by Niklas Ahola on 8/15/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "CustomSearchBar.h"
#import "UIImage+Device.h"

@interface CustomSearchBar() <UITextFieldDelegate> {
    
}

@property (weak, nonatomic) IBOutlet UIButton *btnSearchClear;
@property (weak, nonatomic) IBOutlet UIButton *btnCover;

@end

@implementation CustomSearchBar

- (id)initWithTarget:(id)target {
    NSArray * subViews = [[NSBundle mainBundle] loadNibNamed:@"CustomSearchBar" owner:nil options:nil];
    self = [subViews firstObject];
    self.delegate = target;
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    NSAttributedString *placeholder = [[NSAttributedString alloc] initWithString:@"Search people" attributes:@{NSForegroundColorAttributeName:Color(177, 177, 177)}];
    self.txtSearch.attributedPlaceholder = placeholder;
    [self addSearchBarObserver];
}

- (void) addSearchBarObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChanged:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
}

- (void) removeSearchBarObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidChangeNotification
                                                  object:nil];
}

#pragma mark - handle button methods
- (IBAction)handleBtnCoverTouch:(id)sender {
    [self.txtSearch becomeFirstResponder];
    self.btnCover.hidden = YES;
}

- (IBAction)handleBtnSearchCancelTouch:(id)sender {
    self.txtSearch.text = @"";
    self.btnCover.hidden = NO;
    [self.txtSearch resignFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(searchBarDidCancel)]) {
        [self.delegate searchBarDidCancel];
    }
}

- (IBAction)handleBtnSearchClearTouch:(id)sender {
    self.txtSearch.text = @"";
    if (![self.txtSearch isFirstResponder]) {
        [self.txtSearch becomeFirstResponder];
    }
    
    [self reloadBtnClearStatus];
    
    if ([self.delegate respondsToSelector:@selector(searchBarDidClear)]) {
        [self.delegate searchBarDidClear];
    }
}

#pragma mark - text field delegate
- (IBAction)onDidEndOnExit:(id)sender {
    if ([self.delegate respondsToSelector:@selector(searchBarDidEndOnExit:)]) {
        [self.delegate searchBarDidEndOnExit:_txtSearch.text];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self reloadBtnClearStatus];
    
    if ([self.delegate respondsToSelector:@selector(searchBarDidStart)]) {
        [self.delegate searchBarDidStart];
    }
    
    return YES;
}

- (void)textFieldDidChanged:(NSNotification *)notification {
    [self reloadBtnClearStatus];
    
    if ([self.delegate respondsToSelector:@selector(searchBarDidChanged:)]) {
        [self.delegate searchBarDidChanged:_txtSearch.text];
    }
}

- (void)reloadBtnClearStatus {
    if (IsNSStringValid(self.txtSearch.text)) {
        self.btnSearchClear.hidden = NO;
    }
    else {
        self.btnSearchClear.hidden = YES;
    }
}

- (void) focusFriendSearchBar {
    self.btnCover.hidden = YES;
    self.txtSearch.text = @"";
    [self.txtSearch becomeFirstResponder];
}

- (BOOL) isSearchBarFirstResponder {
    return self.txtSearch.isFirstResponder;
}

- (void)resignFriendSearchBar {
    [self.txtSearch resignFirstResponder];
}

- (void)dealloc {
    [self removeSearchBarObserver];
}

@end
