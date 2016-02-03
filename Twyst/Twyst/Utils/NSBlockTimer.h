//
//  NSTimer+ScheduledBlock.h
//  Twyst
//
//  Created by Nahuel Morales on 9/14/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBlockTimer : NSObject

+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)ti scheduledBlock:(void(^)(NSTimer *))scheduledBlock userInfo:(id)userInfo repeats:(BOOL)yesOrNo;

- (void)invalidate;

@end
