//
//  ContactManageService.m
//  Twyst
//
//  Created by Default on 8/22/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <AddressBook/AddressBook.h>

#import "ContactManageService.h"

@interface ContactManageService() {
    NSMutableArray *_invitedArray;
}

@property (nonatomic, assign) ABAddressBookRef addressBookRef;

@end

@implementation ContactManageService

static id _sharedObject = nil;
+ (id) sharedInstance   {
    @synchronized(self) {
        if (!_sharedObject) {
            _sharedObject = [[self alloc] init];
        }
        return _sharedObject;
    }
}

- (id)init {
    self = [super init];
    if (self) {
        _addressBookRef = ABAddressBookCreateWithOptions(NULL, nil);
        _invitedArray = [[NSMutableArray alloc] init];
        NSString *key = [self getRequestKey];
        NSArray *tmp = [[[NSUserDefaults standardUserDefaults] objectForKey:key] mutableCopy];
        [_invitedArray addObjectsFromArray:tmp];
    }
    return self;
}

- (void)startNewContactSession {
    [self startNewContactSession:^(BOOL accessGranted, BOOL userBannedAccess) {}];
}

- (void)startNewContactSession:(void(^)(BOOL accessGranted, BOOL userBannedAccess))completion {
    _isContactLoaded = NO;
    
    [_contacts removeAllObjects];
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(self.addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                [self accessToContactsGranted:^(BOOL accessGranted) {
                    completion(accessGranted, NO);
                }];
            } else {
                if (completion) completion(NO, NO);
                // TODO: Show alert
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        [self accessToContactsGranted:nil];
        if (completion) completion(YES, NO);
    }
    else {
        if (completion) completion(NO, YES);
    }
}

- (void)accessToContactsGranted:(void(^)(BOOL accessGranted))completion {
    if ([Global deviceType] == DeviceTypePhone4) {
        [NSThread detachNewThreadSelector:@selector(getContactsFromAddressBook_iPhone4:) toTarget:self withObject:completion];
    }
    else {
        [self getContactsFromAddressBook:completion];
    }
}

- (void)getContactsFromAddressBook:(void(^)(BOOL accessGranted))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        CFErrorRef error = NULL;
        self.contacts = [[NSMutableDictionary alloc] init];
        
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
        if (addressBook) {
            NSArray *allContacts = (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
            NSUInteger i = 0;
            for (i = 0; i<[allContacts count]; i++)
            {
                Contact *contact = [[Contact alloc] init];
                ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
                
                // Get first and last names
                NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
                NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
                NSString *fullName = nil;
                if(firstName != nil && lastName != nil) {
                    fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
                } else if (firstName != nil) {
                    fullName = firstName;
                } else if (lastName != nil) {
                    fullName = lastName;
                } else {
                    fullName = @"";
                }
                // Set Contact properties
                [contact setValue:fullName forKey:@"fullName"];
                
                // Get mobile number
                ABMultiValueRef phonesRef = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
                NSString *phoneNumber = [self getMobilePhoneProperty:phonesRef];
                phoneNumber = [FlipframeUtils getNumbersFromString:phoneNumber];
                if (IsNSStringValid(phoneNumber)) {
                    [contact setValue:phoneNumber forKey:@"phone"];
                    [self.contacts setObject:contact forKey:phoneNumber];
                }
                if(phonesRef) {
                    CFRelease(phonesRef);
                }
            }
            
            if(addressBook) {
                CFRelease(addressBook);
            }
        }
        else
        {
            NSLog(@"Error");
        }
        
        _isContactLoaded = YES;
        
        //post notification
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kContactDidLoadNotification object:nil];
            if (completion) completion(YES);
        });
    });
}

