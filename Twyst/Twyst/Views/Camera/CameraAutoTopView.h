//
//  CameraAutoTopView.h
//  Twyst
//
//  Created by Niklas Ahola on 4/6/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraAutoTopView : UIView

- (void) prepareNewSection;
- (void) resetAll;
- (void) updateCell:(int) index withCountDown:(int) countDown withMaxPhotos:(int) maxPhotos;
- (void) tutorialCountDown;
- (void) tutorialPicTaken;
- (void) tutorialChangeFace;

@end
