//
//  VerifyCodeView.h
//  Twyst
//
//  Created by Niklas Ahola on 7/29/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "LandingBaseView.h"

@interface VerifyCodeView : LandingBaseView

@property (nonatomic, retain) NSString * phoneNumber;

+ (VerifyCodeView*)verifyCodeViewWithParent:(LandingPageViewController*)parent phoneNumber:(NSString*)phoneNumber;

@end