- (void)getContactsFromAddressBook_iPhone4:(void(^)(BOOL accessGranted))completion {
    CFErrorRef error = NULL;
    self.contacts = [[NSMutableDictionary alloc] init];
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (addressBook) {
        NSArray *allContacts = (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
        NSUInteger i = 0;
        for (i = 0; i<[allContacts count]; i++)
        {
            Contact *contact = [[Contact alloc] init];
            ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
            
            // Get first and last names
            NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
            NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
            NSString *fullName = nil;
            if(firstName != nil && lastName != nil) {
                fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            } else if (firstName != nil) {
                fullName = firstName;
            } else if (lastName != nil) {
                fullName = lastName;
            } else {
                fullName = @"";
            }
            // Set Contact properties
            [contact setValue:fullName forKey:@"fullName"];
            
            // Get mobile number
            ABMultiValueRef phonesRef = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
            NSString *phoneNumber = [self getMobilePhoneProperty:phonesRef];
            phoneNumber = [FlipframeUtils getNumbersFromString:phoneNumber];
            if (IsNSStringValid(phoneNumber)) {
                [contact setValue:phoneNumber forKey:@"phone"];
                [self.contacts setObject:contact forKey:phoneNumber];
            }
            if(phonesRef) {
                CFRelease(phonesRef);
            }
        }
        
        if(addressBook) {
            CFRelease(addressBook);
        }
    }
    else
    {
        NSLog(@"Error");
    }
    
    _isContactLoaded = YES;
    
    //post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kContactDidLoadNotification object:nil];
    if (completion) completion(YES);
}

- (NSString *)getMobilePhoneProperty:(ABMultiValueRef)phonesRef
{
    for (int i=0; i < ABMultiValueGetCount(phonesRef); i++) {
        CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phonesRef, i);
        CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phonesRef, i);
        
        if(currentPhoneLabel) {
            if (CFStringCompare(currentPhoneLabel, kABPersonPhoneMainLabel, 0) == kCFCompareEqualTo) {
                return (__bridge NSString *)currentPhoneValue;
            }
            else if (CFStringCompare(currentPhoneLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo) {
                return (__bridge NSString *)currentPhoneValue;
            }
            else if (CFStringCompare(currentPhoneLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
                return (__bridge NSString *)currentPhoneValue;
            }
        }
        if(currentPhoneLabel) {
            CFRelease(currentPhoneLabel);
        }
        if(currentPhoneValue) {
            CFRelease(currentPhoneValue);
        }
    }
    
    return nil;
}

- (NSString*) getRequestKey {
    OCUser *user = [Global getOCUser];
    return [NSString stringWithFormat:@"Invited_Contact_Key_%ld", user.Id];
}

#pragma mark - public methods
- (NSString*)realNameFromPhoneNumber:(NSString*)phoneNumber {
    if (!_isContactLoaded) {
        return nil;
    }
    
    Contact *contact = [self.contacts objectForKey:phoneNumber];
    if (contact) {
        return [contact fullName];
    }
    return nil;
}

- (NSString*)generatePhoneNumberString {
    if (!_isContactLoaded) {
        return nil;
    }
    
    NSArray *keys = [self.contacts allKeys];
    if (keys.count) {
        NSMutableString * retval = [[NSMutableString alloc] initWithString:@"\""];
        for (NSString *key in keys) {
            [retval appendFormat:@"%@,", key];
        }
        [retval insertString:@"\"" atIndex:retval.length - 1];
        return [retval substringToIndex:retval.length - 1];
    }
    else
        return @"";
}

- (BOOL)isInvitedAlready:(NSString*)phoneNumber {
    return [_invitedArray containsObject:phoneNumber];
}

- (void)inviteContacts:(NSArray*)phoneNumbers {
    NSString *key = [self getRequestKey];
    for (NSString *phoneNumber in phoneNumbers) {
        if (![_invitedArray containsObject:phoneNumber]) {
            [_invitedArray addObject:phoneNumber];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:_invitedArray forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Alert

- (void)showAccessDeniedAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Access to contacts denied"
                                                    message:@"Please change your application settings in your system preferences, the Twyst's access to your contacts has been denied."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

@end
