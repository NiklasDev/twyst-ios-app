//
//  AddPeopleViewController.h
//  Twyst
//
//  Created by Niklas Ahola on 9/22/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "BaseViewController.h"

@protocol AddPeopleStringgDelegate <NSObject>

- (void)addPeopleStringgAdded;

@end

@interface AddPeopleViewController : BaseViewController

@property (nonatomic, assign) long stringgId;
@property (nonatomic, assign) id <AddPeopleStringgDelegate> delegate;

@end
