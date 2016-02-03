//
//  NSString+Extension.h
//  Twyst
//
//  Created by Niklas Ahola on 9/4/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)

- (CGSize)stringSizeWithFont:(UIFont*)font constrainedToWidth:(CGFloat)width;

- (CGSize)stringSizeWithFont:(UIFont*)font lineSpace:(CGFloat)lineSpace constrainedToWidth:(CGFloat)width;

- (NSString*)stringByTruncatingToWidth:(CGFloat)width withFont:(UIFont*)font;

+ (NSAttributedString*)formattedString:(NSArray*)subStrings fonts:(NSArray*)fonts colors:(NSArray*)colors;

+ (NSAttributedString*)formattedString:(NSArray*)subStrings fonts:(NSArray*)fonts colors:(NSArray*)colors lineSpace:(CGFloat)lineSpace;

+ (NSAttributedString*)formattedString:(NSArray*)subStrings fonts:(NSArray*)fonts colors:(NSArray*)colors lineSpace:(CGFloat)lineSpace alignment:(NSTextAlignment)alignment;

@end
