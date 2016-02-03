//
//  ContactListViewController.h
//  Twyst
//
//  Created by Fang Chen on 8/13/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "BaseViewController.h"
#import "UIViewController+FadeHeader.h"

@interface ContactListViewController : BaseViewController <HeaderProtocol>

@property (nonatomic, assign) BOOL isPushed;
@property (nonatomic, assign) BOOL isFirst;
@property (weak, nonatomic) IBOutlet UIView *headerView;

+ (id)sharedInstance;

@end
