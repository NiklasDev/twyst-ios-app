//
//  ContactManageService.h
//  Twyst
//
//  Created by Default on 8/22/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//


#import "Contact.h" 
#import <Foundation/Foundation.h>

@interface ContactManageService : NSObject

@property (nonatomic, assign) BOOL isContactLoaded;
@property (nonatomic, strong) NSMutableDictionary *contacts;

+ (id) sharedInstance;
- (void)startNewContactSession;
- (void)startNewContactSession:(void(^)(BOOL accessGranted, BOOL accessRequested))completion;
- (NSString*)realNameFromPhoneNumber:(NSString*)phoneNumber;
- (NSString*)generatePhoneNumberString;
- (BOOL)isInvitedAlready:(NSString*)phoneNumber;
- (void)inviteContacts:(NSArray*)phoneNumbers;

- (void)showAccessDeniedAlert;

@end
