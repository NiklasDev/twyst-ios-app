//
//  NSTimer+ScheduledBlock.m
//  Twyst
//
//  Created by Nahuel Morales on 9/14/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "NSBlockTimer.h"

@interface NSBlockTimer ()

@property (nonatomic, strong) void(^scheduledBlock)(NSTimer *sender);
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation NSBlockTimer

+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)ti scheduledBlock:(void(^)(NSTimer *))scheduledBlock userInfo:(id)userInfo repeats:(BOOL)yesOrNo {
    NSBlockTimer *timer = [[NSBlockTimer alloc] init];
    [timer setScheduledBlock:scheduledBlock];
    timer.timer = [NSTimer scheduledTimerWithTimeInterval:ti target:timer selector:@selector(scheduledSelector:) userInfo:userInfo repeats:yesOrNo];
    return timer;
}

- (void)scheduledSelector:(NSTimer *)sender {
    self.scheduledBlock(sender);
}

- (void)invalidate {
    [self.timer invalidate];
    self.timer = nil;
}

@end
