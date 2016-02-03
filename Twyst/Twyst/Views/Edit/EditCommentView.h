//
//  EditCommentView.h
//  Twyst
//
//  Created by Niklas Ahola on 12/29/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditCommentView : UIView

@property (nonatomic, assign) CGFloat topBarHeight;
@property (nonatomic, assign) CGFloat bottomBarHeight;

- (BOOL)containsPoint:(CGPoint)pt;
- (void)moveComment:(CGPoint)pt;
- (void)setFirstResponder;
- (void)resignFirstResponder;

- (NSString*)getComment;
- (void)setComment:(NSString*)comment frame:(CGRect)frame;

@end
