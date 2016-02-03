//
//  EditFilterViewCell.h
//  Twyst
//
//  Created by Niklas Ahola on 7/4/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditFilterViewCell : UICollectionViewCell

- (void) updateState:(BOOL) isSelected withBundleImage:(NSString*) bundleImage selectedBundleImage:(NSString*)selectedBundleImage;
- (void) cellSelected:(BOOL)selected;

@end
